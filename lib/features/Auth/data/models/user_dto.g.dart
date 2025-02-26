// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalUserDTOAdapter extends TypeAdapter<LocalUserDTO> {
  @override
  final int typeId = 2;

  @override
  LocalUserDTO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalUserDTO(
      id: fields[0] as String,
      memberCode: fields[2] as String,
      firstName: fields[3] as String,
      middleName: fields[4] as String,
      lastName: fields[5] as String,
      address: fields[6] as String,
      city: fields[7] as String,
      country: fields[8] as String,
      phoneNumber: fields[9] as String,
      email: fields[1] as String,
      realm: fields[10] as String,
      token: fields[11] as String,
      enabled: fields[12] as bool,
      isDeleted: fields[13] as bool,
      isVerified: fields[14] as bool,
      dateJoined: fields[15] as DateTime,
      lastModified: fields[16] as DateTime,
      deviceUUID: fields[17] as String,
      is_shipper: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalUserDTO obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.memberCode)
      ..writeByte(3)
      ..write(obj.firstName)
      ..writeByte(4)
      ..write(obj.middleName)
      ..writeByte(5)
      ..write(obj.lastName)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.country)
      ..writeByte(9)
      ..write(obj.phoneNumber)
      ..writeByte(10)
      ..write(obj.realm)
      ..writeByte(11)
      ..write(obj.token)
      ..writeByte(12)
      ..write(obj.enabled)
      ..writeByte(13)
      ..write(obj.isDeleted)
      ..writeByte(14)
      ..write(obj.isVerified)
      ..writeByte(15)
      ..write(obj.dateJoined)
      ..writeByte(16)
      ..write(obj.lastModified)
      ..writeByte(17)
      ..write(obj.deviceUUID)
      ..writeByte(18)
      ..write(obj.is_shipper);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalUserDTOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
