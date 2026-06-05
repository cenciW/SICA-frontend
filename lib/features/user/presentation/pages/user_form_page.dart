import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user.dart';
import '../providers/user_provider.dart';

class UserFormPage extends StatefulWidget {
  final User? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _passwordController;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _fullNameController = TextEditingController(text: widget.user?.fullName ?? '');
    _passwordController = TextEditingController();
    _active = widget.user?.active ?? true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Usuário' : 'Novo Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
              ),
              const SizedBox(height: 16),
              if (!isEditing) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              SwitchListTile(
                title: const Text('Ativo'),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final data = {
                    'email': _emailController.text,
                    'username': _usernameController.text,
                    'full_name': _fullNameController.text,
                    'active': _active,
                    if (!isEditing) 'password': _passwordController.text,
                  };
                  final provider = context.read<UserProvider>();
                  final success = isEditing
                      ? await provider.updateUser(widget.user!.id, data)
                      : await provider.createUser(data);
                  if (success && mounted) {
                    Navigator.pop(context);
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.error ?? 'Erro ao salvar')),
                    );
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
