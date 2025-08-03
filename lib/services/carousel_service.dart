import 'package:homechef/models/carousel_item.dart';
import 'package:homechef/supabase/supabase_config.dart';

class CarouselService {
  static const String tableName = 'carousel';
  
  /// Fetches carousel items from Supabase database
  static Future<List<CarouselItem>> fetchCarouselItems() async {
    try {
      final response = await SupabaseConfig.client
          .from(tableName)
          .select('*')
          .order('order', ascending: true)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return CarouselItem.getSampleItems();
      }
      
      final items = response
          .map<CarouselItem>((json) => CarouselItem.fromJson(json))
          .toList();
      
      return items;
    } catch (error) {
      // Return sample data as fallback
      return CarouselItem.getSampleItems();
    }
  }
  
  /// Legacy method for storage-based approach (kept for compatibility)
  static Future<List<CarouselItem>> fetchCarouselItemsFromStorage() async {
    // Redirecting to database approach
    return fetchCarouselItems();
  }
  
  /// Fetches a specific carousel item by ID
  static Future<CarouselItem?> fetchCarouselItemById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(tableName)
          .select('*')
          .eq('id', id)
          .single();

      return CarouselItem.fromJson(response);
    } catch (error) {
      return null;
    }
  }
}