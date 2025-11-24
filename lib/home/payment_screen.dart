import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class PaymentScreen extends StatefulWidget {
  final String planName;
  final String planPrice;

  const PaymentScreen({
    super.key,
    required this.planName,
    required this.planPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPayment; // stores selected payment method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Confirm Your Upgrade',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
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
                color: Colors.black,
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan: ${widget.planName}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Billing Cycle: Monthly',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Total Due: ${widget.planPrice}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),

            const Text(
              'Choose Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),

            // Payment Options
            _buildPaymentOption(Icons.credit_card, 'Visa', 'Visa'),
            _buildPaymentOption(Icons.credit_card_rounded, 'Mastercard', 'Mastercard'),
            _buildPaymentOption(Icons.payments_rounded, 'PayPal', 'PayPal'),
            _buildPaymentOption(Icons.apple, 'Apple Pay', 'Apple Pay'),
            _buildPaymentOption(Icons.payment_rounded, 'Stripe', 'Stripe'),

            const Spacer(),

            // Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedPayment == null
                        ? null
                        : () {
                      Navigator.pushNamed(
                        context,
                        '/success',
                        arguments: {
                          'planName': widget.planName,
                          'planPrice': widget.planPrice,
                          'userName': 'Unknown User',  // Replace with real user name if needed
                          'paymentDate': DateTime.now().toString(),
                        },
                      );

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPayment == null
                          ? Colors.white10
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: selectedPayment == null
                            ? Colors.white38
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: selectedPayment == null
                        ? null
                        : () {
                      Navigator.pushNamed(
                        context,
                        '/success',
                        arguments: {
                          'planName': widget.planName,
                          'planPrice': widget.planPrice,
                          // 'userName': 'User',  // Put actual user name if stored
                          // 'paymentDate': DateTime.now().toString(),
                        },
                      );
                    },

                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Go Back',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String text, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPayment == value
                ? Colors.white
                : Colors.white24,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            selectedPayment == value
                ? Icons.check_circle
                : Icons.circle_outlined,
            color: selectedPayment == value
                ? Colors.white
                : Colors.white38,
          ),
        ),
      ),
    );
  }
}
