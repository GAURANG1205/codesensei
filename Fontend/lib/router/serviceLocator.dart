import 'package:codesensei/logic/Auth/AuthCubit.dart';
import 'package:codesensei/logic/OtherCubit/codeTranspilerCubit.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getit = GetIt.instance;
Future<void> setupServiceLocator() async {
  getit.registerLazySingleton(()=>AppRouter());
  getit.registerLazySingleton(()=>AuthCubit());
  getit.registerLazySingleton(()=>codeTranspilerCubit());
}