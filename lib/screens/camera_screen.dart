import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String detectedGesture = '';
  bool isDetecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caméra'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Espace réservé pour le widget caméra
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Caméra en attente...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Zone d'affichage des résultats
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Geste détecté :',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    detectedGesture.isEmpty
                        ? 'En attente de détection...'
                        : detectedGesture,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: detectedGesture.isEmpty
                          ? Colors.grey
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Boutons actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isDetecting = !isDetecting;
                    });
                  },
                  icon: Icon(isDetecting ? Icons.pause : Icons.play_arrow),
                  label: Text(isDetecting ? 'Pause' : 'Démarrer'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      detectedGesture = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Réinitialiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
