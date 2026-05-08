import 'package:acoms_app/models/service.dart';
import 'package:acoms_app/views/service.dart';
import 'package:flutter/material.dart';
import 'package:acoms_app/widgets/fictional.dart';

class GenericRowCard extends StatelessWidget {
  final bool isLast;
  final String name;
  final String description;
  final String status;
  final VoidCallback? onTap;

  const GenericRowCard({
    super.key,
    required this.isLast,
    required this.name,
    required this.description,
    required this.status,
    this.onTap,
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
                  top: BorderSide(color: FiColors.border, width: 2),
                  left: BorderSide(color: FiColors.border, width: 2),
                  bottom: isLast ? BorderSide(color: FiColors.border, width: 2) : BorderSide.none,
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
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: FiColors.border, width: 2),
                right: BorderSide(color: FiColors.border, width: 2),
                left: BorderSide(color: FiColors.border, width: 2),
                bottom: isLast ? BorderSide(color: FiColors.border, width: 2) : BorderSide.none,
              ),
            ),
            child: TextButton(
              onPressed: () {
                if (onTap != null) {
                  onTap!();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                overlayColor: FiColors.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
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
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Service service;
  final bool isLast;

  const ServiceCard({super.key, required this.service, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return GenericRowCard(
      isLast: isLast,
      name: service.name,
      description: service.description,
      status: service.status == 'healthy' ? 'ONLINE' : 'OFFLINE',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceView(service: service),
          ),
        );
      },
    );
  }
}

class TerminalCard extends StatelessWidget {
  final String name;
  final String description;
  final String status;
  final bool isLast;

  const TerminalCard({
    super.key,
    required this.name,
    required this.description,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return GenericRowCard(
      isLast: isLast,
      name: name,
      description: description,
      status: status,
    );
  }
}