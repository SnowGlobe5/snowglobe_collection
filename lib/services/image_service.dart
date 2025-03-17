import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  final supabase = Supabase.instance.client;

  /// Deletes an image at the given [path] from the 'snowglobe-images' storage bucket.
  Future<void> deleteImage(String path) async {
    try {
      // The remove method takes a list of paths.
      await supabase.storage.from('snowglobe-images').remove([path]);
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }

  /// Uploads the given [imageFile] to the specified [path] in the 'snowglobe-images' storage bucket.
  /// Returns the public URL of the uploaded image.
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      // Use the upsert option to replace if the file already exists.
      await supabase.storage.from('snowglobe-images').upload(
            path,
            imageFile,
            fileOptions: FileOptions(upsert: true),
          );
      final publicUrl = supabase.storage.from('snowglobe-images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
