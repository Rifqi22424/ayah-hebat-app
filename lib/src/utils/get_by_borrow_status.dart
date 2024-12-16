class GetByBorrowStatus {
    static textByBorrowStatus(String status) {
    switch (status) {
      case "PENDING":
        return "Tanggal pengajuan: ";
      case "ALLOWED":
        return "Tanggal pengambilan: ";
      case "TAKEN":
        return "Tanggal akhir pengumpulan: ";
      case "RETURNED":
        return "Tanggal dikembalikan: ";
      case "CANCELLED":
        return "Tanggal dibatalkan: ";
      default:
        return "Tanggal Kembali: ";
    }
  }

    static statusByBorrowStatus(String status) {
    switch (status) {
      case "PENDING":
        return "Pengajuan";
      case "ALLOWED":
        return "Diperbolehkan";
      case "TAKEN":
        return "Diambil";
      case "RETURNED":
        return "Dikembalikan";
      case "CANCELLED":
        return "Dibatalkan";
      default:
        return "Pengajuan";
    }
  }
}