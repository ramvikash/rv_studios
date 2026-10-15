import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/datasources/local_model_service.dart';
import 'data/repositories/ai_repository_impl.dart';
import 'domain/usecases/generate_image_usecase.dart';
import 'presentation/viewmodels/ai_viewmodel.dart';
import 'presentation/views/ai_home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalModelService>(create: (_) => LocalModelService()),
        ProxyProvider<LocalModelService, AiRepositoryImpl>(
          update: (_, localService, __) => AiRepositoryImpl(localService),
        ),
        ProxyProvider<AiRepositoryImpl, GenerateImageUseCase>(
          update: (_, repository, __) => GenerateImageUseCase(repository),
        ),
        ChangeNotifierProvider<AiViewModel>(
          create: (context) => AiViewModel(context.read<GenerateImageUseCase>()),
        ),
      ],
      child: MaterialApp(
        title: 'HF Local AI App',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const AiHomeView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
