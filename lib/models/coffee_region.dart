class CoffeeRegion {
  final String name;
  final List<String> countries;

  CoffeeRegion({
    required this.name,
    required this.countries,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'countries': countries,
    };
  }

  factory CoffeeRegion.fromJson(Map<String, dynamic> json) {
    return CoffeeRegion(
      name: json['name'],
      countries: List<String>.from(json['countries']),
    );
  }

  // Create a copy with modified countries list
  CoffeeRegion copyWith({List<String>? countries}) {
    return CoffeeRegion(
      name: this.name,
      countries: countries ?? this.countries,
    );
  }
}

class BeanLibrary {
  List<CoffeeRegion> regions;
  List<String> customBeans;

  BeanLibrary({
    required this.regions,
    this.customBeans = const [],
  });

  // Default regions and countries
  static BeanLibrary defaultLibrary() {
    return BeanLibrary(
      regions: [
        CoffeeRegion(
          name: 'Africa',
          countries: [
            'Ethiopia',
            'Kenya',
            'Rwanda',
            'Uganda',
            'Tanzania',
          ],
        ),
        CoffeeRegion(
          name: 'South & Central America',
          countries: [
            'Colombia',
            'Brazil',
            'Costa Rica',
            'Guatemala',
            'Panama',
            'Honduras',
            'Peru',
          ],
        ),
        CoffeeRegion(
          name: 'Southeast Asia',
          countries: [
            'Indonesia (Sumatra)',
            'Vietnam',
            'Thailand',
            'Papua New Guinea',
            'Yemen',
            'India',
          ],
        ),
      ],
      customBeans: [],
    );
  }

  // Get all beans as a flat list
  List<String> getAllBeans() {
    List<String> allBeans = [];
    for (var region in regions) {
      for (var country in region.countries) {
        allBeans.add(country);
      }
    }
    allBeans.addAll(customBeans);
    return allBeans;
  }

  // Add a custom bean
  void addCustomBean(String beanName) {
    if (!customBeans.contains(beanName)) {
      customBeans.add(beanName);
    }
  }

  // Add a country to a region
  void addCountryToRegion(String regionName, String countryName) {
    for (int i = 0; i < regions.length; i++) {
      if (regions[i].name == regionName) {
        if (!regions[i].countries.contains(countryName)) {
          var updatedCountries = List<String>.from(regions[i].countries);
          updatedCountries.add(countryName);
          regions[i] = regions[i].copyWith(countries: updatedCountries);
        }
        break;
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'regions': regions.map((region) => region.toJson()).toList(),
      'customBeans': customBeans,
    };
  }

  factory BeanLibrary.fromJson(Map<String, dynamic> json) {
    return BeanLibrary(
      regions: (json['regions'] as List)
          .map((region) => CoffeeRegion.fromJson(region))
          .toList(),
      customBeans: List<String>.from(json['customBeans'] ?? []),
    );
  }
}
