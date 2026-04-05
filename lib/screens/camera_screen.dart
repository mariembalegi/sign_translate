import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
	const CameraScreen({super.key});

	@override
	State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
	CameraController? controller;
	List<CameraDescription>? cameras;
	bool _loadingCamera = true;
	String _detectedText = '';

	@override
	void initState() {
		super.initState();
		initCamera();
	}

	Future<void> initCamera() async {
		try {
			cameras = await availableCameras();
			if (cameras == null || cameras!.isEmpty) {
				return;
			}

			controller = CameraController(
				cameras!.first,
				ResolutionPreset.medium,
			);
			await controller!.initialize();
		} catch (_) {
			// Keep a graceful fallback UI when camera is unavailable.
		} finally {
			if (mounted) {
				setState(() {
					_loadingCamera = false;
				});
			}
		}
	}

	@override
	void dispose() {
		controller?.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF071329),
			body: SafeArea(
				child: Column(
					children: [
						Padding(
							padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
							child: Row(
								children: [
									IconButton(
										style: IconButton.styleFrom(
											backgroundColor: const Color(0x332A3A58),
										),
										onPressed: () => Navigator.pop(context),
										icon: const Icon(Icons.arrow_back, color: Colors.white),
									),
									const SizedBox(width: 10),
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
											color: const Color(0xFF1F2C44),
											borderRadius: BorderRadius.circular(20),
										),
										child: const Text(
											'IDLE',
											style: TextStyle(
												color: Color(0xFF9FB2D3),
												fontWeight: FontWeight.w700,
											),
										),
									),
								],
							),
						),
						Expanded(
							child: SingleChildScrollView(
								padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
								child: Column(
									children: [
										ClipRRect(
											borderRadius: BorderRadius.circular(20),
											child: AspectRatio(
												aspectRatio: 3 / 4,
												child: _loadingCamera ||
																controller == null ||
																!controller!.value.isInitialized
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
														: CameraPreview(controller!),
											),
										),
										const SizedBox(height: 16),
										Container(
											width: double.infinity,
											padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
											decoration: BoxDecoration(
												color: const Color(0xFF1B2A42),
												borderRadius: BorderRadius.circular(16),
												border: Border.all(color: const Color(0xFF2A3A57)),
											),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													const Text(
														'DETECTED TEXT',
														style: TextStyle(
															color: Color(0xFF8DA3C6),
															fontWeight: FontWeight.w700,
														),
													),
													const SizedBox(height: 10),
													Container(
														width: double.infinity,
														constraints: const BoxConstraints(minHeight: 92),
														decoration: BoxDecoration(
															borderRadius: BorderRadius.circular(14),
															color: const Color(0xFF132137),
														),
														padding: const EdgeInsets.all(14),
														child: Text(
															_detectedText.isEmpty
																	? 'Start detection to see translated text here...'
																	: _detectedText,
															style: TextStyle(
																color: _detectedText.isEmpty
																		? const Color(0xFF6E87AD)
																		: Colors.white,
																fontSize: 16,
															),
														),
													),
													const SizedBox(height: 14),
													SizedBox(
														width: double.infinity,
														child: ElevatedButton.icon(
															style: ElevatedButton.styleFrom(
																backgroundColor: const Color(0xFF3A82F7),
																foregroundColor: Colors.white,
																padding: const EdgeInsets.symmetric(vertical: 14),
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(12),
																),
															),
															onPressed: () {
																setState(() {
																	_detectedText =
																			'Hello, nice to meet you. This is a demo translation output.';
																});
															},
															icon: const Icon(Icons.auto_awesome),
															label: const Text(
																'Start Detection',
																style: TextStyle(fontWeight: FontWeight.w700),
															),
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
		);
	}
}
