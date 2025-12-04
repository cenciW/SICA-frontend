import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/estufa_usuario.dart';
import '../providers/estufa_usuario_provider.dart';
import '../../../../features/usuario/presentation/providers/usuario_provider.dart';
import '../../../../features/estufa/presentation/providers/estufa_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class EstufaUsuarioFormPage extends StatefulWidget {
  final EstufaUsuario? estufaUsuario;

  const EstufaUsuarioFormPage({super.key, this.estufaUsuario});

  @override
  State<EstufaUsuarioFormPage> createState() => _EstufaUsuarioFormPageState();
}

class _EstufaUsuarioFormPageState extends State<EstufaUsuarioFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEstufaId;
  String? _selectedUsuarioId;
  late TextEditingController _roleController;
  DateTime? _dataAcessoFim;

  @override
  void initState() {
    super.initState();
    _selectedEstufaId = widget.estufaUsuario?.estufaId;
    _selectedUsuarioId = widget.estufaUsuario?.usuarioId;
    _roleController =
        TextEditingController(text: widget.estufaUsuario?.role ?? '');
    _dataAcessoFim = widget.estufaUsuario?.dataAcessoFim;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<UsuarioProvider>().loadUsuarios(token);
        context.read<EstufaProvider>().loadEstufas(token);
      }
    });
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.estufaUsuario != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Vínculo' : 'Novo Vínculo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Consumer<EstufaProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedEstufaId,
                    decoration: const InputDecoration(labelText: 'Estufa'),
                    items: provider.estufas.map((estufa) {
                      return DropdownMenuItem(
                        value: estufa.id,
                        child: Text(estufa.nome),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? null
                        : (value) {
                            setState(() {
                              _selectedEstufaId = value;
                            });
                          },
                    validator: (value) =>
                        value == null ? 'Selecione uma estufa' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<UsuarioProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedUsuarioId,
                    decoration: const InputDecoration(labelText: 'Usuário'),
                    items: provider.usuarios.map((usuario) {
                      return DropdownMenuItem(
                        value: usuario.id,
                        child: Text(usuario.email),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? null
                        : (value) {
                            setState(() {
                              _selectedUsuarioId = value;
                            });
                          },
                    validator: (value) =>
                        value == null ? 'Selecione um usuário' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data de Fim de Acesso'),
                subtitle: Text(_dataAcessoFim != null
                    ? _dataAcessoFim.toString()
                    : 'Indefinido'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dataAcessoFim ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dataAcessoFim = picked;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'estufa_id': _selectedEstufaId,
                      'usuario_id': _selectedUsuarioId,
                      'role': _roleController.text,
                      'data_acesso_fim': _dataAcessoFim?.toIso8601String(),
                    };

                    final provider = context.read<EstufaUsuarioProvider>();
                    final token = context.read<AuthProvider>().token;
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Sessão expirada. Faça login novamente.')),
                      );
                      return;
                    }
                    bool success;
                    if (isEditing) {
                      success = await provider.updateEstufaUsuario(
                          widget.estufaUsuario!.id, data, token);
                    } else {
                      success = await provider.createEstufaUsuario(data, token);
                    }

                    if (success && mounted) {
                      Navigator.pop(context);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(provider.error ?? 'Erro ao salvar')),
                      );
                    }
                  }
                },
                child: Text(isEditing ? 'Salvar Alterações' : 'Criar Vínculo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
