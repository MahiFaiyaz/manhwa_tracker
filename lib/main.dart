import 'package:flutter/material.dart';
import 'app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://khbqbdpaiwfnlyrwkzmq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoYnFiZHBhaXdmbmx5cndrem1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MTIzMjksImV4cCI6MjA1NzQ4ODMyOX0.N7FPbhTk9ZAysSTIUsuExzeK8flgKTU7wKjXt5XxbfA',
  );

  runApp(const MyApp());
}
