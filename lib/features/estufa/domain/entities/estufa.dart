import 'dart:math';

class Estufa {
  final String id;
  final String nome;
  final String? localizacao;
  final double largura;
  final double altura;
  final double comprimento;
  final double? volumeTotal;
  final String status;
  final String? firmwareVersao;
  final bool exaustorLigado;
  final bool ventiladorLigado;
  final bool ledLigado;
  final double? temperatura;
  final double? umidade;
  final DateTime createdAt;
  final DateTime updatedAt;

  Estufa({
    required this.id,
    required this.nome,
    this.localizacao,
    required this.largura,
    required this.altura,
    required this.comprimento,
    this.volumeTotal,
    required this.status,
    this.firmwareVersao,
    this.exaustorLigado = false,
    this.ventiladorLigado = false,
    this.ledLigado = false,
    this.temperatura,
    this.umidade,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate VPD (Vapor Pressure Deficit) in kPa
  double? get vpd {
    if (temperatura == null || umidade == null) return null;
    // SVP = Saturated Vapor Pressure using Magnus-Tetens formula
    final svp = 0.6108 * exp(17.27 * temperatura! / (temperatura! + 237.3));
    // VPD = SVP × (1 - RH/100)
    return svp * (1 - umidade! / 100);
  }

  factory Estufa.fromJson(Map<String, dynamic> json) {
    return Estufa(
      id: json['id'],
      nome: json['nome'],
      localizacao: json['localizacao'],
      largura: (json['largura'] as num).toDouble(),
      altura: (json['altura'] as num).toDouble(),
      comprimento: (json['comprimento'] as num).toDouble(),
      volumeTotal: json['volume_total'] != null ? (json['volume_total'] as num).toDouble() : null,
      status: json['status'],
      firmwareVersao: json['firmware_versao'],
      exaustorLigado: json['exaustor_ligado'] ?? false,
      ventiladorLigado: json['ventilador_ligado'] ?? false,
      ledLigado: json['led_ligado'] ?? false,
      temperatura: json['temperatura'] != null ? (json['temperatura'] as num).toDouble() : 25.0,
      umidade: json['umidade'] != null ? (json['umidade'] as num).toDouble() : 60.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'localizacao': localizacao,
      'largura': largura,
      'altura': altura,
      'comprimento': comprimento,
      'volume_total': volumeTotal,
      'status': status,
      'firmware_versao': firmwareVersao,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
