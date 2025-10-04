import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../prescriptions/data/models/prescription_model.dart';

class PrescriptionCard extends StatelessWidget {
  final PrescriptionModel prescription;
  final VoidCallback onTap;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstMed = prescription.medications.isNotEmpty
        ? prescription.medications.first
        : null;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      firstMed?.name ?? prescription.diagnosis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (prescription.status == 'ISSUED')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.send,
                                size: 14,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '전송 대기',
                                style: TextStyle(
                                  color: AppColors.info,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: prescription.isExpiringSoon
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${prescription.remainingDays}일 남음',
                          style: TextStyle(
                            color: prescription.isExpiringSoon
                                ? AppColors.error
                                : AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (firstMed != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${firstMed.dosage} • ${firstMed.frequency}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '처방의: ${prescription.doctorName}${prescription.doctorClinic != null ? " (${prescription.doctorClinic})" : ""}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (prescription.canSendToPharmacy) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement send to pharmacy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('약국 전송 기능은 준비 중입니다'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('약국으로 전송'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
