import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/generate_image_usecase.dart';

class AiViewModel extends ChangeNotifier {
  final GenerateImageUseCase _useCase;

  AiViewModel(this._useCase);

  bool isLoading = false;
  String statusMessage = "Model not downloaded locally.";
  String? resultOutput;
  File? selectedSourceImage;
  String? localModelPath;

  Future<void> downloadModel(String url, String fileName, String modelName) async {
    isLoading = true;
    statusMessage = "Downloading model from Hugging Face to local phone storage...";
    notifyListeners();

    try {
      final file = await _useCase.cacheModel(url, fileName, modelName);
      localModelPath = file.parent.path;
      statusMessage = "Model stored locally at: $localModelPath";
    } catch (e) {
      statusMessage = "Failed to download model: $e";
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
      resultOutput = await _useCase.executeTextToImage(prompt, localModelPath!);
      statusMessage = "Generation complete!";
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
      resultOutput = await _useCase.executeImageToImage(image, prompt, localModelPath!);
      statusMessage = "Image-to-Image complete!";
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
