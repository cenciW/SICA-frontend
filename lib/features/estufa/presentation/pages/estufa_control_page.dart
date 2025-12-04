import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/entities/estufa.dart';
import '../providers/estufa_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EstufaControlPage extends StatefulWidget {
  final Estufa estufa;

  const EstufaControlPage({super.key, required this.estufa});

  @override
  State<EstufaControlPage> createState() => _EstufaControlPageState();
}

class _EstufaControlPageState extends State<EstufaControlPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle - ${widget.estufa.nome}'),
      ),
      body: Consumer<EstufaProvider>(
        builder: (context, provider, child) {
          // Find the updated estufa from provider
          final currentEstufa = provider.estufas
              .firstWhere((e) => e.id == widget.estufa.id, orElse: () => widget.estufa);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Informações da Estufa'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Localização: ${currentEstufa.localizacao ?? "Não especificada"}'),
                        Text('Status: ${currentEstufa.status}'),
                        Text('Volume: ${currentEstufa.volumeTotal?.toStringAsFixed(2) ?? "N/A"} m³'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dispositivos IoT',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Exaustor Control
                DeviceControlCard(
                  deviceName: 'Exaustor',
                  icon: FontAwesomeIcons.fan,
                  isOn: currentEstufa.exaustorLigado,
                  onToggle: (state) async {
                    final token = context.read<AuthProvider>().token;
                    if (token != null) {
                      await context.read<EstufaProvider>().toggleDevice(
                        currentEstufa.id, 'exaustor', state, token,
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                // Ventilador Control
                DeviceControlCard(
                  deviceName: 'Ventilador',
                  icon: FontAwesomeIcons.wind,
                  isOn: currentEstufa.ventiladorLigado,
                  onToggle: (state) async {
                    final token = context.read<AuthProvider>().token;
                    if (token != null) {
                      await context.read<EstufaProvider>().toggleDevice(
                        currentEstufa.id, 'ventilador', state, token,
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                // LED Control
                DeviceControlCard(
                  deviceName: 'LED',
                  icon: FontAwesomeIcons.lightbulb,
                  isOn: currentEstufa.ledLigado,
                  onToggle: (state) async {
                    final token = context.read<AuthProvider>().token;
                    if (token != null) {
                      await context.read<EstufaProvider>().toggleDevice(
                        currentEstufa.id, 'led', state, token,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DeviceControlCard extends StatelessWidget {
  final String deviceName;
  final IconData icon;
  final bool isOn;
  final Function(bool) onToggle;

  const DeviceControlCard({
    super.key,
    required this.deviceName,
    required this.icon,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
          color: isOn ? Colors.green : Colors.grey,
        ),
        title: Text(
          deviceName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isOn ? 'Ligado' : 'Desligado',
          style: TextStyle(
            color: isOn ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Switch(
          value: isOn,
          onChanged: onToggle,
          activeColor: Colors.green,
        ),
      ),
    );
  }
}
