<?php

namespace App\Controllers;

use App\Models\TaskFileModel;
use App\Models\UserModel;
use CodeIgniter\HTTP\DownloadResponse;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Libraries\Uploader;

class TaskFileController extends ResourceController
{
    protected $modelName = TaskFileModel::class;
    protected $format    = 'json';

    /* Helper: tải file qua URL nội bộ */
    protected function buildDownloadUrl(int $id): string
    {
        return site_url("task-files/{$id}/download");
    }

    protected function currentUser(): ?array
    {
        $sess = session();
        // Nếu login() lưu theo key phẳng
        $id = $sess->get('user_id');
        if ($id) {
            return [
                'id'       => (int)$sess->get('user_id'),
                'email'    => $sess->get('user_email'),
                'role_id'  => $sess->get('role_id'),
                'role'     => $sess->get('role'),
                'is_admin' => $sess->get('is_admin'),
            ];
        }

        // DEV fallback: client gửi user_id/user_role
        $postId   = (int)$this->request->getPost('user_id');
        $postRole = trim((string)$this->request->getPost('user_role') ?? '');
        if ($postId > 0) {
            return [
                'id'   => $postId,
                'role' => $postRole ?: null,
            ];
        }

        return null;
    }



    /* Helper: user hiện tại (tuỳ hệ thống auth của bạn) */
    protected function currentUserRole(): ?string
    {
        $u = $this->currentUser();
        return $u ? (string)($u['role'] ?? ($u['user_role'] ?? '')) : null;
    }

    protected function currentUserId(): ?int
    {
        $u = $this->currentUser();
        return $u ? (int)($u['id'] ?? 0) : null;
    }

    /* Helper: kiểm tra quyền duyệt (tùy app của bạn chỉnh lại) */
    protected function canApprove(int $userId, array $row): bool
    {
        // ví dụ tối giản: chỉ cần có user_id > 0 là cho duyệt
        // Hãy thay bằng logic role: admin/approver/phòng ban...
        return $userId > 0;
    }

    // ✅ Upload file cho task (cha hoặc con) — luôn ở trạng thái uploaded và auto-pin
    public function upload($task_id = null): ResponseInterface
    {
        $file     = $this->request->getFile('file');
        $user_id  = (int)$this->request->getPost('user_id');
        $title    = $this->request->getPost('title');

        if (!$task_id || !$user_id) {
            return $this->failValidationErrors('Thiếu task_id hoặc user_id.');
        }
        if (!$file || !$file->isValid()) {
            return $this->failValidationErrors('File không hợp lệ.');
        }

        $upload = Uploader::saveFile($file, 'file'); // kỳ vọng trả về: file_name, file_path, (tuỳ) file_size, mime_type, ext...
        if (!$upload) {
            return $this->fail('Lỗi khi lưu file.');
        }

        $now = date('Y-m-d H:i:s');

        $data = [
            'task_id'     => $task_id,
            'title'       => $title ?: ($upload['file_name'] ?? ''),
            'file_name'   => $upload['file_name'] ?? ($file->getClientName() ?? ''),
            'file_path'   => $upload['file_path'] ?? '',
            'file_size'   => $upload['file_size'] ?? null,
            'mime_type'   => $upload['mime_type'] ?? ($file->getMimeType() ?? null),
            'file_ext'    => $upload['file_ext'] ?? ($file->getExtension() ?? null),
            'uploaded_by' => $user_id,
            'is_link'     => 0,
            'status'      => 'uploaded',
            // auto-pin on upload
            'is_pinned'   => 1,
            'pinned_at'   => $now,
            'pinned_by'   => $user_id,
        ];

        $id = $this->model->insert($data, true);

        $fresh = $this->model->find($id);
        $fresh['download_url'] = $this->buildDownloadUrl((int)$id);

        return $this->respondCreated([
            'message' => 'Upload thành công và đã ghim tài liệu',
            'data'    => $fresh
        ]);
    }

    // ✅ Lấy danh sách file theo task
    public function byTask($task_id): ResponseInterface
    {
        $files = $this->model->where('task_id', $task_id)
            ->orderBy('created_at', 'DESC')
            ->findAll();

        // thêm download_url nếu là file
        $files = array_map(function ($f) {
            if (empty($f['is_link'])) {
                $f['download_url'] = $this->buildDownloadUrl((int) $f['id']);
            } else {
                $f['download_url'] = null;
            }
            return $f;
        }, $files);

        return $this->respond($files);
    }

    // ✅ Xoá file — chặn nếu đã duyệt
    public function delete($id = null)
    {
        $row = $this->model->find($id);
        if (!$row) {
            return $this->failNotFound('File không tồn tại');
        }
        if (($row['status'] ?? 'pending') === 'approved') {
            return $this->failForbidden('Tài liệu đã duyệt, không thể xoá.');
        }

        // nếu là file vật lý thì xoá luôn file
        if (empty($row['is_link']) && !empty($row['file_path'])) {
            $full = WRITEPATH . 'uploads/' . ltrim($row['file_path'], '/');
            if (is_file($full)) @unlink($full);
        }

        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Đã xoá file']);
    }

    // ✅ Lưu link tài liệu — luôn pending và auto-pin
    public function uploadLink($task_id = null): ResponseInterface
    {
        $title   = $this->request->getPost('title');
        $url     = $this->request->getPost('url'); // nhận 'url'
        $user_id = (int)$this->request->getPost('user_id');

        if (!$task_id || !$user_id) {
            return $this->failValidationErrors('Thiếu task_id hoặc user_id.');
        }
        if (!$title || !$url) {
            return $this->failValidationErrors('Thiếu tiêu đề hoặc link.');
        }
        if (!filter_var($url, FILTER_VALIDATE_URL)) {
            return $this->failValidationErrors('URL không hợp lệ.');
        }

        $now = date('Y-m-d H:i:s');

        $id = $this->model->insert([
            'task_id'     => $task_id,
            'title'       => $title,
            'file_name'   => $title,
            'link_url'    => $url,
            'uploaded_by' => $user_id,
            'is_link'     => 1,
            'status'      => 'uploaded',
            // auto-pin link on save
            'is_pinned'   => 1,
            'pinned_at'   => $now,
            'pinned_by'   => $user_id,
        ], true);

        $fresh = $this->model->find($id);

        return $this->respondCreated([
            'message' => 'Đã lưu link tài liệu và đã ghim',
            'data'    => $fresh
        ]);
    }

    // ✅ Cập nhật meta (title, link_url nếu là link) — CHỈ khi chưa duyệt
    public function updateMeta($id = null): ResponseInterface
    {
        $row = $this->model->find($id);
        if (!$row) return $this->failNotFound('File không tồn tại');
        if (($row['status'] ?? 'pending') === 'approved') {
            return $this->failForbidden('Tài liệu đã duyệt, không thể chỉnh sửa.');
        }

        $title = trim((string)$this->request->getPost('title'));
        $link  = trim((string)$this->request->getPost('link_url'));
        $upd   = [];

        if ($title !== '') $upd['title'] = $title;

        if (!empty($row['is_link']) && $link !== '') {
            if (!filter_var($link, FILTER_VALIDATE_URL)) {
                return $this->failValidationErrors('URL không hợp lệ.');
            }
            $upd['link_url'] = $link;
            $upd['file_name'] = $title !== '' ? $title : ($row['file_name'] ?? $row['title'] ?? '');
        }

        if (!$upd) return $this->failValidationErrors('Không có dữ liệu cập nhật.');
        $this->model->update($id, $upd);

        return $this->respond(['message' => 'Đã cập nhật', 'data' => $this->model->find($id)]);
    }

    // ✅ Thay file vật lý — CHỈ khi chưa duyệt
    public function replaceFile($id = null): ResponseInterface
    {
        $row = $this->model->find($id);
        if (!$row) return $this->failNotFound('File không tồn tại');
        if (!empty($row['is_link'])) return $this->failValidationErrors('Đây là link, không thể thay file.');
        if (($row['status'] ?? 'pending') === 'approved') {
            return $this->failForbidden('Tài liệu đã duyệt, không thể thay file.');
        }

        $file = $this->request->getFile('file');
        if (!$file || !$file->isValid()) {
            return $this->failValidationErrors('File không hợp lệ.');
        }

        $upload = Uploader::saveFile($file, 'file');
        if (!$upload) {
            return $this->fail('Lỗi khi lưu file mới.');
        }

        // Xoá vật lý file cũ (nếu có)
        if (!empty($row['file_path'])) {
            $old = WRITEPATH . 'uploads/' . ltrim($row['file_path'], '/');
            if (is_file($old)) @unlink($old);
        }

        $this->model->update($id, [
            'file_name' => $upload['file_name'] ?? ($file->getClientName() ?? ''),
            'file_path' => $upload['file_path'] ?? '',
            'file_size' => $upload['file_size'] ?? null,
            'mime_type' => $upload['mime_type'] ?? ($file->getMimeType() ?? null),
            'file_ext'  => $upload['file_ext'] ?? ($file->getExtension() ?? null),
        ]);

        $fresh = $this->model->find($id);
        $fresh['download_url'] = $this->buildDownloadUrl((int)$id);

        return $this->respond(['message' => 'Đã thay file', 'data' => $fresh]);
    }

    // ✅ Tải/stream file theo id
    public function download($id = null): ResponseInterface|DownloadResponse|null
    {
        $row = $this->model->find($id);
        if (!$row) return $this->failNotFound('File không tồn tại');
        if (!empty($row['is_link'])) return $this->failValidationErrors('Đây là link, không có file để tải.');

        $full = WRITEPATH . 'uploads/' . ltrim($row['file_path'], '/');
        if (!is_file($full)) return $this->failNotFound('Tệp vật lý không còn tồn tại.');

        return $this->response
            ->download($full, null)
            ->setFileName($row['file_name'] ?: basename($full));
    }

    // ✅ DUYỆT (approve)
    public function approve($id = null): ResponseInterface
    {
        $row = $this->model->find($id);
        if (!$row) return $this->failNotFound('File không tồn tại');

        $uid = $this->currentUserId();
        if (!$this->canApprove($uid, $row)) return $this->failForbidden('Không có quyền duyệt.');

        if (($row['status'] ?? 'pending') === 'approved') {
            return $this->respond(['message' => 'Tài liệu đã ở trạng thái approved.', 'data' => $row]);
        }

        $note = trim((string)$this->request->getPost('note'));
        $this->model->update($id, [
            'status'      => 'approved',
            'approved_by' => $uid,
            'approved_at' => date('Y-m-d H:i:s'),
            'review_note' => $note ?: null,
        ]);

        return $this->respond(['message' => 'Đã duyệt tài liệu', 'data' => $this->model->find($id)]);
    }

    // ✅ TỪ CHỐI (reject) — quay về rejected để tác giả sửa/đổi
    public function reject($id = null): ResponseInterface
    {
        $row = $this->model->find($id);
        if (!$row) return $this->failNotFound('File không tồn tại');

        $uid = $this->currentUserId();
        if (!$this->canApprove($uid, $row)) return $this->failForbidden('Không có quyền từ chối.');

        $note = trim((string)$this->request->getPost('note'));
        $this->model->update($id, [
            'status'      => 'rejected',
            'approved_by' => null,
            'approved_at' => null,
            'review_note' => $note ?: null,
        ]);

        return $this->respond(['message' => 'Đã từ chối tài liệu', 'data' => $this->model->find($id)]);
    }


    protected function countPinnedInTask(int $taskId): int {
        return (int)$this->model
            ->where('task_id', $taskId)
            ->where('is_pinned', 1)
            ->countAllResults();
    }


    public function pinnedByTask($taskId): ResponseInterface
    {
        $rows = $this->model
            ->where('task_id', (int)$taskId)
            ->where('is_pinned', 1)
            ->orderBy('pinned_at', 'DESC')
            ->findAll();

        if (empty($rows)) {
            return $this->respond([]);
        }

        // ✅ Map ID -> tên user (chỉ query 1 lần)
        $userIds = array_unique(array_filter(array_column($rows, 'uploaded_by')));
        $userNames = [];
        if (!empty($userIds)) {
            $users = (new UserModel())
                ->select('id, name')
                ->whereIn('id', $userIds)
                ->findAll();
            foreach ($users as $u) {
                $userNames[(int)$u['id']] = $u['name'];
            }
        }

        // ✅ Gắn thêm tên vào mỗi record
        foreach ($rows as &$r) {
            $r['pinned_by_name'] = $userNames[(int)$r['uploaded_by']] ?? null;
        }

        return $this->respond($rows);
    }


    // ✅ Pin: bỏ giới hạn (server now allows unlimited pins)
    public function pin($fileId): ResponseInterface
    {
        $row = $this->model->find((int)$fileId);
        if (!$row) return $this->failNotFound('File không tồn tại');

        $userId = (int)($this->request->getPost('user_id') ?? 0);
        $now = date('Y-m-d H:i:s');

        $this->model->update((int)$fileId, [
            'is_pinned' => 1,
            'pinned_at' => $now,
            'pinned_by' => $userId,
        ]);

        return $this->respond(['message' => 'Đã ghim']);
    }


    public function unpin($fileId): ResponseInterface
    {
        $row = $this->model->find((int)$fileId);
        if (!$row) {
            return $this->failNotFound('File không tồn tại');
        }

        // Ưu tiên lấy từ session
        $uid  = $this->currentUserId();
        $role = $this->currentUserRole();

        dd($role);

        // Dù có uid hay không, nếu role rỗng -> dùng fallback từ POST
        $postUid  = (int)($this->request->getPost('user_id') ?? 0);
        $postRole = trim((string)($this->request->getPost('user_role') ?? ''));

        if (empty($uid) && $postUid > 0) {
            $uid = $postUid;
        }
        if (empty($role) && $postRole !== '') {
            $role = $postRole;
        }

        log_message('debug', "unpin: uid={$uid}, role={$role}, postRole={$postRole}");

        // Chuẩn hoá role (tránh lỗi chữ hoa/thường hoặc khoảng trắng)
        $roleNorm = strtolower(trim((string)$role));

        if ($roleNorm !== 'super admin') {
            return $this->failForbidden('Chỉ Super Admin mới được bỏ ghim file này.');
        }

        // Cập nhật record
        $this->model->update((int)$fileId, [
            'is_pinned' => 0,
            'pinned_at' => null,
            'pinned_by' => null,
        ]);

        return $this->respond(['message' => 'Đã bỏ ghim']);
    }






    // adopt từ file_path trên server — auto-pin; nếu đã tồn tại record thì trả về và ensure pinned
    public function adoptFromPath($task_id = null): ResponseInterface
    {
        $task_id = (int) $task_id;
        $file_path = trim((string)$this->request->getPost('file_path'));
        $file_name = trim((string)$this->request->getPost('file_name'));
        $user_id   = (int) $this->request->getPost('user_id');

        if (!$task_id || !$user_id || $file_path === '') {
            return $this->failValidationErrors('Thiếu task_id, user_id hoặc file_path.');
        }

        // Tránh trùng: nếu đã có record cùng task_id + file_path thì trả về luôn (và đảm bảo nó được ghim)
        $existed = $this->model
            ->where('task_id', $task_id)
            ->where('file_path', $file_path)
            ->first();
        $now = date('Y-m-d H:i:s');

        if ($existed) {
            // nếu chưa ghim thì ghim luôn
            if (empty($existed['is_pinned']) || intval($existed['is_pinned']) !== 1) {
                $this->model->update((int)$existed['id'], [
                    'is_pinned' => 1,
                    'pinned_at' => $now,
                    'pinned_by' => $user_id,
                ]);
                $existed = $this->model->find((int)$existed['id']);
            }
            return $this->respond(['message' => 'Đã tồn tại (và đã ghim nếu chưa ghim)', 'data' => $existed]);
        }

        $insert = [
            'task_id'     => $task_id,
            'title'       => $file_name ?: basename($file_path),
            'file_name'   => $file_name ?: basename($file_path),
            'file_path'   => $file_path,
            'uploaded_by' => $user_id,
            'is_link'     => 0,
            'status'      => null,
            // auto-pin new adopted file
            'is_pinned'   => 1,
            'pinned_at'   => $now,
            'pinned_by'   => $user_id,
        ];
        $id = $this->model->insert($insert, true);
        $row = $this->model->find($id);

        return $this->respondCreated(['message' => 'Đã nhận file vào tài liệu và đã ghim', 'data' => $row]);
    }

}
