import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/sign_language_service.dart';
import '../services/storage_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, this.initialText = ''});
  final String initialText;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _controller;
  final _service = SignLanguageService();
  final _storage = StorageService();

  bool _loading = false;
  String? _errorMessage;
  VideoPlayerController? _videoController;
  int _playingIndex = 0;
  List<String> _playlist = const [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _openServerSettings() async {
    final current = _storage.getServerUrl();
    final ctrl = TextEditingController(text: current.isEmpty ? _service.baseUrl : current);

    final saved = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Serveur API'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'Ex: http://10.0.2.2:8000',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (saved == null) return;
    await _storage.setServerUrl(saved);
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _playPlaylist(List<String> sources) async {
    _videoController?.dispose();
    _videoController = null;
    _playlist = sources;
    _playingIndex = 0;

    if (sources.isEmpty) {
      throw Exception('Aucun mot détecté dans le texte.');
    }

    await _startSource(sources.first);
  }

  Future<void> _startSource(String source) async {
    final controller = source.startsWith('asset://')
        ? VideoPlayerController.asset(source.replaceFirst('asset://', ''))
        : VideoPlayerController.networkUrl(Uri.parse(source));
    await controller.initialize();
    controller.setLooping(false);
    controller.play();

    void listener() {
      final v = controller.value;
      if (!v.isInitialized) return;
      final ended = v.duration.inMilliseconds > 0 &&
          v.position.inMilliseconds >= v.duration.inMilliseconds - 120;
      if (!ended) return;

      controller.removeListener(listener);
      controller.pause();
      _goNext();
    }

    controller.addListener(listener);

    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _videoController = controller);
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final nextIndex = _playingIndex + 1;
    if (nextIndex >= _playlist.length) {
      // Fin: on boucle sur la dernière vidéo (plus agréable pour l’utilisateur)
      final ctrl = _videoController;
      if (ctrl != null) {
        ctrl.setLooping(true);
        ctrl.play();
      }
      return;
    }

    setState(() => _playingIndex = nextIndex);
    final nextSource = _playlist[nextIndex];
    _videoController?.dispose();
    _videoController = null;
    await _startSource(nextSource);
  }

  Future<void> _translate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _videoController?.dispose();
      _videoController = null;
      _playlist = const [];
      _playingIndex = 0;
    });
    try {
      final urls = await _service.textToSignSequence(text);
      await _playPlaylist(urls);
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071329),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────
              Row(
                children: [
                  const SizedBox(width: 6),
                  const Text(
                    'Text to Sign',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Serveur',
                    onPressed: _openServerSettings,
                    icon: const Icon(Icons.settings, color: Color(0xFFB4BECC)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ── Text input ───────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A42),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF243554)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.title, color: Color(0xFFB4BECC)),
                                const SizedBox(width: 10),
                                const Text(
                                  'Enter text to translate',
                                  style: TextStyle(
                                    color: Color(0xFF8C96A8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_controller.text.length}/200',
                                  style: const TextStyle(color: Color(0xFFAFB9C8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _controller,
                              cursorColor: Colors.white,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLength: 200,
                              maxLines: 3,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'Type your message here...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA8B9),
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF132137),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // ── Translate button ─────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _controller.text.trim().isEmpty
                                ? const Color(0xFFC7CCD6)
                                : const Color(0xFF3A82F7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: (_controller.text.trim().isEmpty || _loading)
                              ? null
                              : _translate,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.bolt_rounded),
                          label: Text(
                            _loading ? 'Generating...' : 'Translate to Sign',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // ── Error message ────────────────
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDED),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFB3B3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFFD32F2F)),
                          ),
                        ),
                      // ── Video output ─────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A42),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF243554)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.ondemand_video,
                                    color: Color(0xFF2EAF7D), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Sign Language Output',
                                  style: TextStyle(
                                    color: Color(0xFF2EAF7D),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_videoController != null &&
                                _videoController!.value.isInitialized)
                              Column(
                                children: [
                                  if (_playlist.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.queue_play_next,
                                              color: Color(0xFF8DA3C6), size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Mot ${_playingIndex + 1}/${_playlist.length}',
                                            style: const TextStyle(
                                              color: Color(0xFF8DA3C6),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: AspectRatio(
                                      aspectRatio:
                                          _videoController!.value.aspectRatio,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _videoController!.value.isPlaying
                                                ? _videoController!.pause()
                                                : _videoController!.play();
                                          });
                                        },
                                        icon: Icon(
                                          _videoController!.value.isPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: const Color(0xFF2EAF7D),
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            else
                              Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(minHeight: 88),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFF132137),
                                ),
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Your sign language video will appear here.',
                                  style: TextStyle(color: Color(0xFF8DA3C6)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
