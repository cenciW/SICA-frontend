import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/modulo_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/modulo.dart';

class AddModuloPage extends StatefulWidget {
  final String estufaId;
  final String estufaNome;

  const AddModuloPage({
    super.key,
    required this.estufaId,
    required this.estufaNome,
  });

  @override
  State<AddModuloPage> createState() => _AddModuloPageState();
}

class _AddModuloPageState extends State<AddModuloPage> {
  ModuloTipo? _selectedTipo;
  final _nomeController = TextEditingController();
  bool _isCreating = false;

  final Map<ModuloTipo, Map<String, dynamic>> _moduloTemplates = {
    ModuloTipo.co2: {
      'nome': 'Controlador de CO2',
      'icon': Icons.cloud,
      'color': Colors.grey.shade400,
      'description': 'Monitoramento e controle de níveis de CO2',
    },
    ModuloTipo.irrigacao: {
      'nome': 'Sistema de Irrigação',
      'icon': Icons.water_drop,
      'color': const Color(0xFF00B0FF),
      'description': 'Controle de irrigação com monitoramento de pH e EC',
    },
    ModuloTipo.iluminacao: {
      'nome': 'Iluminação Avançada',
      'icon': Icons.lightbulb,
      'color': const Color(0xFFFFB300),
      'description': 'Controle de espectro e intensidade luminosa',
    },
    ModuloTipo.clima: {
      'nome': 'Controle de Clima',
      'icon': Icons.thermostat,
      'color': const Color(0xFFFF6F00),
      'description': 'Temperatura, umidade e ventilação',
    },
    ModuloTipo.nutricao: {
      'nome': 'Solução Nutritiva',
      'icon': Icons.science,
      'color': const Color(0xFF00C853),
      'description': 'Dosagem automática de nutrientes',
    },
  };

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _createModulo() async {
    if (_selectedTipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um tipo de módulo')),
      );
      return;
    }

    setState(() => _isCreating = true);

    final token = context.read<AuthProvider>().token;
    if (token == null) {
      setState(() => _isCreating = false);
      return;
    }

    final data = {
      'estufaId': widget.estufaId,
      'tipo': _selectedTipo.toString().split('.').last.toUpperCase(),
      'nome': _nomeController.text.isEmpty
          ? _moduloTemplates[_selectedTipo]!['nome']
          : _nomeController.text,
      'ativo': true,
    };

    final success =
        await context.read<ModuloProvider>().createModulo(data, token);

    if (mounted) {
      setState(() => _isCreating = false);

      if (success) {
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao criar módulo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), //blue smoothed background
      appBar: AppBar(
        title: const Text('Adicionar Módulo'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionar módulo em:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.estufaNome,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Selecione o tipo de módulo:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...ModuloTipo.values.map((tipo) => _buildModuloTypeCard(tipo)),
            const SizedBox(height: 24),
            if (_selectedTipo != null) ...[
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Módulo (opcional)',
                  hintText: _moduloTemplates[_selectedTipo]!['nome'],
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createModulo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Criar Módulo',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModuloTypeCard(ModuloTipo tipo) {
    final template = _moduloTemplates[tipo]!;
    final isSelected = _selectedTipo == tipo;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? template['color'] : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedTipo = tipo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: template['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  template['icon'],
                  color: template['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template['nome'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: template['color'],
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
