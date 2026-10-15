import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ai_viewmodel.dart';

class AiHomeView extends StatefulWidget {
  const AiHomeView({super.key});

  @override
  State<AiHomeView> createState() => _AiHomeViewState();
}

class _AiHomeViewState extends State<AiHomeView> {
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AiViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('RV Studio v1.0')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        compression: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(viewModel.statusMessage, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      // Example Hugging Face file URL (Replace with your target ONNX/TFLite model file URL)
                      viewModel.downloadModel(
                        "https://huggingface.co/Llama-3-Instruct-Model-Weights-Sample/resolve/main/model.tflite",
                        "model.tflite",
                        "stable_diffusion_tiny",
                      );
                    },
              child: const Text('Download & Store Model Locally'),
            ),
            const Divider(height: 32),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(labelText: 'Enter Generation Prompt', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      viewModel.runTextToImage(_promptController.text);
                    },
              child: const Text('Generate Text-to-Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        File file = File(image.path);
                        viewModel.setSelectedImage(file);
                        viewModel.runImageToImage(file, _promptController.text);
                      }
                    },
              child: const Text('Pick Image & Run Image-to-Image'),
            ),
            const SizedBox(height: 24),
            // if (viewModel.isLoading) const Center(child: CircularProgressIndicator()),

            // Inside your download button section of AiHomeView:
            if (viewModel.isLoading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: viewModel.downloadProgress),
            const SizedBox(height: 8),
            Text(
                "${(viewModel.downloadProgress * 100).toStringAsFixed(1)}% downloaded", textAlign: TextAlign.center,),
            ],
            if (viewModel.resultOutput != null) ...[
              const Text('Result Output / Path:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade200,
                child: Text(viewModel.resultOutput!),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
