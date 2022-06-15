class Owner {
  String id;
  String imageUrl;
  String email;
  final String firstname;
  final String lastname;
  final String mobile;
  final String address;

  Owner({
    this.id = '',
    this.imageUrl = '',
    this.email = '',
    required this.firstname,
    required this.lastname,
    required this.mobile,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'firstName': firstname,
        'lastName': lastname,
        'email': email,
        'contactNumber': mobile,
        'address': address
      };

  static Owner fromJson(Map<String, dynamic> json) => Owner(
        id: json['id'],
        firstname: json['firstName'],
        imageUrl: json['imageUrl'],
        lastname: json['lastName'],
        email: json['email'],
        mobile: json['contactNumber'],
        address: json['address'],
      );
}
