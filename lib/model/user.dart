class UserData {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String image;

  UserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.image,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] ?? 0,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      image: map['image'] ?? '',
    );
  }
}
