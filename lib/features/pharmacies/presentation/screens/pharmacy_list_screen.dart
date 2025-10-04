import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/pharmacy_repository.dart';
import '../../data/models/pharmacy_model.dart';

class PharmacyListScreen extends StatefulWidget {
  final String? prescriptionId;

  const PharmacyListScreen({
    super.key,
    this.prescriptionId,
  });

  @override
  State<PharmacyListScreen> createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends State<PharmacyListScreen> {
  final PharmacyRepository _pharmacyRepo = PharmacyRepository();
  List<PharmacyModel> _pharmacies = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // 30분 쿨다운 관리
  Map<String, PrescriptionSendInfo> _sendStatus = {};
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
    _loadSendStatus();

    // 매 분마다 현재 시간 업데이트 (쿨다운 표시용)
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSendStatus() async {
    if (widget.prescriptionId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = prefs.getString('prescription_send_status');

      if (statusJson != null) {
        final Map<String, dynamic> statusMap = jsonDecode(statusJson);
        final Map<String, PrescriptionSendInfo> loadedStatus = {};

        statusMap.forEach((key, value) {
          loadedStatus[key] = PrescriptionSendInfo.fromJson(value);
        });

        // 30분이 지난 항목은 제거
        final now = DateTime.now();
        loadedStatus.removeWhere((key, info) {
          final elapsed = now.difference(info.sentAt);
          return elapsed.inMinutes >= 30;
        });

        setState(() {
          _sendStatus = loadedStatus;
        });
      }
    } catch (e) {
      print('Load send status error: $e');
    }
  }

  Future<void> _saveSendStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> statusMap = {};

      _sendStatus.forEach((key, info) {
        statusMap[key] = info.toJson();
      });

      await prefs.setString('prescription_send_status', jsonEncode(statusMap));
    } catch (e) {
      print('Save send status error: $e');
    }
  }

  Future<void> _loadPharmacies() async {
    setState(() => _isLoading = true);

    try {
      // TODO: 실제 위치 정보 가져오기 (Geolocator 패키지 사용)
      final pharmacies = await _pharmacyRepo.getPharmacies(
        // latitude: currentLat,
        // longitude: currentLng,
        radius: 10.0,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      setState(() {
        _pharmacies = pharmacies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('약국 로드 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.prescriptionId != null ? '약국 선택' : '가까운 약국'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 검색 바
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '약국 이름 또는 주소 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadPharmacies();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _loadPharmacies(),
            ),
          ),

          // 약국 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pharmacies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_pharmacy_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '가까운 약국이 없습니다',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPharmacies,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pharmacies.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildPharmacyCard(_pharmacies[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  SendButtonStatus _getSendButtonStatus(String pharmacyId) {
    if (widget.prescriptionId == null) {
      return SendButtonStatus(
        canSend: false,
        buttonText: '처방전을 선택해주세요',
        timeRemaining: 0,
      );
    }

    final sendKey = '${widget.prescriptionId}_$pharmacyId';
    final sendInfo = _sendStatus[sendKey];

    if (sendInfo == null) {
      return SendButtonStatus(
        canSend: true,
        buttonText: '이 약국으로 전송',
        timeRemaining: 0,
      );
    }

    const thirtyMinutes = Duration(minutes: 30);
    final elapsed = _currentTime.difference(sendInfo.sentAt);
    final remaining = thirtyMinutes - elapsed;

    if (elapsed >= thirtyMinutes) {
      return SendButtonStatus(
        canSend: true,
        buttonText: '이 약국으로 재전송',
        timeRemaining: 0,
      );
    }

    final minutesRemaining = remaining.inMinutes + 1;
    return SendButtonStatus(
      canSend: false,
      buttonText: '전송완료 (${minutesRemaining}분 후 재전송 가능)',
      timeRemaining: minutesRemaining,
    );
  }

  Widget _buildPharmacyCard(PharmacyModel pharmacy) {
    final buttonStatus = _getSendButtonStatus(pharmacy.id);

    return Card(
      child: InkWell(
        onTap: () {
          if (widget.prescriptionId != null && buttonStatus.canSend) {
            _sendPrescriptionToPharmacy(pharmacy);
          } else if (widget.prescriptionId == null) {
            _showPharmacyDetail(pharmacy);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_pharmacy,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pharmacy.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (pharmacy.distance != null)
                          Text(
                            pharmacy.displayDistance,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: pharmacy.isOpen
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pharmacy.isOpen ? '영업중' : '영업종료',
                      style: TextStyle(
                        color: pharmacy.isOpen ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // 정보
              _buildInfoRow(Icons.location_on, pharmacy.address),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone, pharmacy.phoneNumber),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.access_time, pharmacy.operatingHours),

              // 선택 버튼 (처방전 전송 모드일 때)
              if (widget.prescriptionId != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: buttonStatus.canSend
                        ? () => _sendPrescriptionToPharmacy(pharmacy)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonStatus.canSend
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                      disabledForegroundColor: AppColors.textSecondary,
                    ),
                    child: Text(buttonStatus.buttonText),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  void _showPharmacyDetail(PharmacyModel pharmacy) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pharmacy.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, pharmacy.address),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, pharmacy.phoneNumber),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time, pharmacy.operatingHours),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: 전화 걸기 기능 (url_launcher)
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('전화하기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 지도에서 보기 (url_launcher)
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('지도보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendPrescriptionToPharmacy(PharmacyModel pharmacy) async {
    if (widget.prescriptionId == null) return;

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('처방전 전송'),
        content: Text('${pharmacy.name}로 처방전을 전송하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('전송'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
      final success = await _pharmacyRepo.sendPrescriptionToPharmacy(
        prescriptionId: widget.prescriptionId!,
        pharmacyId: pharmacy.id,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // 로딩 닫기

      if (success) {
        // 전송 성공 - 타임스탬프 저장
        final sendKey = '${widget.prescriptionId}_${pharmacy.id}';
        setState(() {
          _sendStatus[sendKey] = PrescriptionSendInfo(
            sentAt: DateTime.now(),
            pharmacyName: pharmacy.name,
          );
          _currentTime = DateTime.now();
        });
        await _saveSendStatus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pharmacy.name}로 처방전이 전송되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // 성공 결과 반환
      } else {
        throw Exception('전송 실패');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // 로딩 닫기

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('처방전 전송 실패: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// 30분 쿨다운 관리를 위한 헬퍼 클래스
class PrescriptionSendInfo {
  final DateTime sentAt;
  final String pharmacyName;

  PrescriptionSendInfo({
    required this.sentAt,
    required this.pharmacyName,
  });

  Map<String, dynamic> toJson() {
    return {
      'sentAt': sentAt.toIso8601String(),
      'pharmacyName': pharmacyName,
    };
  }

  factory PrescriptionSendInfo.fromJson(Map<String, dynamic> json) {
    return PrescriptionSendInfo(
      sentAt: DateTime.parse(json['sentAt']),
      pharmacyName: json['pharmacyName'],
    );
  }
}

class SendButtonStatus {
  final bool canSend;
  final String buttonText;
  final int timeRemaining;

  SendButtonStatus({
    required this.canSend,
    required this.buttonText,
    required this.timeRemaining,
  });
}
