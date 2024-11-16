class Organization {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String location;
  final String contactNumber;
  final String website;

  Organization({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.contactNumber,
    required this.website,
  });

  // Factory method to create an instance from a JSON object
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      website: json['website'] ?? '',
    );
  }

  // Method to convert an instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'contactNumber': contactNumber,
      'website': website,
    };
  }
}
final List<Organization> organizations = [
  Organization(
    id: '1',
    name: 'Charity A',
    description: 'Providing food to homeless and low-income families.',
    imageUrl: 'https://example.com/images/charity_a.png',
    location: 'New York, USA',
    contactNumber: '+1 123-456-7890',
    website: 'https://charitya.org',
  ),
  Organization(
    id: '2',
    name: 'Shelter B',
    description: 'Supporting individuals in need with food and shelter.',
    imageUrl: 'https://example.com/images/shelter_b.png',
    location: 'Los Angeles, USA',
    contactNumber: '+1 987-654-3210',
    website: 'https://shelterb.org',
  ),
  Organization(
    id: '3',
    name: 'Food Bank C',
    description: 'Collecting and distributing food to local communities.',
    imageUrl: 'https://example.com/images/food_bank_c.png',
    location: 'Chicago, USA',
    contactNumber: '+1 555-123-4567',
    website: 'https://foodbankc.org',
  ),
];