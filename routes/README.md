# Admin User Seeder

This directory contains seeders for the maSOKOtips application.

## Admin User Seeder

The `AdminUserSeeder.php` file creates an admin user in the database with the following credentials:

- Email: admin@masokotips.com
- Password: admin123

## How to Run the Seeder

1. Make sure you have set up your Laravel environment correctly.
2. Navigate to your Laravel project directory in the terminal.
3. Run the migrations to create the necessary tables:

```bash
php artisan migrate
```

4. Run the following command to execute the seeder:

```bash
php artisan db:seed
```

Or to run only the AdminUserSeeder:

```bash
php artisan db:seed --class=AdminUserSeeder
```

## Important Notes

- The seeder checks if an admin user already exists before creating a new one.
- The admin user is created with the role 'admin' in both the `role` and `roles` fields.
- The `is_admin` flag is set to true for the admin user.
- For security reasons, it's recommended to change the admin password after the first login.

## Troubleshooting

If you encounter any issues:

1. Make sure your database connection is properly configured in the `.env` file.
2. Check if the `users` table exists in your database.
3. Verify that the `role`, `roles`, and `is_admin` columns exist in the `users` table. 