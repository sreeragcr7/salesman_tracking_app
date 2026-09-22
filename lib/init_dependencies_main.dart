part of 'init_dependencies.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External dependencies
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  _initAuth();
  _initUsers();
  _initTrips();
  _initVisits();
  _initMedia();
}

void _initAuth() {
  sl
    ..registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(supabase: sl<SupabaseClient>()))
    ..registerFactory<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()))
    ..registerFactory<Login>(() => Login(sl<AuthRepository>()))
    ..registerFactory<Logout>(() => Logout(sl<AuthRepository>()))
    ..registerFactory<GetCurrentUser>(() => GetCurrentUser(sl<AuthRepository>()));
}

void _initUsers() {
  sl
    ..registerFactory<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(supabase: sl<SupabaseClient>()))
    ..registerFactory<UserRepository>(() => UserRepositoryImpl(remoteDataSource: sl<UserRemoteDataSource>()))
    ..registerFactory<GetSalesmen>(() => GetSalesmen(sl<UserRepository>()))
    ..registerFactory<CreateSalesman>(() => CreateSalesman(sl<UserRepository>()))
    ..registerFactory<DeleteSalesman>(() => DeleteSalesman(sl<UserRepository>()))
    ..registerFactory<UpdateProfileImage>(() => UpdateProfileImage(sl<UserRepository>()))
    ..registerFactory<UpdateSalesman>(() => UpdateSalesman(sl<UserRepository>()))
    ;
}

void _initTrips() {
  sl
    ..registerFactory<TripRemoteDataSource>(() => TripRemoteDataSourceImpl(supabase: sl<SupabaseClient>()))
    ..registerFactory<TripRepository>(() => TripRepositoryImpl(remoteDataSource: sl<TripRemoteDataSource>()))
    ..registerFactory<GetWorkingTrips>(() => GetWorkingTrips(sl<TripRepository>()))
    ..registerFactory<StartDay>(() => StartDay(sl<TripRepository>()))
    ..registerFactory<GetActiveTripForToday>(() => GetActiveTripForToday(sl<TripRepository>()))
    ..registerFactory<GetTodayTrip>(() => GetTodayTrip(sl<TripRepository>()))
    ..registerFactory<GetTodayTripForUser>(() => GetTodayTripForUser(sl<TripRepository>()))
    ..registerFactory<FinishDay>(() => FinishDay(sl<TripRepository>()))
    ..registerFactory<SaveTripLocation>(() => SaveTripLocation(sl<TripRepository>()))
    ..registerFactory<GetTripLocations>(() => GetTripLocations(sl<TripRepository>()))
    ..registerFactory<GetTripById>(() => GetTripById(sl<TripRepository>()));
}

void _initVisits() {
  sl
    ..registerFactory<VisitRemoteDataSource>(() => VisitRemoteDataSourceImpl(supabase: sl<SupabaseClient>()))
    ..registerFactory<VisitRepository>(() => VisitRepositoryImpl(remoteDataSource: sl<VisitRemoteDataSource>()))
    ..registerFactory<GetVisitsForTrip>(() => GetVisitsForTrip(sl<VisitRepository>()))
    ..registerFactory<CreateVisit>(() => CreateVisit(sl<VisitRepository>()))
    ..registerFactory<CreateVisitMedia>(() => CreateVisitMedia(sl<MediaRepository>()))
    ..registerFactory<GetVisitMedia>(() => GetVisitMedia(sl<MediaRepository>()));
}

void _initMedia() {
  sl
    ..registerFactory<MediaRemoteDataSource>(() => MediaRemoteDataSourceImpl(supabase: sl<SupabaseClient>()))
    ..registerFactory<MediaRepository>(() => MediaRepositoryImpl(remoteDataSource: sl<MediaRemoteDataSource>()))
    ..registerFactory<UploadProfileImage>(() => UploadProfileImage(sl<MediaRepository>()))
    ..registerFactory<UploadVisitMedia>(() => UploadVisitMedia(sl<MediaRepository>()));
}
