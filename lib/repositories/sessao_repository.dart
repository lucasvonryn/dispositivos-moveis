import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/usuario.dart';
import 'erros.dart';

class SessaoRepository extends ChangeNotifier {
  final PocketBase pb;
  Usuario? _usuarioAtual;

  SessaoRepository(this.pb);

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get estaLogado => _usuarioAtual != null;

  /// Retorna null em caso de sucesso, ou uma mensagem de erro.
  Future<String?> login(String email, String senha) async {
    try {
      final auth = await pb.collection('users').authWithPassword(
            email.trim(),
            senha,
          );
      _usuarioAtual = Usuario.fromRecord(auth.record);
      notifyListeners();
      return null;
    } on ClientException catch (erro) {
      if (erro.statusCode == 0 || erro.isAbort) {
        return mensagemPocketBase(
          erro,
          fallback: 'Não foi possível conectar ao PocketBase.',
        );
      }
      return 'E-mail ou senha inválidos.';
    } catch (erro) {
      return mensagemPocketBase(
        erro,
        fallback: 'E-mail ou senha inválidos.',
      );
    }
  }

  /// Cria a conta e já entra com ela.
  Future<String?> cadastrar(String nome, String email, String senha) async {
    try {
      await pb.collection('users').create(body: {
        'name': nome.trim(),
        'email': email.trim(),
        'password': senha,
        'passwordConfirm': senha,
      });
    } catch (erro) {
      return mensagemPocketBase(
        erro,
        fallback: 'Não foi possível criar a conta.',
      );
    }

    return login(email, senha);
  }

  void logout() {
    pb.authStore.clear();
    _usuarioAtual = null;
    notifyListeners();
  }
}
