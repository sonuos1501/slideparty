import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slideparty/src/features/app_setting/app_setting_controller.dart';
import 'package:slideparty/src/features/home/home.dart';
import 'package:slideparty/src/features/multiple_mode/multiple_mode.dart';
import 'package:slideparty/src/features/online_mode/online_mode.dart';
import 'package:slideparty/src/features/playboard/playboard.dart';
import 'package:slideparty/src/features/single_mode/controllers/single_mode_controller.dart';
import 'package:slideparty/src/features/single_mode/single_mode.dart';
import 'package:slideparty/src/widgets/buttons/models/slideparty_button_params.dart';

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  static final router = GoRouter(
    initialLocation: '/',
    urlPathStrategy: UrlPathStrategy.hash,
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: '/s_mode',
        pageBuilder: (context, state) => NoTransitionPage(
          child: ProviderScope(
            overrides: [
              playboardControllerProvider
                  .overrideWithProvider(singleModeControllerProvider),
            ],
            child: const SingleModePage(),
          ),
        ),
      ),
      GoRoute(
        path: '/o_mode',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnlineModePage(),
        ),
      ),
      GoRoute(
        path: '/m_mode',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MultipleModePage(),
        ),
      ),
    ],
  );

  @override
  _AppState createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final playboardDefaultColor = ref
        .watch(playboardInfoControllerProvider.select((value) => value.color));
    final isDarkTheme = ref.watch(
        appSettingControllerProvider.select((value) => value.isDarkTheme));

    return MaterialApp.router(
      routeInformationParser: App.router.routeInformationParser,
      routerDelegate: App.router.routerDelegate,
      debugShowCheckedModeBanner: false,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: FlexColorScheme.light(
        fontFamily: 'kenvector_future',
        primary: playboardDefaultColor.primaryColor,
        blendLevel: 20,
        surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
      ).toTheme,
      darkTheme: FlexColorScheme.dark(
        fontFamily: 'kenvector_future',
        primary: playboardDefaultColor.primaryColor,
        blendLevel: 20,
        surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
      ).toTheme,
    );
  }
}
