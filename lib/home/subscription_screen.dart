import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '';

class AppColors {
  static const Color bg = Color(0xFF0A0A0A);
  static const Color card = Color(0xFF1A1A1A);
  static const Color accent = Color(0xFF8C00FF);
  static const Color accent2 = Color(0xFFB100FF);
  static const Color text = Colors.white;
  static const Color muted = Colors.white70;
  static const Color tagBg = Color(0xFF3A008C);
}

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedTab = 0;
  int? expandedIndex;
  int bottomIndex = 2;

  final List<Map<String, dynamic>> plans = [
    {
      'title': 'Basic Plan',
      'price': '₹9,999 / month',
      'short': '10 shoots + Editing',
      'icon': Icons.star_border_rounded,
      'tag': 'Starter', // The 'tag' data is still here if you want to use it elsewhere
      'features': [
        "10 Professional Video Shoots",
        "Editing Included",
        "1 Revision Per Video",
        "1 Final Change Allowed",
      ],
    },
    {
      'title': 'Growth Plan',
      'price': '₹14,999 / month',
      'short': '15 Shoots + Social Posting',
      'icon': Icons.auto_graph_rounded,
      'tag': 'Most Popular',
      'features': [
        "15 Premium Shoots",
        "Premium Editing",
        "2 Revisions Per Video",
        "Social Media Posting",
        "2 Final Change Allowed",
        "Logo Generation",
      ],
    },
    {
      'title': 'Premium Plan',
      'price': '₹24,999 / month',
      'short': '30 Shoots + Creative Team',
      'icon': Icons.diamond_rounded,
      'tag': 'Best Value',
      'features': [
        "30 Premium Shoots",
        "Premium Editing",
        "7 Creatives (Posters)",
        "Script + Content Planning",
        "Daily Posting Support",
        "Priority 24/7 Support",
        "1 AI Generated Video",
        "2 Final Change Allowed",
        "Brand Guideline Support",
      ],
    },
  ];

  void handleBottomTap(int i) {
    setState(() => bottomIndex = i);

    if (i == 0) Navigator.pushReplacementNamed(context, '/home');
    if (i == 1) Navigator.pushReplacementNamed(context, '/slot_booking');
    if (i == 2) return;
    if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
  }

  void _navigateToPayment(String planTitle) {
    // ... old navigation logic ...
    Navigator.pushNamed(context, '/payment_screen');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          "Our Packages",
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------
      body: Column(
        children: [
          // TOP TOGGLE BUTTONS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  _tabButton("Monthly", 0),
                  _tabButton("Yearly", 1),
                ],
              ),
            ),
          ),

          // PLAN LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final isExpanded = expandedIndex == index;
                // final isMostPopular = plan['tag'] == 'Most Popular';

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.card,
                        isExpanded
                            ? AppColors.accent.withAlpha(38)
                            : AppColors.card

                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: isExpanded ? AppColors.accent : const Color(0x1AFFFFFF),
                      // width: isExpanded || isMostPopular ? 2.0 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isExpanded
                            ? AppColors.accent.withAlpha(89)
                            : Colors.black.withAlpha(76),
                        // blurRadius: isExpanded || isMostPopular ? 18 : 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- HEADER (Tap to expand)
                      InkWell(
                        onTap: () =>
                            setState(() => expandedIndex = isExpanded ? null : index),
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. PLAN ICON
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: AppColors.accent.withAlpha(51),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withAlpha(38),
                                        blurRadius: 8,
                                      )
                                    ]
                                ),
                                child: Icon(
                                  plan['icon'],
                                  color: AppColors.accent,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // 2. TITLE + SHORT DETAILS (Now takes all available space)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title now has maximum horizontal space
                                    Text(
                                      plan['title'],
                                      style: const TextStyle(
                                        color: AppColors.text,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Short description only
                                    Text(
                                      plan['short'],
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 3. PRICE + ARROW (Fixed width, but now has more flexibility)
                              SizedBox(
                                width: 95,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      plan['price'],
                                      style: const TextStyle(
                                        color: AppColors.text,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ---- EXPANDED AREA
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(
                                plan['features'].length,
                                    (i) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline,
                                          color: AppColors.accent, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          plan['features'][i],
                                          style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 15,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  // Inside SubscriptionScreen's ElevatedButton onPressed:

                                  onPressed: () {
                                    // Navigate using the defined route name, passing arguments as a map
                                    Navigator.pushNamed(
                                      context,
                                      '/payment_screen', // This matches the key in main.dart
                                      arguments: {
                                        'planName': plan['title'] as String,
                                        'planPrice': plan['price'] as String,
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    "Choose Plan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                );
              },
            ),
          ),
        ],
      ),

      // BOTTOM NAVBAR
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: bottomIndex,
        onTap: handleBottomTap,
      ),
    );
  }

  // ----------------------------------------------------------
  // TOGGLE BUTTON WIDGET
  // ----------------------------------------------------------
  Widget _tabButton(String title, int index) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            border: isSelected ? Border.all(color: AppColors.accent, width: 1.5) : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}