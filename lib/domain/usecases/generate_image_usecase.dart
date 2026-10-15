import 'dart:io';
import '../repositories/ai_repository.dart';

class GenerateImageUseCase {
  final AiRepository repository;

  GenerateImageUseCase(this.repository);

  Future<File> cacheModel(String url, String file, String model) {
    return repository.downloadModelWeights(url, file, model);
  }

  Future<String> executeTextToImage(String prompt, String modelPath) {
    return repository.generateTextToImage(prompt, modelPath);
  }

  Future<String> executeImageToImage(File image, String prompt, String modelPath) {
    return repository.generateImageToImage(image, prompt, modelPath);
  }
}
