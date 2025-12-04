import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/estufa_provider.dart';
import 'estufa_form_page.dart';
import 'estufa_control_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../modulo/presentation/pages/modulo_list_page.dart';
import '../../../modulo/presentation/providers/modulo_provider.dart';
import '../../../modulo/domain/entities/modulo.dart';

class EstufaListPage extends StatefulWidget {
  const EstufaListPage({super.key});

  @override
  State<EstufaListPage> createState() => _EstufaListPageState();
}

class _EstufaListPageState extends State<EstufaListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        await context.read<EstufaProvider>().loadEstufas(token);

        // Load all modules at once to avoid race conditions
        final estufas = context.read<EstufaProvider>().estufas;
        final estufaIds = estufas.map((e) => e.id).toList();
        await context.read<ModuloProvider>().loadAllModulos(estufaIds, token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), // blue smoothed background
      appBar: AppBar(
        title: const Text('Minhas Estufas'),
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E3A5F), // Deep blue
                          const Color(0xFF2C5F8D), // Lighter blue
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      estufa.nome,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Color(0xFFB0BEC5),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          estufa.localizacao ??
                                              'Sem localização',
                                          style: const TextStyle(
                                            color: Color(0xFFB0BEC5),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF00C853), // Bright green
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00C853)
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'ATIVA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Volume Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B0FF)
                                  .withOpacity(0.2), // Bright blue tint
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00B0FF).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B0FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.view_in_ar,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Volume Total',
                                      style: TextStyle(
                                        color: Color(0xFFB0BEC5),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${estufa.volumeTotal?.toStringAsFixed(2) ?? "N/A"} m³',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Environmental Metrics Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetric(
                                  icon: Icons.thermostat,
                                  label: 'Temp',
                                  value:
                                      '${estufa.temperatura?.toStringAsFixed(1) ?? "--"}°C',
                                  color:
                                      const Color(0xFFFF6F00), // Vivid orange
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetric(
                                  icon: Icons.water_drop,
                                  label: 'Umidade',
                                  value:
                                      '${estufa.umidade?.toStringAsFixed(0) ?? "--"}%',
                                  color: const Color(0xFF00B8D4), // Bright cyan
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetric(
                                  icon: Icons.air,
                                  label: 'VPD',
                                  value:
                                      '${estufa.vpd?.toStringAsFixed(2) ?? "--"}',
                                  color:
                                      const Color(0xFFAA00FF), // Vivid purple
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // IoT Devices
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dispositivos IoT',
                                  style: TextStyle(
                                    color: Color(0xFFB0BEC5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildDeviceIndicator(
                                      context,
                                      icon: Icons.air,
                                      label: 'Exaustor',
                                      isOn: estufa.exaustorLigado,
                                      onTap: () async {
                                        final token =
                                            context.read<AuthProvider>().token;
                                        if (token != null) {
                                          await context
                                              .read<EstufaProvider>()
                                              .toggleDevice(
                                                estufa.id,
                                                'exaustor',
                                                !estufa.exaustorLigado,
                                                token,
                                              );
                                        }
                                      },
                                    ),
                                    _buildDeviceIndicator(
                                      context,
                                      icon: Icons.wind_power,
                                      label: 'Ventilador',
                                      isOn: estufa.ventiladorLigado,
                                      onTap: () async {
                                        final token =
                                            context.read<AuthProvider>().token;
                                        if (token != null) {
                                          await context
                                              .read<EstufaProvider>()
                                              .toggleDevice(
                                                estufa.id,
                                                'ventilador',
                                                !estufa.ventiladorLigado,
                                                token,
                                              );
                                        }
                                      },
                                    ),
                                    _buildDeviceIndicator(
                                      context,
                                      icon: Icons.lightbulb,
                                      label: 'LED',
                                      isOn: estufa.ledLigado,
                                      onTap: () async {
                                        final token =
                                            context.read<AuthProvider>().token;
                                        if (token != null) {
                                          await context
                                              .read<EstufaProvider>()
                                              .toggleDevice(
                                                estufa.id,
                                                'led',
                                                !estufa.ledLigado,
                                                token,
                                              );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Modules Status Indicator (NEW!)
                          Consumer<ModuloProvider>(
                            builder: (context, moduloProvider, child) {
                              // CRITICAL FIX: Filter modules by THIS estufa's ID only!
                              final modulosAtivos = moduloProvider.modulos
                                  .where(
                                      (m) => m.estufaId == estufa.id && m.ativo)
                                  .toList();

                              print(
                                  'DEBUG: Estufa ${estufa.nome} (${estufa.id})');
                              print(
                                  '  Total modulos in provider: ${moduloProvider.modulos.length}');
                              print(
                                  '  Modulos for this estufa: ${modulosAtivos.length}');

                              if (modulosAtivos.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00C853).withOpacity(0.2),
                                      const Color(0xFF64DD17).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF00C853)
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00C853),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.extension,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${modulosAtivos.length} ${modulosAtivos.length == 1 ? "Módulo" : "Módulos"} Instalados',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: modulosAtivos.map((modulo) {
                                        // Check if any actuator is ON
                                        final hasActiveActuator = modulo
                                            .atuadores
                                            .any((a) => a.estado);

                                        // DEBUG: Print module info
                                        print(
                                            '  Module: ${modulo.nome} (${modulo.tipoString})');
                                        print(
                                            '    Atuadores: ${modulo.atuadores.length}');
                                        for (var a in modulo.atuadores) {
                                          print(
                                              '      - ${a.tipo}: ${a.estado}');
                                        }
                                        print(
                                            '    hasActive: $hasActiveActuator');

                                        return _buildModuleBadge(
                                          tipo: modulo.tipo,
                                          nome: modulo.tipoString,
                                          isActive: hasActiveActuator,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Modules Button
                          InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModuloListPage(
                                    estufaId: estufa.id,
                                    estufaNome: estufa.nome,
                                  ),
                                ),
                              );

                              // Reload modules after returning to update badges
                              if (context.mounted) {
                                final token =
                                    context.read<AuthProvider>().token;
                                if (token != null) {
                                  await context
                                      .read<ModuloProvider>()
                                      .loadModulosByEstufa(estufa.id, token);
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00B0FF),
                                    Color(0xFF0091EA)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00B0FF)
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.extension,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ver Módulos IoT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.arrow_forward_ios,
                                      color: Colors.white, size: 14),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Color(0xFFE67E22)),
                                tooltip: 'Editar',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EstufaFormPage(estufa: estufa),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Color(0xFFE74C3C)),
                                tooltip: 'Excluir',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Text('Confirmar exclusão'),
                                      content: Text(
                                          'Deseja realmente excluir "${estufa.nome}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Excluir',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    final token =
                                        context.read<AuthProvider>().token;
                                    if (token != null) {
                                      await context
                                          .read<EstufaProvider>()
                                          .deleteEstufa(estufa.id, token);
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

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFBDC3C7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIndicator(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isOn,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOn
                  ? const Color(0xFF27AE60).withOpacity(0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isOn ? const Color(0xFF27AE60) : const Color(0xFF95A5A6),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isOn ? const Color(0xFF27AE60) : const Color(0xFF95A5A6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isOn ? const Color(0xFF27AE60) : const Color(0xFF95A5A6),
              fontWeight: isOn ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleBadge({
    required ModuloTipo tipo,
    required String nome,
    required bool isActive,
  }) {
    Color getModuleColor() {
      switch (tipo) {
        case ModuloTipo.co2:
          return Colors.grey.shade400;
        case ModuloTipo.irrigacao:
          return const Color(0xFF00B0FF);
        case ModuloTipo.iluminacao:
          return const Color(0xFFFFB300);
        case ModuloTipo.clima:
          return const Color(0xFFFF6F00);
        case ModuloTipo.nutricao:
          return const Color(0xFF00C853);
      }
    }

    final color = getModuleColor();

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated pulsing dot
          if (isActive)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                final pulse = (value * 2 - 1).abs(); // 0 -> 1 -> 0
                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8 * pulse),
                        blurRadius: 6 * pulse,
                        spreadRadius: 2 * pulse,
                      ),
                    ],
                  ),
                );
              },
              onEnd: () {
                // Restart animation by using StatefulWidget or other method
                // For now, this creates a one-time pulse
              },
            )
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nome,
                style: TextStyle(
                  color:
                      isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isActive ? 'ON' : 'OFF',
                style: TextStyle(
                  color: isActive
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white.withOpacity(0.3),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Wrap in AnimatedContainer for smooth transitions
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: isActive ? _PulsingWidget(child: badge) : badge,
    );
  }
}

// Stateful widget for continuous pulsing animation
class _PulsingWidget extends StatefulWidget {
  final Widget child;
  const _PulsingWidget({required this.child});

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity:
              0.85 + (_controller.value * 0.15), // Pulse between 0.85 and 1.0
          child: widget.child,
        );
      },
    );
  }
}
