<?php

namespace App\Services;

use Config\Database;
use Exception;
use ReflectionException;
use App\Models\{
    WorkflowSubmissionModel,
    WorkflowStepModel,
    WorkflowLogModel
};
use CodeIgniter\Database\Exceptions\DatabaseException;

class WorkflowService
{
    protected WorkflowSubmissionModel $submissionModel;
    protected WorkflowStepModel $stepModel;
    protected WorkflowLogModel $logModel;

    public function __construct()
    {
        $this->submissionModel = new WorkflowSubmissionModel();
        $this->stepModel       = new WorkflowStepModel();
        $this->logModel        = new WorkflowLogModel();
    }

    /* ======================================================
     * HELPER
     * ====================================================== */
    protected function now(): string
    {
        return date('Y-m-d H:i:s');
    }

    /* ======================================================
     * BOARD DATA
     * ====================================================== */
    public function getBoardData(array $filter): array
    {
        $builder = $this->submissionModel
            ->select('
                workflow_submissions.id,
                workflow_submissions.title,
                workflow_submissions.status,
                workflow_submissions.current_level,
                workflow_steps.department_id,
                workflow_steps.position_code
            ')
            ->join(
                'workflow_steps',
                'workflow_steps.id = workflow_submissions.current_step_id'
            )
            ->where('workflow_submissions.status', 'pending');

        if (!empty($filter['department_id'])) {
            $builder->where('workflow_steps.department_id', $filter['department_id']);
        }

        if (!empty($filter['position_code'])) {
            $builder->where('workflow_steps.position_code', $filter['position_code']);
        }

        if (!empty($filter['level'])) {
            $builder->where('workflow_submissions.current_level', $filter['level']);
        }

        return $builder
            ->orderBy('workflow_submissions.created_at', 'DESC')
            ->findAll();
    }

    /* ======================================================
     * SUBMIT
     * ====================================================== */
    public function submit(array $data, int $userId): int
    {
        $workflowId = match ((int)$data['department_id']) {
            3 => 1, // Kinh doanh
            4 => 2, // Thương mại
            default => throw new Exception('Chưa cấu hình workflow cho phòng này'),
        };

        $firstStep = $this->stepModel
            ->where('workflow_id', $workflowId)
            ->orderBy('order_index', 'ASC')
            ->first();

        if (!$firstStep) {
            throw new Exception('Workflow chưa có step');
        }

        return $this->submissionModel->insert([
            'workflow_id'     => $workflowId,
            'title'           => $data['title'],
            'description'     => $data['note'] ?? null,
            'created_by'      => $userId,
            'department_id'   => $data['department_id'],
            'current_step_id' => $firstStep['id'],
            'current_level'   => $firstStep['level'],
            'status'          => 'pending',
        ]);
    }

    /* ======================================================
     * APPROVE
     * ====================================================== */
    /**
     * @throws ReflectionException
     */
    public function approve(int $id, int $userId, ?string $comment): bool
    {
        $db = Database::connect();
        $db->transStart();

        try {
            $submission = $this->submissionModel->find($id);
            if (!$submission) {
                throw new Exception('Không tồn tại hồ sơ');
            }

            $currentStep = $this->stepModel->find($submission['current_step_id']);

            // LOG
            $this->logModel->insert([
                'submission_id'    => $id,
                'workflow_step_id' => $currentStep['id'],
                'action'           => 'approved',
                'comment'          => $comment,
                'actor_id'         => $userId,
                'created_at'       => $this->now(),
            ]);

            $nextStep = $this->stepModel
                ->where('workflow_id', $submission['workflow_id'])
                ->where('order_index >', $currentStep['order_index'])
                ->orderBy('order_index', 'ASC')
                ->first();

            if ($nextStep) {
                $this->submissionModel->update($id, [
                    'current_step_id' => $nextStep['id'],
                    'current_level'   => $nextStep['level'],
                ]);
            } else {
                $this->submissionModel->update($id, [
                    'status' => 'approved',
                ]);
            }

            $db->transComplete();
            return true;

        } catch (Exception $e) {
            $db->transRollback();
            throw $e;
        }
    }

    /* ======================================================
     * REJECT
     * ====================================================== */
    /**
     * @throws ReflectionException
     */
    public function reject(int $id, int $userId, string $comment): bool
    {
        $db = Database::connect();
        $db->transStart();

        try {
            $submission = $this->submissionModel->find($id);
            if (!$submission) {
                throw new Exception('Không tồn tại hồ sơ');
            }

            $this->logModel->insert([
                'submission_id'    => $id,
                'workflow_step_id' => $submission['current_step_id'],
                'action'           => 'rejected',
                'comment'          => $comment,
                'actor_id'         => $userId,
                'created_at'       => $this->now(),
            ]);

            $this->submissionModel->update($id, [
                'status' => 'rejected',
            ]);

            $db->transComplete();
            return true;

        } catch (Exception $e) {
            $db->transRollback();
            throw $e;
        }
    }

    /* ======================================================
     * RETURN TO PREVIOUS STEP
     * ====================================================== */
    /**
     * @throws ReflectionException
     */
    public function returnToPreviousStep(int $id, int $userId, ?string $comment): bool
    {
        $db = Database::connect();
        $db->transStart();

        try {
            $submission = $this->submissionModel->find($id);
            if (!$submission) {
                throw new Exception('Không tồn tại hồ sơ');
            }

            $currentStep = $this->stepModel->find($submission['current_step_id']);

            $prevStep = $this->stepModel
                ->where('workflow_id', $submission['workflow_id'])
                ->where('order_index <', $currentStep['order_index'])
                ->orderBy('order_index', 'DESC')
                ->first();

            if (!$prevStep) {
                throw new Exception('Không có bước trước');
            }

            $this->logModel->insert([
                'submission_id'    => $id,
                'workflow_step_id' => $currentStep['id'],
                'action'           => 'returned',
                'comment'          => $comment,
                'actor_id'         => $userId,
                'created_at'       => $this->now(),
            ]);

            $this->submissionModel->update($id, [
                'current_step_id' => $prevStep['id'],
                'current_level'   => $prevStep['level'],
            ]);

            $db->transComplete();
            return true;

        } catch (Exception $e) {
            $db->transRollback();
            throw $e;
        }
    }

    /* ======================================================
     * BOARD DATA FOR USER
     * ====================================================== */
    public function getBoardDataForUser(array $user): array
    {
        $builder = $this->submissionModel
            ->select('
                workflow_submissions.id,
                workflow_submissions.title,
                workflow_submissions.status,
                workflow_submissions.current_level,
                workflow_submissions.created_by,
                workflow_submissions.created_at,
                workflow_steps.department_id,
                workflow_steps.position_code
            ')
            ->join(
                'workflow_steps',
                'workflow_steps.id = workflow_submissions.current_step_id'
            )
            ->where('workflow_submissions.status', 'pending');

        if (!empty($user['id'])) {
            $builder->orWhere('workflow_submissions.created_by', $user['id']);
        }

        return $builder
            ->orderBy('workflow_submissions.created_at', 'DESC')
            ->findAll();
    }
}
