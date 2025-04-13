import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screen/home_screen.dart';
import 'provider/image_provider.dart';
import 'helper/pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize preferences
  await Pref.initialize();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageBlendProvider()),
      ],
      child: GetMaterialApp(
        title: 'AI Art Blender',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.deepPurple),
            titleTextStyle: TextStyle(
              color: Colors.deepPurple,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

extension AppTheme on ThemeData {
  //light text color
  Color get lightTextColor =>
      brightness == Brightness.dark ? Colors.white70 : Colors.black54;

  //button color
  Color get buttonColor =>
      brightness == Brightness.dark ? Colors.cyan.withOpacity(.5) : Colors.blue;
}
