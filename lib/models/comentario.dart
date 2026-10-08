import 'package:pocketbase/pocketbase.dart';

class Comentario {
  final String id;
  final String texto;
  final String solicitacaoId;
  final String usuarioId;
  final String nomeUsuario;
  final DateTime criadoEm;

  const Comentario({
    required this.id,
    required this.texto,
    required this.solicitacaoId,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.criadoEm,
  });

  factory Comentario.fromRecord(RecordModel record) {
    return Comentario(
      id: record.id,
      texto: record.getStringValue('texto'),
      solicitacaoId: record.getStringValue('solicitacao'),
      usuarioId: record.getStringValue('usuario'),
      nomeUsuario: record.getStringValue('nomeUsuario'),
      criadoEm: DateTime.tryParse(record.getStringValue('created')) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
