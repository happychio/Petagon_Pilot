class Documents {
  String id;
  String fileSrc;
  String dateUploaded;
  String petID;
  String ownerID;
  String filePath;
  bool isVerified;
  final String fileType;

  Documents({
    this.id = '',
    this.fileSrc = '',
    this.dateUploaded = '',
    this.petID = '',
    this.ownerID = '',
    this.filePath = '',
    this.isVerified = false,
    required this.fileType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'srcFile': fileSrc,
        'dateUploaded': dateUploaded,
        'petID': petID,
        'ownerID': ownerID,
        'filePath': filePath,
        'isVerified': isVerified,
        'documentType': fileType
      };

  static Documents fromJson(Map<String, dynamic> json) => Documents(
        id: json['id'],
        fileSrc: json['srcFile'],
        dateUploaded: json['dateUploaded'],
        petID: json['petID'],
        ownerID: json['ownerID'],
        filePath: json['filePath'],
        isVerified: json['isVerified'],
        fileType: json['documentType'],
      );
}
