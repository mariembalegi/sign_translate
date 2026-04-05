import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'camera_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  
  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TranslationProvider _translationProvider;
  
  @override
  void initState() {
    super.initState();
    _translationProvider = context.read<TranslationProvider>();
  }
  
  @override
  Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: [
					_TopBar(),
					Expanded(
						child: SingleChildScrollView(
							padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
							child: Center(
								child: ConstrainedBox(
									constraints: const BoxConstraints(maxWidth: 480),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Container(
												decoration: BoxDecoration(
													borderRadius: BorderRadius.circular(24),
													gradient: const LinearGradient(
														colors: [Color(0xFF4A8AFB), Color(0xFF2E63D9)],
														begin: Alignment.topLeft,
														end: Alignment.bottomRight,
													),
												),
												padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														const Text(
															"TODAY'S HIGHLIGHT",
															style: TextStyle(
																color: Colors.white70,
																fontSize: 12,
																fontWeight: FontWeight.w700,
																letterSpacing: 0.6,
															),
														),
														const SizedBox(height: 8),
														const Text(
															'Translate sign language\nin real-time',
															style: TextStyle(
																color: Colors.white,
																fontSize: 31,
																height: 1.1,
																fontWeight: FontWeight.w800,
															),
														),
														const SizedBox(height: 16),
														ElevatedButton(
															style: ElevatedButton.styleFrom(
																backgroundColor: Colors.white,
																foregroundColor: const Color(0xFF2E63D9),
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(14),
																),
															),
															onPressed: () {
																Navigator.push(
																	context,
																	MaterialPageRoute(
																		builder: (_) => const CameraScreen(),
																	),
																);
															},
															child: const Text(
																'Get Started',
																style: TextStyle(fontWeight: FontWeight.w700),
															),
														),
													],
												),
											),
											const SizedBox(height: 26),
											const Text(
												'Translation Tools',
												style: TextStyle(
													fontSize: 24,
													fontWeight: FontWeight.w800,
													color: Color(0xFF2E3A53),
												),
											),
											const SizedBox(height: 14),
											Row(
												children: [
													Expanded(
														child: _ToolCard(
															icon: Icons.photo_camera_outlined,
															iconColor: const Color(0xFF4A8AFB),
															title: 'Sign to Text',
															subtitle: 'Camera-based\ndetection',
															onTap: () {
																Navigator.push(
																	context,
																	MaterialPageRoute(
																		builder: (_) => const CameraScreen(),
																	),
																);
															},
														),
													),
													const SizedBox(width: 12),
													Expanded(
														child: _ToolCard(
															icon: Icons.translate_rounded,
															iconColor: const Color(0xFF34C38F),
															title: 'Text to Sign',
															subtitle: 'Avatar\nanimation',
															onTap: () {
																Navigator.push(
																	context,
																	MaterialPageRoute(
																		builder: (_) => const ResultScreen(),
																	),
																);
															},
														),
													),
												],
											),
										],
									),
								),
							),
						),
					),
				],
			),
		);
	}
}

class _TopBar extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		final isNarrow = MediaQuery.of(context).size.width < 390;

		return SafeArea(
			bottom: false,
			child: Container(
				height: 82,
				padding: const EdgeInsets.symmetric(horizontal: 18),
				decoration: const BoxDecoration(
					color: Colors.white,
					boxShadow: [
						BoxShadow(
							color: Color(0x120F172A),
							blurRadius: 12,
							offset: Offset(0, 4),
						),
					],
				),
				child: Row(
					children: [
						Container(
							width: 40,
							height: 40,
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								color: const Color(0xFFECF5FF),
								border: Border.all(color: const Color(0xFFE1ECFA)),
							),
							child: const Icon(
								Icons.waving_hand_rounded,
								color: Color(0xFF3A82F7),
							),
						),
						const SizedBox(width: 12),
						const Expanded(
							child: Text(
								'SignTranslate',
								maxLines: 1,
								overflow: TextOverflow.ellipsis,
								style: TextStyle(
									fontWeight: FontWeight.w800,
									fontSize: 26,
									color: Color(0xFF182134),
								),
							),
						),
						const Spacer(),
						if (!isNarrow)
							ElevatedButton(
								style: ElevatedButton.styleFrom(
									elevation: 0,
									backgroundColor: const Color(0xFF3A82F7),
									foregroundColor: Colors.white,
									padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(40),
									),
								),
								onPressed: () {},
								child: const Text(
									'Download',
									style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
								),
							),
					],
				),
			),
		);
	}
}

class _ToolCard extends StatelessWidget {
	const _ToolCard({
		required this.icon,
		required this.iconColor,
		required this.title,
		required this.subtitle,
		required this.onTap,
	});

	final IconData icon;
	final Color iconColor;
	final String title;
	final String subtitle;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return Material(
			color: Colors.white,
			borderRadius: BorderRadius.circular(22),
			child: InkWell(
				borderRadius: BorderRadius.circular(22),
				onTap: onTap,
				child: Container(
					height: 210,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(22),
						border: Border.all(color: const Color(0xFFE8EDF4)),
						boxShadow: const [
							BoxShadow(
								color: Color(0x140F172A),
								blurRadius: 12,
								offset: Offset(0, 6),
							),
						],
					),
					padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Container(
								width: 74,
								height: 74,
								decoration: BoxDecoration(
									color: iconColor.withValues(alpha: 0.12),
									borderRadius: BorderRadius.circular(18),
								),
								child: Icon(icon, size: 36, color: iconColor),
							),
							const SizedBox(height: 18),
							Text(
								title,
								style: const TextStyle(
									fontSize: 22,
									fontWeight: FontWeight.w800,
									color: Color(0xFF1C2538),
								),
								maxLines: 1,
								overflow: TextOverflow.ellipsis,
							),
							const SizedBox(height: 10),
							Flexible(
								child: Text(
									subtitle,
									textAlign: TextAlign.center,
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
									style: const TextStyle(
										color: Color(0xFF7F8A9E),
										fontWeight: FontWeight.w600,
										height: 1.3,
										fontSize: 17,
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
