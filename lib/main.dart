import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/item_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/storage_service.dart';
import 'providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MyApp(storageService: storageService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return CupertinoApp(
          title: 'Lost Item Tracker',
          theme:  CupertinoThemeData(
            primaryColor: CupertinoColors.systemBlue,
            brightness: Brightness.light,
            textTheme: CupertinoTextThemeData(
              textStyle: GoogleFonts.tajawal()
            ),
            scaffoldBackgroundColor: CupertinoColors.systemBackground,
          ),
          locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: LoginScreen(storageService: storageService),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Lost Item Tracker'),
      ),
      body: const Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Text('Welcome to Lost Item Tracker'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add item functionality
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

extension Loclizer on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this)!;
}

