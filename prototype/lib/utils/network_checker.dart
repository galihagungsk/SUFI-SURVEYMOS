import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkChecker {
  static final InternetConnection _connection = InternetConnection();

  /// Cek apakah benar-benar ada koneksi internet aktif
  static Future<bool> isOnline() async {
    return await _connection.hasInternetAccess;
  }

  /// Stream untuk memantau perubahan koneksi (opsional)
  static Stream<bool> get onStatusChange async* {
    await for (final status in _connection.onStatusChange) {
      yield status == InternetStatus.connected;
    }
  }
}
