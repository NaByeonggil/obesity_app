import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../data/models/doctor_model.dart';
import '../widgets/doctor_card.dart';

class ClinicListScreen extends StatefulWidget {
  final String? department;

  const ClinicListScreen({
    super.key,
    this.department,
  });

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends State<ClinicListScreen> {
  List<DoctorModel> _doctors = [];
  List<DoctorModel> _filteredDoctors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedSpecialization;

  final Map<String, String> _departmentNames = {
    'obesity-treatment': '마운자로·위고비',
    'obesity': '비만 관련 처방',
    'eye-care': '인공눈물',
    'cold': '감기 관련',
    'internal-medicine': '내과',
    'pediatrics': '소아과',
    'dermatology': '피부과',
    'orthopedics': '정형외과',
    'neurosurgery': '신경외과',
    'ent': '이비인후과',
    'obgyn': '산부인과',
    'urology': '비뇨기과',
  };

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);

    try {
      final doctorRepo = context.read<DoctorRepository>();
      final doctors = await doctorRepo.getDoctors(department: widget.department);

      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('의사 목록 로드 실패: ${e.toString()}')),
        );
      }
    }
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final matchesSearch = _searchQuery.isEmpty ||
            doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (doctor.clinic?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        final matchesSpecialization = _selectedSpecialization == null ||
            doctor.specialization == _selectedSpecialization;

        return matchesSearch && matchesSpecialization;
      }).toList();
    });
  }

  String _getDepartmentTitle() {
    if (widget.department != null) {
      return _departmentNames[widget.department] ?? '병원 찾기';
    }
    return '병원 찾기';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getDepartmentTitle()),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterDoctors();
                  },
                  decoration: InputDecoration(
                    hintText: '병원명 또는 의사명 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
                const SizedBox(height: 12),
                // Specialization Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('전체'),
                        selected: _selectedSpecialization == null,
                        onSelected: (selected) {
                          setState(() => _selectedSpecialization = null);
                          _filterDoctors();
                        },
                      ),
                      const SizedBox(width: 8),
                      ..._getUniqueSpecializations().map((spec) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(spec),
                            selected: _selectedSpecialization == spec,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSpecialization = selected ? spec : null;
                              });
                              _filterDoctors();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '검색 결과가 없습니다',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDoctors,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredDoctors.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return DoctorCard(
                              doctor: _filteredDoctors[index],
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/booking',
                                  arguments: {
                                    'doctor': _filteredDoctors[index],
                                    'department': widget.department,
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueSpecializations() {
    final specializations = <String>{};
    for (var doctor in _doctors) {
      if (doctor.specialization != null) {
        specializations.add(doctor.specialization!);
      }
    }
    return specializations.toList()..sort();
  }
}
