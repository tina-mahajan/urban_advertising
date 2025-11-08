import 'package:flutter/material.dart';
import 'package:urban_application/core/theme.dart';
import 'package:urban_application/home/payment_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'title': 'Basic',
        'price': '₹14,999/-',
        'details': [
          '15 Videos included',
          'Editing for all videos',
          'Posting support',
          'Festival Banners'
        ],
        'color1': Color(0xFFB2EBF2),
        'color2': Color(0xFF81D4FA),
      },
      {
        'title': 'Standard',
        'price': '₹24,999/-',
        'details': [
          '30 Videos included',
          'Editing for all videos',
          'Posting support',
          'Festival Banners'
        ],
        'color1': Color(0xFFC8E6C9),
        'color2': Color(0xFF80CBC4),
      },
      {
        'title': 'Premium',
        'price': '₹26,999/-',
        'details': [
          '30 Videos included',
          'Editing for all videos',
          'Posting support',
          'Festival Banners'
        ],
        'color1': Color(0xFFE1BEE7),
        'color2': Color(0xFFCE93D8),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Subscription',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [plan['color1'] as Color, plan['color2'] as Color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['price'].toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      plan['title'].toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (plan['details'] as List<String>)
                          .map((detail) => Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(detail,
                                style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 14)),
                          ],
                        ),
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                planName: plan['title'].toString(),
                                planPrice: plan['price'].toString(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Upgrade Now'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}