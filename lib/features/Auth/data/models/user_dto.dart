import 'package:flutter/material.dart';
import 'package:smarttask/features/Auth/domain/entities/user.dart';
import 'package:hive/hive.dart';

part 'user_dto.g.dart';

@HiveType(typeId: 2)
class LocalUserDTO extends LocalUser {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String memberCode;

  @HiveField(3)
  final String firstName;

  @HiveField(4)
  final String middleName;

  @HiveField(5)
  final String lastName;

  @HiveField(6)
  final String address;

  @HiveField(7)
  final String city;

  @HiveField(8)
  final String country;

  @HiveField(9)
  final String phoneNumber;

  @HiveField(10)
  final String realm;

  @HiveField(11)
  final String token;

  @HiveField(12)
  final bool enabled;

  @HiveField(13)
  final bool isDeleted;

  @HiveField(14)
  final bool isVerified;

  @HiveField(15)
  final DateTime dateJoined;

  @HiveField(16)
  final DateTime lastModified;

  @HiveField(17)
  final String deviceUUID;

  @HiveField(18)
  final bool is_shipper;

  const LocalUserDTO({
    required this.id,
    required this.memberCode,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.address,
    required this.city,
    required this.country,
    required this.phoneNumber,
    required this.email,
    required this.realm,
    required this.token,
    required this.enabled,
    required this.isDeleted,
    required this.isVerified,
    required this.dateJoined,
    required this.lastModified,
    required this.deviceUUID,
    required this.is_shipper,
  }) : super(
          id: id,
          memberCode: memberCode,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          address: address,
          city: city,
          country: country,
          phoneNumber: phoneNumber,
          email: email,
          realm: realm,
          token: token,
          enabled: enabled,
          isDeleted: isDeleted,
          isVerified: isVerified,
          dateJoined: dateJoined,
          lastModified: lastModified,
          deviceUUID: deviceUUID,
          is_shipper: is_shipper,
        );

  factory LocalUserDTO.fromJson(Map<String, dynamic> json) {
    debugPrint('User Data in fromJson Under LocalUserDTO Json: ${json}');
    // Extract user data from nested structure
    final userData = json['data']?['user'] ?? json['user'] ?? json;
    final token = json['data']?['token'] ?? json['accessToken'];
    debugPrint('User Data in fromJson Under LocalUserDTO : ${userData}');

    return LocalUserDTO(
      id: userData['id']?.toString() ?? '',
      memberCode: userData['member_code']?.toString() ?? '',
      firstName: userData['name']?.toString() ?? '',
      middleName: userData['middle_name']?.toString() ?? '',
      lastName: userData['last_name']?.toString() ?? '',
      address: userData['address']?.toString() ?? '',
      city: userData['city']?.toString() ?? '',
      country: userData['country']?.toString() ?? '',
      phoneNumber: userData['phone']?.toString() ?? '',
      email: userData['email']?.toString() ?? '',
      realm: userData['realm']?.toString() ?? '',
      is_shipper: userData['is_shipper'] as bool? ?? false,
      token: token.toString(),
      enabled: true,
      isDeleted: false,
      isVerified: false,
      dateJoined:
          DateTime.tryParse(userData['date_joined']?.toString() ?? '') ??
              DateTime.now(),
      lastModified:
          DateTime.tryParse(userData['last_modified']?.toString() ?? '') ??
              DateTime.now(),
      deviceUUID: userData['device_uuid']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'user': {
            'id': id,
            'member_code': memberCode,
            'name': firstName,
            'middle_name': middleName,
            'last_name': lastName,
            'address': address,
            'city': city,
            'country': country,
            'phone': phoneNumber,
            'email': email,
            'realm': realm,
            'enabled': enabled,
            'is_deleted': isDeleted,
            'is_verified': isVerified,
            'date_joined': dateJoined.toIso8601String(),
            'last_modified': lastModified.toIso8601String(),
            'device_uuid': deviceUUID,
            'is_shipper': is_shipper,
          },
          'token': token,
        }
      };

  LocalUserDTO copyWith({
    String? id,
    String? memberCode,
    String? firstName,
    String? middleName,
    String? lastName,
    String? address,
    String? city,
    String? country,
    String? phoneNumber,
    String? email,
    String? realm,
    String? token,
    bool? enabled,
    bool? isDeleted,
    bool? isVerified,
    DateTime? dateJoined,
    DateTime? lastModified,
    String? deviceUUID,
    bool? is_shipper,
  }) {
    return LocalUserDTO(
      id: id ?? this.id,
      memberCode: memberCode ?? this.memberCode,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      realm: realm ?? this.realm,
      token: token ?? this.token,
      enabled: enabled ?? this.enabled,
      isDeleted: isDeleted ?? this.isDeleted,
      isVerified: isVerified ?? this.isVerified,
      dateJoined: dateJoined ?? this.dateJoined,
      lastModified: lastModified ?? this.lastModified,
      deviceUUID: deviceUUID ?? this.deviceUUID,
      is_shipper: is_shipper ?? this.is_shipper,
    );
  }

  LocalUser toEntity() {
    return LocalUser(
      id: '',
      city: '',
      country: '',
      memberCode: memberCode,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      email: email,
      address: address,
      phoneNumber: phoneNumber,
      realm: realm,
      enabled: enabled,
      isDeleted: isDeleted,
      isVerified: isVerified,
      dateJoined: dateJoined,
      lastModified: lastModified,
      deviceUUID: deviceUUID,
      is_shipper: is_shipper,
    );
  }
}
