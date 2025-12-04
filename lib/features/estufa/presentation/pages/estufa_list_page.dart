import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/estufa_provider.dart';
import 'estufa_form_page.dart';
import 'estufa_control_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EstufaListPage extends StatefulWidget {
  const EstufaListPage({super.key});

  @override
  State<EstufaListPage> createState() => _EstufaListPageState();
}

class _EstufaListPageState extends State<EstufaListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<EstufaProvider>().loadEstufas(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estufas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EstufaFormPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<EstufaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Erro: ${provider.error}'));
          }

          if (provider.estufas.isEmpty) {
            return const Center(child: Text('Nenhuma estufa encontrada.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.estufas.length,
            itemBuilder: (context, index) {
              final estufa = provider.estufas[index];
              final statusColor = estufa.status == 'ativa' 
                  ? Colors.green 
                  : estufa.status == 'inativa' 
                      ? Colors.red 
                      : Colors.orange;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EstufaControlPage(estufa: estufa),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with name and status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  estufa.nome,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor, width: 2),
                                ),
                                child: Text(
                                  estufa.status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Location
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  estufa.localizacao ?? 'Sem localização',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Volume info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade50, Colors.blue.shade100],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Volume Total',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${estufa.volumeTotal?.toStringAsFixed(2) ?? "N/A"} m³',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.space_dashboard,
                                    color: Colors.blue,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Environment Metrics
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.thermostat, size: 18, color: Colors.orange.shade700),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${estufa.temperatura?.toStringAsFixed(1) ?? "25.0"}°C',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.water_drop, size: 18, color: Colors.cyan.shade700),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${estufa.umidade?.toStringAsFixed(0) ?? "60"}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.cyan.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed, size: 18, color: Colors.purple.shade700),
                                      const SizedBox(width: 6),
                                      Text(
                                        'VPD ${estufa.vpd?.toStringAsFixed(2) ?? "0.0"}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // IoT Devices Status
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _DeviceIndicator(
                                  icon: Icons.air,
                                  label: 'Exaustor',
                                  isOn: estufa.exaustorLigado,
                                  onTap: () async {
                                    final token = context.read<AuthProvider>().token;
                                    if (token != null) {
                                      await context.read<EstufaProvider>().toggleDevice(
                                        estufa.id, 'exaustor', !estufa.exaustorLigado, token,
                                      );
                                    }
                                  },
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey[300],
                                ),
                                _DeviceIndicator(
                                  icon: Icons.wind_power,
                                  label: 'Ventilador',
                                  isOn: estufa.ventiladorLigado,
                                  onTap: () async {
                                    final token = context.read<AuthProvider>().token;
                                    if (token != null) {
                                      await context.read<EstufaProvider>().toggleDevice(
                                        estufa.id, 'ventilador', !estufa.ventiladorLigado, token,
                                      );
                                    }
                                  },
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey[300],
                                ),
                                _DeviceIndicator(
                                  icon: Icons.lightbulb,
                                  label: 'LED',
                                  isOn: estufa.ledLigado,
                                  onTap: () async {
                                    final token = context.read<AuthProvider>().token;
                                    if (token != null) {
                                      await context.read<EstufaProvider>().toggleDevice(
                                        estufa.id, 'led', !estufa.ledLigado, token,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.videocam, color: Colors.blue),
                                tooltip: 'Câmera',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Row(
                                        children: [
                                          Icon(Icons.videocam, color: Colors.blue),
                                          const SizedBox(width: 8),
                                          const Text('Monitoramento por Câmera'),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.construction,
                                            size: 64,
                                            color: Colors.orange.shade300,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Futuramente...',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Em breve você poderá monitorar sua estufa em tempo real através de câmeras!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Voltar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                tooltip: 'Editar',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EstufaFormPage(estufa: estufa),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'Excluir',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Text('Confirmar exclusão'),
                                      content: Text('Deseja realmente excluir "${estufa.nome}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text(
                                            'Excluir', 
                                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    final token = context.read<AuthProvider>().token;
                                    if (token != null) {
                                      await context.read<EstufaProvider>().deleteEstufa(estufa.id, token);
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeviceIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final VoidCallback? onTap;

  const _DeviceIndicator({
    required this.icon,
    required this.label,
    required this.isOn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOn ? Colors.green.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isOn ? Colors.green : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isOn ? Colors.green : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isOn ? Colors.green.shade700 : Colors.grey[600],
              fontWeight: isOn ? FontWeight.bold : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
