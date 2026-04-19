import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/sign_language_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, this.initialText = ''});
  final String initialText;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _controller;
  final _service = SignLanguageService();

  bool _loading = false;
  String? _errorMessage;
  VideoPlayerController? _videoController;

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

  Future<void> _translate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _videoController?.dispose();
      _videoController = null;
    });
    try {
      final videoUrl = await _service.textToSign(text);
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      if (mounted) {
        setState(() {
          _videoController = controller;
          _loading = false;
        });
      }
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
