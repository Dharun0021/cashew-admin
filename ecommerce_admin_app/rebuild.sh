#!/bin/bash
# Complete rebuild script for fixing image picker

echo "==================================="
echo "Flutter App Complete Rebuild"
echo "==================================="

# Step 1: Clean Flutter
echo ""
echo "Step 1: Cleaning Flutter cache..."
flutter clean
echo "✓ Flutter cleaned"

# Step 2: Get dependencies
echo ""
echo "Step 2: Getting dependencies..."
flutter pub get
echo "✓ Dependencies fetched"

# Step 3: Clean device
echo ""
echo "Step 3: Clearing app from device..."
adb shell pm clear com.example.ecommerce_admin_app 2>/dev/null || true
echo "✓ App cleared"

# Step 4: Rebuild and run
echo ""
echo "Step 4: Building and running app..."
echo "This may take a few minutes..."
flutter run -v

echo ""
echo "==================================="
echo "Build Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Navigate to Categories"
echo "2. Click 'Add Category'"
echo "3. Click 'Gallery' or 'Camera'"
echo ""
echo "If you still see errors, check the logs:"
echo "   flutter logs -v | grep ImagePicker"
