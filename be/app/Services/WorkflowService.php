<?php

namespace App\Services;

use Exception;
use ReflectionException;
use App\Models\{
    WorkflowSubmissionModel,
    WorkflowStepModel,
    WorkflowLogModel
};

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

    /**
     * =======================
     * BOARD DATA
     * =======================
     */
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
            ->join('workflow_steps', 'workflow_steps.id = workflow_submissions.current_step_id')
            ->where('workflow_submissions.status', 'pending');

        if ($filter['department_id']) {
            $builder->where('workflow_steps.department_id', $filter['department_id']);
        }

        if ($filter['position_code']) {
            $builder->where('workflow_steps.position_code', $filter['position_code']);
        }

        if ($filter['level']) {
            $builder->where('workflow_submissions.current_level', $filter['level']);
        }

        return $builder->orderBy('workflow_submissions.created_at', 'DESC')->findAll();
    }

    /**
     * =======================
     * SUBMIT
     * =======================
     * @throws ReflectionException
     * @throws Exception
     */
    public function submit(array $data, int $userId): int
    {
        // 1️⃣ Map workflow_id theo phòng
        $workflowId = match ((int)$data['department_id']) {
            3 => 1, // KD
            4 => 2, // TM
            default => throw new Exception('Chưa cấu hình workflow cho phòng này'),
        };

        // 2️⃣ Lấy step đầu tiên
        $firstStep = $this->stepModel
            ->where('workflow_id', $workflowId)
            ->orderBy('order_index', 'ASC')
            ->first();

        if (!$firstStep) {
            throw new Exception('Workflow chưa có step');
        }

        // 3️⃣ Tạo submission
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


    /**
     * @throws ReflectionException
     * @throws Exception
     */
    public function approve(int $id, int $userId, ?string $comment): bool
    {
        $submission = $this->submissionModel->find($id);
        if (!$submission) throw new Exception('Không tồn tại hồ sơ');

        $currentStep = $this->stepModel->find($submission['current_step_id']);

        $this->logModel->insert([
            'submission_id'    => $id,
            'workflow_step_id' => $currentStep['id'],
            'action'           => 'approved',
            'comment'          => $comment,
            'actor_id'         => $userId,
        ]);

        $nextStep = $this->stepModel
            ->where('workflow_id', $submission['workflow_id'])
            ->where('order_index >', $currentStep['order_index'])
            ->orderBy('order_index', 'ASC')
            ->first();

        if ($nextStep) {
            return $this->submissionModel->update($id, [
                'current_step_id' => $nextStep['id'],
                'current_level'   => $nextStep['level'],
            ]);
        }

        return $this->submissionModel->update($id, ['status' => 'approved']);
    }

    /**
     * @throws ReflectionException
     */
    public function reject(int $id, int $userId, string $comment): bool
    {
        $submission = $this->submissionModel->find($id);

        $this->logModel->insert([
            'submission_id'    => $id,
            'workflow_step_id' => $submission['current_step_id'],
            'action'           => 'rejected',
            'comment'          => $comment,
            'actor_id'         => $userId,
        ]);

        return $this->submissionModel->update($id, ['status' => 'rejected']);
    }

    /**
     * @throws ReflectionException
     * @throws Exception
     */
    public function returnToPreviousStep(int $id, int $userId, ?string $comment): bool
    {
        $submission = $this->submissionModel->find($id);
        $currentStep = $this->stepModel->find($submission['current_step_id']);

        $prevStep = $this->stepModel
            ->where('workflow_id', $submission['workflow_id'])
            ->where('order_index <', $currentStep['order_index'])
            ->orderBy('order_index', 'DESC')
            ->first();

        if (!$prevStep) throw new Exception('Không có bước trước');

        $this->logModel->insert([
            'submission_id'    => $id,
            'workflow_step_id' => $currentStep['id'],
            'action'           => 'returned',
            'comment'          => $comment,
            'actor_id'         => $userId,
        ]);

        return $this->submissionModel->update($id, [
            'current_step_id' => $prevStep['id'],
            'current_level'   => $prevStep['level'],
        ]);
    }
}
