<?php

namespace App\Models;

use CodeIgniter\Model;

class EntityImageModel extends Model
{
    protected $table = 'entity_images';
    protected $primaryKey = 'id';
    protected $allowedFields = ['entity_type', 'entity_id', 'url', 'is_cover', 'created_at', 'updated_at'];
    protected $useTimestamps = true;

    public function getImages($entityType, $entityId)
    {
        return $this->where('entity_type', $entityType)
            ->where('entity_id', $entityId)
            ->orderBy('id', 'asc')
            ->findAll();
    }

        public function getCoverImage($entityType, $entityId)
    {
        return $this->where('entity_type', $entityType)
            ->where('entity_id', $entityId)
            ->where('is_cover', 1)
            ->first();
    }
}
