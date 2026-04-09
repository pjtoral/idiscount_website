import 'package:idiscount_website/models/school_option.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolService {
  static final SchoolService _instance = SchoolService._internal();
  static const String _schoolSupabaseUrl =
      'https://xeulpnrqkjbghghbgcfu.supabase.co';
  static const String _schoolSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhldWxwbnJxa2piZ2hnaGJnY2Z1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3ODA2NzAsImV4cCI6MjA2MzM1NjY3MH0.QMLMvZ8qL7UJR78QYtHD2KKRVBf2AMo5EA7D2ToUU7E';
  final SupabaseClient _supabase = SupabaseClient(
    _schoolSupabaseUrl,
    _schoolSupabaseAnonKey,
  );

  SchoolService._internal();

  factory SchoolService() {
    return _instance;
  }

  Future<List<SchoolOption>> fetchSchools() async {
    final rows = await _supabase.from('schools').select();

    final schools =
        rows
            .map((row) => SchoolOption.fromMap(Map<String, dynamic>.from(row)))
            .where((school) => school.names.isNotEmpty)
            .toList();

    schools.sort(
      (a, b) =>
          a.displayLabel.toLowerCase().compareTo(b.displayLabel.toLowerCase()),
    );

    return schools;
  }
}
