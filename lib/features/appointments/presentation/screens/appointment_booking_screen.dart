import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../clinics/data/models/doctor_model.dart';
import '../../data/repositories/appointment_repository.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final DoctorModel doctor;
  final String? department;

  const AppointmentBookingScreen({
    super.key,
    required this.doctor,
    this.department,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _appointmentType = 'offline'; // 'online' or 'offline'
  String _consultationType = 'video'; // 'video' or 'phone' for online
  bool _isLoading = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜와 시간을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appointmentRepo = context.read<AppointmentRepository>();

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      String notes = '';
      if (_appointmentType == 'online') {
        notes = _consultationType == 'video' ? '화상진료' : '전화진료';
      }

      final appointment = await appointmentRepo.createAppointment(
        doctorId: widget.doctor.id,
        date: dateStr,
        time: timeStr,
        type: _appointmentType,
        symptoms: _symptomsController.text,
        department: widget.department ?? 'internal-medicine',
        notes: notes,
      );

      if (!mounted) return;

      if (appointment != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('예약이 완료되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
        // 예약 현황 페이지로 이동
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushNamed('/appointments');
      } else {
        throw Exception('예약 생성 실패');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('예약 실패: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('예약하기'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctor.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.doctor.displaySpecialization,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.doctor.displayClinic,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Appointment Type
              Text(
                '진료 방식',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAppointmentTypeCard(
                      type: 'offline',
                      icon: Icons.local_hospital,
                      title: '방문 진료',
                      subtitle: '병원 방문',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAppointmentTypeCard(
                      type: 'online',
                      icon: Icons.videocam,
                      title: '비대면 진료',
                      subtitle: '온라인',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Online Consultation Type
              if (_appointmentType == 'online') ...[
                Text(
                  '비대면 진료 방법',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildConsultationTypeCard(
                        type: 'video',
                        icon: Icons.videocam,
                        title: '화상 진료',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildConsultationTypeCard(
                        type: 'phone',
                        icon: Icons.phone,
                        title: '전화 진료',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Date & Time
              Text(
                '예약 일시',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? '날짜 선택'
                                  : DateFormat('yyyy년 MM월 dd일')
                                      .format(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              _selectedTime == null
                                  ? '시간 선택'
                                  : _selectedTime!.format(context),
                              style: TextStyle(
                                color: _selectedTime == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Symptoms
              Text(
                '증상',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _symptomsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '현재 증상을 자세히 입력해주세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '증상을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '예약하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentTypeCard({
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _appointmentType == type;
    return InkWell(
      onTap: () => setState(() => _appointmentType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationTypeCard({
    required String type,
    required IconData icon,
    required String title,
  }) {
    final isSelected = _consultationType == type;
    return InkWell(
      onTap: () => setState(() => _consultationType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.success.withOpacity(0.05)
              : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
