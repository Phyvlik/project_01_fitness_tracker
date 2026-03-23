import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'providers/app_provider.dart';
import 'widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite needs an explicit database factory on web.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final appProvider = AppProvider();
  await appProvider.init();
  runApp(MyApp(appProvider: appProvider));
}

class MyApp extends StatelessWidget {
  final AppProvider? appProvider;

  const MyApp({super.key, this.appProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: appProvider)],
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Fitness Quest & Training Challenge Hub',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: provider.isDarkMode
                    ? Brightness.dark
                    : Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}
