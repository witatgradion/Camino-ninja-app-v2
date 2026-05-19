import 'dart:typed_data';

/// Binary codec for stage plan sharing via QR code.
///
/// All formats start with:
/// - 2-byte magic number "CN" (0x43 0x4E) to identify Camino Ninja QR codes
/// - 4-byte build number (uint32) for compatibility tracking
/// - 1-byte platform identifier (0=unknown, 1=android, 2=ios)
///
/// ## Common Header (7 bytes)
///
/// ```
/// ┌─────────────────┬──────────────────┬──────────────┐
/// │      MAGIC      │   BUILD NUMBER   │   PLATFORM   │
/// │     2 bytes     │     4 bytes      │    1 byte    │
/// │   0x43 0x4E     │    uint32 LE     │  0/1/2       │
/// │     ("CN")      │   (0-999999+)    │              │
/// └─────────────────┴──────────────────┴──────────────┘
/// ```
///
/// ## Version 2 - Multiple Plans with Name
///
/// ```
/// HEADER (2 bytes):
/// ┌─────────┬───────────┐
/// │ version │ planCount │
/// │ 1 byte  │  1 byte   │
/// │ uint8=2 │  uint8    │
/// └─────────┴───────────┘
///
/// PLAN BLOCK (repeated planCount times):
/// ┌─────────────┬─────────────┬──────────────┬───────────────────┬────────────┬──────────┐
/// │   routeId   │ stageCount  │  startDate   │   STAGE RECORDS   │ nameLength │   name   │
/// │  2 bytes    │   1 byte    │   2 bytes    │ 9 bytes × count   │   1 byte   │ 0-255 b  │
/// └─────────────┴─────────────┴──────────────┴───────────────────┴────────────┴──────────┘
///
/// STAGE RECORD (9 bytes each):
/// ┌───────────┬─────────────┬───────────┬────────────────┬──────────────┐
/// │ dateDelta │ startCityId │ endCityId │ startAlbergueId│ endAlbergueId│
/// │  1 byte   │  2 bytes    │  2 bytes  │    2 bytes     │   2 bytes    │
/// └───────────┴─────────────┴───────────┴────────────────┴──────────────┘
///
/// FOOTER: CRC16 (2 bytes)
/// ```
class StagePlanCodec {
  StagePlanCodec._();

  /// Magic number "CN" (Camino Ninja) - identifies this as a Camino Ninja QR code
  static const int _magicByte1 = 0x43; // 'C'
  static const int _magicByte2 = 0x4E; // 'N'
  static const int _magicSize = 2;

  /// Build number size: 4 bytes (uint32) - supports 6+ digit build numbers
  static const int _buildNumberSize = 4;

  /// Platform size: 1 byte
  static const int _platformSize = 1;

  /// Common header size: magic + build number + platform
  static const int _commonHeaderSize =
      _magicSize + _buildNumberSize + _platformSize;

  static const int _versionMulti = 2;
  static const int _headerSizeMulti = 2;
  static const int _planBlockHeaderSize = 5;
  static const int _stageRecordSize = 9;
  static const int _footerSize = 2;

  /// Epoch for date encoding: January 1, 2020
  static final DateTime _epoch = DateTime(2020);

  /// Encode a single stage plan to a Base45 string for QR code.
  static String encode(
    StagePlanData plan, {
    required int buildNumber,
    required QrPlatform platform,
  }) {
    return encodeMultiple([plan], buildNumber: buildNumber, platform: platform);
  }

  /// Encode multiple stage plans to a Base45 string for QR code.
  static String encodeMultiple(
    List<StagePlanData> plans, {
    required int buildNumber,
    required QrPlatform platform,
  }) {
    if (plans.isEmpty) {
      throw const CodecException('Must have at least one plan');
    }
    if (plans.length > 255) {
      throw const CodecException('Cannot encode more than 255 plans');
    }

    // Validate all plans and convert names to UTF-8 bytes
    final nameBytes = <Uint8List>[];
    for (final plan in plans) {
      if (plan.stages.isEmpty) {
        throw const CodecException('Each plan must have at least one stage');
      }
      if (plan.stages.length > 255) {
        throw const CodecException(
            'Each plan cannot have more than 255 stages',);
      }
      if (plan.name != null && plan.name!.isNotEmpty) {
        final bytes = _encodeUtf8(plan.name!);
        if (bytes.length > 255) {
          throw const CodecException('Plan name too long (max 255 bytes)');
        }
        nameBytes.add(bytes);
      } else {
        nameBytes.add(Uint8List(0));
      }
    }

    // Calculate total size (common header + format header + data + footer)
    var totalSize = _commonHeaderSize + _headerSizeMulti + _footerSize;
    for (var i = 0; i < plans.length; i++) {
      totalSize +=
          _planBlockHeaderSize + (_stageRecordSize * plans[i].stages.length);
      totalSize += 1 + nameBytes[i].length; // 1 byte length + name bytes
    }

    final buffer = ByteData(totalSize);
    var offset = 0;

    // MAGIC NUMBER
    buffer.setUint8(offset++, _magicByte1);
    buffer.setUint8(offset++, _magicByte2);

    // BUILD NUMBER (uint32)
    if (buildNumber < 0) {
      throw const CodecException('Build number must be non-negative');
    }
    buffer.setUint32(offset, buildNumber, Endian.little);
    offset += 4;

    // PLATFORM
    buffer.setUint8(offset++, platform.value);

    // FORMAT HEADER
    buffer.setUint8(offset++, _versionMulti);
    buffer.setUint8(offset++, plans.length);

    // PLAN BLOCKS
    for (var planIndex = 0; planIndex < plans.length; planIndex++) {
      final plan = plans[planIndex];
      // Sort stages by date
      final sortedStages = List<StageData>.from(plan.stages)
        ..sort((a, b) => a.date.compareTo(b.date));

      // Plan block header
      buffer.setUint16(offset, plan.routeId, Endian.little);
      offset += 2;
      buffer.setUint8(offset++, sortedStages.length);

      final startDate = sortedStages.first.date;
      final daysSinceEpoch = startDate.difference(_epoch).inDays;
      if (daysSinceEpoch < 0 || daysSinceEpoch > 65535) {
        throw const CodecException('Start date out of encodable range');
      }
      buffer.setUint16(offset, daysSinceEpoch, Endian.little);
      offset += 2;

      // Stage records
      var previousDate = startDate;
      for (final stage in sortedStages) {
        final dateDelta = stage.date.difference(previousDate).inDays;
        if (dateDelta < 0 || dateDelta > 255) {
          throw const CodecException('Date delta out of range (0-255 days)');
        }
        buffer.setUint8(offset++, dateDelta);
        buffer.setUint16(offset, stage.startCityId, Endian.little);
        offset += 2;
        buffer.setUint16(offset, stage.endCityId, Endian.little);
        offset += 2;
        buffer.setUint16(offset, stage.startAlbergueId ?? 0, Endian.little);
        offset += 2;
        buffer.setUint16(offset, stage.endAlbergueId ?? 0, Endian.little);
        offset += 2;
        previousDate = stage.date;
      }

      // Write name (1 byte length + name bytes)
      final planNameBytes = nameBytes[planIndex];
      buffer.setUint8(offset++, planNameBytes.length);
      for (final byte in planNameBytes) {
        buffer.setUint8(offset++, byte);
      }
    }

    // FOOTER (CRC16)
    final dataBytes = Uint8List.view(buffer.buffer, 0, totalSize - _footerSize);
    final crc = Crc16Ccitt.compute(dataBytes);
    buffer.setUint16(offset, crc, Endian.little);

    // Convert to Base45
    final bytes = Uint8List.view(buffer.buffer);
    return Base45.encode(bytes);
  }

  /// Decode a Base45 string from QR code to stage plan data.
  /// Returns a [DecodeResult] containing plans, build number, and platform.
  static DecodeResult decode(String encoded) {
    // Decode Base45
    final Uint8List bytes;
    try {
      bytes = Base45.decode(encoded);
    } catch (e) {
      throw CodecException('Invalid Base45 encoding: $e');
    }

    if (bytes.length < _commonHeaderSize + 3) {
      throw const CodecException('Data too short');
    }

    final buffer = ByteData.view(bytes.buffer);

    // Validate magic number first
    final magic1 = buffer.getUint8(0);
    final magic2 = buffer.getUint8(1);
    if (magic1 != _magicByte1 || magic2 != _magicByte2) {
      throw const CodecException('Not a valid Camino Ninja QR code');
    }

    // Read build number (uint32)
    final buildNumber = buffer.getUint32(2, Endian.little);

    // Read platform
    final platformValue = buffer.getUint8(6);
    final platform = QrPlatform.fromValue(platformValue);

    // Validate CRC16
    final dataBytes =
        Uint8List.view(bytes.buffer, 0, bytes.length - _footerSize);
    final expectedCrc = Crc16Ccitt.compute(dataBytes);
    final actualCrc =
        buffer.getUint16(bytes.length - _footerSize, Endian.little);
    if (expectedCrc != actualCrc) {
      throw const CodecException('CRC16 checksum mismatch - data corrupted');
    }

    final version = buffer.getUint8(_commonHeaderSize);

    final List<StagePlanData> plans;
    if (version == _versionMulti) {
      plans = _decodeMultiplePlans(buffer, bytes.length);
    } else {
      throw CodecException('Unsupported version: $version');
    }

    return DecodeResult(
      plans: plans,
      buildNumber: buildNumber,
      platform: platform,
    );
  }

  /// Decode version 2 (multiple plans with name) format
  static List<StagePlanData> _decodeMultiplePlans(
    ByteData buffer,
    int totalLength,
  ) {
    var offset = _commonHeaderSize + 1; // Skip common header + version byte
    final planCount = buffer.getUint8(offset++);

    if (planCount == 0) {
      throw const CodecException('Plan count cannot be zero');
    }

    final plans = <StagePlanData>[];

    for (var p = 0; p < planCount; p++) {
      if (offset + _planBlockHeaderSize > totalLength - _footerSize) {
        throw const CodecException('Data truncated - missing plan header');
      }

      final routeId = buffer.getUint16(offset, Endian.little);
      offset += 2;
      final stageCount = buffer.getUint8(offset++);
      final startDateDays = buffer.getUint16(offset, Endian.little);
      offset += 2;

      if (stageCount == 0) {
        throw CodecException('Plan $p has zero stages');
      }

      final requiredBytes = _stageRecordSize * stageCount;
      if (offset + requiredBytes > totalLength - _footerSize) {
        throw const CodecException('Data truncated - missing stage records');
      }

      // STAGE RECORDS
      final stages = <StageData>[];
      var currentDate = _epoch.add(Duration(days: startDateDays));

      for (var i = 0; i < stageCount; i++) {
        final dateDelta = buffer.getUint8(offset++);
        currentDate = currentDate.add(Duration(days: dateDelta));

        final startCityId = buffer.getUint16(offset, Endian.little);
        offset += 2;
        final endCityId = buffer.getUint16(offset, Endian.little);
        offset += 2;
        final startAlbergueIdRaw = buffer.getUint16(offset, Endian.little);
        offset += 2;
        final endAlbergueIdRaw = buffer.getUint16(offset, Endian.little);
        offset += 2;

        stages.add(
          StageData(
            date: currentDate,
            startCityId: startCityId,
            endCityId: endCityId,
            startAlbergueId:
                startAlbergueIdRaw == 0 ? null : startAlbergueIdRaw,
            endAlbergueId: endAlbergueIdRaw == 0 ? null : endAlbergueIdRaw,
          ),
        );
      }

      // Read name (1 byte length + name bytes)
      String? name;
      final nameLength = buffer.getUint8(offset++);
      if (nameLength > 0) {
        if (offset + nameLength > totalLength - _footerSize) {
          throw const CodecException('Data truncated - missing name bytes');
        }
        final nameBytes = Uint8List(nameLength);
        for (var i = 0; i < nameLength; i++) {
          nameBytes[i] = buffer.getUint8(offset++);
        }
        name = _decodeUtf8(nameBytes);
      }

      plans.add(StagePlanData(routeId: routeId, stages: stages, name: name));
    }

    return plans;
  }

  /// Encode string to UTF-8 bytes
  static Uint8List _encodeUtf8(String str) {
    final bytes = <int>[];
    for (var i = 0; i < str.length; i++) {
      final codeUnit = str.codeUnitAt(i);
      if (codeUnit < 0x80) {
        bytes.add(codeUnit);
      } else if (codeUnit < 0x800) {
        bytes.add(0xC0 | (codeUnit >> 6));
        bytes.add(0x80 | (codeUnit & 0x3F));
      } else if (codeUnit >= 0xD800 &&
          codeUnit <= 0xDBFF &&
          i + 1 < str.length) {
        final nextCodeUnit = str.codeUnitAt(i + 1);
        if (nextCodeUnit >= 0xDC00 && nextCodeUnit <= 0xDFFF) {
          final codePoint =
              0x10000 + ((codeUnit - 0xD800) << 10) + (nextCodeUnit - 0xDC00);
          bytes.add(0xF0 | (codePoint >> 18));
          bytes.add(0x80 | ((codePoint >> 12) & 0x3F));
          bytes.add(0x80 | ((codePoint >> 6) & 0x3F));
          bytes.add(0x80 | (codePoint & 0x3F));
          i++;
        }
      } else {
        bytes.add(0xE0 | (codeUnit >> 12));
        bytes.add(0x80 | ((codeUnit >> 6) & 0x3F));
        bytes.add(0x80 | (codeUnit & 0x3F));
      }
    }
    return Uint8List.fromList(bytes);
  }

  /// Decode UTF-8 bytes to string
  static String _decodeUtf8(Uint8List bytes) {
    final buffer = StringBuffer();
    var i = 0;
    while (i < bytes.length) {
      final byte = bytes[i];
      if (byte < 0x80) {
        buffer.writeCharCode(byte);
        i++;
      } else if ((byte & 0xE0) == 0xC0) {
        final codePoint = ((byte & 0x1F) << 6) | (bytes[i + 1] & 0x3F);
        buffer.writeCharCode(codePoint);
        i += 2;
      } else if ((byte & 0xF0) == 0xE0) {
        final codePoint = ((byte & 0x0F) << 12) |
            ((bytes[i + 1] & 0x3F) << 6) |
            (bytes[i + 2] & 0x3F);
        buffer.writeCharCode(codePoint);
        i += 3;
      } else if ((byte & 0xF8) == 0xF0) {
        final codePoint = ((byte & 0x07) << 18) |
            ((bytes[i + 1] & 0x3F) << 12) |
            ((bytes[i + 2] & 0x3F) << 6) |
            (bytes[i + 3] & 0x3F);
        if (codePoint > 0xFFFF) {
          final highSurrogate = 0xD800 + ((codePoint - 0x10000) >> 10);
          final lowSurrogate = 0xDC00 + ((codePoint - 0x10000) & 0x3FF);
          buffer.writeCharCode(highSurrogate);
          buffer.writeCharCode(lowSurrogate);
        } else {
          buffer.writeCharCode(codePoint);
        }
        i += 4;
      } else {
        i++;
      }
    }
    return buffer.toString();
  }
}

/// Platform that generated the QR code.
enum QrPlatform {
  unknown(0),
  android(1),
  ios(2);

  const QrPlatform(this.value);
  final int value;

  static QrPlatform fromValue(int value) {
    return QrPlatform.values.firstWhere(
      (p) => p.value == value,
      orElse: () => QrPlatform.unknown,
    );
  }
}

/// Result of decoding a QR code, containing all metadata.
class DecodeResult {
  const DecodeResult({
    required this.plans,
    required this.buildNumber,
    required this.platform,
  });

  final List<StagePlanData> plans;
  final int buildNumber;
  final QrPlatform platform;

  /// Returns the first plan (for backward compatibility).
  StagePlanData get firstPlan {
    if (plans.isEmpty) {
      throw const CodecException('No plans found in data');
    }
    return plans.first;
  }

  /// Whether multiple plans were decoded.
  bool get isMultiplePlans => plans.length > 1;

  @override
  String toString() =>
      'DecodeResult(plans: ${plans.length}, buildNumber: $buildNumber, platform: $platform)';
}

/// Data transfer object for encoded/decoded stage plans.
class StagePlanData {
  const StagePlanData({
    required this.routeId,
    required this.stages,
    this.name,
  });

  final int routeId;
  final List<StageData> stages;
  final String? name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StagePlanData &&
          routeId == other.routeId &&
          name == other.name &&
          _listEquals(stages, other.stages);

  @override
  int get hashCode => Object.hash(routeId, name, Object.hashAll(stages));

  static bool _listEquals(List<StageData> a, List<StageData> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Data transfer object for encoded/decoded stages.
class StageData {
  const StageData({
    required this.date,
    required this.startCityId,
    required this.endCityId,
    this.startAlbergueId,
    this.endAlbergueId,
  });

  final DateTime date;
  final int startCityId;
  final int endCityId;
  final int? startAlbergueId;
  final int? endAlbergueId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StageData &&
          _sameDay(date, other.date) &&
          startCityId == other.startCityId &&
          endCityId == other.endCityId &&
          startAlbergueId == other.startAlbergueId &&
          endAlbergueId == other.endAlbergueId;

  @override
  int get hashCode => Object.hash(
        date.year,
        date.month,
        date.day,
        startCityId,
        endCityId,
        startAlbergueId,
        endAlbergueId,
      );

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Exception thrown by codec operations.
class CodecException implements Exception {
  const CodecException(this.message);
  final String message;

  @override
  String toString() => 'CodecException: $message';
}

/// CRC-16/CCITT (polynomial 0x1021, init 0xFFFF)
class Crc16Ccitt {
  Crc16Ccitt._();

  static const int _polynomial = 0x1021;
  static const int _init = 0xFFFF;

  /// Precomputed lookup table for CRC-16/CCITT
  static final List<int> _table = _generateTable();

  static List<int> _generateTable() {
    final table = List<int>.filled(256, 0);
    for (var i = 0; i < 256; i++) {
      var crc = i << 8;
      for (var j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ _polynomial) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
      table[i] = crc;
    }
    return table;
  }

  /// Compute CRC-16/CCITT checksum
  static int compute(Uint8List data) {
    var crc = _init;
    for (final byte in data) {
      final index = ((crc >> 8) ^ byte) & 0xFF;
      crc = (_table[index] ^ (crc << 8)) & 0xFFFF;
    }
    return crc;
  }
}

/// Base45 encoder/decoder (RFC 9285)
///
/// Base45 is optimized for QR codes in alphanumeric mode.
/// Encodes 2 bytes into 3 characters.
class Base45 {
  Base45._();

  static const String _charset =
      r'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:';

  static const int _base = 45;
  static const int _base2 = 45 * 45; // 2025

  /// Encode bytes to Base45 string
  static String encode(Uint8List data) {
    final result = StringBuffer();

    // Process pairs of bytes
    var i = 0;
    while (i < data.length) {
      if (i + 1 < data.length) {
        // Encode 2 bytes into 3 characters
        final value = data[i] * 256 + data[i + 1];
        final c = value % _base;
        final d = (value ~/ _base) % _base;
        final e = value ~/ _base2;
        result
          ..write(_charset[c])
          ..write(_charset[d])
          ..write(_charset[e]);
        i += 2;
      } else {
        // Encode 1 byte into 2 characters
        final value = data[i];
        final c = value % _base;
        final d = value ~/ _base;
        result
          ..write(_charset[c])
          ..write(_charset[d]);
        i++;
      }
    }

    return result.toString();
  }

  /// Decode Base45 string to bytes
  static Uint8List decode(String data) {
    if (data.isEmpty) {
      return Uint8List(0);
    }

    // Validate and convert characters to values
    final values = <int>[];
    for (var i = 0; i < data.length; i++) {
      final index = _charset.indexOf(data[i]);
      if (index < 0) {
        throw FormatException(
          'Invalid Base45 character: ${data[i]} at position $i',
        );
      }
      values.add(index);
    }

    final result = <int>[];

    // Process groups of 3 characters
    var i = 0;
    while (i < values.length) {
      if (i + 2 < values.length) {
        // Decode 3 characters into 2 bytes
        final c = values[i];
        final d = values[i + 1];
        final e = values[i + 2];
        final value = c + d * _base + e * _base2;
        if (value > 0xFFFF) {
          throw const FormatException('Invalid Base45 triplet value');
        }
        result
          ..add(value ~/ 256)
          ..add(value % 256);
        i += 3;
      } else if (i + 1 < values.length) {
        // Decode 2 characters into 1 byte
        final c = values[i];
        final d = values[i + 1];
        final value = c + d * _base;
        if (value > 0xFF) {
          throw const FormatException('Invalid Base45 pair value');
        }
        result.add(value);
        i += 2;
      } else {
        throw const FormatException('Invalid Base45 length');
      }
    }

    return Uint8List.fromList(result);
  }
}
