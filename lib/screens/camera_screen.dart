import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/sign_language_service.dart';

class CameraScreen extends StatefulWidget {
	const CameraScreen({super.key});

	@override
	State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
	// ── Camera ──────────────────────────────────
	CameraController? _controller;
	List<CameraDescription>? _cameras;
	bool _loadingCamera = true;

	// ── Detection state ──────────────────────────
	bool _isDetecting = false;
	bool _isBusy = false;           // prevents concurrent captures
	Timer? _detectionTimer;

	// ── Results ──────────────────────────────────
	String _sentence = '';
	String _currentGesture = '';
	double _confidence = 0.0;
	int _progress = 0;
	bool _handsDetected = false;
	String _statusMsg = '';          // inline error / info message

	final SignLanguageService _service = SignLanguageService();

	// ─────────────────────────────────────────────
	// LIFECYCLE
	// ─────────────────────────────────────────────
	@override
	void initState() {
		super.initState();
		_initCamera();
	}

	@override
	void dispose() {
		_detectionTimer?.cancel();
		_controller?.dispose();
		super.dispose();
	}

	// ─────────────────────────────────────────────
	// CAMERA INIT
	// ─────────────────────────────────────────────
	Future<void> _initCamera() async {
		try {
			_cameras = await availableCameras();
			if (_cameras == null || _cameras!.isEmpty) return;

			_controller = CameraController(
				_cameras!.first,
				ResolutionPreset.medium,
				enableAudio: false,
			);
			await _controller!.initialize();
		} catch (_) {
			// graceful fallback
		} finally {
			if (mounted) setState(() => _loadingCamera = false);
		}
	}

	// ─────────────────────────────────────────────
	// DETECTION CONTROLS
	// ─────────────────────────────────────────────
	Future<void> _startDetection() async {
		if (_isDetecting) return;

		// Reset server buffer
		await _service.resetSession();

		setState(() {
			_isDetecting = true;
			_sentence = '';
			_currentGesture = '';
			_confidence = 0.0;
			_progress = 0;
			_handsDetected = false;
			_statusMsg = '';
		});

		// Capture a frame every 350 ms
		_detectionTimer = Timer.periodic(
			const Duration(milliseconds: 350),
			(_) => _captureAndPredict(),
		);
	}

	void _stopDetection() {
		_detectionTimer?.cancel();
		setState(() {
			_isDetecting = false;
			_isBusy = false;
			_progress = 0;
			_handsDetected = false;
		});
	}

	void _clearText() {
		_service.resetSession();
		setState(() {
			_sentence = '';
			_currentGesture = '';
			_confidence = 0.0;
			_progress = 0;
		});
	}

	// ─────────────────────────────────────────────
	// CAPTURE + PREDICT
	// ─────────────────────────────────────────────
	Future<void> _captureAndPredict() async {
		if (_isBusy ||
				!_isDetecting ||
				_controller == null ||
				!_controller!.value.isInitialized) return;

		_isBusy = true;
		try {
			final xFile = await _controller!.takePicture();
			final bytes = await xFile.readAsBytes();
			final result = await _service.predictFromImage(bytes);

			if (mounted) {
				setState(() {
					_handsDetected = result.handsDetected;
					_progress = result.progress;
					_confidence = result.confidence;
					if (result.gesture.isNotEmpty) _currentGesture = result.gesture;
					if (result.sentence.isNotEmpty) _sentence = result.sentence;
					_statusMsg = '';
				});
			}
		} catch (e) {
			if (mounted) {
				setState(() => _statusMsg = 'Server unreachable. Is the API running?');
			}
			_stopDetection();
		} finally {
			_isBusy = false;
		}
	}

	// ─────────────────────────────────────────────
	// BUILD
	// ─────────────────────────────────────────────
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF071329),
			body: SafeArea(
				child: Column(
					children: [
						_buildHeader(),
						Expanded(
							child: SingleChildScrollView(
								padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
								child: Column(
									children: [
										_buildCameraPreview(),
										const SizedBox(height: 16),
										_buildDetectionPanel(),
									],
								),
							),
						),
					],
				),
			),
		);
	}

	// ── Header ────────────────────────────────────
	Widget _buildHeader() {
		final statusLabel = _isDetecting
				? (_handsDetected ? 'DETECTING' : 'WAITING')
				: 'IDLE';
		final statusColor = _isDetecting
				? (_handsDetected ? const Color(0xFF22C55E) : const Color(0xFFF59E0B))
				: const Color(0xFF9FB2D3);

		return Padding(
			padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
			child: Row(
				children: [
					const Text(
						'Sign to Text',
						style: TextStyle(
						color: Colors.white,
							fontSize: 26,
							fontWeight: FontWeight.w800,
						),
					),
					const Spacer(),
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
						decoration: BoxDecoration(
							color: const Color(0xFF1B2A42),
							borderRadius: BorderRadius.circular(20),
						),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								if (_isDetecting)
									Container(
										width: 8,
										height: 8,
										margin: const EdgeInsets.only(right: 6),
										decoration: BoxDecoration(
											color: statusColor,
											shape: BoxShape.circle,
										),
									),
								Text(
									statusLabel,
									style: TextStyle(
										color: statusColor,
										fontWeight: FontWeight.w700,
									),
								),
							],
						),
					),
				],
			),
		);
	}

	// ── Camera Preview ────────────────────────────
	Widget _buildCameraPreview() {
		return Stack(
			children: [
				ClipRRect(
					borderRadius: BorderRadius.circular(20),
					child: AspectRatio(
						aspectRatio: 3 / 4,
						child: _loadingCamera ||
								_controller == null ||
								!_controller!.value.isInitialized
								? Container(
							color: const Color(0xFF111827),
							child: const Center(
								child: Icon(
									Icons.videocam_off_outlined,
									color: Color(0xFF8AA0C6),
										size: 48,
									),
								),
							)
								: CameraPreview(_controller!),
					),
				),
				// Hand-detected indicator
				if (_isDetecting)
					Positioned(
						top: 12,
						left: 12,
						child: _HandStatusBadge(detected: _handsDetected),
					),
				// Progress bar
				if (_isDetecting)
					Positioned(
						bottom: 0,
						left: 0,
						right: 0,
						child: ClipRRect(
							borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
							child: LinearProgressIndicator(
								value: _progress / 100,
								minHeight: 5,
								backgroundColor: const Color(0x442A3A58),
								valueColor: AlwaysStoppedAnimation<Color>(
									_handsDetected
											? const Color(0xFF3A82F7)
											: const Color(0xFF475569),
								),
							),
						),
					),
			],
		);
	}

	// ── Detection Panel ───────────────────────────
	Widget _buildDetectionPanel() {
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
			decoration: BoxDecoration(
			color: const Color(0xFF1B2A42),
			borderRadius: BorderRadius.circular(16),
			border: Border.all(color: const Color(0xFF243554)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Detected text header
					Row(
						children: [
							const Text(
								'DETECTED TEXT',
								style: TextStyle(
									color: Color(0xFF8DA3C6),
									fontWeight: FontWeight.w700,
								),
							),
							const Spacer(),
							if (_sentence.isNotEmpty && !_isDetecting)
								GestureDetector(
									onTap: _clearText,
									child: const Text(
										'CLEAR',
										style: TextStyle(
											color: Color(0xFF3A82F7),
											fontWeight: FontWeight.w600,
											fontSize: 12,
										),
									),
								),
						],
					),
					const SizedBox(height: 10),

					// Sentence box
					Container(
						width: double.infinity,
						constraints: const BoxConstraints(minHeight: 92),
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(14),
							color: const Color(0xFF132137),
						),
						padding: const EdgeInsets.all(14),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								// Confirmed sentence
								if (_sentence.isNotEmpty)
									Text(
										_sentence,
										style: const TextStyle(
											color: Colors.white,
											fontSize: 18,
											fontWeight: FontWeight.w600,
										),
									),
								// Current gesture while detecting
								if (_isDetecting && _currentGesture.isNotEmpty) ...[
									if (_sentence.isNotEmpty) const SizedBox(height: 8),
									Row(
										children: [
											const Icon(Icons.gesture, color: Color(0xFF3A82F7), size: 15),
											const SizedBox(width: 6),
											Text(
												_currentGesture,
												style: const TextStyle(
													color: Color(0xFF3A82F7),
													fontSize: 15,
													fontStyle: FontStyle.italic,
												),
											),
											const Spacer(),
											Text(
												'${(_confidence * 100).toStringAsFixed(0)}%',
												style: TextStyle(
													color: _confidence > 0.65
															? const Color(0xFF22C55E)
															: const Color(0xFFF59E0B),
													fontWeight: FontWeight.w600,
													fontSize: 13,
												),
											),
										],
									),
								],
								// Placeholder
								if (_sentence.isEmpty && (!_isDetecting || _currentGesture.isEmpty))
									Text(
										_isDetecting
												? 'Show your hands to the camera...'
												: 'Start detection to see translated text here...',
										style: const TextStyle(
										color: Color(0xFF9CA8B9),
											fontSize: 15,
										),
									),
							],
						),
					),

					// Error / info message
					if (_statusMsg.isNotEmpty)
						Padding(
							padding: const EdgeInsets.only(top: 8),
							child: Text(
								_statusMsg,
								style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
							),
						),

					const SizedBox(height: 14),

					// Progress label
					if (_isDetecting)
						Padding(
							padding: const EdgeInsets.only(bottom: 8),
							child: Text(
								_handsDetected
										? 'Collecting frames... $_progress%'
										: 'Show your hands to the camera',
								style: const TextStyle(
									color: Color(0xFF8DA3C6),
									fontSize: 12,
								),
							),
						),

					// Start / Stop button
					SizedBox(
						width: double.infinity,
						child: ElevatedButton.icon(
							style: ElevatedButton.styleFrom(
								backgroundColor: _isDetecting
										? const Color(0xFFEF4444)
										: const Color(0xFF3A82F7),
								foregroundColor: Colors.white,
								padding: const EdgeInsets.symmetric(vertical: 14),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
							),
							onPressed: _loadingCamera
									? null
									: (_isDetecting ? _stopDetection : _startDetection),
							icon: Icon(_isDetecting ? Icons.stop : Icons.play_arrow),
							label: Text(
								_isDetecting ? 'Stop Detection' : 'Start Detection',
								style: const TextStyle(fontWeight: FontWeight.w700),
							),
						),
					),

					// Clear button (shown during active detection too)
					if (_sentence.isNotEmpty && _isDetecting)
						Padding(
							padding: const EdgeInsets.only(top: 8),
							child: SizedBox(
								width: double.infinity,
								child: OutlinedButton.icon(
									style: OutlinedButton.styleFrom(
								foregroundColor: const Color(0xFF8DA3C6),
									side: const BorderSide(color: Color(0xFF243554)),
										padding: const EdgeInsets.symmetric(vertical: 12),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(12),
										),
									),
									onPressed: _clearText,
									icon: const Icon(Icons.clear_all, size: 18),
									label: const Text('Clear Text'),
								),
							),
						),
				],
			),
		);
	}
}

// ─────────────────────────────────────────────
// HAND STATUS BADGE
// ─────────────────────────────────────────────
class _HandStatusBadge extends StatelessWidget {
	final bool detected;

	const _HandStatusBadge({required this.detected});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
			decoration: BoxDecoration(
				color: detected
						? const Color(0xCC052E16)
						: const Color(0xCC1C1917),
				borderRadius: BorderRadius.circular(20),
				border: Border.all(
					color: detected
							? const Color(0xFF22C55E)
							: const Color(0xFF78716C),
				),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(
						detected ? Icons.pan_tool : Icons.pan_tool_outlined,
						color: detected ? const Color(0xFF22C55E) : const Color(0xFF78716C),
						size: 14,
					),
					const SizedBox(width: 5),
					Text(
						detected ? 'Hands detected' : 'No hands',
						style: TextStyle(
							color: detected ? const Color(0xFF22C55E) : const Color(0xFF78716C),
							fontSize: 12,
							fontWeight: FontWeight.w600,
						),
					),
				],
			),
		);
	}
}

