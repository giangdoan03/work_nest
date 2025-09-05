<?php
namespace App\Models;
use CodeIgniter\Model;

class CommentReadModel extends Model
{
    protected $table = 'comment_reads';
    protected $primaryKey = 'id';
    protected $allowedFields = ['user_id', 'comment_id', 'read_at'];
    public $useTimestamps = false;
}
