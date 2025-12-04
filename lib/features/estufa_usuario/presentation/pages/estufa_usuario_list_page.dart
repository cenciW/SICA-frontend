import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/estufa_usuario_provider.dart';
import 'estufa_usuario_form_page.dart';

class EstufaUsuarioListPage extends StatefulWidget {
  const EstufaUsuarioListPage({super.key});

  @override
  State<EstufaUsuarioListPage> createState() => _EstufaUsuarioListPageState();
}

class _EstufaUsuarioListPageState extends State<EstufaUsuarioListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<EstufaUsuarioProvider>().loadEstufaUsuarios(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vínculos Estufa-Usuário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EstufaUsuarioFormPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<EstufaUsuarioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Erro: ${provider.error}'));
          }

          if (provider.estufaUsuarios.isEmpty) {
            return const Center(child: Text('Nenhum vínculo encontrado.'));
          }

          return ListView.builder(
            itemCount: provider.estufaUsuarios.length,
            itemBuilder: (context, index) {
              final estufaUsuario = provider.estufaUsuarios[index];
              return ListTile(
                title: Text(
                    'Estufa: ${estufaUsuario.estufa?.nome ?? estufaUsuario.estufaId}'),
                subtitle: Text(
                    'Usuário: ${estufaUsuario.usuario?.email ?? estufaUsuario.usuarioId} - Role: ${estufaUsuario.role}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EstufaUsuarioFormPage(
                                estufaUsuario: estufaUsuario),
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
                            content: const Text(
                                'Deseja realmente excluir este vínculo?'),
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
                          final token = context.read<AuthProvider>().token;
                          if (token != null) {
                            await context
                                .read<EstufaUsuarioProvider>()
                                .deleteEstufaUsuario(estufaUsuario.id, token);
                          }
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
