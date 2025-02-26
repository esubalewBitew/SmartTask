import 'package:smarttask/core/enum/contact_type.dart';

class Contact {
  final String name;
  final String? email;
  final String? phone;
  final String? countryCode;
  final String? photoUrl;
  final ContactType type;

  const Contact({
    required this.name,
    this.email,
    this.phone,
    this.countryCode,
    this.photoUrl,
    required this.type,
  });

  Map<String, String> toMap() {
    return {
      'name': name,
      'type': type.value,
      if (email != null) 'email': email!,
      if (phone != null) 'phone': phone!,
      if (countryCode != null) 'countryCode': countryCode!,
      if (photoUrl != null) 'photoUrl': photoUrl!,
    };
  }

  String get displayValue => type == ContactType.email ? email! : phone!;
}
