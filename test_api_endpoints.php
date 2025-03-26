<?php
/**
 * Masoko Tips API Test Script
 * 
 * This script tests the API endpoints for your Laravel backend
 * Run it from the command line: php test_api_endpoints.php
 */

// Configuration
$baseUrl = 'http://127.0.0.1:8000/api';
$email = 'seller@example.com';
$password = 'password';

// Colors for terminal output
$green = "\033[32m";
$red = "\033[31m";
$yellow = "\033[33m";
$reset = "\033[0m";

echo "{$yellow}Masoko Tips API Test Script{$reset}\n";
echo "Testing API at: {$baseUrl}\n\n";

// Step 1: Login to get token
echo "Step 1: Logging in as seller...\n";
$loginData = [
    'email' => $email,
    'password' => $password
];

$loginResponse = makeRequest("/auth/login", "POST", $loginData);

if (!isset($loginResponse['token'])) {
    die("{$red}Failed to login. No token received.{$reset}\n");
}

$token = $loginResponse['token'];
$user = $loginResponse['user'] ?? null;

echo "{$green}Login successful!{$reset}\n";
echo "Token: " . substr($token, 0, 10) . "...\n";
if ($user) {
    echo "User: {$user['name']} (ID: {$user['id']})\n";
    echo "Role: {$user['role']}\n";
    
    if ($user['role'] !== 'seller') {
        echo "{$yellow}Warning: User is not a seller. Product creation may fail.{$reset}\n";
    }
}
echo "\n";

// Step 2: Test getting categories
echo "Step 2: Getting categories...\n";
$categoriesResponse = makeRequest("/categories", "GET", null, $token);
if (is_array($categoriesResponse) && isset($categoriesResponse['data'])) {
    echo "{$green}Categories retrieved successfully!{$reset}\n";
    echo "Found " . count($categoriesResponse['data']) . " categories.\n";
    
    // Print first few categories
    $count = min(3, count($categoriesResponse['data']));
    for ($i = 0; $i < $count; $i++) {
        $category = $categoriesResponse['data'][$i];
        echo " - {$category['name']} (ID: {$category['id']})\n";
    }
} else {
    echo "{$red}Failed to retrieve categories.{$reset}\n";
    print_r($categoriesResponse);
}
echo "\n";

// Step 3: Test getting seller products
echo "Step 3: Getting seller products...\n";
$productsResponse = makeRequest("/seller/products", "GET", null, $token);
if (is_array($productsResponse)) {
    echo "{$green}Seller products retrieved successfully!{$reset}\n";
    $productCount = count($productsResponse);
    echo "Found $productCount products.\n";
    
    if ($productCount > 0) {
        // Print first few products
        $count = min(3, $productCount);
        for ($i = 0; $i < $count; $i++) {
            $product = $productsResponse[$i];
            echo " - {$product['name']} (ID: {$product['id']}, Price: \${$product['price']})\n";
        }
    }
} else {
    echo "{$red}Failed to retrieve seller products.{$reset}\n";
    print_r($productsResponse);
}
echo "\n";

// Step 4: Create a test product
echo "Step 4: Creating a test product...\n";
$newProduct = [
    'name' => 'Test Product ' . rand(1000, 9999),
    'description' => 'This is a test product created by the API test script',
    'price' => 19.99,
    'stock' => 100,
    'is_active' => true,
    'category_id' => 1, // Use the first category or adjust based on your db
    'user_id' => $user['id'] ?? 1,
];

$createResponse = makeRequest("/seller/products", "POST", $newProduct, $token);
if (isset($createResponse['success']) && $createResponse['success']) {
    echo "{$green}Product created successfully!{$reset}\n";
    echo "Product ID: {$createResponse['id']}\n";
    echo "Product Name: {$createResponse['product']['name']}\n";
} else {
    echo "{$red}Failed to create product.{$reset}\n";
    print_r($createResponse);
}
echo "\n";

echo "{$green}API tests completed!{$reset}\n";

/**
 * Helper function to make HTTP requests
 */
function makeRequest($endpoint, $method, $data = null, $token = null) {
    global $baseUrl, $red;
    
    $url = $baseUrl . $endpoint;
    $ch = curl_init($url);
    
    $headers = ['Accept: application/json', 'Content-Type: application/json'];
    if ($token) {
        $headers[] = "Authorization: Bearer $token";
    }
    
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    
    if ($method === 'POST') {
        curl_setopt($ch, CURLOPT_POST, true);
        if ($data) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
    } else if ($method !== 'GET') {
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
        if ($data) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
    }
    
    $response = curl_exec($ch);
    $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    
    if (curl_errno($ch)) {
        echo "{$red}Error making request to $url: " . curl_error($ch) . "{$reset}\n";
        curl_close($ch);
        return null;
    }
    
    curl_close($ch);
    
    $responseData = json_decode($response, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo "{$red}Error decoding JSON response: " . json_last_error_msg() . "{$reset}\n";
        echo "Raw response: " . substr($response, 0, 200) . (strlen($response) > 200 ? '...' : '') . "\n";
        return null;
    }
    
    return $responseData;
} 