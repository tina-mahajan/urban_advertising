import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:urban_advertising/home/payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int? hoveredIndex;

  final plans = [
    {
      'title': 'Basic Plan',
      'price': '₹9,999/- (Per Month)',
      'features': [
        {'text': '10 video shoots', 'highlight': true},
        {'text': 'Professional video editing'},
        {'text': '1 revision per video', 'highlight': true},
        {'text': '1 change allowed after final delivery'},
      ],
    },
    {
      'title': 'Growth Plan',
      'price': '₹14,999/- (Per Month)',
      'features': [
        {'text': '15 video shoots', 'highlight': true},
        {'text': 'Professional editing'},
        {'text': '3 revision per video', 'highlight': true},
        {'text': '2 changes allowed after delivery per video', 'highlight': true},
        {'text': 'Social media posting support'},
        {'text': 'Logo generation (if required)'},
      ],
    },
    {
      'title': 'Premium Plan',
      'price': '₹24,999/- (Per Month)',
      'features': [
        {'text': '30 video shoots', 'highlight': true},
        {'text': 'Premium editing'},
        {'text': '3 changes allowed after delivery', 'highlight': true},
        {'text': 'Daily posting support'},
        {'text': '7 creative posters per month', 'highlight': true},
        {'text': '24/7 priority support'},
        {'text': '1 AI generated Video', 'highlight': true},
        {'text': 'Logo generation (if required)'},
        {'text': 'Script + content planning'},
        {'text': 'Brand guideline support'},
      ],
    },
  ];

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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
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
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: hoveredIndex == index
                              ? Colors.orangeAccent.withOpacity(0.4)
                              : Colors.white.withOpacity(0.08),
                          blurRadius: hoveredIndex == index ? 25 : 10,
                          spreadRadius: hoveredIndex == index ? 2 : 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Frosted glass effect
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),

                        // Neon accent line
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
                                    ? [Colors.white, Colors.orangeAccent]
                                    : [Colors.transparent, Colors.transparent],
                              ),
                            ),
                          ),
                        ),

                        // Main Content
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
                                    AnimatedRotation(
                                      turns: hoveredIndex == index ? 0.1 : 0.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: const Icon(Icons.star_border_outlined,
                                          color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      plan['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
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
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: hoveredIndex == index ? 1 : 0.5,
                                  child: const Divider(color: Colors.white24, height: 20),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                  (plan['features'] as List).map((feature) {
                                    final f = feature as Map<String, dynamic>;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.check,
                                              color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              f['text'] as String,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: f['highlight'] == true
                                                    ? Colors.orangeAccent
                                                    : Colors.white70,
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
                                    scale: hoveredIndex == index ? 1.05 : 1.0,
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
                                        side: const BorderSide(color: Colors.white),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        backgroundColor: hoveredIndex == index
                                            ? Colors.white12
                                            : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 30),
                                      ),
                                      child: const Text(
                                        'Upgrade Now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
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
    );
  }
}
