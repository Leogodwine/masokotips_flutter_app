<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'roles',
        'is_admin',
        'phone_number',
        'avatar',
        'bio',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'is_admin' => 'boolean',
    ];

    public function hasRole($role)
    {
        // Check if the user has the role in the roles field
        if (is_array($this->roles)) {
            return in_array($role, $this->roles);
        }
        
        // If roles is a string, check if it contains the role
        if (is_string($this->roles)) {
            $roles = explode(',', $this->roles);
            return in_array($role, $roles);
        }
        
        // Check the single role field
        return $this->role === $role;
    }

    public function addRole($role)
    {
        if (!$this->hasRole($role)) {
            if (is_array($this->roles)) {
                $this->roles[] = $role;
            } else if (is_string($this->roles)) {
                $roles = explode(',', $this->roles);
                $roles[] = $role;
                $this->roles = implode(',', $roles);
            } else {
                $this->roles = $role;
            }
            $this->save();
        }
    }

    public function removeRole($role)
    {
        if (is_array($this->roles)) {
            $this->roles = array_diff($this->roles, [$role]);
        } else if (is_string($this->roles)) {
            $roles = explode(',', $this->roles);
            $roles = array_diff($roles, [$role]);
            $this->roles = implode(',', $roles);
        }
        $this->save();
    }
} 