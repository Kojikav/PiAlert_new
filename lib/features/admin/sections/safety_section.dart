import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/safety_confirmation_model.dart';
import '../../../services/firestore_service.dart';

class SafetySection extends StatelessWidget {
  const SafetySection({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.safetyConfirmations.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final confirmations = snapshot.data!.docs.map((doc) {
          return SafetyConfirmationModel.fromFirestore(doc);
        }).toList();

        if (confirmations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text('Belum ada warga yang konfirmasi',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        )),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text('${confirmations.length} warga sudah konfirmasi aman',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: confirmations.length,
                itemBuilder: (context, index) {
                  final c = confirmations[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.person, color: AppColors.success),
                    title: Text(c.name),
                    subtitle: Text('${DateFormatter.timeAgo(c.confirmedAt)} • Level ${c.siagaLevel}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
