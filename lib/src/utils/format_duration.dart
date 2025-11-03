String formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;

  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
