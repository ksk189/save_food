class RequestModel {
  final String id;
  final String items;
  final String portion;
  final String status;

  RequestModel({
    required this.id,
    required this.items,
    required this.portion,
    required this.status,
  });

  // Convert RequestModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items,
      'portion': portion,
      'status': status,
    };
  }

  // Create RequestModel from a Firestore document snapshot
  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RequestModel(
      id: id,
      items: map['items'] ?? '',
      portion: map['portion'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }
}