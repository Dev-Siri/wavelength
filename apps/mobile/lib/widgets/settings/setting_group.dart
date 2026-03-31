import "package:flutter/material.dart";

class SettingGroup extends StatelessWidget {
  final List<Widget> options;

  const SettingGroup({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade900,
      ),
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            options[i],
            if (i != options.length - 1)
              Container(
                height: 1,
                color: Colors.grey.shade800,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
          ],
        ],
      ),
    );
  }
}
