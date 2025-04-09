import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brewhand/models/coffee_region.dart';

class BeanLibraryService {
  static const String _beanLibraryKey = 'bean_library';

  // Singleton pattern
  static final BeanLibraryService _instance = BeanLibraryService._internal();

  factory BeanLibraryService() {
    return _instance;
  }

  BeanLibraryService._internal();

  Future<BeanLibrary> getBeanLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final String? libraryJson = prefs.getString(_beanLibraryKey);

    if (libraryJson == null) {
      // Return the default library if none is saved
      return BeanLibrary.defaultLibrary();
    }

    return BeanLibrary.fromJson(jsonDecode(libraryJson));
  }

  Future<void> saveBeanLibrary(BeanLibrary library) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_beanLibraryKey, jsonEncode(library.toJson()));
  }

  Future<void> addCustomBean(String beanName) async {
    BeanLibrary library = await getBeanLibrary();
    library.addCustomBean(beanName);
    await saveBeanLibrary(library);
  }

  Future<void> addCountryToRegion(String regionName, String countryName) async {
    BeanLibrary library = await getBeanLibrary();
    library.addCountryToRegion(regionName, countryName);
    await saveBeanLibrary(library);
  }

  Future<List<String>> getAllBeans() async {
    BeanLibrary library = await getBeanLibrary();
    return library.getAllBeans();
  }

  Future<List<CoffeeRegion>> getRegions() async {
    BeanLibrary library = await getBeanLibrary();
    return library.regions;
  }

  // Reset to default library
  Future<void> resetToDefaultLibrary() async {
    await saveBeanLibrary(BeanLibrary.defaultLibrary());
  }
}
