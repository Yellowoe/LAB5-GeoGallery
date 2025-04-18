// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TravelEntryAdapter extends TypeAdapter<TravelEntry> {
  @override
  final int typeId = 0;

  @override
  TravelEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TravelEntry(
      photoPath: fields[0] as String,
      comment: fields[1] as String,
      date: fields[2] as DateTime,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      locationName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TravelEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.photoPath)
      ..writeByte(1)
      ..write(obj.comment)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.locationName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
