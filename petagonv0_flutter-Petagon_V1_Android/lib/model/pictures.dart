class Pictures {
  String id;
  String petID;
  String ownerID;
  String imageUrl;
  Pictures({
    this.id = '',
    this.petID = '',
    this.ownerID = '',
    this.imageUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'picID': id,
        'petID': petID,
        'ownerID': ownerID,
        'imageUrl': imageUrl,
      };

  static Pictures fromJson(Map<String, dynamic> json) => Pictures(
        id: json['picID'],
        petID: json['petID'],
        ownerID: json['ownerID'],
        imageUrl: json['imageUrl'],
      );
}
