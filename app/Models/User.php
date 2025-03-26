<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    // Role constants
    const ROLE_ADMIN = 'admin';
    const ROLE_BUYER = 'buyer';
    const ROLE_SELLER = 'seller';
    const ROLE_SERVICE_PROVIDER = 'service_provider';
    const ROLE_MODERATOR = 'moderator';
    const ROLE_SUPPORT = 'support';
    const ROLE_DELIVERY_PARTNER = 'delivery_partner';
    const ROLE_AFFILIATE = 'affiliate';
    const ROLE_CONTENT_CREATOR = 'content_creator';
    const ROLE_FINANCIAL_MANAGER = 'financial_manager';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'address',
        'role',
        'avatar',
        'is_active',
        'last_login_at',
        'last_login_ip'
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'is_active' => 'boolean',
        'last_login_at' => 'datetime'
    ];

    /**
     * Get the products that belong to the user (seller).
     */
    public function products()
    {
        return $this->hasMany(Product::class);
    }

    /**
     * Get the orders that belong to the user.
     */
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Get the reviews that belong to the user.
     */
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    /**
     * Get the chats where the user is the customer.
     */
    public function customerChats()
    {
        return $this->hasMany(Chat::class, 'user_id');
    }

    /**
     * Get the chats where the user is the seller.
     */
    public function sellerChats()
    {
        return $this->hasMany(Chat::class, 'seller_id');
    }

    /**
     * Check if user is an admin
     */
    public function isAdmin(): bool
    {
        return $this->hasRole(self::ROLE_ADMIN);
    }

    /**
     * Check if user is a seller
     */
    public function isSeller(): bool
    {
        return $this->hasRole(self::ROLE_SELLER);
    }

    /**
     * Check if user is a buyer
     */
    public function isBuyer(): bool
    {
        return $this->hasRole(self::ROLE_BUYER);
    }

    /**
     * Check if user is a service provider
     */
    public function isServiceProvider(): bool
    {
        return $this->hasRole(self::ROLE_SERVICE_PROVIDER);
    }

    /**
     * Get all available roles
     */
    public static function getAvailableRoles(): array
    {
        return [
            self::ROLE_ADMIN => 'Administrator',
            self::ROLE_BUYER => 'Buyer',
            self::ROLE_SELLER => 'Seller',
            self::ROLE_SERVICE_PROVIDER => 'Service Provider',
            self::ROLE_MODERATOR => 'Moderator',
            self::ROLE_SUPPORT => 'Support Staff',
            self::ROLE_DELIVERY_PARTNER => 'Delivery Partner',
            self::ROLE_AFFILIATE => 'Affiliate',
            self::ROLE_CONTENT_CREATOR => 'Content Creator',
            self::ROLE_FINANCIAL_MANAGER => 'Financial Manager',
        ];
    }

    /**
     * Check if user has a specific role
     */
    public function hasRole(string $role): bool
    {
        return $this->role === $role;
    }

    /**
     * Check if user has any of the given roles
     */
    public function hasAnyRole(array $roles): bool
    {
        return !empty(array_intersect($roles, $this->roles ?? []));
    }

    /**
     * Check if user has all of the given roles
     */
    public function hasAllRoles(array $roles): bool
    {
        return empty(array_diff($roles, $this->roles ?? []));
    }

    /**
     * Add a role to the user
     */
    public function addRole(string $role): void
    {
        if (!$this->hasRole($role)) {
            $this->roles = array_merge($this->roles ?? [], [$role]);
            $this->save();
        }
    }

    /**
     * Remove a role from the user
     */
    public function removeRole(string $role): void
    {
        if ($this->hasRole($role)) {
            $this->roles = array_diff($this->roles ?? [], [$role]);
            $this->save();
        }
    }

    /**
     * Set multiple roles at once
     */
    public function syncRoles(array $roles): void
    {
        $this->roles = array_values(array_intersect($roles, array_keys(self::getAvailableRoles())));
        $this->save();
    }

    /**
     * Get the user's primary role (first role in the array)
     */
    public function getPrimaryRole(): ?string
    {
        return $this->roles[0] ?? null;
    }

    /**
     * Get formatted roles for display
     */
    public function getFormattedRoles(): array
    {
        $availableRoles = self::getAvailableRoles();
        return array_map(function($role) use ($availableRoles) {
            return $availableRoles[$role] ?? $role;
        }, $this->roles ?? []);
    }

    /**
     * Update last login information
     */
    public function updateLastLogin(): void
    {
        $this->update([
            'last_login_at' => now(),
            'last_login_ip' => request()->ip()
        ]);
    }

    /**
     * Get the services that belong to the user (service provider).
     */
    public function services()
    {
        return $this->hasMany(Service::class);
    }

    /**
     * Get the bookings that belong to the user.
     */
    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    /**
     * Get the user's favorite products.
     */
    public function favorites()
    {
        return $this->belongsToMany(Product::class, 'favorites')->withTimestamps();
    }
} 