class Usuario {
  final String id;
  final String email;
  final String usuario;
  final String? nomeCompleto;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Usuario({
    required this.id,
    required this.email,
    required this.usuario,
    this.nomeCompleto,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      email: json['email'],
      usuario: json['usuario'],
      nomeCompleto: json['nome_completo'],
      ativo: json['ativo'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'usuario': usuario,
      'nome_completo': nomeCompleto,
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
