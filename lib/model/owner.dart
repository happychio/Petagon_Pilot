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
}
