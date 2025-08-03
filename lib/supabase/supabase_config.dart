import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = "https://iiqrtzioysbuyrrxxqdu.supabase.co";
  static const String anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlpcXJ0emlveXNidXlycnh4cWR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMjg3ODQsImV4cCI6MjA1NTcwNDc4NH0.EsqCPJwF8I6yuy0aXfZyFC8EgeOxSVeTKaGQ2EUrsbA";
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
    );
  }
  
  // Helper method for getting public storage URL
  static String getPublicImageUrl(String bucketName, String filePath) {
    return client.storage.from(bucketName).getPublicUrl(filePath);
  }
  
  // Helper method for error handling
  static String handleError(dynamic error) {
    if (error is PostgrestException) {
      return 'Database error: ${error.message}';
    } else if (error is StorageException) {
      return 'Storage error: ${error.message}';
    } else {
      return 'Unknown error occurred: $error';
    }
  }
}