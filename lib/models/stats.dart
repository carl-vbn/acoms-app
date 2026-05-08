class StatsSlice {
  final int sliceStart;
  final int sliceEnd;
  final int sessionCount;
  final int actorCount;
  final int sessionsPerActor;
  final int viewsPerSession;
  final List<int>? pageViewsPerDay;
  final List<int>? uniqueActorsPerDay;

  StatsSlice({
    required this.sliceStart,
    required this.sliceEnd,
    required this.sessionCount,
    required this.actorCount,
    required this.sessionsPerActor,
    required this.viewsPerSession,
    this.pageViewsPerDay,
    this.uniqueActorsPerDay,
  });
}