class AppUser {
  final String? uid;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String? type;

  AppUser({this.uid, this.email, this.name, this.photoUrl, this.type});

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      type: data['type'] ?? '',
    );
  }
}
