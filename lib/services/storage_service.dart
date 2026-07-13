import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../core/constants/cloudinary_config.dart';

class StorageService {
  late final CloudinaryPublic _cloudinary;

  StorageService() {
    _cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName,
      CloudinaryConfig.uploadPreset,
    );
  }

  Future<String> uploadReportPhoto({
    required String reportId,
    required File file,
  }) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        folder: 'reports',
        publicId: reportId,
      ),
    );
    return response.secureUrl;
  }
}
