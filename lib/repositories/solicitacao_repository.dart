import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../models/solicitacao.dart';
import '../models/usuario.dart';
import 'erros.dart';

class SolicitacaoRepository extends ChangeNotifier {
  final PocketBase pb;

  SolicitacaoRepository(this.pb);

  List<Solicitacao> itens = [];
  bool carregando = false;
  String? erro;

  Solicitacao? buscarPorId(String id) {
    for (final item in itens) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final records = await pb.collection('solicitacoes').getFullList(
            sort: '-created',
          );
      itens = records.map(Solicitacao.fromRecord).toList()
        ..sort((a, b) => b.criadaEm.compareTo(a.criadaEm));
    } catch (e) {
      erro = mensagemPocketBase(
        e,
        fallback: 'Não foi possível carregar as solicitações.',
      );
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<Solicitacao> buscarRemoto(String id) async {
    final record = await pb.collection('solicitacoes').getOne(id);
    final item = Solicitacao.fromRecord(record);
    final index = itens.indexWhere((atual) => atual.id == id);
    if (index >= 0) {
      itens[index] = item;
    } else {
      itens.add(item);
      itens.sort((a, b) => b.criadaEm.compareTo(a.criadaEm));
    }
    notifyListeners();
    return item;
  }

  Future<String?> criar({
    required String titulo,
    required String descricao,
    required List<int> foto,
    required Usuario usuario,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await pb.collection('solicitacoes').create(
        body: {
          'titulo': titulo,
          'descricao': descricao,
          'usuario': usuario.id,
          'nomeUsuario': usuario.nome,
          'latitude': latitude,
          'longitude': longitude,
        },
        files: [
          http.MultipartFile.fromBytes(
            'foto',
            foto,
            filename: 'foto.jpg',
          ),
        ],
      );
      await carregar();
      return null;
    } catch (e) {
      return mensagemPocketBase(
        e,
        fallback: 'Não foi possível cadastrar a solicitação.',
      );
    }
  }

  Future<String?> atualizar({
    required String id,
    required String titulo,
    required String descricao,
    List<int>? foto,
  }) async {
    try {
      await pb.collection('solicitacoes').update(
        id,
        body: {
          'titulo': titulo,
          'descricao': descricao,
        },
        files: foto == null
            ? const []
            : [
                http.MultipartFile.fromBytes(
                  'foto',
                  foto,
                  filename: 'foto.jpg',
                ),
              ],
      );
      await carregar();
      return null;
    } catch (e) {
      return mensagemPocketBase(
        e,
        fallback: 'Não foi possível salvar a solicitação.',
      );
    }
  }

  Future<String?> excluir(String id) async {
    try {
      await pb.collection('solicitacoes').delete(id);
      itens.removeWhere((item) => item.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return mensagemPocketBase(
        e,
        fallback: 'Não foi possível excluir a solicitação.',
      );
    }
  }
}
