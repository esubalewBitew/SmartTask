import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarttask/core/common/entities/contacts.dart';
import 'package:smarttask/core/enum/contact_type.dart';

class ContactListPage extends StatelessWidget {
  final Function(Map<String, String>?) onContactSelected;
  final ContactType selectedType;

  const ContactListPage({
    super.key,
    required this.onContactSelected,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Contacts List',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Select a contact with a CBRS Wallet and transfer funds directly to their wallet.',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  final contact = Contact(
                    name: "Jane Cooper",
                    email: selectedType == ContactType.email
                        ? "jane.cooper@example.com"
                        : null,
                    phone:
                        selectedType == ContactType.phone ? "2705550117" : null,
                    countryCode:
                        selectedType == ContactType.phone ? "+1" : null,
                    photoUrl:
                        index % 3 == 0 ? "assets/images/avatar.png" : null,
                    type: selectedType,
                  );

                  return _ContactListTile(
                    contact: contact,
                    onTap: () => context.pop(contact.toMap()),
                  ).animate().fadeIn(
                        duration: const Duration(milliseconds: 200),
                        delay: Duration(milliseconds: index * 50),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const _ContactListTile({
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: contact.photoUrl != null
          ? CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage(contact.photoUrl!),
            )
          : CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF065234),
              child: Text(
                _getInitials(contact.name),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      title: Text(
        contact.name,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        contact.displayValue,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}
