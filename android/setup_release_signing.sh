#!/bin/bash

# Script to set up release signing for Android app
# This will create a keystore and key.properties file

echo "🔐 Setting up release signing for ClassHub"
echo ""

# Check if keystore already exists
if [ -f "classhub-keystore.jks" ]; then
    echo "⚠️  Keystore already exists at: classhub-keystore.jks"
    read -p "Do you want to create a new one? (y/N): " create_new
    if [ "$create_new" != "y" ] && [ "$create_new" != "Y" ]; then
        echo "Using existing keystore..."
        exit 0
    fi
fi

# Get keystore password
echo "Enter a password for your keystore (store password):"
read -s STORE_PASSWORD
echo ""

# Get key password (can be same as store password)
echo "Enter a password for your key (key password, can be same as store password):"
read -s KEY_PASSWORD
echo ""

# Create keystore
echo "Creating keystore..."
keytool -genkey -v -keystore classhub-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias classhub \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=ClassHub, OU=Development, O=ClassHub, L=City, ST=State, C=US"

if [ $? -eq 0 ]; then
    echo "✅ Keystore created successfully!"
    
    # Create key.properties file
    echo "Creating key.properties file..."
    cat > key.properties << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=classhub
storeFile=classhub-keystore.jks
EOF
    
    echo "✅ key.properties created successfully!"
    echo ""
    echo "⚠️  IMPORTANT:"
    echo "   - Keep your keystore file (classhub-keystore.jks) safe and backed up!"
    echo "   - If you lose it, you won't be able to update your app on Play Store"
    echo "   - The key.properties file is in .gitignore and won't be committed"
    echo ""
    echo "✅ You can now build your release AAB with:"
    echo "   flutter build appbundle --release"
else
    echo "❌ Failed to create keystore"
    exit 1
fi

