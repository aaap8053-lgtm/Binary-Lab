import 'package:flutter/foundation.dart';

import '../utils/binary_utils.dart';

/// State for the Real World screen: RGB mixer, IP address, storage size.
class RealWorldProvider extends ChangeNotifier {
  static const List<int> defaultIp = [192, 168, 1, 1];

  // ---- RGB mixer -----------------------------------------------------------
  int _r = 0;
  int _g = 255;
  int _b = 156; // starts on our neon green brand color

  int get r => _r;
  int get g => _g;
  int get b => _b;

  void setRed(int v) => _set(() => _r = v.clamp(0, 255));
  void setGreen(int v) => _set(() => _g = v.clamp(0, 255));
  void setBlue(int v) => _set(() => _b = v.clamp(0, 255));

  // ---- IP address ----------------------------------------------------------
  List<int> _ip = List.of(defaultIp);

  List<int> get ip => _ip;

  /// "11000000.10101000.00000001.00000001"
  String get ipBinary => _ip.map(BinaryUtils.toBinary8).join('.');

  void setOctet(int index, int value) {
    _ip = [..._ip]..[index] = value.clamp(0, 255);
    notifyListeners();
  }

  void setIp(List<int> octets) {
    _ip = [for (final o in octets) o.clamp(0, 255)];
    notifyListeners();
  }

  // ---- Memory explorer -----------------------------------------------------
  int _storageGb = 128;

  int get storageGb => _storageGb;

  void setStorageGb(int gb) => _set(() => _storageGb = gb);

  // ---- helpers -------------------------------------------------------------
  void _set(VoidCallback mutate) {
    mutate();
    notifyListeners();
  }
}
