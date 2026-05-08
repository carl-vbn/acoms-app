class StatsSlice {
  final int sliceStart;
  final int sliceEnd;
  final int sessionCount;
  final int actorCount;
  final double sessionsPerActor;
  final double viewsPerSession;
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

  @override
  String toString() {
    return 'StatsSlice(sliceStart: $sliceStart, sliceEnd: $sliceEnd, sessionCount: $sessionCount, '
    'actorCount: $actorCount, sessionsPerActor: $sessionsPerActor, viewsPerSession: $viewsPerSession, '
    'pageViewsPerDay: $pageViewsPerDay, uniqueActorsPerDay: $uniqueActorsPerDay)';
  }
}