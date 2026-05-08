import 'package:acoms_app/models/service.dart';
import 'package:acoms_app/remote.dart';
import 'package:acoms_app/widgets/fictional.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StatsWidget extends StatefulWidget {
  final Service service;

  const StatsWidget({super.key, required this.service});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  @override
  void initState() {
    Remote remote = Remote();

    int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var stats = remote.stats.retrieveStats(widget.service.id, 0, secondsSinceEpoch);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ServiceView extends StatelessWidget {
  final Service service;

  const ServiceView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            FiHeading(primaryText: 'OVERVIEW'),
            Column(
              children: [
                Row(
                  children: [
                    FiRowElement(
                      label: 'SERVICE ID',
                      value: service.id,
                    ),
                    Expanded(child: FiRowElement(label: 'DESCRIPTION', value: service.description)),
                    FiRowElement(
                      label: 'STATUS',
                      value: service.status,
                      isLastH: true,
                    )
                  ],
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: FiRowElement(
                          label: 'HOST',
                          value: service.host,
                          isLastV: true
                        ),
                      ),
                      FiButton(text: "VISIT", onPressed: (){
                        launchUrlString(service.url, mode: LaunchMode.platformDefault);
                      }, isLastH: true, isLastV: true),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            FiHeading(primaryText: 'STATS'),
            StatsWidget(),
          ]
        )
      ),
    );
  }
}
