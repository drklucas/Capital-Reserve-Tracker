# Firebase Security Rules Documentation

## Overview

This document describes the Firestore Security Rules implemented for the Capital Reserve Tracker application. These rules ensure that:

1. Users can only access their own data
2. All data is validated before being written
3. No unauthorized access is possible
4. Data integrity is maintained

## Rules Structure

### Users Collection

```
users/{userId}
├── Can read: Only if authenticated user owns this document
├── Can create: Only if creating own user document
├── Can update: Only if authenticated user owns this document
└── Can delete: Only if authenticated user owns this document
```

### Transactions Subcollection

```
users/{userId}/transactions/{transactionId}
├── Can read: Only if user owns the parent user document
├── Can create: With validation (see below)
├── Can update: With validation, cannot change userId
└── Can delete: Only if user owns the transaction
```

#### Transaction Validation Rules

When creating or updating a transaction, the following validations apply:

**Required Fields:**
- `userId`: Must match the authenticated user's ID
- `type`: Must be either `'income'` or `'expense'`
- `amount`: Must be a number between 0.01 and 999,999,999
- `description`: Must be a string between 1 and 500 characters
- `category`: Must be one of the allowed categories
- `date`: Must be a valid timestamp
- `createdAt`: Must be a valid timestamp

**Allowed Categories:**

**Income Categories:**
- `salary`
- `bonus`
- `investment`
- `freelance`
- `gift`
- `other`

**Expense Categories:**
- `food`
- `transport`
- `housing`
- `utilities`
- `entertainment`
- `healthcare`
- `education`
- `shopping`
- `savings`

**Security Constraints:**
- User can only create transactions under their own user document
- User cannot change the `userId` field when updating
- All amounts must be positive and within reasonable limits
- Descriptions must not be empty or exceed 500 characters

### Goals Subcollection (Prepared for Future)

```
users/{userId}/goals/{goalId}
├── Can read: Only if user owns the parent user document
├── Can create: With validation
├── Can update: With validation, cannot change userId
└── Can delete: Only if user owns the goal
```

#### Goal Validation Rules

- `userId`: Must match the authenticated user's ID
- `title`: Must be a string between 1 and 200 characters
- `targetAmount`: Must be a number between 0 and 999,999,999

### Tasks Subcollection (Prepared for Future)

```
users/{userId}/tasks/{taskId}
├── Can read: Only if user owns the parent user document
├── Can create: With validation
├── Can update: With validation, cannot change userId
└── Can delete: Only if user owns the task
```

#### Task Validation Rules

- `userId`: Must match the authenticated user's ID
- `title`: Must be a string between 1 and 200 characters

## Deploying Rules

### Prerequisites

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Set the correct project:
   ```bash
   firebase use mygoals-19463
   ```

### Deployment Methods

#### Method 1: Using the Deploy Script (Windows)

```bash
deploy-rules.bat
```

#### Method 2: Using the Deploy Script (Linux/Mac)

```bash
chmod +x deploy-rules.sh
./deploy-rules.sh
```

#### Method 3: Manual Deployment

```bash
firebase deploy --only firestore:rules
```

#### Method 4: Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/project/mygoals-19463/firestore/rules)
2. Navigate to Firestore Database → Rules
3. Copy the contents of `firestore.rules`
4. Paste into the editor
5. Click "Publish"

## Testing Rules

### Using Firebase Emulator

1. Start the emulator:
   ```bash
   firebase emulators:start
   ```

2. Run your app against the emulator:
   ```bash
   flutter run
   ```

### Manual Testing Checklist

- [ ] ✅ User can create transactions in their own collection
- [ ] ✅ User cannot create transactions in another user's collection
- [ ] ✅ User can read their own transactions
- [ ] ✅ User cannot read another user's transactions
- [ ] ✅ User can update their own transactions
- [ ] ✅ User cannot update another user's transactions
- [ ] ✅ User can delete their own transactions
- [ ] ✅ User cannot delete another user's transactions
- [ ] ✅ Invalid transaction data is rejected
- [ ] ✅ Unauthenticated users cannot access any data

## Common Errors and Solutions

### Error: "Missing or insufficient permissions"

**Cause:** The security rules are blocking the operation.

**Solutions:**
1. Ensure the user is authenticated
2. Verify the user is trying to access their own data
3. Check that all required fields are present and valid
4. Verify the `userId` in the data matches the authenticated user

### Error: "Transaction validation failed"

**Cause:** The transaction data doesn't meet validation requirements.

**Solutions:**
1. Check that `type` is either `'income'` or `'expense'`
2. Verify `category` is in the allowed list
3. Ensure `amount` is between 0.01 and 999,999,999
4. Verify `description` is 1-500 characters
5. Check that `date` and `createdAt` are valid timestamps

### Error: "Cannot change userId"

**Cause:** Trying to update the `userId` field of an existing document.

**Solution:** The `userId` field is immutable. Create a new transaction instead.

## Security Best Practices

### ✅ DO:

- Always authenticate users before allowing access
- Validate all input data on both client and server (rules)
- Use the minimum necessary permissions
- Keep rules simple and maintainable
- Test rules thoroughly before deployment
- Monitor Firestore usage and security events

### ❌ DON'T:

- Never allow public read/write access
- Don't trust client-side validation alone
- Don't expose user IDs or sensitive data in documents
- Don't allow users to modify immutable fields
- Don't skip testing rules in development

## Monitoring and Auditing

### View Rule Violations

1. Go to [Firebase Console](https://console.firebase.google.com/project/mygoals-19463/firestore/usage)
2. Navigate to Firestore → Usage
3. Check for security rule violations

### Enable Audit Logging

1. Go to [GCP Console](https://console.cloud.google.com/logs)
2. Filter for Firestore audit logs
3. Monitor for unauthorized access attempts

## Updating Rules

When adding new features:

1. Update `firestore.rules` file
2. Add validation for new fields
3. Test locally with emulator
4. Deploy to staging/test project first
5. Verify in production
6. Update this documentation

## Version History

### v1.0.0 - October 18, 2025
- Initial rules implementation
- User data protection
- Transaction CRUD with validation
- Goal and Task rules (prepared for future)

## Related Documentation

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore Security Rules Reference](https://firebase.google.com/docs/reference/security/firestore)
- [Testing Security Rules](https://firebase.google.com/docs/rules/unit-tests)

## Support

If you encounter issues with security rules:

1. Check the [Troubleshooting Guide](troubleshooting.md)
2. Review Firebase Console logs
3. Test with the Firebase Emulator
4. Create an issue with detailed error messages
