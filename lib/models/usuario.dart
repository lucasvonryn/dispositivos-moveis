import 'package:pocketbase/pocketbase.dart';

class Usuario {
  final String id;
  final String nome;
  final String email;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
  });

  factory Usuario.fromRecord(RecordModel record) {
    final email = record.getStringValue('email');
    final nome = record.getStringValue('name').trim();
    return Usuario(
      id: record.id,
      nome: nome.isEmpty ? email : nome,
      email: email,
    );
  }
}
