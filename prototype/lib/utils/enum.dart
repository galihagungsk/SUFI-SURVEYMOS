enum LoadingStep {
  checkingConnection("Memeriksa koneksi..."),
  loadingConfig("Memuat konfigurasi..."),
  preparingUserData("Menyiapkan data..."),
  connectingToServer("Menghubungkan ke server..."),
  openingApp("Membuka aplikasi...");

  final String message;
  const LoadingStep(this.message);
}
