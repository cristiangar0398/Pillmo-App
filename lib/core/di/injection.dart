import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/config/environment.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/firebase_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_email.dart';
import '../../features/auth/domain/usecases/register_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/presentation/blocs/auth_cubit.dart';
import '../../features/calendar/presentation/blocs/calendar_cubit.dart';
import '../../features/medications/data/datasources/medications_remote_data_source.dart';
import '../../features/medications/data/repositories/medications_repository_impl.dart';
import '../../features/medications/domain/repositories/medications_repository.dart';
import '../../features/medications/domain/usecases/get_medications.dart';
import '../../features/medications/presentation/blocs/medications_cubit.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../theme/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt
    ..registerLazySingleton<Dio>(
      () => Dio(BaseOptions(baseUrl: Environment.apiBaseUrl)),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()))
    ..registerLazySingleton<SecureStorage>(
      () => SecureStorage(const FlutterSecureStorage()),
    )
    ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn())
    ..registerLazySingleton<FirebaseAuthDataSource>(
      () => FirebaseAuthDataSourceImpl(getIt<GoogleSignIn>()),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(getIt<SecureStorage>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<FirebaseAuthDataSource>(),
        getIt<AuthRemoteDataSource>(),
        getIt<AuthLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<RegisterWithEmailUseCase>(
      () => RegisterWithEmailUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<LoginWithEmailUseCase>(
      () => LoginWithEmailUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<SignInWithGoogleUseCase>(
      () => SignInWithGoogleUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        getIt<RegisterWithEmailUseCase>(),
        getIt<LoginWithEmailUseCase>(),
        getIt<SignInWithGoogleUseCase>(),
        getIt<AuthLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<MedicationRemoteDataSource>(
      () => MedicationRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<MedicationsRepository>(
      () => MedicationRepositoryImpl(getIt<MedicationRemoteDataSource>()),
    )
    ..registerLazySingleton<GetTodayTimelineUseCase>(
      () => GetTodayTimelineUseCase(getIt<MedicationsRepository>()),
    )
    ..registerLazySingleton<CreateMedicationUseCase>(
      () => CreateMedicationUseCase(getIt<MedicationsRepository>()),
    )
    ..registerLazySingleton<ConfirmDoseUseCase>(
      () => ConfirmDoseUseCase(getIt<MedicationsRepository>()),
    )
    ..registerLazySingleton<ScanPrescriptionUseCase>(
      () => ScanPrescriptionUseCase(getIt<MedicationsRepository>()),
    )
    ..registerLazySingleton<GetTimelineRangeUseCase>(
      () => GetTimelineRangeUseCase(getIt<MedicationsRepository>()),
    )
    ..registerFactory<MedicationCubit>(
      () => MedicationCubit(
        getIt<GetTodayTimelineUseCase>(),
        getIt<CreateMedicationUseCase>(),
        getIt<ConfirmDoseUseCase>(),
        getIt<ScanPrescriptionUseCase>(),
      ),
    )
    ..registerFactory<CalendarCubit>(
      () => CalendarCubit(
        getIt<GetTimelineRangeUseCase>(),
        getIt<ConfirmDoseUseCase>(),
      ),
    )
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
