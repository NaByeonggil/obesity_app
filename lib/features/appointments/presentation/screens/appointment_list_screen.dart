import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/appointment_repository.dart';
import '../../data/models/appointment_model.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final appointmentRepo = context.read<AppointmentRepository>();
      final appointments = await appointmentRepo.getPatientAppointments();

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예약 로드 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('내 예약'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '예약이 없습니다',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/clinics');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('병원 찾기'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAppointments,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _appointments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(_appointments[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Card(
      child: InkWell(
        onTap: () {
          _showAppointmentDetail(appointment);
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
                          appointment.doctor,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.clinic ?? '병원 정보 없음',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(appointment.status),
                ],
              ),
              const Divider(height: 24),

              // Details
              _buildInfoRow(
                Icons.local_hospital,
                '진료과',
                appointment.department,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today,
                '예약일',
                '${appointment.date} ${appointment.time}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                appointment.isOnline ? Icons.videocam : Icons.local_hospital,
                '진료 방식',
                appointment.consultationMethod,
              ),
              if (appointment.symptoms?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.edit_note,
                  '증상',
                  appointment.symptoms!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toLowerCase()) {
      case 'confirmed':
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = '확정';
        break;
      case 'pending':
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        text = '대기중';
        break;
      case 'completed':
        bgColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
        text = '완료';
        break;
      case 'cancelled':
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = '취소';
        break;
      default:
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        text = status;
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

  void _showAppointmentDetail(AppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                  '예약 상세',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Doctor Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.doctor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (appointment.clinic != null)
                                    Text(
                                      appointment.clinic!,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Appointment Details
                _buildDetailSection('예약 정보', [
                  _buildDetailRow('진료과', appointment.department),
                  _buildDetailRow('예약일시', '${appointment.date} ${appointment.time}'),
                  _buildDetailRow('진료 방식', appointment.consultationMethod),
                  _buildDetailRow('상태', _getStatusText(appointment.status)),
                ]),

                if (appointment.symptoms?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection('증상', [
                    Text(
                      appointment.symptoms!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ]),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                if (appointment.status.toLowerCase() == 'confirmed') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showCancelDialog(appointment);
                      },
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('예약 취소'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return '확정';
      case 'pending':
        return '대기중';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소';
      default:
        return status;
    }
  }

  Future<void> _showCancelDialog(AppointmentModel appointment) async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('예약을 취소하시겠습니까?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '취소 사유 (선택사항)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('취소하기'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      reasonController.dispose();
      return;
    }

    // 로딩 표시
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final appointmentRepo = context.read<AppointmentRepository>();
      final success = await appointmentRepo.cancelAppointment(
        appointment.id,
        cancelReason: reasonController.text.isNotEmpty ? reasonController.text : null,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // 로딩 닫기
      reasonController.dispose();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('예약이 취소되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
        // 목록 새로고침
        _loadAppointments();
      } else {
        throw Exception('취소 실패');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // 로딩 닫기
      reasonController.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('예약 취소 실패: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
