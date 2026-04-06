import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/currency_provider.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: Text(
          "Billing Details",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Methods",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildPaymentCard(context, "Visa ending in 4242", true),
            const SizedBox(height: 10),
            _buildPaymentCard(context, "Mastercard ending in 8888", false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LineAwesomeIcons.plus),
                label: const Text("Add Payment Method"),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Billing History",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(LineAwesomeIcons.receipt),
                      title: const Text("Order #12345"),
                      subtitle: const Text("Dec 24, 2025"),
                      trailing: Text(currencyProvider.convert(45.00)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(LineAwesomeIcons.receipt),
                      title: const Text("Order #12344"),
                      subtitle: const Text("Dec 22, 2025"),
                      trailing: Text(currencyProvider.convert(12.50)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, String title, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(LineAwesomeIcons.credit_card, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Default",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
