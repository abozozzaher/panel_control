class UserData {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String image;

  UserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.image,
  });

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      id: data['id']?.toString() ?? '',
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      image: data['image']?.toString() ?? 'assets/img/user.jpg',
    );
  }
}
