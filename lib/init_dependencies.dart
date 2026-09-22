import 'package:get_it/get_it.dart';
import 'package:salesman_tracking_app/data/datasources/auth_remote_datasource.dart';
import 'package:salesman_tracking_app/data/datasources/media_remote_datasource.dart';
import 'package:salesman_tracking_app/data/datasources/trip_remote_datasource.dart';
import 'package:salesman_tracking_app/data/datasources/user_remote_datasource.dart';
import 'package:salesman_tracking_app/data/datasources/visit_remote_datasource.dart';

import 'package:salesman_tracking_app/data/repositories/auth_repository_impl.dart';
import 'package:salesman_tracking_app/data/repositories/media_repository_impl.dart';

import 'package:salesman_tracking_app/data/repositories/trip_repository_impl.dart';
import 'package:salesman_tracking_app/data/repositories/user_repository_impl.dart';
import 'package:salesman_tracking_app/data/repositories/visit_repository_impl.dart';
import 'package:salesman_tracking_app/domain/repositories/auth_repository.dart';
import 'package:salesman_tracking_app/domain/repositories/media_repository.dart';
import 'package:salesman_tracking_app/domain/repositories/trip_repository.dart';
import 'package:salesman_tracking_app/domain/repositories/user_repository.dart';
import 'package:salesman_tracking_app/domain/repositories/visit_repository.dart';
import 'package:salesman_tracking_app/domain/usecases/auth/get_current_user.dart';
import 'package:salesman_tracking_app/domain/usecases/auth/login.dart';
import 'package:salesman_tracking_app/domain/usecases/auth/logout.dart';
import 'package:salesman_tracking_app/domain/usecases/media/create_visit_media.dart';
import 'package:salesman_tracking_app/domain/usecases/media/get_visit_media.dart';
import 'package:salesman_tracking_app/domain/usecases/media/upload_profile_image.dart';
import 'package:salesman_tracking_app/domain/usecases/media/upload_visit_media.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/finish_day.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_active_trip_for_today.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_today_trip.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_trip_by_id.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_trip_locations.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_working_trips.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/save_trip_location.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/start_day.dart';
import 'package:salesman_tracking_app/domain/usecases/users/create_salesman.dart';
import 'package:salesman_tracking_app/domain/usecases/users/delete_salesman.dart';
import 'package:salesman_tracking_app/domain/usecases/users/get_salesmen.dart';
import 'package:salesman_tracking_app/domain/usecases/users/update_profile_image.dart';
import 'package:salesman_tracking_app/domain/usecases/users/update_salesman.dart';
import 'package:salesman_tracking_app/domain/usecases/visits/create_visit.dart';
import 'package:salesman_tracking_app/domain/usecases/visits/get_visits_for_trip.dart';
import 'domain/usecases/trips/get_today_trip_for_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Part
part 'init_dependencies_main.dart';
