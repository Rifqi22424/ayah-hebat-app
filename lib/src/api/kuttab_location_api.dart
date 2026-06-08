import '../models/kuttab_zone_model.dart';

class KuttabLocationApi {
  static const List<Map<String, dynamic>> _mockData = [
    {
      'id': 1,
      'name': 'Zona JABODETABEK',
      'branches': [
        {'id': 1, 'name': 'Cibinong'},
        {'id': 2, 'name': 'Beji'},
        {'id': 3, 'name': 'Sawangan'},
        {'id': 4, 'name': 'Jakarta Timur'},
        {'id': 5, 'name': 'Depok (Pusat)'},
        {'id': 6, 'name': 'Bogor'},
        {'id': 7, 'name': 'Bekasi'},
        {'id': 8, 'name': 'Tangerang Selatan'},
        {'id': 9, 'name': 'Tangerang Kota'},
      ],
    },
    {
      'id': 2,
      'name': 'Zona JAWA BARAT',
      'branches': [
        {'id': 10, 'name': 'Bandung Cileunyi'},
        {'id': 11, 'name': 'Bandung Gedebage'},
        {'id': 12, 'name': 'Sukabumi'},
        {'id': 13, 'name': 'Bandung'},
        {'id': 14, 'name': 'Purwakarta'},
      ],
    },
    {
      'id': 3,
      'name': 'Zona JAWA TENGAH',
      'branches': [
        {'id': 15, 'name': 'Demak'},
        {'id': 16, 'name': 'Yogyakarta'},
        {'id': 17, 'name': 'Semarang'},
        {'id': 18, 'name': 'Tegal'},
        {'id': 19, 'name': 'Purwokerto'},
      ],
    },
    {
      'id': 4,
      'name': 'Zona JAWA TIMUR',
      'branches': [
        {'id': 20, 'name': 'Sidoarjo'},
        {'id': 21, 'name': 'Gresik'},
        {'id': 22, 'name': 'Jember'},
        {'id': 23, 'name': 'Malang'},
        {'id': 24, 'name': 'Jombang'},
        {'id': 25, 'name': 'Probolinggo'},
        {'id': 26, 'name': 'Kediri'},
        {'id': 27, 'name': 'Surabaya'},
      ],
    },
    {
      'id': 5,
      'name': 'Zona SUMATERA',
      'branches': [
        {'id': 28, 'name': 'Medan'},
        {'id': 29, 'name': 'Lampung Pagar Alam'},
        {'id': 30, 'name': 'Lampung Kemiling'},
        {'id': 31, 'name': 'Padang'},
        {'id': 32, 'name': 'Pekanbaru'},
        {'id': 33, 'name': 'Banda Aceh'},
      ],
    },
    {
      'id': 6,
      'name': 'Zona KALIMANTAN \u2013 SULAWESI',
      'branches': [
        {'id': 34, 'name': 'Makassar'},
        {'id': 35, 'name': 'Balikpapan'},
      ],
    },
  ];

  // SWAP SEAM: replace the mock body with an http GET to $serverPath/...
  // keeping this exact signature so the provider and UI do not change.
  Future<List<KuttabZone>> getAllKuttabLocations() async {
    return _mockData
        .map((item) => KuttabZone.fromJson(item))
        .toList();
  }
}
