// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_action_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncActionModelAdapter extends TypeAdapter<SyncActionModel> {
  @override
  final int typeId = 5;

  @override
  SyncActionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncActionModel(
      id: fields[0] as String,
      typeIndex: fields[1] as int,
      entityId: fields[2] as String,
      payloadJson: fields[3] as String,
      createdAt: fields[4] as DateTime,
      retryCount: fields[5] as int,
      errorMessage: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncActionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.typeIndex)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.payloadJson)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncActionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
