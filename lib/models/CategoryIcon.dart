/// Represents an available icon choice for training categories.
/// Uses PNG asset files provided by the user and Flaticon.
class CategoryIconOption {
  final String id;
  final String label;
  final String assetPath;

  const CategoryIconOption({
    required this.id,
    required this.label,
    required this.assetPath,
  });

  /// All available icons for category selection.
  static const List<CategoryIconOption> allIcons = [
    CategoryIconOption(id: 'dumbbell', label: 'Dumbbell', assetPath: 'FLUTTER_ICON:dumbbell'),
    CategoryIconOption(id: 'chest', label: 'Chest', assetPath: 'lib/assets/icons/chest.png'),
    CategoryIconOption(id: 'back', label: 'Back', assetPath: 'lib/assets/icons/back.png'),
    CategoryIconOption(id: 'arm', label: 'Arm', assetPath: 'lib/assets/icons/arm.png'),
    CategoryIconOption(id: 'leg', label: 'Leg', assetPath: 'lib/assets/icons/leg.png'),
  ];

  /// Get icon option by id. Returns Dumbbell as fallback.
  static CategoryIconOption getById(String id) {
    return allIcons.firstWhere(
      (icon) => icon.id == id,
      orElse: () => allIcons.first, // Dumbbell as default
    );
  }

  /// Get a default icon id based on a category name.
  static String defaultIconId(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'chest':
        return 'chest';
      case 'back':
        return 'back';
      case 'arm':
      case 'arms':
      case 'bicep':
      case 'biceps':
      case 'tricep':
      case 'triceps':
        return 'arm';
      case 'leg':
      case 'legs':
      case 'quad':
      case 'quads':
      case 'hamstring':
      case 'hamstrings':
        return 'leg';
      case 'others':
      default:
        return 'dumbbell'; // Fallback to dumbbell for general/others categories
    }
  }
}
