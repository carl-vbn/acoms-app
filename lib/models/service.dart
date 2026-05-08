class Service {
  final String id;
  final String name;
  final String description;
  final String host;
  final String status;
  final bool https;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.host,
    required this.status,
    this.https = false,
  });

  String get url => '${https ? 'https' : 'http'}://$host';
}
