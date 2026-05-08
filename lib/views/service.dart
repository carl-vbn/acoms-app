import 'package:acoms_app/models/service.dart';
import 'package:flutter/material.dart';

class ServiceView extends StatelessWidget {
  final Service service;

  const ServiceView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Details'),
      ),
      body: Center(
        child: Text('Details for service: ${service.id}'),
      ),
    );
  }
}
