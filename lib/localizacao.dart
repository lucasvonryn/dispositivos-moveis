import 'package:geolocator/geolocator.dart';

class LocalizacaoException implements Exception {
  final String mensagem;

  const LocalizacaoException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Lê a posição atual depois de checar serviço e permissão.
Future<Position> obterLocalizacaoAtual() async {
  final servicoAtivo = await Geolocator.isLocationServiceEnabled();
  if (!servicoAtivo) {
    throw const LocalizacaoException(
      'Ative a localização do aparelho para cadastrar a solicitação.',
    );
  }

  var permissao = await Geolocator.checkPermission();
  if (permissao == LocationPermission.denied) {
    permissao = await Geolocator.requestPermission();
  }

  if (permissao == LocationPermission.denied ||
      permissao == LocationPermission.deniedForever) {
    throw const LocalizacaoException(
      'Permita o acesso à localização para cadastrar a solicitação.',
    );
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  } on LocationServiceDisabledException {
    throw const LocalizacaoException(
      'Ative a localização do aparelho para cadastrar a solicitação.',
    );
  } on PermissionDeniedException {
    throw const LocalizacaoException(
      'Permita o acesso à localização para cadastrar a solicitação.',
    );
  }
}
