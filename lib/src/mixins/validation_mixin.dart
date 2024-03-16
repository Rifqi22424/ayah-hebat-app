
mixin ValidationMixin {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password harus setidaknya 8 karakter';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, [String? password]) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != password) {
      return 'Konfirmasi password tidak sesuai dengan password';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor HP tidak boleh kosong';
    }
    if (value.length < 10) {
      return 'Nomor HP setidaknnya berisi 10 nomor';
    }
    return null;
  }

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lengkapi data terlebih dahulu!';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    return null;
  }

  String? validateNoKtp(String? value) {
    if (value!.length != 16) {
      return 'Nomor KTP harus berisi 16 nomor';
    }
    return null;
  }

   String? validateTahun(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tahun tidak boleh kosong';
    }

    int? tahun;
    try {
      tahun = int.parse(value);
    } catch (e) {
      return 'Tahun harus berupa angka';
    }

    if (tahun < 1900 || tahun > 2050) {
      return 'Masukan tahun yang valid';
    }

    return null;
  }

  String? validateAlamat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat tidak boleh kosong';
    }
    if (value.length > 50) {
      return 'Alamat tidak boleh melebihi 50 karakter';
    }
    return null;
  }

  // dropdown vlaidator

  String? validateProvince(String? value) {
    if (value == null || value.isEmpty) {
      return 'Provinsi tidak boleh kosong';
    }
    return null;
  }

  String? validateNonNull(String? value) {
    if (value == null || value.isEmpty) {
      return 'Isi data diatas terlebih dahulu';
    }
    return null;
  }
}
