# Security Guidelines

## CRITICAL WARNING

**THIS IS A PUBLIC REPOSITORY**

All code and files committed to this repository are publicly visible. Never commit sensitive information, credentials, or private data.

## Files That Must NEVER Be Committed

### High Priority - Contains Secrets
- `.env` - Contains all Firebase API keys and configuration
- `google-services.json` - Android Firebase configuration
- `GoogleService-Info.plist` - iOS Firebase configuration
- Any file with `.key`, `.pem`, `.p12`, `.keystore` extensions
- Any backup files (`.env.backup`, `.env.local`, etc.)

### Firebase Related
- `firebase-debug.log`
- `firestore-debug.log`
- `.firebaserc` (if it contains sensitive project aliases)
- Service account JSON files
- Firebase Admin SDK credentials

### Build and IDE Files
- `android/key.properties` - Contains Android signing configuration
- `android/app/*.keystore` - Android signing keys
- Any files in `.gradle/` containing credentials
- `.idea/` files with database passwords or API keys

## Managing Credentials Locally

### 1. Environment Variables (.env)

**Setup Process:**
```bash
# 1. Copy the example file
cp .env.example .env

# 2. Edit .env with your actual credentials
# 3. NEVER commit the .env file
```

**Best Practices:**
- Keep `.env.example` updated with all required variables (with dummy values)
- Use strong, unique API keys for production
- Rotate credentials regularly
- Use different credentials for development and production

### 2. Firebase Configuration Files

**Android (google-services.json):**
```bash
# Place in:
app/android/app/google-services.json

# Verify it's ignored:
git status # Should not show google-services.json
```

**iOS (GoogleService-Info.plist):**
```bash
# Place in:
app/ios/Runner/GoogleService-Info.plist

# Verify it's ignored:
git status # Should not show GoogleService-Info.plist
```

### 3. Secure Storage for Team Collaboration

If working with a team:
- Use a password manager (1Password, LastPass) for sharing credentials
- Use encrypted communication (Signal, encrypted email) for sensitive data
- Consider using secret management tools (HashiCorp Vault, AWS Secrets Manager)
- Document who has access to production credentials

## Security Checklist Before Every Commit

Run this checklist before EVERY commit:

### 1. Check Git Status
```bash
git status
# Review ALL files being staged
```

### 2. Verify No Secrets in Code
```bash
# Search for common secret patterns
grep -r "api_key\|apikey\|api-key" --exclude-dir=.git .
grep -r "password\|passwd\|pwd" --exclude-dir=.git .
grep -r "secret\|token\|auth" --exclude-dir=.git .
grep -r "firebase" --include="*.dart" . | grep -v "import\|package"
```

### 3. Check for Hardcoded Values
Look for patterns like:
- API keys: `apiKey: "AIza..."`
- URLs with credentials: `https://user:pass@domain.com`
- Base64 encoded secrets
- JWT tokens
- Database connection strings

### 4. Verify .gitignore
```bash
# Ensure critical files are ignored
cat .gitignore | grep -E "\.env|google-services|GoogleService"
```

### 5. Review Changes
```bash
# Review all changes line by line
git diff --staged
```

### 6. Double-Check Sensitive Files
```bash
# Ensure these don't exist in staging
git ls-files | grep -E "\.env$|google-services\.json|GoogleService-Info\.plist"
```

## What To Do If Credentials Are Accidentally Committed

**IMMEDIATE ACTIONS REQUIRED:**

### 1. If Not Yet Pushed
```bash
# Remove from staging
git reset HEAD~1

# Remove sensitive file
rm <sensitive-file>

# Add to .gitignore
echo "<sensitive-file>" >> .gitignore

# Recommit without the sensitive file
git add .
git commit -m "Remove accidentally staged sensitive file"
```

### 2. If Already Pushed to GitHub

**Time is critical - act immediately!**

1. **Revoke and Rotate All Exposed Credentials:**
   - Go to Firebase Console immediately
   - Regenerate all API keys
   - Create new service credentials
   - Update all applications using these credentials

2. **Remove from Repository History:**
   ```bash
   # Use BFG Repo-Cleaner (faster than git filter-branch)
   java -jar bfg.jar --delete-files <sensitive-file> --no-blob-protection
   git push --force
   ```

3. **Alternative: Complete History Rewrite:**
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch <sensitive-file>" \
     --prune-empty --tag-name-filter cat -- --all
   git push --force --all
   ```

4. **Contact GitHub Support:**
   - Report the incident
   - Request cache invalidation
   - Ask for removal from forks

5. **Audit and Monitor:**
   - Check Firebase usage for unauthorized access
   - Review authentication logs
   - Monitor for suspicious activity
   - Enable additional security features (2FA, IP restrictions)

## Firebase Security Best Practices

### 1. Firestore Security Rules

**Never use open rules in production:**
```javascript
// DANGEROUS - NEVER USE IN PRODUCTION
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // NEVER DO THIS
    }
  }
}
```

**Use proper authentication:**
```javascript
// SECURE - Require authentication
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2. API Key Restrictions

In Firebase Console:
1. Go to Google Cloud Console
2. Navigate to "APIs & Services" > "Credentials"
3. For each API key:
   - Add application restrictions (Android, iOS, web domains)
   - Add API restrictions (only enable required APIs)
   - Add IP restrictions if possible

### 3. Enable Security Features

- Enable App Check for additional security
- Use Firebase Authentication with secure providers
- Enable audit logging
- Set up alerts for unusual activity
- Use Cloud Functions for sensitive operations

## Code Security Guidelines

### 1. Never Log Sensitive Data
```dart
// BAD - Never log sensitive information
print('User password: ${password}');
print('API Response: ${responseWithTokens}');

// GOOD - Log only necessary information
print('Login attempt for user: ${email}');
print('API call successful');
```

### 2. Validate All Input
```dart
// Always validate and sanitize user input
String sanitizeInput(String input) {
  // Remove potential SQL injection attempts
  // Escape special characters
  // Limit length
  return input.replaceAll(RegExp(r'[^\w\s]'), '');
}
```

### 3. Use Secure Storage
```dart
// Use flutter_secure_storage for sensitive data
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Write
await storage.write(key: 'auth_token', value: token);

// Read
String? token = await storage.read(key: 'auth_token');

// Delete
await storage.delete(key: 'auth_token');
```

### 4. Implement Certificate Pinning
```dart
// Pin SSL certificates for critical API calls
// Use dio with certificate pinning
// Verify server certificates
```

## Security Testing

### 1. Automated Security Checks
```bash
# Add to CI/CD pipeline
flutter analyze
dart analyze

# Check for secrets in code
git secrets --scan
trufflehog --regex --entropy=False
```

### 2. Manual Security Review
- Code review focusing on security
- Penetration testing
- Security audit of Firebase rules
- Review of all external dependencies

## Incident Response Plan

If a security breach occurs:

1. **Immediate Response:**
   - Revoke all potentially compromised credentials
   - Enable "Emergency Mode" in Firebase (restrict all access)
   - Document the timeline of events

2. **Investigation:**
   - Review logs for unauthorized access
   - Identify scope of breach
   - Determine what data was exposed

3. **Remediation:**
   - Fix the vulnerability
   - Rotate all credentials
   - Update security rules
   - Implement additional security measures

4. **Communication:**
   - Notify affected users if required
   - Update team on incident
   - Document lessons learned

5. **Prevention:**
   - Implement additional security controls
   - Update security procedures
   - Conduct security training

## Additional Security Resources

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/android#building-a-release-apk)
- [Firebase Security Checklist](https://firebase.google.com/support/guides/security-checklist)
- [Google Cloud Security Best Practices](https://cloud.google.com/security/best-practices)

## Contact for Security Issues

If you discover a security vulnerability:
1. Do NOT create a public issue
2. Send details to: [security@yourproject.com]
3. Include:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Remember

**Security is everyone's responsibility. When in doubt, ask for help before committing.**