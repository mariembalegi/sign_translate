import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
	const ResultScreen({super.key, this.initialText = ''});

	final String initialText;

	@override
	State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
	late final TextEditingController _controller;
	String _output = '';

	@override
	void initState() {
		super.initState();
		_controller = TextEditingController(text: widget.initialText);
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF2F5FA),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									IconButton(
										onPressed: () => Navigator.pop(context),
										icon: const Icon(Icons.arrow_back),
									),
									const SizedBox(width: 6),
									const Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'Text to Sign',
												style: TextStyle(
													fontSize: 29,
													fontWeight: FontWeight.w800,
													color: Color(0xFF212B3D),
												),
											),
											Text(
												'ASL - American Sign Language',
												style: TextStyle(
													color: Color(0xFF98A4B5),
													fontWeight: FontWeight.w600,
												),
											),
										],
									),
									const Spacer(),
									const Icon(Icons.info_outline, color: Color(0xFF7E8798)),
								],
							),
							const SizedBox(height: 14),
							Expanded(
								child: SingleChildScrollView(
									child: Column(
										children: [
											Container(
												padding: const EdgeInsets.all(14),
												decoration: BoxDecoration(
													color: Colors.white,
													borderRadius: BorderRadius.circular(20),
													border: Border.all(color: const Color(0xFFE8EDF4)),
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
																fillColor: const Color(0xFFF6F8FC),
																border: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(14),
																	borderSide: BorderSide.none,
																),
															),
															onChanged: (_) => setState(() {}),
														),
														const SizedBox(height: 10),
														Wrap(
															spacing: 8,
															runSpacing: 8,
															children: [
																'Hello, nice to meet you',
																'Thank you very much',
																'How are you today?',
															]
																	.map(
																		(sample) => ActionChip(
																			backgroundColor: const Color(0xFFEFF5FF),
																			labelStyle: const TextStyle(
																				color: Color(0xFF4A8AFB),
																				fontWeight: FontWeight.w700,
																			),
																			onPressed: () {
																				setState(() {
																					_controller.text = sample;
																				});
																			},
																			label: Text(sample),
																		),
																	)
																	.toList(),
														),
													],
												),
											),
											const SizedBox(height: 14),
											Row(
												children: [
													Expanded(
														child: Container(
															padding: const EdgeInsets.all(14),
															decoration: BoxDecoration(
																color: Colors.white,
																borderRadius: BorderRadius.circular(16),
																border: Border.all(color: const Color(0xFFE8EDF4)),
															),
															child: const Row(
																children: [
																	Icon(Icons.g_translate,
																			color: Color(0xFF667085)),
																	SizedBox(width: 10),
																	Text(
																		'English',
																		style: TextStyle(
																			fontWeight: FontWeight.w700,
																			color: Color(0xFF344054),
																		),
																	),
																],
															),
														),
													),
													const SizedBox(width: 10),
													Container(
														width: 48,
														height: 48,
														decoration: const BoxDecoration(
															shape: BoxShape.circle,
															color: Color(0xFF3A82F7),
														),
														child: const Icon(Icons.arrow_forward,
																color: Colors.white),
													),
													const SizedBox(width: 10),
													Expanded(
														child: Container(
															padding: const EdgeInsets.all(14),
															decoration: BoxDecoration(
																color: Colors.white,
																borderRadius: BorderRadius.circular(16),
																border: Border.all(color: const Color(0xFFE8EDF4)),
															),
															child: const Row(
																children: [
																	Icon(Icons.sign_language,
																			color: Color(0xFF34C38F)),
																	SizedBox(width: 10),
																	Text(
																		'ASL',
																		style: TextStyle(
																			fontWeight: FontWeight.w700,
																			color: Color(0xFF344054),
																		),
																	),
																],
															),
														),
													),
												],
											),
											const SizedBox(height: 14),
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
													onPressed: _controller.text.trim().isEmpty
															? null
															: () {
																	setState(() {
																		_output =
																				'Sign animation generated for: "${_controller.text}"';
																	});
																},
													icon: const Icon(Icons.bolt_rounded),
													label: const Text(
														'Translate to Sign',
														style: TextStyle(fontWeight: FontWeight.w800),
													),
												),
											),
											const SizedBox(height: 14),
											Container(
												width: double.infinity,
												padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
												decoration: BoxDecoration(
													color: const Color(0xFFEAF9F2),
													borderRadius: BorderRadius.circular(16),
													border: Border.all(color: const Color(0xFFC8EDD9)),
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
														Container(
															width: double.infinity,
															constraints: const BoxConstraints(minHeight: 88),
															decoration: BoxDecoration(
																borderRadius: BorderRadius.circular(12),
																color: Colors.white,
															),
															padding: const EdgeInsets.all(12),
															child: Text(
																_output.isEmpty
																		? 'Your generated sign output will appear here.'
																		: _output,
																style: TextStyle(
																	color: _output.isEmpty
																			? const Color(0xFF8B98A8)
																			: const Color(0xFF2B3648),
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
			),
		);
	}
}
