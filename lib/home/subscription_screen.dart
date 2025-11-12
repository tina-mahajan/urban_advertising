import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:urban_advertising/home/payment_screen.dart';
import '../widgets/bottom_navbar.dart';

class AppColors {
  static const Color primaryAccent = Color(0xFF3A3A3A);
  static const Color secondaryAccent = Color(0xFFD0D337);
  static const Color cardSurface = Color(0xFF1B1B1B);
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color textLight = Colors.white;
  static const Color textMuted = Colors.white70;
  static const Color checkIcon = Color(0xFFFFFFFF);
}

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int? hoveredIndex;
  int currentIndex = 2; // Plans tab selected by default

  final plans = [
    {
      'title': 'Basic Plan',
      'price': '₹9,999/- (Per Month)',
      'icon': Icons.trending_up_outlined,
      'features': [
        {'icon': Icons.videocam_outlined, 'text': '10 video shoots', 'highlight': true},
        {'icon': Icons.video_call_outlined, 'text': 'Professional video editing'},
        {'icon': Icons.replay_outlined, 'text': '1 revision per video', 'highlight': true},
        {'icon': Icons.change_circle_outlined, 'text': '1 change allowed after final delivery'},
      ],
    },
    {
      'title': 'Growth Plan',
      'price': '₹14,999/- (Per Month)',
      'icon': Icons.slow_motion_video_outlined,
      'features': [
        {'icon': Icons.videocam_outlined, 'text': '15 video shoots', 'highlight': true},
        {'icon': Icons.video_settings_outlined, 'text': 'Professional editing'},
        {'icon': Icons.repeat_on_outlined, 'text': '3 revision per video', 'highlight': true},
        {'icon': Icons.cached_outlined, 'text': '2 changes allowed after delivery per video', 'highlight': true},
        {'icon': Icons.share_outlined, 'text': 'Social media posting support'},
        {'icon': Icons.brush_outlined, 'text': 'Logo generation (if required)'},
      ],
    },
    {
      'title': 'Premium Plan',
      'price': '₹24,999/- (Per Month)',
      'icon': Icons.diamond_outlined,
      'features': [
        {'icon': Icons.videocam_outlined, 'text': '30 video shoots', 'highlight': true},
        {'icon': Icons.star_outline, 'text': 'Premium editing'},
        {'icon': Icons.change_circle_outlined, 'text': '3 changes allowed after delivery', 'highlight': true},
        {'icon': Icons.calendar_month_outlined, 'text': 'Daily posting support'},
        {'icon': Icons.design_services_outlined, 'text': '7 creative posters per month', 'highlight': true},
        {'icon': Icons.edit_note_outlined, 'text': 'Script + content planning'},
        {'icon': Icons.smart_toy_outlined, 'text': '1 AI generated Video', 'highlight': true},
        {'icon': Icons.brush_outlined, 'text': 'Logo generation (if required)'},
        {'icon': Icons.support_agent_outlined, 'text': '24/7 priority support', 'highlight': true},
        {'icon': Icons.branding_watermark_outlined, 'text': 'Brand guideline support'},
      ],
    },
  ];

  void onTap(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/slot_booking');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Our Plans',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 30),
          child: Column(
            children: List.generate(plans.length, (index) {
              final plan = plans[index];

              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 500 + (index * 200)),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 40),
                      child: child,
                    ),
                  );
                },
                child: MouseRegion(
                  onEnter: (_) => setState(() => hoveredIndex = index),
                  onExit: (_) => setState(() => hoveredIndex = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hoveredIndex == index
                            ? AppColors.secondaryAccent
                            : AppColors.primaryAccent.withOpacity(0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: hoveredIndex == index
                              ? AppColors.secondaryAccent.withOpacity(0.35)
                              : AppColors.primaryAccent.withOpacity(0.15),
                          blurRadius: hoveredIndex == index ? 25 : 10,
                          spreadRadius: hoveredIndex == index ? 3 : 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              color: AppColors.cardSurface.withOpacity(0.8),
                            ),
                          ),
                        ),

                        // 🔸 Faint background icon (new addition)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Icon(
                            plan['icon'] as IconData,
                            size: 100,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),

                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: hoveredIndex == index
                                    ? [AppColors.secondaryAccent, AppColors.primaryAccent]
                                    : [Colors.transparent, Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  planName: plan['title'] as String,
                                  planPrice: plan['price'] as String,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.textLight,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      plan['title'] as String,
                                      style: const TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  plan['price'] as String,
                                  style: const TextStyle(
                                    color: AppColors.secondaryAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Divider(
                                  color: AppColors.primaryAccent.withOpacity(0.5),
                                  height: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (plan['features'] as List).map((feature) {
                                    final f = feature as Map<String, dynamic>;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            f['icon'] as IconData? ?? Icons.check,
                                            color: AppColors.checkIcon,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              f['text'] as String,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: f['highlight'] == true
                                                    ? AppColors.secondaryAccent
                                                    : AppColors.textMuted,
                                                fontSize: 15,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 250),
                                    scale: hoveredIndex == index ? 1.08 : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          if (hoveredIndex == index)
                                            BoxShadow(
                                              color: AppColors.secondaryAccent.withOpacity(0.4),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                        ],
                                      ),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PaymentScreen(
                                                planName: plan['title'] as String,
                                                planPrice: plan['price'] as String,
                                              ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: AppColors.secondaryAccent,
                                            width: hoveredIndex == index ? 2 : 1.2,
                                          ),
                                          backgroundColor: hoveredIndex == index
                                              ? AppColors.secondaryAccent.withOpacity(0.1)
                                              : Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 30),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          'Upgrade Now',
                                          style: TextStyle(
                                            color: AppColors.textLight,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ),
                                    ),
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
            }),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
