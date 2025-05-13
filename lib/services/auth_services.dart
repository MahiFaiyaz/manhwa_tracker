import 'package:supabase_flutter/supabase_flutter.dart';

final session = Supabase.instance.client.auth.currentSession;

Future<bool> isUserLoggedIn() async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user != null) {
    return true;
  }

  return false;
}
