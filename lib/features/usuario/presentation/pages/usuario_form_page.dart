import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/usuario.dart';
import '../providers/usuario_provider.dart';

class UsuarioFormPage extends StatefulWidget {
  final Usuario? usuario;

  const UsuarioFormPage({super.key, this.usuario});

  @override
  State<UsuarioFormPage> createState() => _UsuarioFormPageState();
}

class _UsuarioFormPageState extends State<UsuarioFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _usuarioController;
  late TextEditingController _nomeCompletoController;
  late TextEditingController _senhaController;
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.usuario?.email ?? '');
    _usuarioController = TextEditingController(text: widget.usuario?.usuario ?? '');
    _nomeCompletoController = TextEditingController(text: widget.usuario?.nomeCompleto ?? '');
    _senhaController = TextEditingController();
    _ativo = widget.usuario?.ativo ?? true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usuarioController.dispose();
    _nomeCompletoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.usuario != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuário' : 'Novo Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(labelText: 'Usuário'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o usuário';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeCompletoController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
              ),
              const SizedBox(height: 16),
              if (!isEditing) ...[
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              SwitchListTile(
                title: const Text('Ativo'),
                value: _ativo,
                onChanged: (value) {
                  setState(() {
                    _ativo = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'email': _emailController.text,
                      'usuario': _usuarioController.text,
                      'nome_completo': _nomeCompletoController.text,
                      'ativo': _ativo,
                    };

                    if (!isEditing) {
                      data['senha'] = _senhaController.text;
                    }

                    final provider = context.read<UsuarioProvider>();
                    bool success;
                    if (isEditing) {
                      success = await provider.updateUsuario(widget.usuario!.id, data);
                    } else {
                      success = await provider.createUsuario(data);
                    }

                    if (success && mounted) {
                      Navigator.pop(context);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.error ?? 'Erro ao salvar')),
                      );
                    }
                  }
                },
                child: Text(isEditing ? 'Salvar Alterações' : 'Criar Usuário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
