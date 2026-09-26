import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('Firebase initialization error: $e\n$stack');
    initError = e;
  }

  if (initError != null) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Invoxa',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Initialization Error',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$initError',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tip: If you are running on Windows, Firebase is currently configured for Web and Android. Run on Chrome or Edge (e.g. flutter run -d chrome).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const InvoxaApp(),
    ),
  );
}

class InvoxaApp extends StatelessWidget {
  const InvoxaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Invoxa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
