class IndonesiaMonth {
  static const Map<int, String> _bulanIndonesia = {
    1: "Januari",
    2: "Februari",
    3: "Maret",
    4: "April",
    5: "Mei",
    6: "Juni",
    7: "Juli",
    8: "Agustus",
    9: "September",
    10: "Oktober",
    11: "November",
    12: "Desember",
  };

  static const Map<int, String> _dayIndonesia = {
    1: "Senin",
    2: "Selasa",
    3: "Rabu",
    4: "Kamis",
    5: "Jumat",
    6: "Sabtu",
    7: "Minggu",
  };

  static String? getMonthName(int monthNumber) {
    return _bulanIndonesia[monthNumber];
  }

  static String? getDayName(int dayNumber) {
    int validDayNumber = dayNumber > 7 ? dayNumber % 7 : dayNumber;
    return _dayIndonesia[validDayNumber];
  }
}
