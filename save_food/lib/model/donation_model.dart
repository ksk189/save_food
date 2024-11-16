class Donation {
  final String id;
  final String items;
  final String portion;
  final String receiver;
  final String expirationDate;
  final String description;
  final List<String> tags;
  final String senderName;
  final String email;
  final String phone;
  final String status;
  final String date;

  Donation({
    required this.id,
    required this.items,
    required this.portion,
    required this.receiver,
    required this.expirationDate,
    required this.description,
    required this.tags,
    required this.senderName,
    required this.email,
    required this.phone,
    required this.status,
    required this.date,
  });

  // Convert Donation object to a map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items,
      'portion': portion,
      'receiver': receiver,
      'expirationDate': expirationDate,
      'description': description,
      'tags': tags,
      'senderName': senderName,
      'email': email,
      'phone': phone,
      'status': status,
      'date': date,
    };
  }

  // Create Donation object from Firestore data
  factory Donation.fromMap(Map<String, dynamic> map, String id) {
    return Donation(
      id: id,
      items: map['items'] ?? '',
      portion: map['portion'] ?? '',
      receiver: map['receiver'] ?? '',
      expirationDate: map['expirationDate'] ?? '',
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      senderName: map['senderName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] ?? '',
      date: map['date'] ?? '',
    );
  }
}