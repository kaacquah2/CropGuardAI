import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data sources
import '../../data/local/database_helper.dart';
import '../../data/ml/crop_disease_classifier.dart';
import '../../data/remote/firebase_auth_service.dart';
import '../../data/remote/firestore_service.dart';

// Repositories
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/classifier_repository_impl.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../data/repositories/detection_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_classifier_repository.dart';
import '../../domain/repositories/i_community_repository.dart';
import '../../domain/repositories/i_detection_repository.dart';

// Use Cases
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/signin_with_google_usecase.dart';
import '../../domain/usecases/auth/signin_anonymously_usecase.dart';
import '../../domain/usecases/auth/send_password_reset_usecase.dart';
import '../../domain/usecases/history/get_history_usecase.dart';
import '../../domain/usecases/history/delete_detection_usecase.dart';
import '../../domain/usecases/home/get_home_data_usecase.dart';
import '../../domain/usecases/scanner/scan_crop_usecase.dart';

// Providers
import '../../presentation/screens/home/home_provider.dart';
import '../../presentation/screens/login/login_provider.dart';
import '../../presentation/screens/register/register_provider.dart';
import '../../presentation/screens/history/history_provider.dart';
import '../../presentation/screens/profile/profile_provider.dart';
import '../../presentation/screens/scanner/scanner_provider.dart';
import '../../presentation/screens/result/result_provider.dart';
import '../../presentation/screens/settings/settings_provider.dart';
import '../../presentation/screens/community/community_provider.dart';
import '../../presentation/screens/result/batch_result_provider.dart';
import '../../presentation/screens/settings/language_provider.dart';
import '../utils/streak_manager.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // 1. Data Sources (Low level)
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService());
  sl.registerLazySingleton<CropDiseaseClassifier>(() => CropDiseaseClassifier());
  sl.registerSingleton<StreakManager>(StreakManager(prefs));

  // 2. Repositories (Implementation details)
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(sl<FirebaseAuthService>()));
  sl.registerLazySingleton<IDetectionRepository>(() => DetectionRepositoryImpl(sl<DatabaseHelper>()));
  sl.registerLazySingleton<ICommunityRepository>(() => CommunityRepositoryImpl(sl<FirestoreService>()));
  sl.registerLazySingleton<IClassifierRepository>(() => ClassifierRepositoryImpl(sl<CropDiseaseClassifier>()));

  // 3. Use Cases (Business logic)
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton<SignInWithGoogleUseCase>(() => SignInWithGoogleUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton<SignInAnonymouslyUseCase>(() => SignInAnonymouslyUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton<SendPasswordResetUseCase>(() => SendPasswordResetUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton<GetHistoryUseCase>(() => GetHistoryUseCase(sl<IDetectionRepository>()));
  sl.registerLazySingleton<DeleteDetectionUseCase>(() => DeleteDetectionUseCase(sl<IDetectionRepository>()));
  sl.registerLazySingleton<GetHomeDataUseCase>(() => GetHomeDataUseCase(sl<IDetectionRepository>()));
  sl.registerLazySingleton<ScanCropUseCase>(() => ScanCropUseCase(sl<IClassifierRepository>(), sl<IDetectionRepository>()));
}

/// Builds the list of top-level providers so they're accessible anywhere
List<SingleChildWidget> buildProviders() {
  return [
    ChangeNotifierProvider(create: (_) => LoginProvider(
      sl<LoginUseCase>(),
      sl<SignInWithGoogleUseCase>(),
      sl<SignInAnonymouslyUseCase>(),
      sl<SendPasswordResetUseCase>(),
      sl<SharedPreferences>(),
    )),
    ChangeNotifierProvider(create: (_) => RegisterProvider(sl<RegisterUseCase>())),
    ChangeNotifierProvider(create: (_) => HomeProvider(sl<GetHomeDataUseCase>(), sl<SharedPreferences>())),
    ChangeNotifierProvider(create: (_) => HistoryProvider(sl<GetHistoryUseCase>(), sl<DeleteDetectionUseCase>())),
    ChangeNotifierProvider(create: (_) => ProfileProvider(sl<FirebaseAuthService>(), sl<DatabaseHelper>(), sl<SharedPreferences>())),
    ChangeNotifierProvider(create: (_) => ScannerProvider(sl<ScanCropUseCase>(), sl<IAuthRepository>())),
    ChangeNotifierProvider(create: (_) => ResultProvider(sl<DatabaseHelper>(), sl<FirestoreService>())),
    ChangeNotifierProvider(create: (_) => SettingsProvider(sl<SharedPreferences>(), sl<FirebaseAuthService>(), sl<DatabaseHelper>())),
    ChangeNotifierProvider(create: (_) => CommunityProvider(sl<FirestoreService>(), sl<FirebaseAuthService>())),
    ChangeNotifierProvider(create: (_) => BatchResultProvider()),
    ChangeNotifierProvider(create: (_) => LanguageProvider(sl<SharedPreferences>())),
  ];
}




