class GetMediaType {
  static String getMediaType(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    if (extension == 'jpeg' || extension == 'jpg' || extension == 'png') {
      return 'image';
    } else {
      return 'application';
    }
  }
}
