function hitungCicilan() {
  const nama = document.getElementById("nama").value;
  const harga = parseFloat(document.getElementById("harga").value);
  const dpPersen = parseFloat(document.getElementById("dp").value);
  const tenor = parseInt(document.getElementById("tenor").value);

  if (isNaN(harga) || isNaN(dpPersen) || isNaN(tenor)) {
    document.getElementById("hasil").innerHTML =
      "⚠️ Mohon isi harga, DP, dan tenor dengan benar!";
    return;
  }

  const dpNominal = (dpPersen / 100) * harga;
  const sisa = harga - dpNominal;
  const cicilan = sisa / tenor;

  // Fungsi untuk menampilkan hasil + kirim ke Flutter
  const tampilkanHasil = (lat, long) => {
    const data = {
      nama,
      harga,
      dp: dpNominal,
      cicilan,
      lat,
      long,
    };

    // kirim data ke Flutter jika dalam InAppWebView
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler("jawaban", JSON.stringify(data));
    }

    // tampilkan di halaman HTML
    document.getElementById("hasil").innerHTML = `
      <b>Nama:</b> ${nama}<br>
      <b>Harga:</b> Rp ${harga.toLocaleString("id-ID")}<br>
      <b>DP:</b> Rp ${dpNominal.toLocaleString("id-ID")}<br>
      <b>Cicilan per bulan:</b> Rp ${cicilan.toLocaleString("id-ID")}<br>
      <b>Lokasi:</b> lat=${lat}, long=${long}
    `;
  };

  // Ambil lokasi
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (pos) => tampilkanHasil(pos.coords.latitude, pos.coords.longitude),
      (err) => {
        document.getElementById(
          "hasil"
        ).innerHTML = `⚠️ Gagal mendapatkan lokasi: ${err.message}`;
        tampilkanHasil("Tidak diketahui", "Tidak diketahui");
      },
      { enableHighAccuracy: true, timeout: 15000 }
    );
  } else {
    document.getElementById("hasil").innerHTML =
      "⚠️ Geolocation tidak didukung.";
    tampilkanHasil("Tidak didukung", "Tidak didukung");
  }
}
