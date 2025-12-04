import '../../../estufa/domain/entities/estufa.dart';
import '../../../usuario/domain/entities/usuario.dart';

class EstufaUsuario {
  final String id;
  final String estufaId;
  final String usuarioId;
  final String role;
  final DateTime dataAcessoInicio;
  final DateTime? dataAcessoFim;
  final Estufa? estufa;
  final Usuario? usuario;

  EstufaUsuario({
    required this.id,
    required this.estufaId,
    required this.usuarioId,
    required this.role,
    required this.dataAcessoInicio,
    this.dataAcessoFim,
    this.estufa,
    this.usuario,
  });

  factory EstufaUsuario.fromJson(Map<String, dynamic> json) {
    return EstufaUsuario(
      id: json['id'],
      estufaId: json['estufa_id'],
      usuarioId: json['usuario_id'],
      role: json['role'],
      dataAcessoInicio: DateTime.parse(json['data_acesso_inicio']),
      dataAcessoFim: json['data_acesso_fim'] != null ? DateTime.parse(json['data_acesso_fim']) : null,
      estufa: json['estufa'] != null ? Estufa.fromJson(json['estufa']) : null,
      usuario: json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estufa_id': estufaId,
      'usuario_id': usuarioId,
      'role': role,
      'data_acesso_inicio': dataAcessoInicio.toIso8601String(),
      'data_acesso_fim': dataAcessoFim?.toIso8601String(),
    };
  }
}
