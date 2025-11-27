import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit History'),
      ),
      body: const Center(
        child: Text('History Screen'),
      ),
    );
  }
}





