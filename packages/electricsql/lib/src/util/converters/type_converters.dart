import 'dart:convert';

import 'package:electricsql/src/util/converters/codecs/date.dart';
import 'package:electricsql/src/util/converters/codecs/float8.dart';
import 'package:electricsql/src/util/converters/codecs/int2.dart';
import 'package:electricsql/src/util/converters/codecs/int4.dart';
import 'package:electricsql/src/util/converters/codecs/time.dart';
import 'package:electricsql/src/util/converters/codecs/timestamp.dart';
import 'package:electricsql/src/util/converters/codecs/timestamptz.dart';
import 'package:electricsql/src/util/converters/codecs/timetz.dart';
import 'package:electricsql/src/util/converters/codecs/uuid.dart';

class TypeConverters {
  static const TimestampCodec timestamp = TimestampCodec();
  static const TimestampTZCodec timestampTZ = TimestampTZCodec();
  static const DateCodec date = DateCodec();
  static const TimeCodec time = TimeCodec();
  static const TimeTZCodec timeTZ = TimeTZCodec();
  static const UUIDCodec uuid = UUIDCodec();
  static const Int2Codec int2 = Int2Codec();
  static const Int4Codec int4 = Int4Codec();
  static const Float8Codec float8 = Float8Codec();
}

class ValidationCodec<T> extends Codec<T, T> {
  const ValidationCodec(this.validate);

  final void Function(T) validate;

  @override
  Converter<T, T> get decoder => _Decoder<T>();

  @override
  Converter<T, T> get encoder => _Encoder<T>(validate);
}

final class _Decoder<T> extends Converter<T, T> {
  const _Decoder();

  @override
  T convert(T input) {
    return input;
  }
}

final class _Encoder<T> extends Converter<T, T> {
  const _Encoder(this.validate);

  final void Function(T) validate;

  @override
  T convert(T input) {
    validate(input);

    return input;
  }
}
