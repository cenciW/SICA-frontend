import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usuario_provider.dart';
import 'usuario_form_page.dart';

class UsuarioListPage extends StatefulWidget {
  const UsuarioListPage({super.key});

  @override
  State<UsuarioListPage> createState() => _UsuarioListPageState();
}

class _UsuarioListPageState extends State<UsuarioListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuarioProvider>().loadUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsuarioFormPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Erro: ${provider.error}'));
          }

          if (provider.usuarios.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          return ListView.builder(
            itemCount: provider.usuarios.length,
            itemBuilder: (context, index) {
              final usuario = provider.usuarios[index];
              return ListTile(
                title: Text(usuario.usuario),
                subtitle: Text(usuario.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UsuarioFormPage(usuario: usuario),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar exclusão'),
                            content: const Text('Deseja realmente excluir este usuário?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await context.read<UsuarioProvider>().deleteUsuario(usuario.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
