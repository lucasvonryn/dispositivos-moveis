import 'package:pocketbase/pocketbase.dart';
import 'config/pocketbase_config.dart';
import 'repositories/comentario_repository.dart';
import 'repositories/sessao_repository.dart';
import 'repositories/solicitacao_repository.dart';

/// Estado compartilhado da aplicação.
class AppState {
  AppState._() {
    pb = PocketBase(PocketBaseConfig.url);
    sessao = SessaoRepository(pb);
    solicitacoes = SolicitacaoRepository(pb);
    comentarios = ComentarioRepository(pb);
  }

  static final AppState instance = AppState._();

  late final PocketBase pb;
  late final SessaoRepository sessao;
  late final SolicitacaoRepository solicitacoes;
  late final ComentarioRepository comentarios;
}
