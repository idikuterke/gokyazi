import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/kullanici_model.dart';
import '../providers/kozmik_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StepItem {
  final String glyph;
  final String title;
  final String body;
  final int duration; // in seconds

  const StepItem({
    required this.glyph,
    required this.title,
    required this.body,
    required this.duration,
  });
}

class KozmikArinmaEkrani extends StatefulWidget {
  final VoidCallback? onHomeRequested;

  const KozmikArinmaEkrani({super.key, this.onHomeRequested});

  @override
  State<KozmikArinmaEkrani> createState() => _KozmikArinmaEkraniState();
}

class _KozmikArinmaEkraniState extends State<KozmikArinmaEkrani>
    with TickerProviderStateMixin {
  // Stages: 'intro' | 'running' | 'done'
  String _stage = 'intro';
  int _currentStepIdx = 0;
  int _tickCount = 0;
  bool _isPlaying = false;
  bool _isAccelerated = false; // Prototype mode (10x speed)

  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation Controllers
  late AnimationController _rotationCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _doneFadeCtrl;

  // Ritual steps matching ExtrasScreens.jsx
  final List<StepItem> _steps = const [
    StepItem(
      glyph: "𐰢",
      title: "Hazırlık",
      body: "Rahat bir yere otur. Üç derin nefes al. Gözlerini hafif kapat.",
      duration: 30,
    ),
    StepItem(
      glyph: "𐰋",
      title: "Niyet",
      body: "Bugün arınmak istediğin şeyi içinden geçir. Tek bir kelime bul.",
      duration: 45,
    ),
    StepItem(
      glyph: "𐰚",
      title: "Tengri'ye Çağrı",
      body: "Göklere ellerini aç. \"Tengri\" diye fısılda. Sesin titreşsin.",
      duration: 60,
    ),
    StepItem(
      glyph: "𐰽",
      title: "Davul Sesi",
      body: "İçinde davulun ritmini duy. Her vuruşta bir parça gölge çözülür.",
      duration: 90,
    ),
    StepItem(
      glyph: "✦",
      title: "Şükran",
      body: "Arınma için Yer Ana'ya ve Ak Ana'ya teşekkür et. Gözlerini aç.",
      duration: 30,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _doneFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _rotationCtrl.dispose();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _doneFadeCtrl.dispose();
    super.dispose();
  }

  void _startRitual() {
    setState(() {
      _stage = 'running';
      _currentStepIdx = 0;
      _tickCount = 0;
      _isPlaying = true;
    });
    _playDrumSound();
    _initTimer();
    HapticFeedback.heavyImpact();
  }

  void _initTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _isAccelerated ? 100 : 1000),
      (timer) {
        if (!_isPlaying) return;

        final currentDuration = _steps[_currentStepIdx].duration;
        if (_tickCount >= currentDuration) {
          _nextStep();
        } else {
          setState(() {
            _tickCount++;
          });
        }
      },
    );
  }

  Future<void> _playDrumSound() async {
    try {
      // Loop the drum wav file
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/drum.wav'));
    } catch (e) {
      debugPrint("Kozmik arınma ses hatası: $e");
    }
  }

  Future<void> _stopDrumSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Ses durdurma hatası: $e");
    }
  }

  void _nextStep() {
    HapticFeedback.mediumImpact();
    if (_currentStepIdx >= _steps.length - 1) {
      _completeRitual();
    } else {
      setState(() {
        _currentStepIdx++;
        _tickCount = 0;
      });
    }
  }

  void _completeRitual() {
    _timer?.cancel();
    _stopDrumSound();
    setState(() {
      _stage = 'done';
    });
    _doneFadeCtrl.forward(from: 0.0);
    HapticFeedback.heavyImpact();

    // Reward points to the user
    final kullaniciModel = Provider.of<KullaniciModel>(context, listen: false);
    kullaniciModel.addKaderPuani(50);
    kullaniciModel.addExperience(50);
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _playDrumSound();
    } else {
      _stopDrumSound();
    }
    HapticFeedback.lightImpact();
  }

  void _resetRitual() {
    _timer?.cancel();
    _stopDrumSound();
    setState(() {
      _stage = 'intro';
      _currentStepIdx = 0;
      _tickCount = 0;
      _isPlaying = false;
      _isAccelerated = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _toggleAcceleration() {
    setState(() {
      _isAccelerated = !_isAccelerated;
    });
    _initTimer();
    HapticFeedback.lightImpact();
  }

  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      body: Stack(
        children: [
          // 1. Background Image with Screen Blend Mode & Scrim
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1500),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/tengri.webp'),
                  fit: BoxFit.cover,
                  opacity: _stage == 'done' ? 0.45 : 0.32,
                  colorFilter: _stage == 'done'
                      ? const ColorFilter.mode(Colors.amber, BlendMode.colorBurn)
                      : null,
                ),
              ),
            ),
          ),

          // 2. Radial Gradient Overlay matching ExtrasScreens.jsx
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1500),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.3),
                  radius: 1.2,
                  colors: _stage == 'done'
                      ? [
                          const Color(0x59FFD700), // Gold overlay
                          AppColors.violetBgGradient[0],
                          AppColors.bgCosmos.withValues(alpha: 0.95),
                          AppColors.bgCosmos,
                        ]
                      : [
                          AppColors.violetBgGradient[0],
                          AppColors.bgCosmos.withValues(alpha: 0.95),
                          AppColors.bgCosmos,
                        ],
                  stops: const [0.0, 0.35, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // 3. Screen Content
          SafeArea(
            child: Column(
              children: [
                // Top Custom Navigation Bar
                _buildAppBar(),

                // Main body area
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 16.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 800),
                          child: _buildStageContent(),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Keep space at bottom for floating bottom navigation bar
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_stage != 'intro')
            Positioned(
              left: 8,
              child: IconButton(
                onPressed: _resetRitual,
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  side: BorderSide(
                    color: Colors.amber.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
            ),
          Text(
            "KOZMİK ARINMA",
            style: AppTypography.displaySm.copyWith(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 2.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case 'running':
        return _buildRunningStage();
      case 'done':
        return _buildDoneStage();
      case 'intro':
      default:
        return _buildIntroStage();
    }
  }

  // --- INTRO STAGE ---
  Widget _buildIntroStage() {
    const runicLetters = ["𐰋", "𐰃", "𐱅", "𐰢", "𐰚", "𐰽", "𐰉", "𐰉"];
    const double orbRadius = 92.0;

    return Column(
      key: const ValueKey('intro_stage'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. Spinning Runic Orb
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Spinning outer circle of runes
              AnimatedBuilder(
                animation: _rotationCtrl,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationCtrl.value * 2 * math.pi,
                    child: Stack(
                      children: List.generate(8, (k) {
                        final angle = (k / 8) * math.pi * 2 - math.pi / 2;
                        final x = orbRadius * math.cos(angle);
                        final y = orbRadius * math.sin(angle);
                        return Positioned(
                          left: 100 + x - 10,
                          top: 100 + y - 10,
                          child: Transform.rotate(
                            angle: -_rotationCtrl.value * 2 * math.pi, // Keep runes upright
                            child: Text(
                              runicLetters[k],
                              style: TextStyle(
                                fontFamily: AppTypography.fontRunic,
                                fontSize: 18,
                                color: AppColors.amber500,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xB3FFC107),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
              // Outer border ring
              Container(
                width: 184,
                height: 184,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
              ),
              // Glowing pulsing inner rune orb
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.08).animate(
                  CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x66FFC107),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "𐰚",
                    style: TextStyle(
                      fontFamily: AppTypography.fontRunic,
                      fontSize: 56,
                      color: Color(0xFFFFD700),
                      shadows: [
                        Shadow(
                          color: Color(0xCCFFD700),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // 2. Title & Subtitle
        Text(
          "Kozmik Arınma",
          textAlign: TextAlign.center,
          style: AppTypography.displayXl.copyWith(
            fontSize: 24,
            letterSpacing: 1.6,
            shadows: [
              const Shadow(
                color: Color(0x66FFD700),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '5 adımda, yaklaşık 4 dakika. Kadim ritüel seni temizleyecek ve yeni bir niyet için açacak.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.fgSecondary,
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // AY FAZI BİLGİSİ KARTI
        _buildAyFaziKarti(),
        
        const SizedBox(height: 28),

        // 3. Step List
        Column(
          children: _steps.map((step) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x990C0A18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      step.glyph,
                      style: TextStyle(
                        fontFamily: AppTypography.fontRunic,
                        fontSize: 14,
                        color: AppColors.amber500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    "${step.duration}s",
                    style: TextStyle(
                      color: AppColors.fgTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // 4. Start Button
        GestureDetector(
          onTap: _startRitual,
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE5B225), Color(0xFFC99411)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A017).withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              "RİTÜELE BAŞLA",
              style: AppTypography.menuLabel.copyWith(
                color: AppColors.bgCosmos,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAyFaziKarti() {
    final kozmikProvider = Provider.of<KozmikProvider>(context, listen: false);
    final bugun = DateTime.now();
    final ayFazi = kozmikProvider.ayFaziYorum(bugun);
    final faz = kozmikProvider.ayFaziHesapla(bugun);
    
    // Ritüel gücü hesapla (Dolunay %150, Yeni Ay %100, diğer %120)
    final rituelGucu = faz == 4 ? 1.5 : (faz == 0 ? 1.0 : 1.2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: faz == 4 ? Colors.yellow.withValues(alpha: 0.1) : const Color(0x990C0A18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: faz == 4 ? Colors.yellow.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                ayFazi['ikon'] ?? '🌙',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ayFazi['ad'] ?? '',
                      style: AppTypography.displaySm.copyWith(
                        color: AppColors.amber500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ritüel Gücü: ${(rituelGucu * 100).toInt()}%',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ayFazi['yorum'] ?? '',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.fgSecondary,
              height: 1.6,
            ),
          ),
          if (ayFazi['mitoloji'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCardSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_stories, color: AppColors.cyanSpecial, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ayFazi['mitoloji']!,
                      style: AppTypography.bodyXs.copyWith(
                        color: AppColors.fgTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- RUNNING STAGE ---
  Widget _buildRunningStage() {
    final currentStep = _steps[_currentStepIdx];
    final currentDuration = currentStep.duration;
    final double stepProgress = _tickCount / currentDuration;
    final double overallProgress =
        (_currentStepIdx + stepProgress) / _steps.length;

    return Column(
      key: const ValueKey('running_stage'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. Big Circular Progress Indicator with Glyph
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(220, 220),
                painter: KozmikProgressPainter(
                  progress: stepProgress,
                  trackColor: Colors.white.withValues(alpha: 0.06),
                  progressColor: AppColors.amber500,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1.04).animate(
                      CurvedAnimation(
                        parent: _pulseCtrl,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Text(
                      currentStep.glyph,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontRunic,
                        fontSize: 66,
                        color: Color(0xFFFFD700),
                        shadows: [
                          Shadow(
                            color: Color(0xB3FFD700),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "ADIM ${_currentStepIdx + 1}/${_steps.length}",
                    style: TextStyle(
                      color: AppColors.amber500.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // 2. Step Title & Description Text
        Text(
          currentStep.title,
          style: AppTypography.displayXl.copyWith(
            fontSize: 22,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              "\"${currentStep.body}\"",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 3. Drum Waveform (11 animated lines)
        SizedBox(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(11, (k) {
              return AnimatedBuilder(
                animation: _waveCtrl,
                builder: (context, child) {
                  double waveScale = 1.0;
                  if (_isPlaying) {
                    final phase = k * 0.45;
                    waveScale = (math.sin(_waveCtrl.value * 2 * math.pi + phase) + 1) * 2.2 + 0.6;
                  }
                  return Container(
                    width: 3,
                    height: 8 * waveScale,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _isPlaying
                          ? AppColors.amber500.withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 25),

        // 4. Overall Progress Bar
        Container(
          width: 280,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 280 * overallProgress,
            height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC99411), Color(0xFFFFD700)],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber500.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 35),

        // 5. Action Buttons (Play/Pause, Reset, Speed-Up prototype toggle)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Acceleration/Prototype toggle
            IconButton(
              onPressed: _toggleAcceleration,
              icon: Icon(
                _isAccelerated ? Icons.bolt : Icons.bolt_outlined,
                size: 22,
                color: _isAccelerated ? Colors.amber : Colors.white.withValues(alpha: 0.4),
              ),
              style: IconButton.styleFrom(
                backgroundColor: _isAccelerated
                    ? Colors.amber.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                side: BorderSide(
                  color: _isAccelerated
                      ? Colors.amber.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                padding: const EdgeInsets.all(12),
              ),
              tooltip: "Hızlandırılmış Test Modu",
            ),
            const SizedBox(width: 16),

            // Play/Pause button
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 32,
                  color: AppColors.amber500,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Reset button
            IconButton(
              onPressed: _resetRitual,
              icon: const Icon(Icons.refresh_rounded, size: 22, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
                padding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),

        if (_isAccelerated) ...[
          const SizedBox(height: 12),
          Text(
            "Test Modu: Hızlandırılmış (10x)",
            style: TextStyle(
              color: Colors.amber.withValues(alpha: 0.6),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ]
      ],
    );
  }

  // --- DONE STAGE ---
  Widget _buildDoneStage() {
    return FadeTransition(
      opacity: _doneFadeCtrl,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: _doneFadeCtrl, curve: Curves.easeOutCubic),
        ),
        child: Column(
          key: const ValueKey('done_stage'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Burst Effect (Golden Rays Rotating & Pulsing)
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning / pulsing rays
                  ...List.generate(12, (k) {
                    final angle = (k / 12) * math.pi * 2;
                    return Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: 2,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.amber.withValues(alpha: 0.85),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  }),
                  // Golden inner orb glow
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.amber.withValues(alpha: 0.5),
                          Colors.amber.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 0.8],
                      ),
                    ),
                  ),
                  // Large ✦ symbol
                  const Text(
                    "✦",
                    style: TextStyle(
                      fontFamily: AppTypography.fontRunic,
                      fontSize: 78,
                      color: Color(0xFFFFD700),
                      shadows: [
                        Shadow(
                          color: Color(0xE6FFD700),
                          blurRadius: 32,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. Success Text
            Text(
              "Arındın",
              style: AppTypography.displayXl.copyWith(
                fontSize: 28,
                letterSpacing: 2,
                color: const Color(0xFFFFD700),
                shadows: [
                  const Shadow(
                    color: Color(0x99FFD700),
                    blurRadius: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Ruhun bir kabuğun kırılışını duydu. Bugünden sonra yeni bir niyet taşıyorsun. Tengri seninle.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.7,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Score Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                  SizedBox(width: 6),
                  Text(
                    "+50 KADER PUANI",
                    style: TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // 4. Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetRitual,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "YENİDEN",
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        color: Colors.amber.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE5B225), Color(0xFFC99411)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A017).withValues(alpha: 0.35),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: widget.onHomeRequested,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "ANA SAYFAYA DÖN",
                        style: TextStyle(
                          fontFamily: AppTypography.fontDisplay,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.6,
                          color: AppColors.bgCosmos,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KozmikProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  KozmikProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw arc starting from top (-90 degrees or -pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant KozmikProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
