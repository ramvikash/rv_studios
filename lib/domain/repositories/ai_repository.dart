import 'dart:io';

abstract class AiRepository {
  Future<File> downloadModelWeights(String repoUrl, String fileName, String modelName);
  Future<String> generateTextToImage(String prompt, String localModelPath);
  Future<String> generateImageToImage(File inputImage, String prompt, String localModelPath);
}
