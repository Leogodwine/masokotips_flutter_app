# User Role Assignment Fix

## Issue Description

When users register in the mobile app, they can select their role (Buyer, Seller, or Service Provider) during registration, but when viewing user details, the role shows as "No Role" instead of the selected role. The role had to be manually assigned in the admin dashboard, which should not be necessary.

## Root Cause Analysis

The issue was in the Laravel backend's user registration process:

### 1. AuthController Issue
- **File**: `app/Http/Controllers/Api/AuthController.php`
- **Problem**: The registration method was:
  1. Trying to assign the role to a non-fillable `role` field in the database
  2. Instead of assigning the requested role (`buyer`, `seller`, `service_provider`), it was assigning a generic `registered_user` role to all new users
  3. The response wasn't including the actual assigned roles

### 2. UserController Issue
- **File**: `app/Http/Controllers/Api/UserController.php`
- **Problem**: The `profile()` method was returning the user object without including the assigned roles

### 3. User Model Issue
- **File**: `app/Models/User.php`
- **Problem**: The `role` field was not included in the `$fillable` array, making it non-mass-assignable

## Solution Implemented

### 1. Fixed AuthController Registration Method

**Changes made to `AuthController.php`**:

1. **Removed non-fillable role assignment**:
   ```php
   // BEFORE (incorrect)
   'role' => $request->role // This field is not mass-assignable
   
   // AFTER (correct)
   // Removed role from User::create() array
   ```

2. **Assign the correct role during registration**:
   ```php
   // Assign the requested role using Spatie permissions with web guard
   try {
       $requestedRole = \Spatie\Permission\Models\Role::where('name', $request->role)
           ->where('guard_name', 'web')
           ->first();
       
       if ($requestedRole) {
           $user->assignRole($requestedRole);
       } else {
           // Fallback to registered_user role if the requested role doesn't exist
           $fallbackRole = \Spatie\Permission\Models\Role::where('name', 'registered_user')
               ->where('guard_name', 'web')
               ->first();
           if ($fallbackRole) {
               $user->assignRole($fallbackRole);
           }
       }
   } catch (\Exception $e) {
       \Log::error('Failed to assign role during registration', [...]);
   }
   ```

3. **Enhanced registration response**:
   ```php
   // Include actual assigned roles in the response
   $userRoles = $user->getRoleNames('web')->toArray();
   $userData = $user->toArray();
   $userData['roles'] = $userRoles;
   ```

### 2. Fixed UserController Profile Method

**Changes made to `UserController.php`**:

```php
public function profile(Request $request)
{
    $user = $request->user();
    
    // Get user roles manually (using web guard) to include in response
    $userRoles = $user->getRoleNames('web')->toArray();
    
    // Create user array with roles
    $userData = $user->toArray();
    $userData['roles'] = $userRoles;
    
    return response()->json([
        'user' => $userData
    ]);
}
```

## Expected Behavior After Fix

1. **Registration Flow**:
   - User selects role (Buyer/Seller/Service Provider) during registration
   - Backend assigns the selected role to the user via Spatie permissions
   - User is created with the correct role assigned
   - Registration response includes the assigned roles

2. **Profile Viewing**:
   - When viewing user details, the correct role is displayed
   - No manual role assignment needed in admin dashboard
   - Role-based features work immediately after registration

3. **Login Flow**:
   - User logs in and gets the correct roles assigned
   - Role-based access control works as expected

## Testing the Fix

To verify the fix works:

1. **Register a new user** with a specific role (e.g., "Seller")
2. **Check the registration response** - should include the correct role in the `roles` array
3. **View user profile** - should show the correct role instead of "No Role"
4. **Check admin dashboard** - user should appear with the correct role assigned

## Files Modified

1. `../../wamp64/www/masoko_tips_api/app/Http/Controllers/Api/AuthController.php`
   - Fixed registration method to assign correct roles
   - Enhanced registration response to include roles

2. `../../wamp64/www/masoko_tips_api/app/Http/Controllers/Api/UserController.php`
   - Fixed profile method to include user roles in response

## Additional Notes

- The fix uses Laravel's Spatie Permission package for role management
- Role assignment is done using the `web` guard as per the application's configuration
- Error logging is included for debugging role assignment issues
- Fallback mechanism ensures users get at least the `registered_user` role if the requested role doesn't exist

This fix ensures that user roles are properly assigned during registration and correctly displayed throughout the application.