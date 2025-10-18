@echo off
REM Deploy Firestore Security Rules to Firebase (Windows)
REM This script deploys the firestore.rules file to your Firebase project

echo 🔐 Deploying Firestore Security Rules...
echo.

REM Check if Firebase CLI is installed
where firebase >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Firebase CLI is not installed.
    echo Please install it with: npm install -g firebase-tools
    exit /b 1
)

REM Check if firestore.rules exists
if not exist "firestore.rules" (
    echo ❌ firestore.rules file not found!
    echo Please create the file first.
    exit /b 1
)

echo 📋 Current Firebase project:
firebase use

echo.
echo 🚀 Deploying rules...
firebase deploy --only firestore:rules

if %errorlevel% equ 0 (
    echo.
    echo ✅ Firestore Security Rules deployed successfully!
    echo.
    echo 📝 What was deployed:
    echo   - User data protection (users can only access their own data^)
    echo   - Transaction validation (type, category, amount, description^)
    echo   - Goal and Task rules (prepared for future features^)
    echo.
    echo 🔍 Verify deployment:
    echo   Visit: https://console.firebase.google.com/project/mygoals-19463/firestore/rules
) else (
    echo.
    echo ❌ Deployment failed!
    echo Please check the error messages above.
    exit /b 1
)
