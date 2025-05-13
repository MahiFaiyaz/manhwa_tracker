import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

Session? get session => supabase.auth.currentSession;
User? get currentUser => Supabase.instance.client.auth.currentUser;

Future<bool> isUserLoggedIn() async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user != null) {
    return true;
  }

  return false;
}
