import "package:flutter/material.dart";

class ErrorMessageDialog extends StatelessWidget {
  final String message;

  const ErrorMessageDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width - 100,
      child: Column(
        children: [
          Icon(Icons.error),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(message, softWrap: true, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
