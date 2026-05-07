import 'package:flutter/material.dart';
import 'package:acoms_app/widgets/status_indicator.dart';
import 'package:acoms_app/widgets/fictional.dart';

class ServiceCard extends StatelessWidget {
  final bool isLast;
  final String name;
  final String description;
  final String status;

  const ServiceCard({
    super.key,
    required this.isLast,
    required this.name,
    required this.description,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: FiColors.backgroundHighlight, width: 2),
                  left: BorderSide(color: FiColors.backgroundHighlight, width: 2),
                  bottom: isLast ? BorderSide(color: FiColors.backgroundHighlight, width: 2) : BorderSide.none,
                ),
                color: FiColors.controlBackground,
              ),
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: FiColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: FiColors.mainText,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: FiStatusTag(text: status, color: status == "ONLINE" ? FiColors.green1 : FiColors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: FiColors.backgroundHighlight,
              overlayColor: FiColors.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide.none,
              ),
            ),
            child: const Text(
              'SHOW',
              style: TextStyle(
                color: FiColors.secondary,
                fontSize: 10,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TerminalCard extends StatelessWidget {
  const TerminalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Handle card tap
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Terminal Title',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  const StatusIndicator()
                ],
              ),
              const SizedBox(height: 8),
              const Text("Windows 11 Home"),
              const SizedBox(height: 12),
              const Text(
                'Last Request: 2024-06-01 12:00 PM\nLast Updated: 2024-06-01 12:00 PM',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}