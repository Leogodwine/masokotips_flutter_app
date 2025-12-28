<?php

/**
 * Script to fix user roles for existing users
 * This script will:
 * 1. Find users who have a 'role' field set but no corresponding Spatie role
 * 2. Assign the correct Spatie role based on their 'role' field
 * 3. Log the changes for review
 */

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Facades\Log;

echo "=== User Role Fix Script ===\n";
echo "Starting role assignment fix for existing users...\n\n";

try {
    // Get all users who have a role field set
    $users = User::whereNotNull('role')
                  ->where('role', '!=', '')
                  ->get();
    
    echo "Found {$users->count()} users with role field set.\n\n";
    
    $fixedUsers = 0;
    $errors = [];
    
    foreach ($users as $user) {
        echo "Processing user: {$user->email} (ID: {$user->id})\n";
        echo "  - Role field: '{$user->role}'\n";
        
        // Get current roles for this user
        $currentRoles = $user->getRoleNames('web');
        echo "  - Current Spatie roles: " . ($currentRoles->isNotEmpty() ? $currentRoles->implode(', ') : 'none') . "\n";
        
        // Check if user already has the correct role
        if ($currentRoles->contains($user->role)) {
            echo "  - ✅ User already has correct role: {$user->role}\n\n";
            continue;
        }
        
        // Check if the role exists in Spatie
        $roleExists = Role::where('name', $user->role)
                          ->where('guard_name', 'web')
                          ->exists();
        
        if (!$roleExists) {
            echo "  - ❌ Role '{$user->role}' does not exist in Spatie roles\n";
            $errors[] = "User {$user->email}: Role '{$user->role}' does not exist";
            continue;
        }
        
        try {
            // Remove all current roles first
            if ($currentRoles->isNotEmpty()) {
                $user->removeRole($currentRoles);
                echo "  - Removed old roles: " . $currentRoles->implode(', ') . "\n";
            }
            
            // Assign the correct role
            $role = Role::where('name', $user->role)
                        ->where('guard_name', 'web')
                        ->first();
            
            $user->assignRole($role);
            echo "  - ✅ Assigned role: {$user->role}\n";
            
            // Log the change
            Log::info('User role fixed via script', [
                'user_id' => $user->id,
                'user_email' => $user->email,
                'old_roles' => $currentRoles->toArray(),
                'new_role' => $user->role,
                'fixed_by' => 'role_fix_script'
            ]);
            
            $fixedUsers++;
            
        } catch (Exception $e) {
            echo "  - ❌ Error assigning role: {$e->getMessage()}\n";
            $errors[] = "User {$user->email}: {$e->getMessage()}";
        }
        
        echo "\n";
    }
    
    echo "=== Summary ===\n";
    echo "Total users processed: {$users->count()}\n";
    echo "Users fixed: {$fixedUsers}\n";
    echo "Errors: " . count($errors) . "\n";
    
    if (!empty($errors)) {
        echo "\nErrors encountered:\n";
        foreach ($errors as $error) {
            echo "  - {$error}\n";
        }
    }
    
    // Also check for users who registered as sellers but don't have seller role
    echo "\n=== Additional Check: Users who might need seller role ===\n";
    $potentialSellers = User::where('role', 'seller')
                           ->whereDoesntHave('roles', function($query) {
                               $query->where('name', 'seller');
                           })
                           ->get();
    
    if ($potentialSellers->isNotEmpty()) {
        echo "Found {$potentialSellers->count()} users who should be sellers:\n";
        foreach ($potentialSellers as $user) {
            echo "  - {$user->email} (ID: {$user->id})\n";
        }
    } else {
        echo "No additional users need seller role assignment.\n";
    }
    
} catch (Exception $e) {
    echo "❌ Script failed: {$e->getMessage()}\n";
    Log::error('User role fix script failed', [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}

echo "\n=== Script completed ===\n";