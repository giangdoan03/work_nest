<?php

namespace App\Traits;

trait AuthTrait
{
    protected function getUserId()
    {
        return session()->get('user_id');
    }
}
