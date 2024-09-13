class UserData {
  String id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String image;
  bool work;
  bool admin;

  UserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.image,
    required this.work,
    required this.admin,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'image': image,
      'work': work,
      'admin': admin,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      id: data['id']?.toString() ?? '',
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      image: data['image']?.toString() ?? 'assets/img/user.png',
      work: data['work']!.toString() == 'true' ? true : false,
      admin: data['admin']!.toString() == 'true' ? true : false,
    );
  }
}
