import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/prescription_repository.dart';
import '../../data/models/prescription_model.dart';

class PrescriptionListScreen extends StatefulWidget {
  const PrescriptionListScreen({super.key});

  @override
  State<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  List<PrescriptionModel> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);

    try {
      final prescriptionRepo = context.read<PrescriptionRepository>();
      final prescriptions = await prescriptionRepo.getPatientPrescriptions();

      setState(() {
        _prescriptions = prescriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('처방전 로드 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('처방전'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescriptions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '처방전이 없습니다',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPrescriptions,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _prescriptions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildPrescriptionCard(_prescriptions[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionModel prescription) {
    final firstMed = prescription.medications.isNotEmpty
        ? prescription.medications.first
        : null;

    return Card(
      child: InkWell(
        onTap: () {
          _showPrescriptionDetail(prescription);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstMed?.name ?? prescription.diagnosis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '처방번호: ${prescription.prescriptionNumber}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(prescription),
                ],
              ),
              const Divider(height: 24),

              // Details
              _buildInfoRow(
                Icons.person,
                '처방의',
                '${prescription.doctorName}${prescription.doctorClinic != null ? " (${prescription.doctorClinic})" : ""}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.local_hospital,
                '진료과',
                prescription.departmentName,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today,
                '발급일',
                DateFormat('yyyy.MM.dd').format(prescription.issuedAt),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.event_available,
                '유효기간',
                '${DateFormat('yyyy.MM.dd').format(prescription.validUntil)} (${prescription.remainingDays}일 남음)',
              ),

              // Medications
              if (prescription.medications.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  '약품 목록 (${prescription.medications.length}개)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...prescription.medications.take(2).map((med) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${med.name} - ${med.dosage}, ${med.frequency}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (prescription.medications.length > 2)
                  Text(
                    '외 ${prescription.medications.length - 2}개',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],

              // Action Button
              if (prescription.canSendToPharmacy) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showSendToPharmacyDialog(prescription);
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

  Widget _buildStatusBadge(PrescriptionModel prescription) {
    Color bgColor;
    Color textColor;
    String text = prescription.statusText;

    switch (prescription.status) {
      case 'ISSUED':
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      case 'PENDING':
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case 'DISPENSING':
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case 'DISPENSED':
        bgColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
        break;
      default:
        bgColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPrescriptionDetail(PrescriptionModel prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '처방전 상세',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // All medications
                Text(
                  '처방 약품',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...prescription.medications.map((med) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMedicationInfo('용량', med.dosage),
                          _buildMedicationInfo('복용 횟수', med.frequency),
                          _buildMedicationInfo('복용 기간', med.duration),
                          if (med.description != null)
                            _buildMedicationInfo('설명', med.description!),
                        ],
                      ),
                    ),
                  );
                }),

                // Notes
                if (prescription.notes != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '참고사항',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prescription.notes!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSendToPharmacyDialog(PrescriptionModel prescription) async {
    final result = await Navigator.of(context).pushNamed(
      '/pharmacies',
      arguments: {'prescriptionId': prescription.id},
    );

    if (result == true && mounted) {
      // 전송 성공 시 처방전 목록 새로고침
      _loadPrescriptions();
    }
  }
}
