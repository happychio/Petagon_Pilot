class Post {
  String id;
  String petID;
  String ownerID;
  final int rating;
  final String title;
  final String description;

  Post({
    this.id = '',
    this.petID = '',
    this.ownerID = '',
    required this.rating,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'postID': id,
        'petID': petID,
        'ownerID': ownerID,
        'rating': rating,
        'title': title,
        'description': description,
      };

  static Post fromJson(Map<String, dynamic> json) => Post(
        id: json['postID'],
        petID: json['petID'],
        ownerID: json['ownerID'],
        rating: json['rating'],
        title: json['title'],
        description: json['description'],
      );
}
