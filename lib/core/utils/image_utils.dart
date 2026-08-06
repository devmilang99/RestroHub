class ImageUtils {
  /// Transforms a Supabase storage URL to include optimization parameters.
  ///
  /// Parameters:
  /// - [url]: The original image URL.
  /// - [width]: The desired width of the image.
  /// - [height]: The desired height of the image.
  /// - [quality]: The compression quality (1-100).
  /// - [format]: The image format (e.g., 'webp', 'origin').
  static String getOptimizedUrl(
    String url, {
    int? width,
    int? height,
    int quality = 80,
    String format = 'webp',
  }) {
    if (url.isEmpty || !url.contains('supabase.co/storage/v1/object/public/')) {
      return url;
    }

    // Check if URL already has query parameters
    final uri = Uri.parse(url);
    final queryParams = Map<String, String>.from(uri.queryParameters);

    if (width != null) queryParams['width'] = width.toString();
    if (height != null) queryParams['height'] = height.toString();
    queryParams['quality'] = quality.toString();
    queryParams['format'] = format;

    // Use the render endpoint if available, otherwise append as query params
    // Note: Supabase Storage Transformation is typically handled via query params
    // on the public URL if the project has it enabled.
    return uri.replace(queryParameters: queryParams).toString();
  }

  /// Convenience method for restaurant banners
  static String getRestaurantBanner(String? url) {
    if (url == null || url.isEmpty) return '';
    return getOptimizedUrl(url, width: 800, quality: 75);
  }

  /// Convenience method for restaurant logos/thumbnails
  static String getRestaurantThumbnail(String? url) {
    if (url == null || url.isEmpty) return '';
    return getOptimizedUrl(url, width: 300, quality: 80);
  }

  /// Convenience method for menu items
  static String getMenuItemImage(String? url) {
    if (url == null || url.isEmpty) return '';
    return getOptimizedUrl(url, width: 400, quality: 80);
  }
}
