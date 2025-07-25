String abbreviateSemester(String semesterName) {
  if (semesterName.toLowerCase().contains('fall')) {
    String year = semesterName.replaceAll(RegExp(r'[^0-9]'), '');
    return 'F${year.substring(year.length - 2)}';
  } else if (semesterName.toLowerCase().contains('spring')) {
    String year = semesterName.replaceAll(RegExp(r'[^0-9]'), '');
    return 'S${year.substring(year.length - 2)}';
  } else if (semesterName.toLowerCase().contains('summer')) {
    String year = semesterName.replaceAll(RegExp(r'[^0-9]'), '');
    return 'Su${year.substring(year.length - 2)}';
  }
  // Fallback: take first 3 characters
  return semesterName.length > 3 ? semesterName.substring(0, 3) : semesterName;
}
