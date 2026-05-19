import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:storage/storage.dart';

class AppEnv {
  static Future<void> load(Flavor flavor) async {
    await dotenv.load(fileName: '.env.${flavor.name}');
  }

  static String? get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'];
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String? get byPassAppCheck => dotenv.env['BYPASS_APP_CHECK_TOKEN'];
  static String get appId => dotenv.env['APP_ID'] ?? '';
  static String get iosAppStoreId => dotenv.env['IOS_APP_STORE_ID'] ?? '';
  static String get amplitudeApiKey => dotenv.env['AMPLITUDE_API_KEY'] ?? '';
  static String get chottuLinkApiKey => dotenv.env['CHOTTULINK_API_KEY'] ?? '';
  static String get mapboxKey => dotenv.env['MAPBOX_KEY'] ?? '';
  static String get mapboxAccessToken => mapboxKey;
}
