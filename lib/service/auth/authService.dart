import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartseed/model/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Convert Firebase Welcome+Regis to AppUser
  AppUser? _userFromFirebase(User? user) {
    return user != null
        ? AppUser(
            uid: user.uid,
            email: user.email,
            name: user.displayName,
            photoUrl: user.photoURL,
            type: "user",
          )
        : null;
  }

  // Stream for Welcome+Regis state changes
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  // Fetch user type by UID (parent or kid)
  Future<String?> getUserTypeByUID(String uid) async {
    try {
      DocumentSnapshot parentDoc =
          await _firestore.collection('parents').doc(uid).get();
      if (parentDoc.exists) return "parent";

      DocumentSnapshot kidDoc =
          await _firestore.collection('kids').doc(uid).get();
      if (kidDoc.exists) return "kid";

      return null;
    } catch (e) {
      print("Error fetching user type: $e");
      return null;
    }
  }

  // Get user data by UID
  Future<Map<String, dynamic>?> getUserByUID(String uid) async {
    try {
      String? userType = await getUserTypeByUID(uid);
      if (userType == "parent") {
        DocumentSnapshot parentDoc =
            await _firestore.collection('parents').doc(uid).get();
        return parentDoc.exists
            ? parentDoc.data() as Map<String, dynamic>
            : null;
      } else if (userType == "kid") {
        DocumentSnapshot kidDoc =
            await _firestore.collection('kids').doc(uid).get();
        return kidDoc.exists ? kidDoc.data() as Map<String, dynamic> : null;
      } else {
        print("Welcome+Regis not found in parent or kid collections.");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Sign in with email and password (Both Parent & Kid)
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register Parent with Email and Password
  Future<User?> registerParent(String fullName, String email, String password,
      String phone, String relationship) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('parents').doc(user.uid).set({
          'parent_id': user.uid,
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'relationship': relationship,
          'screen_time_limit': null, // Default to null
          'notification_preferences': '',
          'subscription_plan': 'Free',
          'created_at': FieldValue.serverTimestamp(),
        });
        return user;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register Kid with Parent's Email
  Future<User?> registerKid(
      String firstName,
      int birthYear,
      String gradeLevel,
      String email,
      String parentEmail,
      String password,
      String mothertongue,
      String parentPassword) async {
    try {
      // Get the currently logged-in user (Parent)
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        print("Error: No parent user is currently logged in.");
        return null;
      }

      String parentUid = currentUser.uid;

      // Ensure that the provided parent email matches the logged-in parent's email
      if (currentUser.email != parentEmail) {
        print(
            "Error: Provided parent email does not match the logged-in parent.");
        print("Logged-in parent: ${currentUser.email}, Provided: $parentEmail");
        return null;
      }

      // Check if the kid's email already exists
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        print("Error: Email is already in use.");
        return null;
      }

      // Verify parent's email exists in Firestore
      QuerySnapshot parentSnapshot = await _firestore
          .collection('parents')
          .where('email', isEqualTo: parentEmail)
          .limit(1)
          .get();

      if (parentSnapshot.docs.isEmpty) {
        print("Error: Parent email not found.");
        return null;
      }

      String parentId = parentSnapshot.docs.first.id;

      // Create the kid's account
      UserCredential kidCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? kidUser = kidCredential.user;

      if (kidUser != null) {
        // Store kid details in Firestore
        await _firestore.collection('kids').doc(kidUser.uid).set({
          'kid_id': kidUser.uid,
          'parent_id': parentId,
          'first_name': firstName,
          'email': email,
          'coins': 0,
          'birth_year': birthYear,
          'grade_level': gradeLevel,
          'learning_preferences': '',
          'avatar': null,
          'mothertongue': mothertongue,
          'skill_level': 'Beginner',
          'preferred_learning_pace': 'Moderate',
          'created_at': FieldValue.serverTimestamp(),
          'progress': {
            'completed_lessons': 0,
            'total_lessons': 20,
            'current_lesson': 1,
            'last_activity': null,
          },
          'achievements': [],
          'performance': {
            'average_score': 0,
            'quiz_attempts': 0,
            'last_quiz_score': 0,
          },
          "unlocked_stories": [],
        });

        // ✅ LOG OUT THE KID BEFORE SWITCHING BACK TO PARENT ACCOUNT
        await _auth.signOut();
        print("Signed out from kid's account.");

        // ✅ SIGN BACK INTO PARENT ACCOUNT
        try {
          UserCredential parentCredential =
              await _auth.signInWithEmailAndPassword(
            email: parentEmail,
            password: parentPassword,
          );

          print(
              "Switched back to parent account: ${parentCredential.user?.email}");
        } catch (signInError) {
          print("Error signing back into parent account: $signInError");
          return null;
        }

        return kidUser;
      }

      return null;
    } catch (e) {
      print("Error registering kid: $e");
      return null;
    }
  }

  // Get Parent by UID

  // Get Kid Data by Parent ID
  Future<List<Map<String, dynamic>>> getKidsByParentID(String parentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('kids')
          .where('parent_id', isEqualTo: parentId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching kids: $e");
      return [];
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
