import 'package:flutter/material.dart';

class FiColors {
  static const Color primary = Color(0xFFc89424);
  static const Color secondary = Color.fromARGB(255, 131, 100, 32);
  static const Color mainText = Color(0xFFa9a9a9);
  static const Color secondaryText = Color(0xFF828282);
  static const Color background = Color(0xFF000000);
  static const Color controlBackground = Color(0xFF0a0a0a);
  static const Color controlBorder = Color(0xFF222222);
  static const Color backgroundHighlight = Color.fromARGB(255, 29, 23, 6);
  static const Color border = Color.fromARGB(255, 46, 36, 10);
  static const Color red = Color.fromARGB(255, 216, 74, 88);
  static const Color green1 = Color.fromARGB(255, 74, 216, 88);
  static const Color green2 = Color(0xFF3a8041);
}

class FiHeading extends StatelessWidget {
  final String primaryText;
  final String? secondaryText;
  const FiHeading({super.key, required this.primaryText, this.secondaryText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: FiColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 22,
          alignment: Alignment.center,
          child: Text(
            primaryText,
            style: const TextStyle(
              color: FiColors.backgroundHighlight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: FiColors.backgroundHighlight,
            height: 24,
            padding: const EdgeInsets.only(right: 5),
            child: secondaryText != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        secondaryText!,
                        style: TextStyle(
                          color: FiColors.secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class FiStatusTag extends StatelessWidget {
  final String text;
  final Color color;
  const FiStatusTag({super.key, required this.text, this.color = FiColors.green1});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FiColors.background,
        border: Border.all(color: FiColors.controlBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 0.5),
            child: Text(
              text,
              style: const TextStyle(
                color: FiColors.mainText,
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
