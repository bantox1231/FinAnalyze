import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_selector/file_selector.dart';

class PlatformService {
  static Future<http.MultipartFile> createMultipartFile(XFile file) async {
    return http.MultipartFile.fromPath(
      'files',
      file.path,
      contentType: MediaType('application', 'pdf'),
    );
  }
} 