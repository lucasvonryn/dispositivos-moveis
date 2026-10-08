import 'package:pocketbase/pocketbase.dart';

String mensagemPocketBase(Object erro, {required String fallback}) {
  if (erro is! ClientException) return fallback;
  if (erro.statusCode == 0 || erro.isAbort) {
    return 'Não foi possível conectar ao PocketBase. '
        'Verifique se o servidor está em execução.';
  }

  final data = erro.response['data'];
  if (data is Map) {
    final email = data['email'];
    if (email is Map && email['code'] == 'validation_not_unique') {
      return 'Este e-mail já está em uso.';
    }
    for (final value in data.values) {
      if (value is Map && value['message'] is String) {
        final message = value['message'] as String;
        if (message.isNotEmpty) return message;
      }
    }
  }

  return fallback;
}
