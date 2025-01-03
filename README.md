![file-storage-app2](https://github.com/user-attachments/assets/03331ff8-ea5a-4a62-9316-83d53818fe8a)
## ⚠️Important

I have removed the `firebase_options.json` file , `.env` file and other credentials linked with this repo,
you need to initialize the app with your firebase project to test this app.

- make sure you initialize your own firebase project
  follow the steps shown in the video
  - like firebase login
  - fluttercli initialize
  - flutterfire configure
  - this will create and add the required files.
- and use your own cloudinary account for api and secret keys.
  the `.env` will be in the root of the folders.

```bash
CLOUDINARY_CLOUD_NAME="******"
CLOUDINARY_API_KEY="*****"
CLOUDINARY_SECRET_KEY="*****************"
```

Replace with your actual keys and create .env file.

## 🔥 Firebase Rules

use this rules to restrict only the current user to read and write in cloud firestore of specific user doc.
*copy from below or get [it here.](https://github.com/Snehasis4321/flutter_cloudinary_file_upload/blob/master/firebase_rules.txt)*

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Match the 'user-files' collection
    match /user-files/{userId} {
      // Allow access only if the user is authenticated and their UID matches the document ID
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Match any nested collections within the user's document
      match /{subCollection=**} {
        // Apply the same rule for nested collections
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## ⚒️Tools used

- firebase auth for authentication
- firebase cloud firestore for database storage
- cloudinary for file storage

## 🔗 Useful Links -

- [Cloudinary Api Docs Link](https://cloudinary.com/documentation/image_upload_api_reference)
- [Firebase Cli Setup](https://firebase.google.com/docs/cli)

## 😃 Authors -

<img style="width: 50px; height: 50px; border-radius: 50%;" src="https://avatars.githubusercontent.com/u/96995340" alt="snehasis4321"></img>
[snehasis4321](https://github.com/Snehasis4321)
