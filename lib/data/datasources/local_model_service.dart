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

  Future<File> downloadModelWithProgress({
    required String url,
    required String fileName,
    required String modelName,
    required Function(int received, int total) onProgress,
  }) async {
    final basePath = await getModelLocalStoragePath(modelName);
    final filePath = '$basePath/$fileName';
    final file = File(filePath);

    int existingFileSize = 0;
    if (await file.exists()) {
      existingFileSize = await file.length();
    }

    try {
      // Request download with range headers to support resuming if partially downloaded
      Options options = Options(
        headers: existingFileSize > 0 ? {'Range': 'bytes=$existingFileSize-'} : {},
        responseType: ResponseType.stream,
      );

      final response = await _dio.get<ResponseBody>(url, options: options);
      
      // Handle server content length properly
      final totalHeader = response.headers.value(Headers.contentLengthHeader);
      final int serverFileSize = totalHeader != null ? int.parse(totalHeader) : 0;
      final int totalFilesize = serverFileSize + existingFileSize;

      // Open file in write-append mode if resuming, else write mode
      final IOSink sink = file.openWrite(mode: existingFileSize > 0 ? FileMode.append : FileMode.write);
      
      int downloaded = existingFileSize;

      await response.data?.stream.forEach((chunk) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (totalFilesize > 0) {
          onProgress(downloaded, totalFilesize);
        }
      });

      await sink.flush();
      await sink.close();
      return file;
    } catch (e) {
      throw Exception("Download paused or failed: $e");
    }
  }
}
