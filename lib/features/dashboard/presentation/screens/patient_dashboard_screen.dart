import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';
import '../../../prescriptions/data/repositories/prescription_repository.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../prescriptions/data/models/prescription_model.dart';
import '../widgets/department_card.dart';
import '../widgets/appointment_card.dart';
import '../widgets/prescription_card.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen>
    with RouteAware {
  List<AppointmentModel> _appointments = [];
  List<PrescriptionModel> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 보일 때마다 데이터 새로고침
    if (!_isLoading) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final appointmentRepo = context.read<AppointmentRepository>();
      final prescriptionRepo = context.read<PrescriptionRepository>();

      final appointments = await appointmentRepo.getPatientAppointments();
      final prescriptions = await prescriptionRepo.getPatientPrescriptions();

      setState(() {
        _appointments = appointments.take(3).toList();
        _prescriptions = prescriptions.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final authRepo = context.read<AuthRepository>();
    await authRepo.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final user = authRepo.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('홈'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      '안녕하세요, ${user?.name ?? '환자'}님',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '필요한 의료 서비스를 선택해 주세요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Department Selection
                    _buildDepartmentSection(),
                    const SizedBox(height: 32),

                    // Prescriptions Section
                    _buildPrescriptionsSection(),
                    const SizedBox(height: 24),

                    // Appointments Section
                    _buildAppointmentsSection(),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDepartmentSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '원하시는 진료를 선택하세요',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '다양한 진료 과목을 온라인/오프라인으로 편리하게 이용할 수 있습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              DepartmentCard(
                title: '마운자로·위고비',
                subtitle: '비만 치료',
                description: 'GLP-1 기반 최신 비만 치료제로 체중 감량을 도와드립니다',
                icon: Icons.medical_services,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                featured: true,
                available: 'offline',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'obesity-treatment'},
                  );
                },
              ),
              DepartmentCard(
                title: '비만 관련 처방',
                subtitle: '체중 관리',
                description: '전문 의료진과 함께 건강한 체중 감량 프로그램',
                icon: Icons.monitor_weight,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                ),
                featured: true,
                available: 'offline',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'obesity'},
                  );
                },
              ),
              DepartmentCard(
                title: '인공눈물',
                subtitle: '안구 건조',
                description: '안구 건조증 치료를 위한 인공눈물 처방',
                icon: Icons.visibility,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                ),
                available: 'online',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'eye-care'},
                  );
                },
              ),
              DepartmentCard(
                title: '감기 관련',
                subtitle: '일반 감기',
                description: '감기 증상 완화를 위한 처방 및 상담',
                icon: Icons.ac_unit,
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                available: 'online',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'cold'},
                  );
                },
              ),
              DepartmentCard(
                title: '내과',
                subtitle: '일반 내과',
                description: '소화기, 호흡기, 순환기 등 내과 진료',
                icon: Icons.local_hospital,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                available: 'online',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'internal-medicine'},
                  );
                },
              ),
              DepartmentCard(
                title: '소아과',
                subtitle: '어린이 진료',
                description: '영유아 및 어린이 전문 진료 서비스',
                icon: Icons.child_care,
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                ),
                available: 'online',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'pediatrics'},
                  );
                },
              ),
              DepartmentCard(
                title: '피부과',
                subtitle: '피부 질환',
                description: '여드름, 아토피, 두드러기 등 피부 질환 진료',
                icon: Icons.face,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
                ),
                available: 'online',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'dermatology'},
                  );
                },
              ),
              DepartmentCard(
                title: '정형외과',
                subtitle: '근골격계',
                description: '관절, 척추, 근육 통증 진료 및 재활 상담',
                icon: Icons.accessibility_new,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B5563), Color(0xFF1F2937)],
                ),
                available: 'online',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'orthopedics'},
                  );
                },
              ),
              DepartmentCard(
                title: '신경외과',
                subtitle: '신경계 질환',
                description: '두통, 어지럼증, 신경통 등 신경계 질환 진료',
                icon: Icons.psychology,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                ),
                available: 'online',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'neurosurgery'},
                  );
                },
              ),
              DepartmentCard(
                title: '이비인후과',
                subtitle: '귀코목',
                description: '중이염, 축농증, 편도염 등 이비인후과 진료',
                icon: Icons.hearing,
                gradient: const LinearGradient(
                  colors: [Color(0xFF14B8A6), Color(0xFF10B981)],
                ),
                available: 'online',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'ent'},
                  );
                },
              ),
              DepartmentCard(
                title: '산부인과',
                subtitle: '여성 건강',
                description: '여성 질환 및 산전 관리 전문 진료',
                icon: Icons.favorite,
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                ),
                available: 'offline',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'obgyn'},
                  );
                },
              ),
              DepartmentCard(
                title: '비뇨기과',
                subtitle: '비뇨기 질환',
                description: '비뇨기계 질환 전문 진료 및 상담',
                icon: Icons.science,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                ),
                available: 'offline',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/clinics',
                    arguments: {'department': 'urology'},
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Show all departments
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('더 많은 진료 과목 보기'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '활성 처방전',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_prescriptions.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/prescriptions');
                },
                child: const Text('전체보기'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_prescriptions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  '현재 활성 처방전이 없습니다',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _prescriptions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return PrescriptionCard(
                prescription: _prescriptions[index],
                onTap: () {
                  Navigator.of(context).pushNamed('/prescriptions');
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '예약 현황',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_appointments.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/appointments');
                },
                child: const Text('전체보기'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_appointments.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  '예정된 진료가 없습니다',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _appointments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return AppointmentCard(
                appointment: _appointments[index],
                onTap: () {
                  Navigator.of(context).pushNamed('/appointments');
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 서비스',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.1,
          children: [
            _buildQuickActionCard(
              icon: Icons.search,
              label: '비급여 의약품 검색',
              onTap: () {
                // TODO: Navigate to pharmacy search
              },
            ),
            _buildQuickActionCard(
              icon: Icons.description,
              label: '진료 기록 조회',
              onTap: () {
                // TODO: Navigate to medical records
              },
            ),
            _buildQuickActionCard(
              icon: Icons.phone,
              label: '의료진 상담',
              onTap: () {
                // TODO: Navigate to consultation
              },
            ),
            _buildQuickActionCard(
              icon: Icons.business,
              label: '약국 찾기',
              onTap: () {
                // TODO: Navigate to pharmacy finder
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
