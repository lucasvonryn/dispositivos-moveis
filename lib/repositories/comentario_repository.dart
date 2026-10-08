import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/comentario.dart';
import '../models/usuario.dart';
import 'erros.dart';

class ComentarioRepository extends ChangeNotifier {
  final PocketBase pb;

  ComentarioRepository(this.pb);

  String? solicitacaoId;
  List<Comentario> itens = [];
  bool carregando = false;
  String? erro;

  Future<void> carregar(String id) async {
    if (solicitacaoId != id) itens = [];
    solicitacaoId = id;
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final records = await pb.collection('comentarios').getFullList(
            filter: 'solicitacao = "$id"',
            sort: 'created',
          );
      if (solicitacaoId != id) return;
      itens = records.map(Comentario.fromRecord).toList()
        ..sort((a, b) => a.criadoEm.compareTo(b.criadoEm));
    } catch (e) {
      if (solicitacaoId != id) return;
      erro = mensagemPocketBase(
        e,
        fallback: 'Não foi possível carregar os comentários.',
      );
    } finally {
      if (solicitacaoId == id) {
        carregando = false;
        notifyListeners();
      }
    }
  }

  Future<String?> adicionar({
    required String solicitacaoId,
    required String texto,
    required Usuario autor,
  }) async {
    try {
      await pb.collection('comentarios').create(body: {
        'texto': texto,
        'solicitacao': solicitacaoId,
        'usuario': autor.id,
        'nomeUsuario': autor.nome,
      });
      await carregar(solicitacaoId);
      return null;
    } catch (e) {
      return mensagemPocketBase(
        e,
        fallback: 'Não foi possível salvar o comentário.',
      );
    }
  }
}
