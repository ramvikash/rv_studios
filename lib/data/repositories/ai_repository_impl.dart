import 'dart:io';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/local_model_service.dart';

class AiRepositoryImpl implements AiRepository {
  final LocalModelService _localModelService;

  AiRepositoryImpl(this._localModelService);

  @override
  Future<File> downloadModelWeights(String repoUrl, String fileName, String modelName) {
    throw UnimplementedError("Use downloadModelWeightsWithProgress instead");
  }

  Future<File> downloadModelWeightsWithProgress({
    required String repoUrl,
    required String fileName,
    required String modelName,
    required Function(int received, int total) onProgress,
  }) async {
    return await _localModelService.downloadModelWithProgress(
      url: repoUrl,
      fileName: fileName,
      modelName: modelName,
      onProgress: onProgress,
    );
  }

  @override
  Future<String> generateTextToImage(String prompt, String localModelPath) async {
    await Future.delayed(const Duration(seconds: 3));
    return "Generated Text-to-Image Result using model at: $localModelPath";
  }

  @override
  Future<String> generateImageToImage(File inputImage, String prompt, String localModelPath) async {
    await Future.delayed(const Duration(seconds: 3));
    return "Generated Image-to-Image Result based on ${inputImage.path}";
  }
}
