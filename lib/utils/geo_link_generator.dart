import 'dart:io';

String generateAndroidMapsMeLink(
    double lat, double lon, String name, String shareUrl,) {
  return 'mapsme://map?=v1&'
      'll=${Uri.encodeComponent(lat.toString())},'
      '${Uri.encodeComponent(lon.toString())}'
      '&n=${Uri.encodeComponent(name)}'
      '&id=${Uri.encodeComponent(shareUrl)}'
      '&backurl=${Uri.encodeComponent(shareUrl)}'
      '&appname=${Uri.encodeComponent(shareUrl)}';
}

String generateMapsMeLink({
  required double lat,
  required double lon,
  required double zoom,
  required String name,
  required String shareUrl,
}) {
  if (Platform.isAndroid) {
    return generateAndroidMapsMeLink(lat, lon, name, shareUrl);
  } else {
    var urlPrefix = 'ge0://ZCoordba64';

    // Convert zoom level to integer value between 0 and 63
    final zoomI =
        (zoom <= 4 ? 0 : (zoom >= 19.75 ? 63 : ((zoom - 4) * 4).toInt()));

    // Update the zoom character in the URL
    final chars = List<int>.from(urlPrefix.codeUnits);
    chars[6] = base64Char(zoomI);
    urlPrefix = String.fromCharCodes(chars);

    // Convert lat/lon to string and modify the URL
    final result = latLonToString(lat, lon, urlPrefix, 7, 9);

    // Build the final URL
    if (name.isEmpty) {
      return result;
    }

    return '$result/${urlEncodeString(transformName(name))}';
  }
}

// Constants
const int kMaxCoordBits = 30;
const int kMaxPointBytes = 9;

// Helper function for lat/lon conversion
int latToInt(double lat, int max) {
  return ((lat + 90.0) / 180.0 * max).round();
}

int lonToInt(double lon, int max) {
  return ((lon + 180.0) / 360.0 * max).round();
}

String latLonToString(
    double lat, double lon, String prefix, int offset, int mLength,) {
  var length = mLength;

  if (length > kMaxPointBytes) {
    length = kMaxPointBytes;
  }

  final latI = latToInt(lat, (1 << kMaxCoordBits) - 1);
  final lonI = lonToInt(lon, (1 << kMaxCoordBits) - 1);

  final chars =
      List<int>.from(prefix.codeUnits); // Create a modifiable copy here too

  for (var i = 0, shift = kMaxCoordBits - 3; i < length; ++i, shift -= 3) {
    final latBits = (latI >> shift) & 7;
    final lonBits = (lonI >> shift) & 7;

    final nextByte = ((latBits >> 2 & 1) << 5) |
        ((lonBits >> 2 & 1) << 4) |
        ((latBits >> 1 & 1) << 3) |
        ((lonBits >> 1 & 1) << 2) |
        ((latBits & 1) << 1) |
        (lonBits & 1);

    chars[offset + i] = base64Char(nextByte);
  }

  return String.fromCharCodes(chars);
}

String transformName(String s) {
  return String.fromCharCodes(s.codeUnits.map((c) => c == ' '.codeUnitAt(0)
      ? '_'.codeUnitAt(0)
      : c == '_'.codeUnitAt(0)
          ? ' '.codeUnitAt(0)
          : c,),);
}

// Helper function to convert integer to base64 character
int base64Char(int value) {
  const base64Chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  return base64Chars.codeUnitAt(value & 63);
}

String urlEncodeString(String str) {
  return Uri.encodeComponent(str);
}
