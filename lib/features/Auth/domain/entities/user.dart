import 'package:equatable/equatable.dart';

class LocalUser extends Equatable {
  final String id;
  final String memberCode;
  final String firstName;
  final String middleName;
  final String lastName;
  final String address;
  final String city;
  final String country;
  final String phoneNumber;
  final String email;
  final String realm;
  final String? token;
  final bool enabled;
  final bool isDeleted;
  final bool isVerified;
  final DateTime dateJoined;
  final DateTime lastModified;
  final String deviceUUID;
  final bool is_shipper;

  const LocalUser({
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
    this.token,
    required this.enabled,
    required this.isDeleted,
    required this.isVerified,
    required this.dateJoined,
    required this.lastModified,
    required this.deviceUUID,
    required this.is_shipper,
  });

  // Helper methods
  String get fullName => '$firstName $middleName $lastName'.trim();
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        memberCode,
        firstName,
        middleName,
        lastName,
        address,
        city,
        country,
        phoneNumber,
        email,
        realm,
        token,
        enabled,
        isDeleted,
        isVerified,
        dateJoined,
        lastModified,
        deviceUUID,
        is_shipper,
      ];

  // Empty user singleton
  static final empty = LocalUser(
    id: '',
    memberCode: '',
    firstName: '',
    middleName: '',
    lastName: '',
    address: '',
    city: '',
    country: '',
    phoneNumber: '',
    email: '',
    realm: '',
    token: null,
    enabled: false,
    isDeleted: false,
    isVerified: false,
    dateJoined: DateTime(2024),
    lastModified: DateTime(2024),
    deviceUUID: '',
    is_shipper: false,
  );
}
