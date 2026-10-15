import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class LocalModelService {
  final Dio _dio = Dio();

  Future<String> getModelLocalStoragePath(String modelName) async {
    final directory = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${directory.path}/huggingface_models/$modelName');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return modelDir.path;
  }

  Future<File> downloadAndStoreFile(String url, String fileName, String modelName) async {
    final basePath = await getModelLocalStoragePath(modelName);
    final filePath = '$basePath/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      return file; // Return cached model file locally
    }

    // Download from Hugging Face repository link
    await _dio.download(url, filePath);
    return file;
  }
}
