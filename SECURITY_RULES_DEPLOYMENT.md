# Firestore Security Rules Deployment

Do not deploy the strict rules until the app has at least one active admin user document.

## Preflight

1. Back up the existing Firestore rules from Firebase Console before changing anything.
2. Verify an admin exists in `users/{uid}`.
3. Confirm the admin document has:
   - `role: admin`
   - `status: active`
   - a complete `permissions` map
4. Open Staff & Roles in the app.
5. Run **Backfill Missing Permissions** before deploying.
6. Confirm the app reports updated/skipped users and no critical errors.

## Deploy Manually

```bash
firebase deploy --only firestore:rules
```

If the Firebase CLI has no active project selected, use:

```bash
firebase deploy --only firestore:rules --project classes-management-pro
```

This repository's `firebase.json` also contains FlutterFire metadata under the `flutter` key. If your Firebase CLI version rejects that metadata during deploy, use a temporary Firebase CLI config that contains only:

```json
{
  "firestore": {
    "rules": "firestore.rules"
  }
}
```

Then deploy with:

```bash
firebase deploy --config path/to/firebase.rules.json --only firestore:rules --project classes-management-pro
```

## Bootstrap / Lockout Warning

These rules depend on `users/{request.auth.uid}`. If no active admin document exists before deployment, first-admin auto bootstrap can be blocked.

If you get locked out:

1. Temporarily relax Firestore rules from Firebase Console.
2. Fix or create `users/{uid}` with `role: admin`, `status: active`, and a complete permissions map.
3. Run **Backfill Missing Permissions** again.
4. Redeploy the strict rules.
