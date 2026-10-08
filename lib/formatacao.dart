String formatarData(DateTime data) {
  final local = data.toLocal();
  String dois(int valor) => valor.toString().padLeft(2, '0');
  return '${dois(local.day)}/${dois(local.month)}/${local.year} '
      '${dois(local.hour)}:${dois(local.minute)}';
}

String formatarCoordenadas(double latitude, double longitude) {
  return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
