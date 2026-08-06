enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSync;
  final String? errorMessage;
  final double progress; // 0.0 to 1.0
  final bool isManual;

  SyncState({
    required this.status,
    this.lastSync,
    this.errorMessage,
    this.progress = 0.0,
    this.isManual = false,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSync,
    String? errorMessage,
    double? progress,
    bool? isManual,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
      isManual: isManual ?? this.isManual,
    );
  }
}
