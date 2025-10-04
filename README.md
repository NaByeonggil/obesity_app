# 비만 치료 플랫폼 - Flutter 모바일 앱

비만 치료를 위한 의료 서비스 플랫폼의 모바일 애플리케이션입니다.

## 주요 기능

### ✅ 구현 완료
- **인증 시스템**: 로그인/로그아웃, 세션 관리, FlutterSecureStorage
- **환자 대시보드**: 12개 진료과 카드, 예약 현황, 처방전 관리
- **병원/의사 검색**: 이름/병원별 검색, 전문 분야 필터링, 진료과별 목록, 위치 정보
- **예약 시스템**:
  - 예약 목록 조회 및 상세 정보
  - 신규 예약 생성 (방문/비대면 진료)
  - 화상/전화 진료 선택
  - 날짜/시간 선택기
  - **예약 취소** (취소 사유 입력, 실시간 반영)
- **처방전 관리**:
  - 처방전 목록 및 상태 표시
  - 약품 상세 정보 (용량, 복용 횟수, 기간)
  - 유효기간 및 남은 일수 표시
  - **약국 전송 기능** (완전 구현, 약국 선택 및 실시간 전송)
- **약국 시스템** ⭐ NEW:
  - 가까운 약국 검색 (위치 기반, 거리 표시)
  - 약국 이름/주소 검색
  - 영업 시간 및 상태 표시
  - 처방전 전송 및 상태 추적
- **데이터 실시간 동기화** ⭐ NEW:
  - 웹 ↔ 앱 환자 데이터 공유
  - 예약 생성/수락/취소 실시간 공유
  - 처방전 발급 및 약국 전송 공유
  - 의사/의원 위치 정보 공유
  - 약국 데이터 및 위치 공유
- **API 통합**: RESTful API 클라이언트, PATCH 메소드 지원, 인증 헤더, 세션 쿠키 관리
- **상태 관리**: Provider 패턴으로 전역 상태 관리
- **Material 3 디자인**: 반응형 UI, 카드 스타일, 색상 시스템

### 🔜 향후 개선 사항
- 실시간 위치 추적 (Geolocator)
- 푸시 알림 (FCM)
- 전화/지도 앱 연동 (URL Launcher)
- 다국어 지원

## 시작하기

### 설치

1. 의존성 설치
\`\`\`bash
cd obesity_app
flutter pub get
\`\`\`

2. API 서버 URL 설정
\`lib/core/constants/api_constants.dart\` 파일에서 baseUrl을 실제 서버 주소로 변경

3. 앱 실행
\`\`\`bash
flutter run
\`\`\`

## 프로젝트 구조

```
lib/
├── core/                    # 핵심 기능
│   ├── constants/          # API URL, 색상 테마
│   └── network/            # Dio HTTP 클라이언트
├── features/               # 기능별 모듈 (Clean Architecture)
│   ├── auth/              # 인증
│   │   ├── data/          # Repository, Models
│   │   └── presentation/  # Screens
│   ├── dashboard/         # 환자 대시보드
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/   # 예약/처방 카드, 진료과 카드
│   ├── appointments/      # 예약 관리
│   │   ├── data/
│   │   └── presentation/  # 예약 목록, 예약 생성
│   ├── clinics/           # 병원/의사 검색
│   │   ├── data/
│   │   └── presentation/  # 의사 목록, 의사 카드
│   ├── prescriptions/     # 처방전
│   │   ├── data/
│   │   └── presentation/  # 처방전 목록, 상세
│   └── pharmacies/        # 약국
│       ├── data/
│       └── presentation/  # 약국 목록, 약국 선택
└── main.dart              # 앱 진입점, Provider 설정, 라우팅
```

## 기술 스택

- **Flutter 3.32+**: 크로스 플랫폼 모바일 개발
- **Provider**: 상태 관리
- **Dio**: HTTP 클라이언트 및 인터셉터
- **FlutterSecureStorage**: 안전한 토큰 저장
- **Material 3 Design**: 최신 디자인 시스템
- **Clean Architecture**: 기능별 모듈 구조

## API 엔드포인트

앱은 다음 API 엔드포인트를 사용합니다:

### 인증
```
POST   /api/auth/login                           # 로그인
GET    /api/auth/me                              # 현재 사용자 정보
```

### 환자 프로필
```
GET    /api/patient/profile                      # 환자 프로필 조회
PUT    /api/patient/profile                      # 환자 프로필 업데이트
```

### 예약
```
GET    /api/patient/appointments                 # 환자 예약 목록
POST   /api/patient/appointments                 # 예약 생성
PATCH  /api/appointments/{id}/status             # 예약 상태 변경 (취소/승인)
```

### 의사/병원
```
GET    /api/doctors                              # 의사 목록
GET    /api/doctors?specialization={spec}        # 전문 분야별 의사 검색
GET    /api/clinics?department={dept}&lat={}&lng={}  # 병원 검색 (위치 기반)
```

### 처방전
```
GET    /api/patient/prescriptions                # 환자 처방전 목록
POST   /api/patient/prescriptions/send-to-pharmacy  # 처방전 약국 전송
```

### 약국
```
GET    /api/pharmacies?latitude={}&longitude={}&radius={}  # 약국 검색 (위치 기반)
```

## 웹 ↔ 앱 데이터 공유

모든 데이터는 웹과 앱 간 실시간으로 동기화됩니다:

- ✅ **환자 정보**: 프로필 수정이 양쪽에 즉시 반영
- ✅ **예약 데이터**: 예약 생성/취소가 웹/앱 모두에서 확인 가능
- ✅ **처방전**: 의사가 웹에서 발급한 처방전을 앱에서 확인 및 약국 전송
- ✅ **의원/약국 위치**: 위치 기반 검색으로 가까운 의료기관 찾기
- ✅ **예약 상태**: 의사의 예약 승인/취소가 환자 앱에 실시간 반영

## 라이선스

Private - All Rights Reserved
