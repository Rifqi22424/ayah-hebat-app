import '../models/kuttab_branch_model.dart';
import '../models/kuttab_zone_model.dart';

class SchoolField {
  static const String schoolName = 'Kutab Alfatih';

  // Returns "Kutab Alfatih <branchName>"
  static String compose(String branchName) {
    return '$schoolName $branchName';
  }

  // Strips the "Kutab Alfatih " prefix and returns the branch name.
  // If the value does not start with the prefix, returns the trimmed original.
  static String extractBranch(String namaKuttab) {
    final prefix = '$schoolName ';
    if (namaKuttab.startsWith(prefix)) {
      return namaKuttab.substring(prefix.length);
    }
    return namaKuttab.trim();
  }

  // Searches all branches across all zones and returns the matching KuttabBranch,
  // or null if no match is found.
  static KuttabBranch? matchBranch(
      List<KuttabZone> zones, String namaKuttab) {
    final branchName = extractBranch(namaKuttab);
    for (final zone in zones) {
      for (final branch in zone.branches) {
        if (branch.name == branchName) {
          return branch;
        }
      }
    }
    return null;
  }
}
