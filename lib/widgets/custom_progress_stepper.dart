import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomProgressStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  const CustomProgressStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on user reference
    // Primary color for completed/active steps
    final primaryColor = Theme.of(context).primaryColor;
    // Light grey for inactive steps
    final inactiveColor = Colors.grey[300]!;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final step = index + 1;
              final isCompletedOrCurrent = step <= currentStep;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: step == totalSteps ? 0 : 8),
                  height: 6, // h-1.5 is approx 6px
                  decoration: BoxDecoration(
                    color: isCompletedOrCurrent ? primaryColor : inactiveColor,
                    borderRadius: BorderRadius.circular(10), // rounded-full
                  ),
                ),
              );
            }),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Langkah $currentStep/$totalSteps',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                stepTitle,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
