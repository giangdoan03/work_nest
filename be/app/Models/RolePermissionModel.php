<?php
namespace App\Models;

use CodeIgniter\Model;

class RolePermissionModel extends Model
{
    protected $table = 'role_permissions';
    protected $primaryKey = 'id';
    protected $allowedFields = ['role_id', 'module', 'action'];

    public function getPermissionsByRole($roleId): array
    {
        return $this->db->table('role_permissions rp')
            ->select('p.id, p.key_name')
            ->join('permissions p', 'p.id = rp.permission_id')
            ->where('rp.role_id', $roleId)
            ->get()
            ->getResultArray();
    }


    /**
     * @throws \ReflectionException
     */
    public function savePermissions($roleId, $permissions): void
    {

        $permModel = new PermissionModel();

        $this->where('role_id', $roleId)->delete();

        $insertData = [];


        foreach ($permissions as $module => $actions) {
            foreach ($actions as $action => $checked) {
                if ($checked) {
                    $key = $module . '.' . $action;
                    $perm = $permModel->where('key_name', $key)->first();
                    if ($perm) {
                        $insertData[] = [
                            'role_id' => $roleId,
                            'permission_id' => $perm['id']
                        ];
                    }
                }
            }
        }

        if (!empty($insertData)) {
            $this->insertBatch($insertData);
        }
    }

    public function hasPermission($roleId, $module, $action): bool
    {
        return $this->db->table('role_permissions rp')
                ->join('permissions p', 'p.id = rp.permission_id')
                ->where('rp.role_id', $roleId)
                ->where('p.key_name', "{$module}.{$action}")
                ->countAllResults() > 0;
    }

}
