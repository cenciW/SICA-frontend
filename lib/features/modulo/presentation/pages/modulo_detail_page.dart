import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/modulo.dart';
import '../providers/modulo_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ModuloDetailPage extends StatefulWidget {
  final String moduloId;

  const ModuloDetailPage({super.key, required this.moduloId});

  @override
  State<ModuloDetailPage> createState() => _ModuloDetailPageState();
}

class _ModuloDetailPageState extends State<ModuloDetailPage> {
  Modulo? _modulo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModulo();
  }

  Future<void> _loadModulo() async {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      final modulo = await context
          .read<ModuloProvider>()
          .getModulo(widget.moduloId, token);
      if (mounted) {
        setState(() {
          _modulo = modulo;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), //blue smoothed background
      appBar: AppBar(
        title: Text(_modulo?.nome ?? 'Carregando...'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remover Módulo',
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _modulo == null
              ? const Center(child: Text('Módulo não encontrado'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Consumer<ModuloProvider>(
      builder: (context, provider, child) {
        // Get updated modulo from provider
        final currentModulo = provider.modulos.firstWhere(
          (m) => m.id == _modulo!.id,
          orElse: () => _modulo!,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Header
              _buildHeader(currentModulo),
              const SizedBox(height: 24),

              // Sensors Section
              if (currentModulo.sensores.isNotEmpty) ...[
                _buildSectionTitle('Sensores'),
                const SizedBox(height: 12),
                ...currentModulo.sensores
                    .map((sensor) => _buildSensorCard(sensor)),
                const SizedBox(height: 24),
              ],

              // Actuators Section
              if (currentModulo.atuadores.isNotEmpty) ...[
                _buildSectionTitle('Controles'),
                const SizedBox(height: 12),
                ...currentModulo.atuadores.map(
                    (atuador) => _buildAtuadorCard(currentModulo, atuador)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Modulo modulo) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getModuleColor(modulo.tipo).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getModuleIcon(modulo.tipo),
                size: 32,
                color: _getModuleColor(modulo.tipo),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modulo.nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    modulo.tipoString,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    modulo.ativo ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                modulo.ativo ? 'Ativo' : 'Inativo',
                style: TextStyle(
                  color: modulo.ativo
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSensorCard(Sensor sensor) {
    final isNormal = sensor.isNormal;
    final statusColor = isNormal ? const Color(0xFF27AE60) : Colors.orange;
    final backgroundColor = isNormal
        ? const Color(0xFF27AE60).withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);

    // Calculate percentage for progress bar
    double? percentage;
    if (sensor.valorAtual != null &&
        sensor.valorMin != null &&
        sensor.valorMax != null) {
      final range = sensor.valorMax! - sensor.valorMin!;
      final value = sensor.valorAtual! - sensor.valorMin!;
      percentage = (value / range).clamp(0.0, 1.0);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSensorIcon(sensor.tipo),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.tipo.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (sensor.ultimaLeitura != null)
                          Text(
                            _formatTime(sensor.ultimaLeitura!),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isNormal ? Icons.check_circle : Icons.warning,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isNormal ? 'Normal' : 'Atenção',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Value Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor Atual',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            sensor.valorAtual?.toStringAsFixed(1) ?? "--",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              sensor.unidade,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (sensor.valorMin != null && sensor.valorMax != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Faixa Ideal',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sensor.valorMin!.toStringAsFixed(0)} - ${sensor.valorMax!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Progress Bar
              if (percentage != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSensorIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'co2':
        return Icons.cloud;
      case 'ph':
        return Icons.science;
      case 'ec':
        return Icons.bolt;
      case 'temperatura':
        return Icons.thermostat;
      case 'umidade':
        return Icons.water_drop;
      case 'nivel':
        return Icons.height;
      case 'luz':
        return Icons.wb_sunny;
      case 'pressao':
        return Icons.compress;
      default:
        return Icons.sensors;
    }
  }

  Widget _buildAtuadorCard(Modulo modulo, Atuador atuador) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: atuador.estado
                ? [
                    const Color(0xFF27AE60).withOpacity(0.1),
                    const Color(0xFF2ECC71).withOpacity(0.05)
                  ]
                : [
                    Colors.grey.shade300.withOpacity(0.1),
                    Colors.grey.shade200.withOpacity(0.05)
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: atuador.estado
                          ? const Color(0xFF27AE60)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getAtuadorIcon(atuador.tipo),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atuador.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              atuador.isAutomatico
                                  ? Icons.auto_mode
                                  : Icons.touch_app,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              atuador.modo.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ON/OFF Switch
                  Transform.scale(
                    scale: 1.2,
                    child: Switch(
                      value: atuador.estado,
                      activeColor: const Color(0xFF27AE60),
                      onChanged: (value) async {
                        final token = context.read<AuthProvider>().token;
                        if (token != null) {
                          await context.read<ModuloProvider>().toggleAtuador(
                                modulo.id,
                                atuador.id,
                                value,
                                token,
                              );
                          setState(() {
                            // Reload to get updated state
                            _loadModulo();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Mode Toggle and Schedule
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // TODO: Toggle between manual/automatic mode
                        final newMode =
                            atuador.isAutomatico ? 'manual' : 'automatico';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Modo $newMode em breve...'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: Icon(
                        atuador.isAutomatico
                            ? Icons.touch_app
                            : Icons.auto_mode,
                        size: 18,
                      ),
                      label: Text(
                        atuador.isAutomatico
                            ? 'Modo Manual'
                            : 'Modo Automático',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showScheduleDialog(atuador);
                    },
                    icon: const Icon(Icons.schedule, size: 18),
                    label:
                        const Text('Agendar', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),

              // Last action timestamp
              if (atuador.ultimaAcao != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Última ação: ${_formatTime(atuador.ultimaAcao!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog(Atuador atuador) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.schedule, color: Color(0xFF3498DB)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Agendar ${atuador.nome}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Agendamento em Desenvolvimento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Em breve você poderá:\n• Programar horários de ativação\n• Criar rotinas automáticas\n• Definir durações',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  IconData _getAtuadorIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'valvula':
      case 'valvula_co2':
        return Icons.water_damage;
      case 'bomba':
      case 'bomba_a':
      case 'bomba_b':
      case 'bomba_ph':
        return Icons.waves;
      case 'led':
        return Icons.lightbulb;
      case 'exaustor':
        return Icons.air;
      case 'ventilador':
        return Icons.wind_power;
      default:
        return Icons.power;
    }
  }

  IconData _getModuleIcon(ModuloTipo tipo) {
    switch (tipo) {
      case ModuloTipo.co2:
        return Icons.cloud;
      case ModuloTipo.irrigacao:
        return Icons.water_drop;
      case ModuloTipo.iluminacao:
        return Icons.lightbulb;
      case ModuloTipo.clima:
        return Icons.thermostat;
      case ModuloTipo.nutricao:
        return Icons.science;
    }
  }

  Color _getModuleColor(ModuloTipo tipo) {
    switch (tipo) {
      case ModuloTipo.co2:
        return Colors.grey;
      case ModuloTipo.irrigacao:
        return Colors.blue;
      case ModuloTipo.iluminacao:
        return Colors.amber;
      case ModuloTipo.clima:
        return Colors.orange;
      case ModuloTipo.nutricao:
        return Colors.green;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Agora';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}min atrás';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h atrás';
    } else {
      return '${diff.inDays}d atrás';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    if (_modulo == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Remover Módulo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja remover o módulo "${_modulo!.nome}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Todos os sensores e atuadores serão removidos',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              final token = context.read<AuthProvider>().token;
              if (token != null) {
                final success =
                    await context.read<ModuloProvider>().deleteModulo(
                          _modulo!.id,
                          token,
                        );

                if (context.mounted) {
                  if (success) {
                    Navigator.pop(context); // Go back to list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Módulo removido com sucesso'),
                        backgroundColor: Color(0xFF27AE60),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao remover módulo'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
