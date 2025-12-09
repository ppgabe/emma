import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_URL', obfuscate: true)
  static final String apiUrl = _Env.apiUrl;

  @EnviedField(varName: 'SUPABASE_PUBLISHABLE_KEY', obfuscate: true)
  static final String supabasePublishableKey = _Env.supabasePublishableKey;

  @EnviedField(varName: 'SUPABASE_PROJECT_URL', obfuscate: true)
  static final String supabaseProjectUrl = _Env.supabaseProjectUrl;
}
