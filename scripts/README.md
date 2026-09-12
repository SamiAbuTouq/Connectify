# Connectify Database Seed Scripts

This folder contains the Firestore seeding script for the **Connectify** app.

## Prerequisites

1. Node.js (v16+) installed.
2. A Firebase Service Account Key for project `connectify-4f06d`.
   - Go to [Firebase Console](https://console.firebase.google.com/) -> **Project Settings** -> **Service Accounts**.
   - Click **Generate New Private Key** and save the JSON file (e.g. as `scripts/serviceAccountKey.json` or root `serviceAccountKey.json`).

> **Security Note:** Never commit `serviceAccountKey.json` to version control. Add it to `.gitignore`.

---

## Setup

Navigate to the `scripts` directory and install dependencies:

```bash
cd scripts
npm install
```

---

## Running the Seed Script

### 1. Default (if `serviceAccountKey.json` is in `scripts/` or workspace root):
```bash
node seed.js
```

### 2. Specifying a custom key path via flag:
```bash
node seed.js --key=C:/path/to/serviceAccountKey.json
```

### 3. Specifying key via Environment Variable:
**PowerShell:**
```powershell
$env:SERVICE_ACCOUNT_KEY="C:\path\to\serviceAccountKey.json"
node seed.js
```

**Bash/Zsh:**
```bash
export SERVICE_ACCOUNT_KEY="/path/to/serviceAccountKey.json"
node seed.js
```

---

## Additional Options

- **Clean and Re-seed (Idempotent):**
  Deletes any documents previously created with `isDummy: true` before inserting fresh records:
  ```bash
  node seed.js --clean
  ```

- **Cleanup Only:**
  Deletes all dummy test documents without adding new ones:
  ```bash
  node seed.js --clean-only
  ```
