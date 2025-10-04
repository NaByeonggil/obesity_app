import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/appointments/data/repositories/appointment_repository.dart';
import 'features/prescriptions/data/repositories/prescription_repository.dart';
import 'features/clinics/data/repositories/doctor_repository.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/patient_dashboard_screen.dart';
import 'features/clinics/presentation/screens/clinic_list_screen.dart';
import 'features/appointments/presentation/screens/appointment_booking_screen.dart';
import 'features/appointments/presentation/screens/appointment_list_screen.dart';
import 'features/prescriptions/presentation/screens/prescription_list_screen.dart';
import 'features/pharmacies/presentation/screens/pharmacy_list_screen.dart';
import 'features/clinics/data/models/doctor_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<AppointmentRepository>(create: (_) => AppointmentRepository()),
        Provider<PrescriptionRepository>(create: (_) => PrescriptionRepository()),
        Provider<DoctorRepository>(create: (_) => DoctorRepository()),
      ],
      child: MaterialApp(
        title: '비만 치료 플랫폼',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          scaffoldBackgroundColor: AppColors.background,
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            color: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF111827),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        home: const AuthCheckScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            case '/dashboard':
              return MaterialPageRoute(
                builder: (context) => const PatientDashboardScreen(),
              );
            case '/clinics':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => ClinicListScreen(
                  department: args?['department'] as String?,
                ),
              );
            case '/appointments':
              return MaterialPageRoute(
                builder: (context) => const AppointmentListScreen(),
              );
            case '/prescriptions':
              return MaterialPageRoute(
                builder: (context) => const PrescriptionListScreen(),
              );
            case '/booking':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => AppointmentBookingScreen(
                  doctor: args['doctor'] as DoctorModel,
                  department: args['department'] as String?,
                ),
              );
            case '/pharmacies':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => PharmacyListScreen(
                  prescriptionId: args?['prescriptionId'] as String?,
                ),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authRepo = context.read<AuthRepository>();
    final isLoggedIn = await authRepo.isLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
