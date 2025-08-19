class AppConfig {
  static const String appName = 'MoBusiness';
  static const String appVersion = '1.0.0';
  
  // API URLs
  static const String baseUrl = 'YOUR_API_URL';
  
  // Gas Types in Tanzania
  static const List<String> gasTypes = [
    'Oryx Gas',
    'Lake Gas',
    'Mihan Gas',
    'Tauragas',
    'Green Gas',
    // Add more gas types as needed
  ];
  
  // Common gas tank sizes in Tanzania (in KG)
  static const List<int> tankSizes = [6, 13, 15, 38, 45];
}
