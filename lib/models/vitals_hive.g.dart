// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vitals_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VitalsHiveAdapter extends TypeAdapter<VitalsHive> {
  @override
  final int typeId = 0;

  @override
  VitalsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VitalsHive(
      heartRate: fields[0] as int,
      temperature: fields[1] as double,
      spo2: fields[2] as int,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VitalsHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.heartRate)
      ..writeByte(1)
      ..write(obj.temperature)
      ..writeByte(2)
      ..write(obj.spo2)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VitalsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
