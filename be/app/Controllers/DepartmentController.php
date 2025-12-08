<?php

namespace App\Controllers;

use App\Models\DepartmentModel;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;

class DepartmentController extends ResourceController
{
    protected $modelName = DepartmentModel::class;
    protected $format    = 'json';

    /* =====================================================
     * 1. GET /departments   -> danh sách phòng ban
     * ===================================================== */
    public function index(): ResponseInterface
    {
        $db = db_connect();

        $departments = $db->table('departments d')
            ->select("
            d.id,
            d.name,
            d.description,
            d.created_at,
            d.updated_at,
            GROUP_CONCAT(u.name SEPARATOR '||') AS users,
            GROUP_CONCAT(u.id SEPARATOR '||') AS user_ids
        ")
            ->join('department_user du', 'du.department_id = d.id', 'left')
            ->join('users u', 'u.id = du.user_id', 'left')
            ->groupBy('d.id')
            ->get()
            ->getResultArray();

        // chuyển users từ string → array
        foreach ($departments as &$item) {

            $names = $item['users'] ? explode('||', $item['users']) : [];
            $ids   = $item['user_ids'] ? explode('||', $item['user_ids']) : [];

            $users = [];
            foreach ($names as $i => $name) {
                if (!empty($name)) {
                    $users[] = [
                        'id'   => $ids[$i] ?? null,
                        'name' => $name
                    ];
                }
            }

            $item['users'] = $users;
            unset($item['user_ids']);
        }

        return $this->respond($departments);
    }


    /* =====================================================
     * 2. GET /departments/{id}
     * ===================================================== */
    public function show($id = null)
    {
        $data = $this->model->find($id);

        return $data
            ? $this->respond($data)
            : $this->failNotFound("Department not found");
    }

    /* =====================================================
     * 3. POST /departments
     * ===================================================== */
    public function create()
    {
        $data = $this->request->getJSON(true);

        if (!$this->validate(['name' => 'required'])) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        $id = $this->model->insert($data);

        return $this->respondCreated(['id' => $id]);
    }

    /* =====================================================
     * 4. PUT /departments/{id}
     * ===================================================== */
    public function update($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound("Department not found");
        }

        $data = $this->request->getJSON(true);

        $this->model->update($id, $data);

        return $this->respond(['status' => 'success', 'message' => 'Updated']);
    }

    /* =====================================================
     * 5. DELETE /departments/{id}
     * ===================================================== */
    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound("Department not found");
        }

        $this->model->delete($id);

        return $this->respondDeleted(['status' => 'success']);
    }



    /* ===============================================================
     * 6. GET /departments/{id}/users → users của phòng ban
     * =============================================================== */
    public function users($departmentId): ResponseInterface
    {
        $db = db_connect();

        $users = $db->table('department_user du')
            ->select('u.id, u.name, u.email, u.phone, u.avatar, u.role_id,
                      du.role_in_department')
            ->join('users u', 'u.id = du.user_id')
            ->where('du.department_id', $departmentId)
            ->get()
            ->getResultArray();

        return $this->respond($users);
    }


    /* ==================================================================
     * 7. POST /departments/{id}/users → thêm 1 hoặc nhiều user
     * ================================================================== */
    public function addUsers($departmentId)
    {
        $data = $this->request->getJSON(true);

        $users = $data['users'] ?? [];

        if (empty($users)) {
            return $this->failValidationErrors("users must not be empty");
        }

        $db = db_connect();

        foreach ($users as $u) {
            $uid  = $u['id'];
            $role = $u['role'] ?? 'user';

            $exists = $db->table('department_user')
                ->where('department_id', $departmentId)
                ->where('user_id', $uid)
                ->countAllResults();

            if ($exists == 0) {
                $db->table('department_user')->insert([
                    'department_id' => $departmentId,
                    'user_id'       => $uid,
                    'role_in_department' => $role
                ]);
            } else {
                // Cập nhật lại role nếu đã tồn tại
                $db->table('department_user')
                    ->where('department_id', $departmentId)
                    ->where('user_id', $uid)
                    ->update(['role_in_department' => $role]);
            }
        }

        return $this->respond(['status' => 'success']);
    }



    /* ==========================================================================
     * 8. DELETE /departments/{departmentId}/users/{userId} → xoá user khỏi phòng
     * ========================================================================== */
    public function removeUser($departmentId, $userId)
    {
        $db = db_connect();

        $db->table('department_user')
            ->where('department_id', $departmentId)
            ->where('user_id', $userId)
            ->delete();

        return $this->respondDeleted(['status' => 'success']);
    }
}
