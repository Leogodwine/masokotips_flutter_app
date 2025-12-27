<?php
// Test script to verify AzamPayTransaction model configuration
require_once __DIR__ . '/vendor/autoload.php';

use App\Models\AzamPayTransaction;

$model = new AzamPayTransaction();
echo "Model table name: " . $model->getTable() . "\n";
echo "Model class: " . get_class($model) . "\n";

// Test if the table exists
try {
    $exists = DB::connection()->getSchemaBuilder()->hasTable('azampay_transactions');
    echo "Table 'azampay_transactions' exists: " . ($exists ? 'Yes' : 'No') . "\n";
} catch (Exception $e) {
    echo "Error checking table: " . $e->getMessage() . "\n";
}

try {
    $exists = DB::connection()->getSchemaBuilder()->hasTable('azam_pay_transactions');
    echo "Table 'azam_pay_transactions' exists: " . ($exists ? 'Yes' : 'No') . "\n";
} catch (Exception $e) {
    echo "Error checking table: " . $e->getMessage() . "\n";
}