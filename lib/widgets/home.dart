import 'package:acoms_app/remote.dart';
import 'package:acoms_app/widgets/cards.dart';
import 'package:acoms_app/widgets/fictional.dart';
import 'package:acoms_app/widgets/status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ChangeNotifier to manage reload triggers
class ReloadNotifier extends ChangeNotifier {
  void reload() {
    notifyListeners();
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionTitle({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final reloadNotifier = ReloadNotifier();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 5.0,
          children: [
            const Text('ACOMS'),
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: const Text(
                '0.1.0-beta',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: StatusIndicator(),
          ), // AppBar
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          ServicesSection(reloadNotifier: reloadNotifier),
          const SizedBox(height: 24),
          TerminalsSection(reloadNotifier: reloadNotifier),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => reloadNotifier.reload(),
              icon: const Icon(Icons.refresh, size: 18, color: FiColors.primary),
              label: const Text('Reload All', style: TextStyle(color: FiColors.primary)),
              style: ElevatedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: FiColors.backgroundHighlight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class ServicesSection extends StatefulWidget {
  final ReloadNotifier reloadNotifier;

  const ServicesSection({super.key, required this.reloadNotifier});

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  final Remote remote = Remote();
  final DateFormat lastSyncFormatter = DateFormat('HH:mm:ss');

  Future<List<Map<String, dynamic>?>> loadingFuture = Future.value([]);
  int lastUpdate = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.reloadNotifier.addListener(_onReload);
  }

  @override
  void dispose() {
    widget.reloadNotifier.removeListener(_onReload);
    super.dispose();
  }

  void _onReload() {
    _loadData();
  }

  void _loadData() {
    setState(() {
      loadingFuture = Future.wait([
        remote.fetchServiceData(),
        remote.fetchStatusData(),
      ]);
    });

    loadingFuture.then((data) {
      if (data[0] != null && data[1] != null) {
        setState(() {
          lastUpdate = DateTime.now().millisecondsSinceEpoch;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>?>>(
      future: loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            (snapshot.hasData && snapshot.data!.length < 2)) {
          return Center(
            child: CircularProgressIndicator(
              color: FiColors.primary,
              strokeWidth: 2.0,
              padding: EdgeInsets.symmetric(vertical: 32),
            ),
          );
        } else if (snapshot.hasError || snapshot.data![0] == null || snapshot.data![1] == null) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final entries = snapshot.data![0]!.entries.toList();
          final statuses = snapshot.data![1]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FiHeading(
                primaryText: 'SERVICES',
                secondaryText:
                    'Last synced: ${lastSyncFormatter.format(DateTime.fromMillisecondsSinceEpoch(lastUpdate))}',
              ),
              ...entries.indexed.map(
                (entry) => ServiceCard(
                  isLast: entry.$1 == entries.length - 1,
                  name: entry.$2.value['name'],
                  description: entry.$2.value['description'],
                  status: statuses[entry.$2.key] == 'healthy'
                      ? 'ONLINE'
                      : 'OFFLINE',
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class TerminalsSection extends StatefulWidget {
  final ReloadNotifier reloadNotifier;

  const TerminalsSection({super.key, required this.reloadNotifier});

  @override
  State<TerminalsSection> createState() => _TerminalsSectionState();
}

class _TerminalsSectionState extends State<TerminalsSection> {
  final Remote remote = Remote();
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateFormat lastSyncFormatter = DateFormat('HH:mm:ss');

  Future<Map<String, dynamic>?> loadingFuture = Future.value(null);
  int lastUpdate = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.reloadNotifier.addListener(_onReload);
  }

  @override
  void dispose() {
    widget.reloadNotifier.removeListener(_onReload);
    super.dispose();
  }

  void _onReload() {
    _loadData();
  }

  void _loadData() {
    setState(() {
      loadingFuture = remote.fetchTerminalData();
    });

    loadingFuture.then((data) {
      if (data != null) {
        setState(() {
          lastUpdate = DateTime.now().millisecondsSinceEpoch;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            (snapshot.hasData && snapshot.data!.length < 2)) {
          return Center(
            child: CircularProgressIndicator(
              color: FiColors.primary,
              strokeWidth: 2.0,
              padding: EdgeInsets.symmetric(vertical: 32),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final entries = snapshot.data!.entries.toList();
          final timestamp5MinutesAgo =
              DateTime.now()
                  .subtract(Duration(minutes: 5))
                  .millisecondsSinceEpoch /
              1000;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FiHeading(
                primaryText: 'TERMINALS',
                secondaryText:
                    'Last synced: ${lastSyncFormatter.format(DateTime.fromMillisecondsSinceEpoch(lastUpdate))}',
              ),
              ...entries.indexed.map(
                (entry) => ServiceCard(
                  isLast: entry.$1 == entries.length - 1,
                  name: entry.$2.value['name'],
                  description:
                      'Last seen: ${formatter.format(DateTime.fromMillisecondsSinceEpoch(entry.$2.value['last_seen'] * 1000))}',
                  status: entry.$2.value['last_seen'] >= timestamp5MinutesAgo
                      ? 'ONLINE'
                      : 'OFFLINE',
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
