#!/bin/bash

# Script to copy AzamPay fixes from WAMP to Live Server
# Source: D:\wamp64\www\masoko_tips_api\
# Target: /home/masokoti/domains/masokotips.com/laravel-backend/

echo "🚀 Copying AzamPay fixes to live server..."

# Define paths
SOURCE_DIR="D:/wamp64/www/masoko_tips_api"
TARGET_DIR="/home/masokoti/domains/masokotips.com/laravel-backend"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Target directory not found: $TARGET_DIR"
    exit 1
fi

echo "📁 Source: $SOURCE_DIR"
echo "📁 Target: $TARGET_DIR"
echo ""

# Copy the fixed files
echo "📋 Copying files..."

# 1. Configuration file
echo "  ✅ Copying config/services.php..."
cp "$SOURCE_DIR/config/services.php" "$TARGET_DIR/config/services.php"

# 2. AzamPay Service
echo "  ✅ Copying app/Services/AzamPayService.php..."
cp "$SOURCE_DIR/app/Services/AzamPayService.php" "$TARGET_DIR/app/Services/AzamPayService.php"

# 3. AzamPay Checkout Controller
echo "  ✅ Copying app/Http/Controllers/Api/AzamPayCheckoutController.php..."
cp "$SOURCE_DIR/app/Http/Controllers/Api/AzamPayCheckoutController.php" "$TARGET_DIR/app/Http/Controllers/Api/AzamPayCheckoutController.php"

echo ""
echo "🎉 All files copied successfully!"
echo ""
echo "🔧 Next steps:"
echo "1. Clear Laravel config cache: php artisan config:clear"
echo "2. Test the subscription flow in your Flutter app"
echo "3. Check Laravel logs for any remaining issues"
echo ""
echo "✨ The fixes include:"
echo "  • Fixed callback_url configuration in services.php"
echo "  • Added missing AzamPayService methods"
echo "  • Improved validation and error handling"
echo "  • Added debug logging for troubleshooting"