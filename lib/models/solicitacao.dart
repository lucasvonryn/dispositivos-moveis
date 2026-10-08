import 'package:pocketbase/pocketbase.dart';

class Solicitacao {
  final String id;
  final String collectionId;
  final String titulo;
  final String descricao;
  final String foto;
  final String usuarioId;
  final String nomeUsuario;
  final double latitude;
  final double longitude;
  final DateTime criadaEm;

  const Solicitacao({
    required this.id,
    required this.collectionId,
    required this.titulo,
    required this.descricao,
    required this.foto,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.latitude,
    required this.longitude,
    required this.criadaEm,
  });

  bool pertenceA(String? usuarioId) =>
      usuarioId != null && this.usuarioId == usuarioId;

  Uri urlFoto(PocketBase pb, {String? token}) {
    final record = RecordModel({
      'id': id,
      'collectionId': collectionId,
      'collectionName': 'solicitacoes',
    });
    return pb.files.getURL(record, foto, token: token);
  }

  factory Solicitacao.fromRecord(RecordModel record) {
    return Solicitacao(
      id: record.id,
      collectionId: record.collectionId,
      titulo: record.getStringValue('titulo'),
      descricao: record.getStringValue('descricao'),
      foto: _arquivo(record.data['foto']),
      usuarioId: record.getStringValue('usuario'),
      nomeUsuario: record.getStringValue('nomeUsuario'),
      latitude: _numero(record.data['latitude']),
      longitude: _numero(record.data['longitude']),
      criadaEm: DateTime.tryParse(record.getStringValue('created')) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

String _arquivo(dynamic valor) {
  if (valor is String) return valor;
  if (valor is List && valor.isNotEmpty) return '${valor.first}';
  return '';
}

double _numero(dynamic valor) {
  if (valor is num) return valor.toDouble();
  return double.tryParse('$valor') ?? 0;
}
