import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/user_product.dart';
import '../providers/user_product_provider.dart';
import '../widgets/add_user_dialog.dart';

class UserProductPage extends StatefulWidget {
  final Product product;

  const UserProductPage({super.key, required this.product});

  @override
  State<UserProductPage> createState() => _UserProductPageState();
}

class _UserProductPageState extends State<UserProductPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProductProvider>().loadMembers(widget.product.id);
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (_) => AddUserDialog(productId: widget.product.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acesso — ${widget.product.name}'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Adicionar usuário',
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: Consumer<UserProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Erro: ${provider.error}'));
          }

          if (provider.members.isEmpty) {
            return const Center(child: Text('Nenhum membro.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.members.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final member = provider.members[index];
              return _MemberTile(
                member: member,
                productId: widget.product.id,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: const Color(0xFF1E3A5F),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final UserProduct member;
  final String productId;

  const _MemberTile({required this.member, required this.productId});

  @override
  Widget build(BuildContext context) {
    final isOwner = member.role == ProductRole.OWNER;
    final displayName = member.userFullName ?? member.userName ?? member.userEmail ?? member.userId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isOwner ? const Color(0xFFF39C12).withOpacity(0.2) : const Color(0xFF2C5F8D).withOpacity(0.15),
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isOwner ? const Color(0xFFF39C12) : const Color(0xFF2C5F8D),
          ),
        ),
      ),
      title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(member.userEmail ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOwner ? const Color(0xFFF39C12).withOpacity(0.15) : const Color(0xFF2C5F8D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isOwner ? const Color(0xFFF39C12) : const Color(0xFF2C5F8D).withOpacity(0.4),
              ),
            ),
            child: Text(
              isOwner ? 'OWNER' : 'VIEWER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOwner ? const Color(0xFFF39C12) : const Color(0xFF2C5F8D),
              ),
            ),
          ),
          if (!isOwner) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
              tooltip: 'Revogar acesso',
              onPressed: () => _confirmRevoke(context),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmRevoke(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revogar acesso'),
        content: Text('Remover acesso de "${member.userFullName ?? member.userEmail}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revogar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<UserProductProvider>().revokeAccess(productId, member.userId);
    }
  }
}
