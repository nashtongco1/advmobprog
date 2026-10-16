class User {
  final int id;
  final String firebaseUid;
  final String loginType;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int age;
  final String contactNo;
  final String gender;
  final String image;
  final String accessToken;
  final String refreshToken;

  const User({
    required this.id,
    required this.firebaseUid,
    required this.loginType,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.contactNo,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
  });

  String get fullName {
    final name =
        '$firstName $lastName'.trim();

    return name.isEmpty
        ? username
        : name;
  }

  bool get isFirebase =>
      loginType == 'firebase';

  bool get isDummyJson =>
      loginType == 'dummyjson';

  factory User.fromJson(
    Map<String, dynamic> json,
  ) {
    return User(
      id: json['id'] ?? 0,
      firebaseUid:
          json['firebaseUid'] ?? '',
      loginType:
          json['loginType'] ?? '',
      username:
          json['username'] ?? '',
      email:
          json['email'] ??
          json['emailAddress'] ??
          '',
      firstName:
          json['firstName'] ??
          json['fName'] ??
          '',
      lastName:
          json['lastName'] ??
          json['lName'] ??
          '',
      age: json['age'] ?? 0,
      contactNo:
          json['contactNo'] ??
          json['phone'] ??
          '',
      gender:
          json['gender'] ?? '',
      image:
          json['image'] ?? '',
      accessToken:
          json['accessToken'] ??
          json['token'] ??
          '',
      refreshToken:
          json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'loginType': loginType,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'contactNo': contactNo,
      'gender': gender,
      'image': image,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}