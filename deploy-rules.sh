#!/bin/bash

# Deploy Firestore Security Rules to Firebase
# This script deploys the firestore.rules file to your Firebase project

echo "🔐 Deploying Firestore Security Rules..."
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null
then
    echo "❌ Firebase CLI is not installed."
    echo "Please install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null
then
    echo "❌ You are not logged in to Firebase."
    echo "Please run: firebase login"
    exit 1
fi

# Check if firestore.rules exists
if [ ! -f "firestore.rules" ]; then
    echo "❌ firestore.rules file not found!"
    echo "Please create the file first."
    exit 1
fi

echo "📋 Current Firebase project:"
firebase use

echo ""
echo "🚀 Deploying rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Firestore Security Rules deployed successfully!"
    echo ""
    echo "📝 What was deployed:"
    echo "  - User data protection (users can only access their own data)"
    echo "  - Transaction validation (type, category, amount, description)"
    echo "  - Goal and Task rules (prepared for future features)"
    echo ""
    echo "🔍 Verify deployment:"
    echo "  Visit: https://console.firebase.google.com/project/mygoals-19463/firestore/rules"
else
    echo ""
    echo "❌ Deployment failed!"
    echo "Please check the error messages above."
    exit 1
fi
