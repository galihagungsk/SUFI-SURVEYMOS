// Fungsi dipanggil dari Flutter
function receiveFromFlutter(message) {
  document.getElementById("fromFlutter").innerText =
    "Message from Flutter: " + message;
}

// Kirim pesan ke Flutter
function sendMessageToFlutter() {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler("jsToFlutter", "Hello from JS!");
  }
}
