import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/repositories/ai_repository_impl.dart';

class AiViewModel extends ChangeNotifier {
  final AiRepositoryImpl _repository;

  AiViewModel(this._repository);

  bool isLoading = false;
  double downloadProgress = 0.0;
  String statusMessage = "Model not downloaded locally.";
  String? resultOutput;
  File? selectedSourceImage;
  String? localModelPath;

  Future<void> downloadModel(String url, String fileName, String modelName) async {
    isLoading = true;
    downloadProgress = 0.0;
    statusMessage = "Downloading model from Hugging Face...";
    notifyListeners();

    try {
      final file = await _repository.downloadModelWeightsWithProgress(
        repoUrl: url,
        fileName: fileName,
        modelName: modelName,
        onProgress: (received, total) {
          if (total > 0) {
            downloadProgress = received / total;
            statusMessage = "Downloading: ${(downloadProgress * 100).toStringAsFixed(1)}%";
            notifyListeners();
          }
        },
      );
      localModelPath = file.parent.path;
      statusMessage = "Model successfully stored locally at: $localModelPath";
    } catch (e) {
      statusMessage = "Download paused/failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> runTextToImage(String prompt) async {
    if (localModelPath == null) {
      statusMessage = "Please download/load model locally first!";
      notifyListeners();
      return;
    }

    isLoading = true;
    statusMessage = "Running Text-to-Image locally...";
    notifyListeners();

    try {
      resultOutput = await _repository.generateTextToImage(prompt, localModelPath!);
      statusMessage = "Text-to-Image generation complete!";
    } catch (e) {
      statusMessage = "Error during generation: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> runImageToImage(File image, String prompt) async {
    if (localModelPath == null) {
      statusMessage = "Please download/load model locally first!";
      notifyListeners();
      return;
    }

    isLoading = true;
    statusMessage = "Running Image-to-Image locally...";
    notifyListeners();

    try {
      resultOutput = await _repository.generateImageToImage(image, prompt, localModelPath!);
      statusMessage = "Image-to-Image processing complete!";
    } catch (e) {
      statusMessage = "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedImage(File image) {
    selectedSourceImage = image;
    notifyListeners();
  }
}
