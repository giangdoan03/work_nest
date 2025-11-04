<?php

namespace App\Controllers;

use App\Models\DocumentApprovalLogModel;
use App\Models\DocumentModel;
use App\Models\DocumentApprovalModel;
use App\Models\DocumentApprovalStepModel;
use App\Models\TaskFileModel;
use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use Throwable;

class DocumentApprovalController extends ResourceController
{
    protected $format = 'json';

    /** Approval (session) status */
    private const A_PENDING  = 'pending';
    private const A_APPROVED = 'approved';
    private const A_REJECTED = 'rejected';

    /** Step status */
    private const S_WAITING  = 'waiting';
    private const S_ACTIVE   = 'active';
    private const S_APPROVED = 'approved';
    private const S_REJECTED = 'rejected';

    /* ==================== Helpers ==================== */

    /** Kiểm tra có step nào đã hành động (approved/rejected) trong phiên chưa */
    private function hasAnyAction(DocumentApprovalStepModel $stepM, int $approvalId): bool
    {
        return (bool) $stepM
            ->where('approval_id', $approvalId)
            ->whereIn('status', [self::S_APPROVED, self::S_REJECTED])
            ->first();
    }

    /** Chỉ owner hoặc admin */
    private function assertOwnerOrAdmin(array $apv, int $userId): ?ResponseInterface
    {
        $isOwner = ((int)$apv['created_by'] === $userId);
        $isAdmin = (bool) session()->get('is_admin');
        if (!($isOwner || $isAdmin)) {
            return $this->failForbidden('Bạn không có quyền thao tác trên phiên duyệt này.');
        }
        return null;
    }

    /** Chuẩn hoá mảng approver: int, unique, bỏ rỗng */
    private function normalizeApprovers(array $ids): array
    {
        $ids = array_map('intval', $ids);
        $ids = array_filter($ids, fn($v) => $v > 0);
        return array_values(array_unique($ids));
    }

    /** Gắn tên + chữ ký người duyệt vào danh sách step */
    private function hydrateSteps(array $steps): array
    {
        if (empty($steps)) return $steps;

        $userIds = [];
        foreach ($steps as $s) {
            if (!empty($s['approver_id'])) {
                $userIds[] = (int) $s['approver_id'];
            }
            if (!empty($s['acted_by'])) {
                $userIds[] = (int) $s['acted_by'];
            }
        }
        $userIds = array_values(array_unique(array_filter($userIds)));

        if (empty($userIds)) return $steps;

        $um = new UserModel();
        // tuỳ cột bảng users của bạn: id, name, signature_url
        $users = $um->select('id, name, signature_url')->whereIn('id', $userIds)->findAll();
        $map = [];
        foreach ($users as $u) {
            $map[(int)$u['id']] = $u;
        }

        foreach ($steps as &$s) {
            $uid = (int) ($s['approver_id'] ?? 0);
            $u   = $map[$uid] ?? null;
            $s['_approver_name']           = $u['name']          ?? null;
            $s['_approver_signature_url']  = $u['signature_url'] ?? null;

            // (tuỳ chọn) meta người đã hành động
            $actedId = (int) ($s['acted_by'] ?? 0);
            if ($actedId && isset($map[$actedId])) {
                $s['_acted_by_name']          = $map[$actedId]['name']          ?? null;
                $s['_acted_by_signature_url'] = $map[$actedId]['signature_url'] ?? null;
            }
        }
        unset($s);

        return $steps;
    }

    /* ==================== End helpers ==================== */

    /** ============ GET /api/document-approvals ============ */
    public function index(): ResponseInterface
    {
        $docId = (int) ($this->request->getGet('document_id') ?? 0);

        $approvalM = new DocumentApprovalModel();
        $builder = $approvalM->orderBy('id', 'DESC');
        if ($docId > 0) $builder->where('document_id', $docId);

        $rows = $builder->findAll();

        if (!empty($rows)) {
            $ids   = array_column($rows, 'id');
            $stepM = new DocumentApprovalStepModel();
            $steps = $stepM->whereIn('approval_id', $ids)
                ->orderBy('sequence', 'ASC')
                ->findAll();

            // gom theo approval_id
            $map = [];
            foreach ($steps as $s) {
                $map[$s['approval_id']][] = $s;
            }
            // hydrate từng approval
            foreach ($rows as &$r) {
                $r['steps'] = $this->hydrateSteps($map[$r['id']] ?? []);
            }
            unset($r);
        }

        return $this->respond($rows);
    }

    /** ============ GET /api/document-approvals/{id} ============ */
    public function show($id = null): ResponseInterface
    {
        $approvalM = new DocumentApprovalModel();
        $stepM     = new DocumentApprovalStepModel();

        $apv = $approvalM->find((int)$id);
        if (!$apv) return $this->failNotFound('Không tìm thấy phiên duyệt');

        $rawSteps = $stepM->where('approval_id', $apv['id'])
            ->orderBy('sequence', 'ASC')
            ->findAll();

        $apv['steps'] = $this->hydrateSteps($rawSteps);

        return $this->respond($apv);
    }

    /** ============ POST /api/document-approvals/send ============ */
    public function send(): ResponseInterface
    {
        $userId = (int) (session()->get('user_id') ?? 0);
        if (!$userId) return $this->failUnauthorized('Chưa đăng nhập');

        $payload      = $this->request->getJSON(true) ?? [];
        $documentId   = (int) ($payload['document_id'] ?? 0);
        $approverIds  = array_values(array_unique(array_filter(array_map('intval', $payload['approver_ids'] ?? []))));
        $note         = trim((string)($payload['note'] ?? ''));

        if ($documentId <= 0)       return $this->failValidationErrors('Thiếu document_id');
        if (empty($approverIds))    return $this->failValidationErrors('Thiếu approver_ids');

        // (tuỳ bạn) kiểm tra tồn tại file:
        $tf = (new TaskFileModel())->find($documentId);
        if (!$tf) return $this->failNotFound('Tài liệu không tồn tại');

        $apvM  = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        // chặn trùng phiên pending
        $existing = $apvM->where('document_id', $documentId)->where('status','pending')->first();
        if ($existing) return $this->failValidationErrors('Tài liệu đang có phiên duyệt PENDING.');

        $db = $apvM->db; $db->transBegin();
        try {
            // 1) Tạo phiên
            $apvId = $apvM->insert([
                'document_id'        => $documentId,
                'status'             => 'pending',
                'created_by'         => $userId,
                'current_step_index' => 0,
                'note'               => $note,
                'source_type' => 'task_file' , // trong send()
            ], true);

            // 2) Tạo các bước
            $seq = 1; $batch = [];
            foreach ($approverIds as $uid) {
                $batch[] = [
                    'approval_id' => $apvId,
                    'approver_id' => $uid,
                    'sequence'    => $seq++,
                    'status'      => 'waiting',
                ];
            }
            $stepM->insertBatch($batch);

            // 3) Kích hoạt step đầu tiên
            $first = $stepM->where('approval_id', $apvId)->orderBy('sequence','ASC')->first();
            if ($first) {
                $stepM->update($first['id'], ['status' => 'active']);
                $apvM->update($apvId, ['current_step_index' => (int)$first['sequence']]);
            }

            $db->transCommit();

            // (khuyến nghị) đồng bộ trạng thái nguồn
            (new TaskFileModel())->update($documentId, [
                'status'       => 'pending',
                'approved_by'  => null,
                'approved_at'  => null,
                'review_note'  => ($note ?: null),
            ]);

            return $this->respondCreated([
                'id'           => (int)$apvId,
                'document_id'  => $documentId,
                'status'       => 'pending',
            ]);
        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError('Khởi tạo duyệt thất bại: '.$e->getMessage());
        }
    }


    /** ============ POST /api/document-approvals/{id}/approve ============ */
    public function approve($id = null): ResponseInterface
    {
        $userId = (int) session()->get('user_id');
        if (!$userId) return $this->failUnauthorized('Chưa đăng nhập');

        $apvM  = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        $apv = $apvM->find((int)$id);
        if (!$apv) return $this->failNotFound('Không tìm thấy phiên duyệt');
        if ($apv['status'] !== self::A_PENDING) {
            return $this->failValidationErrors('Phiên không còn ở trạng thái pending.');
        }

        $step = $stepM->where('approval_id', $apv['id'])
            ->where('status', self::S_ACTIVE)
            ->orderBy('sequence', 'ASC')
            ->first();
        if (!$step) return $this->failValidationErrors('Không có step ACTIVE.');
        if ((int)$step['approver_id'] !== $userId) {
            return $this->failForbidden('Bạn không phải người duyệt ở bước hiện tại.');
        }

        // ===== NHẬN THÊM DỮ LIỆU TỪ FE =====
        $payload       = $this->request->getJSON(true) ?? [];
        $comment       = (string)($payload['comment'] ?? '');
        $signatureUrl  = isset($payload['signature_url'])   ? (string)$payload['signature_url']   : null;
        $signedPdfUrl  = isset($payload['signed_pdf_url'])  ? (string)$payload['signed_pdf_url']  : null;
        $signerName    = (string) (session()->get('user_name') ?? session()->get('name') ?? ''); // tuỳ bạn set session

        $db = $apvM->db;
        $db->transBegin();
        try {
            // 1) Mark step APPROVED
            $stepM->update($step['id'], [
                'status'         => self::S_APPROVED,
                'acted_by'       => $userId,
                'acted_at'       => date('Y-m-d H:i:s'),
                'comment'        => $comment,
                'signature_url'  => $signatureUrl,          // ảnh chữ ký FE gửi lên
                'signed_at'      => date('Y-m-d H:i:s'),    // thời điểm ký
            ]);


            // 2) Next step hoặc kết thúc phiên
            $next = $stepM->where('approval_id', $apv['id'])
                ->where('sequence >', (int)$step['sequence'])
                ->orderBy('sequence', 'ASC')
                ->first();

            if ($next) {
                $stepM->update($next['id'], ['status' => self::S_ACTIVE]);
                $apvM->update($apv['id'], ['current_step_index' => (int)$next['sequence']]);
            } else {
                $apvM->update($apv['id'], [
                    'status'             => self::A_APPROVED,
                    'current_step_index' => (int)$step['sequence'],
                    'finished_at'        => date('Y-m-d H:i:s'),
                ]);

                // 🔗 Sync status to task_files: chuyển 'approved'
                $tf = new TaskFileModel();
                $tf->update((int)$apv['document_id'], [
                    'status'      => 'approved',
                    'approved_by' => $userId,                 // hoặc để null và ghi người cuối trong log
                    'approved_at' => date('Y-m-d H:i:s'),
                    // 'review_note' giữ nguyên
                ]);
            }

            // 3) Ghi log hành động (ai/bao giờ/chữ ký/link pdf đã ký)
            //    - Không ràng buộc bắt buộc phải có signature_url, signed_pdf_url: nếu FE không gửi thì để null
            $logM = new DocumentApprovalLogModel();
            $logM->insert([
                'approval_id'   => (int)$apv['id'],
                'document_id'   => (int)$apv['document_id'],
                'action'        => 'approved',
                'acted_by'      => $userId,
                'acted_at'      => date('Y-m-d H:i:s'),
                'signer_name'   => $signerName ?: null,
                'signature_url' => $signatureUrl,
                'signed_pdf_url'=> $signedPdfUrl,
                'comment'       => $comment,
            ]);

            if (!empty($signedPdfUrl)) {
                $apvM->update($apv['id'], ['signed_pdf_url' => $signedPdfUrl]);
            }

            $db->transCommit();

            // trả về chi tiết mới nhất
            $apv          = $apvM->find((int)$id);
            $rawSteps     = $stepM->where('approval_id', (int)$id)->orderBy('sequence', 'ASC')->findAll();
            // Nếu bạn có hydrateSteps:
            $apv['steps'] = method_exists($this, 'hydrateSteps') ? $this->hydrateSteps($rawSteps) : $rawSteps;

            return $this->respond($apv);
        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError('Approve lỗi: ' . $e->getMessage());
        }
    }


    /** ============ POST /api/document-approvals/{id}/reject ============ */
    public function reject($id = null): ResponseInterface
    {
        $userId = (int) session()->get('user_id');
        if (!$userId) return $this->failUnauthorized('Chưa đăng nhập');

        $apvM  = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        $apv = $apvM->find((int)$id);
        if (!$apv) return $this->failNotFound('Không tìm thấy phiên duyệt');
        if ($apv['status'] !== self::A_PENDING) {
            return $this->failValidationErrors('Phiên không còn ở trạng thái pending.');
        }

        $step = $stepM->where('approval_id', $apv['id'])
            ->where('status', self::S_ACTIVE)
            ->orderBy('sequence', 'ASC')
            ->first();
        if (!$step) return $this->failValidationErrors('Không có step ACTIVE.');
        if ((int)$step['approver_id'] !== $userId) {
            return $this->failForbidden('Bạn không phải người duyệt ở bước hiện tại.');
        }

        // ---- Lấy dữ liệu từ FE ----
        $payload      = $this->request->getJSON(true) ?? [];
        $comment      = (string)($payload['comment'] ?? '');
        $signatureUrl = isset($payload['signature_url']) ? (string)$payload['signature_url'] : null;

        $db = $apvM->db;
        $db->transBegin();
        try {
            // 1) Cập nhật step bị từ chối
            $stepM->update($step['id'], [
                'status'        => self::S_REJECTED,
                'acted_by'      => $userId,
                'acted_at'      => date('Y-m-d H:i:s'),
                'comment'       => $comment,
                'signature_url' => $signatureUrl,
                'signed_at'     => date('Y-m-d H:i:s'),
            ]);

            // 2) Đánh dấu phiên duyệt là bị từ chối
            $apvM->update($apv['id'], [
                'status'             => self::A_REJECTED,
                'current_step_index' => (int)$step['sequence'],
                'finished_at'        => date('Y-m-d H:i:s'),
            ]);

            $tf = new TaskFileModel();
            $tf->update((int)$apv['document_id'], [
                'status'      => 'rejected',
                'approved_by' => null,
                'approved_at' => null,
                'review_note' => $comment ?: null,
            ]);


            // 3) Ghi log hành động (tùy chọn)
            $logM = new DocumentApprovalLogModel();
            $logM->insert([
                'approval_id'   => (int)$apv['id'],
                'document_id'   => (int)$apv['document_id'],
                'action'        => 'rejected',
                'acted_by'      => $userId,
                'acted_at'      => date('Y-m-d H:i:s'),
                'signature_url' => $signatureUrl,
                'comment'       => $comment,
            ]);

            $db->transCommit();

            // 4) Trả lại dữ liệu mới nhất
            $apv          = $apvM->find((int)$id);
            $rawSteps     = $stepM->where('approval_id', (int)$id)->orderBy('sequence', 'ASC')->findAll();
            $apv['steps'] = $this->hydrateSteps($rawSteps);
            return $this->respond($apv);
        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError('Reject lỗi: ' . $e->getMessage());
        }
    }


    /** ============ POST /api/document-approvals/{id}/update-steps ============ */
    public function updateSteps($id = null): ResponseInterface
    {
        $userId = (int) session()->get('user_id');
        if (!$userId) return $this->failUnauthorized('Chưa đăng nhập');

        $apvM  = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        $apv = $apvM->find((int)$id);
        if (!$apv) return $this->failNotFound('Không tìm thấy phiên duyệt');
        if ($apv['status'] !== self::A_PENDING) {
            return $this->failValidationErrors('Chỉ cập nhật khi phiên còn PENDING.');
        }

        if ($res = $this->assertOwnerOrAdmin($apv, $userId)) {
            return $res;
        }

        if ($this->hasAnyAction($stepM, (int)$apv['id'])) {
            return $this->failValidationErrors('Không thể cập nhật tuyến duyệt vì đã có người hành động.');
        }

        $body        = $this->request->getJSON(true) ?? [];
        $approverIds = $this->normalizeApprovers($body['approver_ids'] ?? []);
        $note        = trim((string)($body['note'] ?? ''));

        if (empty($approverIds)) return $this->failValidationErrors('Thiếu approver_ids');

        $db = $apvM->db;
        $db->transBegin();
        try {
            $stepM->where('approval_id', $apv['id'])->delete();

            $seq   = 1;
            $batch = [];
            foreach ($approverIds as $uid) {
                $batch[] = [
                    'approval_id' => (int)$apv['id'],
                    'approver_id' => (int)$uid,
                    'sequence'    => $seq++,
                    'status'      => self::S_WAITING,
                    'acted_by'    => null,
                    'acted_at'    => null,
                    'comment'     => null,
                ];
            }
            $stepM->insertBatch($batch);

            $first = $stepM->where('approval_id', $apv['id'])
                ->orderBy('sequence', 'ASC')
                ->first();
            if ($first) {
                $stepM->update($first['id'], ['status' => self::S_ACTIVE]);
                $apvM->update($apv['id'], [
                    'current_step_index' => (int)$first['sequence'],
                    'note'               => ($note !== '' ? $note : $apv['note']),
                ]);
            }

            $db->transCommit();

            $apv          = $apvM->find((int)$id);
            $rawSteps     = $stepM->where('approval_id', (int)$id)->orderBy('sequence', 'ASC')->findAll();
            $apv['steps'] = $this->hydrateSteps($rawSteps);
            return $this->respond($apv);
        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError('Cập nhật tuyến duyệt lỗi: ' . $e->getMessage());
        }
    }

    /** ============ DELETE /api/document-approvals/{id} ============ */
    public function delete($id = null)
    {
        $userId = (int) session()->get('user_id');
        if (!$userId) return $this->failUnauthorized('Chưa đăng nhập');

        $apvM  = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        $apv = $apvM->find((int)$id);
        if (!$apv) return $this->failNotFound('Không tìm thấy phiên duyệt');

        if ($res = $this->assertOwnerOrAdmin($apv, $userId)) {
            return $res;
        }

        if ($this->hasAnyAction($stepM, (int)$apv['id'])) {
            return $this->failValidationErrors('Phiên đã có người duyệt, không thể xoá.');
        }

        $db = $apvM->db;
        $db->transBegin();
        try {
            $stepM->where('approval_id', $apv['id'])->delete();
            $apvM->delete($apv['id']);
            $db->transCommit();

            return $this->respondDeleted(['status' => 'deleted']);
        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError('Xoá thất bại: ' . $e->getMessage());
        }
    }

    // ============ GET /api/document-approvals/active-by-document?document_id=123 ============
    public function activeByDocument(): ResponseInterface
    {
        $docId = (int) ($this->request->getGet('document_id') ?? 0);
        if ($docId <= 0) return $this->failValidationErrors('Thiếu document_id');

        $apvM = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        // lấy phiên pending mới nhất (nếu cần có thể nới thêm approved)
        $apv = $apvM->where('document_id', $docId)
            ->where('status', self::A_PENDING)
            ->orderBy('id', 'DESC')
            ->first();

        if (!$apv) {
            return $this->respond(['instance' => null]);
        }

        // kèm vài thông tin step cơ bản (tuỳ ý)
        $rawSteps = $stepM->where('approval_id', (int)$apv['id'])
            ->orderBy('sequence', 'ASC')
            ->findAll();

        $apv['steps'] = $this->hydrateSteps($rawSteps);

        return $this->respond(['instance' => [
            'id' => (int)$apv['id'],
            'status' => $apv['status'],
            'current_step_index' => (int)$apv['current_step_index'],
            'steps' => $apv['steps'],
        ]]);
    }

    public function inboxFiles(): ResponseInterface
    {
        $s = session();
        $userId = (int) ($s->get('user_id') ?? 0);
        if ($userId <= 0) {
            return $this->failUnauthorized('Chưa đăng nhập.');
        }

        $db = db_connect();

        $sql = "
        SELECT
            das.id          AS step_id,
            das.status      AS step_status,
            da.id           AS approval_id,
            da.document_id,
            da.source_type,
            da.status       AS approval_status,
            d.title,
            d.file_path,
            d.uploaded_by,
            u.name AS uploader_name,
            d.created_at
        FROM document_approval_steps das
        JOIN document_approvals da ON da.id = das.approval_id
        LEFT JOIN documents d      ON d.id  = da.document_id
        LEFT JOIN users u          ON u.id  = d.uploaded_by
        WHERE das.approver_id = ?
        
        ORDER BY das.id DESC
    ";

        $rows = $db->query($sql, [$userId])->getResultArray();

        return $this->respond([
            'data' => $rows,
            'count' => count($rows),
        ]);
    }


    public function resolvedByMe(): ResponseInterface
    {
        // --- Auth ---
        $uid = (int) (session()->get('user_id') ?? 0);
        if (!$uid && function_exists('auth')) $uid = (int) (auth()->id() ?? 0);
        $uid = $uid ?: (int) $this->request->getGet('user_id');
        if (!$uid) return $this->failUnauthorized('Chưa đăng nhập');

        // --- Paging ---
        $page   = max(1, (int)$this->request->getGet('page'));
        $ps     = min(100, max(1, (int)$this->request->getGet('pageSize')));
        $offset = ($page - 1) * $ps;

        $db = db_connect();

        // --- TOTAL: step của tôi đã hành động ---
        $total = $db->table('document_approval_steps das')
            ->join('document_approvals da', 'da.id = das.approval_id', 'inner')
            ->where('das.approver_id', $uid)
            ->where('das.acted_at IS NOT NULL', null, false)
            ->countAllResults();

        // --- PAGE DATA ---
        $rows = $db->table('document_approval_steps das')
            ->select("
            das.id  AS step_id,
            da.id   AS approval_id,
            da.document_id,
            da.source_type,

            CASE WHEN da.source_type='comment' THEN c.file_name  ELSE tf.file_name  END AS file_name,
            CASE WHEN da.source_type='comment' THEN c.file_path  ELSE tf.file_path  END AS file_path,
            COALESCE(
                CASE WHEN da.source_type='comment' THEN c.created_at ELSE tf.created_at END,
                da.created_at
            ) AS file_created_at,

            COALESCE(u_sender_c.name, u_comment_author.name, u_sender_tf.name) AS sender_name,

            da.status AS approval_status,
            da.current_step_index,
            das.sequence,
            das.status AS step_status,
            das.acted_at,
            das.comment AS step_comment,

            u_approver.name AS approver_name
        ", false)
            ->join('document_approvals da', 'da.id = das.approval_id', 'inner')
            ->join('task_files tf', 'tf.id = da.document_id AND da.source_type="task_file"', 'left')
            ->join('task_comments c', 'c.id = da.document_id AND da.source_type="comment"', 'left')

            ->join('users u_sender_tf', 'u_sender_tf.id = tf.uploaded_by', 'left')
            ->join('users u_sender_c',  'u_sender_c.id  = c.uploaded_by',  'left')
            ->join('users u_approver',  'u_approver.id  = das.approver_id','left')
            ->join('users u_comment_author', 'u_comment_author.id = c.user_id', 'left')

            ->where('das.approver_id', $uid)
            ->where('das.acted_at IS NOT NULL', null, false)
            ->orderBy('das.acted_at', 'DESC')
            ->limit($ps, $offset)
            ->get()->getResultArray();

        $base = base_url();
        $items = array_map(static function(array $r) use ($base) {
            $url = $r['file_path'] ?? null;
            $abs = $url ? (str_starts_with($url, 'http') ? $url : $base . ltrim($url, '/')) : null;

            // Với tab "đã xử lý" → ưu tiên trạng thái step (approved/rejected/…)
            $finalStatus = $r['step_status'] ?: $r['approval_status'];

            return [
                'approval_id' => (int)$r['approval_id'],
                'step_id'     => (int)$r['step_id'],
                'document_id' => (int)$r['document_id'],
                'source_type' => $r['source_type'],                 // 'task_file' | 'comment'
                'name'        => $r['file_name'] ?: '(Không tên)',
                'url'         => $abs,
                'created_at'  => $r['file_created_at'] ?: $r['acted_at'],
                'sender_name' => $r['sender_name'] ?: null,
                'status'      => $finalStatus,                      // approved | rejected | …
                'step_info'   => [
                    'sequence'      => (int)$r['sequence'],
                    'status'        => $r['step_status'],
                    'approver_name' => $r['approver_name'] ?? null,
                    'acted_at'      => $r['acted_at'],
                    'comment'       => $r['step_comment'],
                ],
            ];
        }, $rows);

        return $this->respond([
            'items'    => $items,
            'total'    => (int)$total,
            'page'     => $page,
            'pageSize' => $ps,
        ]);
    }

    public function act($id = null): ResponseInterface
    {
        // Gộp payload từ mọi kiểu gửi
        $json = (array)($this->request->getJSON(true) ?? []);
        $post = (array)$this->request->getPost();
        $get  = (array)$this->request->getGet();
        $payload = array_merge($get, $post, $json);

        // Lấy approval_id và action
        $approvalId = (int)($id ?? ($payload['approval_id'] ?? 0));
        $action = strtolower(trim((string)($payload['action'] ?? '')));
        $comment = (string)($payload['comment'] ?? '');

        if (!$approvalId || !in_array($action, ['approve', 'reject'], true)) {
            return $this->failValidationErrors('Thiếu approval_id hoặc action không hợp lệ.');
        }

        // Gắn dữ liệu cho reuse
        $this->request->setGlobal('post', array_merge($post, ['comment' => $comment]));

        // Gọi lại các hàm xử lý chính
        if ($action === 'approve') {
            return $this->approve($approvalId);
        }
        return $this->reject($approvalId);
    }



}
