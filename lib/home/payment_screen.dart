import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class PaymentScreen extends StatelessWidget {
  final String planName;
  final String planPrice;

  const PaymentScreen({
    super.key,
    required this.planName,
    required this.planPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Your Upgrade'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Summary Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan: $planName Plan',
                      style: const TextStyle(
                          color: AppColors.secondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Billing Cycle: Monthly',
                      style:
                      TextStyle(color: AppColors.secondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Total Due: $planPrice',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),

            const Text(
              'Choose Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),

            // Payment Options
            _buildPaymentOption(Icons.credit_card, 'Pay with Visa'),
            _buildPaymentOption(Icons.credit_card, 'Pay with Mastercard'),
            _buildPaymentOption(Icons.payment, 'Pay with Paypal'),
            _buildPaymentOption(Icons.apple, 'Pay with Apple Pay'),
            _buildPaymentOption(Icons.payment_rounded, 'Pay with Stripe'),
            const Spacer(),

            // Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/success');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Go Back',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          text,
          style: const TextStyle(color: AppColors.textDark),
        ),
        trailing: const Icon(Icons.check_box_outline_blank,
            color: AppColors.accent),
      ),
    );
  }
}