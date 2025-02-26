enum ContactType {
  email('email'),
  phone('phone');

  final String value;
  const ContactType(this.value);

  static ContactType fromString(String value) {
    return ContactType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ContactType.phone,
    );
  }
}