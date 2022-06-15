// ignore_for_file: avoid_print
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PDFApi {
  static Future<File> loadNetwork(String srcFile) async {
    final Uri url = Uri.parse(srcFile);
    final response = await http.get(url);
    final bytes = response.bodyBytes;
    return _storeFile(srcFile, bytes);
  }

  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<File?> loadFirebase(String url) async {
    try {
      final refPDF = FirebaseStorage.instance.ref().child(url);
      final bytes = await refPDF.getData();

      return _storeFile(url, bytes!);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
