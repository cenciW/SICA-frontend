enum ModuloTipo {
  co2,
  irrigacao,
  iluminacao,
  clima,
  nutricao,
}

class Modulo {
  final String id;
  final String estufaId;
  final ModuloTipo tipo;
  final String nome;
  final bool ativo;
  final Map<String, dynamic>? configuracao;
  final List<Sensor> sensores;
  final List<Atuador> atuadores;
  final DateTime createdAt;
  final DateTime updatedAt;

  Modulo({
    required this.id,
    required this.estufaId,
    required this.tipo,
    required this.nome,
    required this.ativo,
    this.configuracao,
    required this.sensores,
    required this.atuadores,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Modulo.fromJson(Map<String, dynamic> json) {
    return Modulo(
      id: json['id'],
      estufaId: json['estufa_id'],
      tipo: _moduloTipoFromString(json['tipo']),
      nome: json['nome'],
      ativo: json['ativo'] ?? true,
      configuracao: json['configuracao'],
      sensores: (json['sensores'] as List?)
              ?.map((s) => Sensor.fromJson(s))
              .toList() ??
          [],
      atuadores: (json['atuadores'] as List?)
              ?.map((a) => Atuador.fromJson(a))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static ModuloTipo _moduloTipoFromString(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'CO2':
        return ModuloTipo.co2;
      case 'IRRIGACAO':
        return ModuloTipo.irrigacao;
      case 'ILUMINACAO':
        return ModuloTipo.iluminacao;
      case 'CLIMA':
        return ModuloTipo.clima;
      case 'NUTRICAO':
        return ModuloTipo.nutricao;
      default:
        return ModuloTipo.co2;
    }
  }

  String get tipoString {
    switch (tipo) {
      case ModuloTipo.co2:
        return 'CO2';
      case ModuloTipo.irrigacao:
        return 'Irrigação';
      case ModuloTipo.iluminacao:
        return 'Iluminação';
      case ModuloTipo.clima:
        return 'Clima';
      case ModuloTipo.nutricao:
        return 'Nutrição';
    }
  }
}

class Sensor {
  final String id;
  final String moduloId;
  final String tipo;
  final String unidade;
  final double? valorAtual;
  final double? valorMin;
  final double? valorMax;
  final DateTime? ultimaLeitura;

  Sensor({
    required this.id,
    required this.moduloId,
    required this.tipo,
    required this.unidade,
    this.valorAtual,
    this.valorMin,
    this.valorMax,
    this.ultimaLeitura,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      moduloId: json['modulo_id'],
      tipo: json['tipo'],
      unidade: json['unidade'],
      valorAtual: json['valor_atual'] != null
          ? (json['valor_atual'] as num).toDouble()
          : null,
      valorMin:
          json['valor_min'] != null ? (json['valor_min'] as num).toDouble() : null,
      valorMax:
          json['valor_max'] != null ? (json['valor_max'] as num).toDouble() : null,
      ultimaLeitura: json['ultima_leitura'] != null
          ? DateTime.parse(json['ultima_leitura'])
          : null,
    );
  }

  bool get isNormal {
    if (valorAtual == null || valorMin == null || valorMax == null) return true;
    return valorAtual! >= valorMin! && valorAtual! <= valorMax!;
  }
}

class Atuador {
  final String id;
  final String moduloId;
  final String tipo;
  final String nome;
  final bool estado;
  final String modo;
  final DateTime? ultimaAcao;

  Atuador({
    required this.id,
    required this.moduloId,
    required this.tipo,
    required this.nome,
    required this.estado,
    required this.modo,
    this.ultimaAcao,
  });

  factory Atuador.fromJson(Map<String, dynamic> json) {
    return Atuador(
      id: json['id'],
      moduloId: json['modulo_id'],
      tipo: json['tipo'],
      nome: json['nome'],
      estado: json['estado'] ?? false,
      modo: json['modo'] ?? 'manual',
      ultimaAcao: json['ultima_acao'] != null
          ? DateTime.parse(json['ultima_acao'])
          : null,
    );
  }

  bool get isAutomatico => modo == 'automatico';
}
