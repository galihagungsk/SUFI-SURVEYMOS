<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
include "db.php";

// Ambil input JSON dari body
$input = file_get_contents("php://input");
$data = json_decode($input, true);

if (!is_array($data)) {
  echo json_encode(["status" => "error", "message" => "Format JSON tidak valid"]);
  exit;
}

foreach ($data as $item) {
  $nama = $conn->real_escape_string($item["nama"]);
  $jenis = $item["jenis"];
  $harga = $item["harga"];
  $dp = $item["dp"];
  $cicilan = $item["cicilan"];
  $lat = $long = ($item['long'] === "Tidak diketahui" || empty($item['long'])) ? "NULL" : "'".$item['long']."'";
  $long = $long = ($item['long'] === "Tidak diketahui" || empty($item['long'])) ? "NULL" : "'".$item['long']."'";


  $sql = "INSERT INTO data (nama, jenis, harga, dp, cicilan, lat, `long`)
          VALUES ('$nama', '$jenis', $harga, $dp, $cicilan, $lat, $long)";
          

  if (!$conn->query($sql)) {
    echo json_encode(["status" => "error", "message" => "Gagal insert: " . $conn->error]);
    exit;
  }
}

echo json_encode(["status" => "success", "message" => "Data berhasil disimpan"]);
$conn->close();
?>
