class Pet {
  String id;
  String ownerID;
  String imageUrl;
  int age;
  final String petName;
  final String petKind;
  final String petBreed;
  final String petGender;
  final String petDOB;

  Pet({
    this.id = '',
    this.ownerID = '',
    this.imageUrl = '',
    this.age = 0,
    required this.petName,
    required this.petKind,
    required this.petBreed,
    required this.petGender,
    required this.petDOB,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerID': ownerID,
        'imageUrl': imageUrl,
        'age': age,
        'Name': petName,
        'Kind': petKind,
        'Breed': petBreed,
        'Gender': petGender,
        'DateOfBirth': petDOB
      };

  static Pet fromJson(Map<String, dynamic> json) => Pet(
      id: json['id'],
      ownerID: json['ownerID'],
      imageUrl: json['imageUrl'],
      age: json['age'],
      petName: json['Name'],
      petKind: json['Kind'],
      petBreed: json['Breed'],
      petGender: json['Gender'],
      petDOB: json['DateOfBirth']);
}
