import 'package:codesensei/Screen/AuthIntialization.dart';

import 'package:codesensei/Theme/ThemeData.dart';
import 'package:codesensei/logic/Auth/AuthCubit.dart';
import 'package:codesensei/logic/OtherCubit/codeTranspilerCubit.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async{
 final widgetbinding = WidgetsFlutterBinding.ensureInitialized();
 FlutterNativeSplash.preserve(widgetsBinding: widgetbinding);
  await setupServiceLocator();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => getit<AuthCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'CodeSensei',
        navigatorKey: getit<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        darkTheme: DarkModeTheme(context),
        theme: lightModeTheme(context),
        home: AuthInitialization(),
      ),
    );
  }
}
