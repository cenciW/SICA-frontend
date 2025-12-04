import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/modulo.dart';
import '../providers/modulo_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'modulo_detail_page.dart';
import 'add_modulo_page.dart';

class ModuloListPage extends StatefulWidget {
  final String estufaId;
  final String estufaNome;

  const ModuloListPage({
    super.key,
    required this.estufaId,
    required this.estufaNome,
  });

  @override
  State<ModuloListPage> createState() => _ModuloListPageState();
}

class _ModuloListPageState extends State<ModuloListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<ModuloProvider>().loadModulosByEstufa(widget.estufaId, token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.estufaNome),
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
      ),
      body: Consumer<ModuloProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final token = context.read<AuthProvider>().token;
                      if (token != null) {
                        provider.loadModulosByEstufa(widget.estufaId, token);
                      }
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.modulos.where((m) => m.estufaId == widget.estufaId).isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.extension_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum módulo instalado',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione módulos para monitorar sua estufa',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.modulos.where((m) => m.estufaId == widget.estufaId).length,
            itemBuilder: (context, index) {
              // CRITICAL FIX: Filter modules for THIS estufa only
              final modulosDaEstufa = provider.modulos
                  .where((m) => m.estufaId == widget.estufaId)
                  .toList();
              final modulo = modulosDaEstufa[index];
              return _ModuloCard(modulo: modulo);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddModuloPage(
                estufaId: widget.estufaId,
                estufaNome: widget.estufaNome,
              ),
            ),
          );
          
          // Reload list if module was created
          if (result == true && mounted) {
            final token = context.read<AuthProvider>().token;
            if (token != null) {
              context.read<ModuloProvider>().loadModulosByEstufa(widget.estufaId, token);
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Módulo'),
      ),
    );
  }
}

class _ModuloCard extends StatelessWidget {
  final Modulo modulo;

  const _ModuloCard({required this.modulo});

  IconData _getIcon() {
    switch (modulo.tipo) {
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

  Color _getColor() {
    switch (modulo.tipo) {
      case ModuloTipo.co2:
        return Colors.grey.shade400;
      case ModuloTipo.irrigacao:
        return const Color(0xFF00B0FF); // Bright cyan
      case ModuloTipo.iluminacao:
        return const Color(0xFFFFB300); // Bright amber
      case ModuloTipo.clima:
        return const Color(0xFFFF6F00); // Vivid orange
      case ModuloTipo.nutricao:
        return const Color(0xFF00C853); // Bright green
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModuloDetailPage(moduloId: modulo.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getIcon(), color: color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            modulo.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: modulo.ativo ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        modulo.ativo ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          color: modulo.ativo ? Colors.green.shade700 : Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sensors Summary
                if (modulo.sensores.isNotEmpty) ...[
                  _SensorsSummary(sensores: modulo.sensores),
                  const SizedBox(height: 12),
                ],

                // Actuators Summary
                if (modulo.atuadores.isNotEmpty)
                  _AtuadoresSummary(atuadores: modulo.atuadores),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SensorsSummary extends StatelessWidget {
  final List<Sensor> sensores;

  const _SensorsSummary({required this.sensores});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sensores',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sensores.map((sensor) {
            final isNormal = sensor.isNormal;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isNormal ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isNormal ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isNormal ? Icons.check_circle : Icons.warning,
                    size: 16,
                    color: isNormal ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${sensor.tipo}: ${sensor.valorAtual?.toStringAsFixed(1) ?? "--"} ${sensor.unidade}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isNormal ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AtuadoresSummary extends StatelessWidget {
  final List<Atuador> atuadores;

  const _AtuadoresSummary({required this.atuadores});

  @override
  Widget build(BuildContext context) {
    final ligados = atuadores.where((a) => a.estado).length;

    return Row(
      children: [
        Icon(Icons.power_settings_new, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          '$ligados/${atuadores.length} dispositivos ligados',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
