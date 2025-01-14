import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/services/cloudinary_service.dart';

class DbService {
  User? user = FirebaseAuth.instance.currentUser;

  // save files links to firestore
  Future<void> saveUploadedFilesData(Map<String, String> data) async {
    return FirebaseFirestore.instance
        .collection("users-img")
        .doc(user!.uid)
        .set(data);
  }

  // read uploaded photo
  Future<Map<String, String>> readUploadedPhoto() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("user-img")
        .doc(user!.uid)
        .get();

    if (snapshot.exists) {
      return Map<String, String>.from(snapshot.data() as Map);
    } else {
      return {}; // return empty map if document doesn't exist
    }
  }

  // delete a specific document
  Future<bool> deleteFile(String docId, String publicId) async {
    // Delete file from Cloudinary
    final result = await deleteFromCloudinary(publicId);

    if (result) {
      // Update Firestore to delete the file link
      await FirebaseFirestore.instance
          .collection("user-img")
          .doc(user!.uid)
          .update({
        "uploads.$docId": FieldValue.delete(), // Delete the specific file field
      });

      return true;
    }
    return false;
  }
}
