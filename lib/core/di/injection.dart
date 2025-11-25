import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../config/constants.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../data/repositories/ai_processing_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../domain/repositories/ai_processing_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/photo/upload_photo_usecase.dart';
import '../../domain/usecases/photo/get_photos_usecase.dart';
import '../../domain/usecases/ai/enhance_photo_usecase.dart';
import '../../domain/usecases/ai/restore_photo_usecase.dart';
import '../../domain/usecases/ai/face_swap_usecase.dart';
import '../../domain/usecases/ai/aging_effect_usecase.dart';
import '../../domain/usecases/ai/style_transfer_usecase.dart';
import '../../domain/usecases/ai/apply_filter_usecase.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/home/home_bloc.dart';
import '../../presentation/bloc/photo_editor/photo_editor_bloc.dart';
import '../../presentation/bloc/subscription/subscription_bloc.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<Dio>(() => _createDio());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<ApiClient>()));

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(apiService: getIt<ApiService>(), localStorage: getIt<LocalStorage>()));
  getIt.registerLazySingleton<PhotoRepository>(() => PhotoRepositoryImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<AIProcessingRepository>(() => AIProcessingRepositoryImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(apiService: getIt<ApiService>()));

  getIt.registerFactory(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => UploadPhotoUseCase(getIt<PhotoRepository>()));
  getIt.registerFactory(() => GetPhotosUseCase(getIt<PhotoRepository>()));
  getIt.registerFactory(() => EnhancePhotoUseCase(getIt<AIProcessingRepository>()));
  getIt.registerFactory(() => RestorePhotoUseCase(getIt<AIProcessingRepository>()));
  getIt.registerFactory(() => FaceSwapUseCase(getIt<AIProcessingRepository>()));
  getIt.registerFactory(() => AgingEffectUseCase(getIt<AIProcessingRepository>()));
  getIt.registerFactory(() => StyleTransferUseCase(getIt<AIProcessingRepository>()));
  getIt.registerFactory(() => ApplyFilterUseCase(getIt<AIProcessingRepository>()));

  getIt.registerFactory(() => AuthBloc(loginUseCase: getIt<LoginUseCase>(), registerUseCase: getIt<RegisterUseCase>(), logoutUseCase: getIt<LogoutUseCase>(), localStorage: getIt<LocalStorage>()));
  getIt.registerFactory(() => HomeBloc(getPhotosUseCase: getIt<GetPhotosUseCase>()));
  getIt.registerFactory(() => PhotoEditorBloc(enhancePhotoUseCase: getIt<EnhancePhotoUseCase>(), restorePhotoUseCase: getIt<RestorePhotoUseCase>(), faceSwapUseCase: getIt<FaceSwapUseCase>(), agingEffectUseCase: getIt<AgingEffectUseCase>(), styleTransferUseCase: getIt<StyleTransferUseCase>(), applyFilterUseCase: getIt<ApplyFilterUseCase>()));
  getIt.registerFactory(() => SubscriptionBloc(subscriptionRepository: getIt<SubscriptionRepository>()));
}

Dio _createDio() {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl, connectTimeout: AppConstants.apiTimeout, receiveTimeout: AppConstants.apiTimeout, headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}));
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async { final localStorage = getIt<LocalStorage>(); final token = await localStorage.getToken(); if (token != null) { options.headers['Authorization'] = 'Bearer $token'; } return handler.next(options); }, onError: (error, handler) async { if (error.response?.statusCode == 401) {} return handler.next(error); }));
  return dio;
}


