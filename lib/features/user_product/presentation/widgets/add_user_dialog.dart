import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_product_provider.dart';

class AddUserDialog extends StatefulWidget {
  final String productId;

  const AddUserDialog({super.key, required this.productId});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _userIdCtrl = TextEditingController();
  String _role = 'VIEWER';
  bool _loading = false;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Usuário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _userIdCtrl,
            decoration: const InputDecoration(
              labelText: 'ID do Usuário',
              hintText: 'UUID do usuário',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(
              labelText: 'Papel',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'VIEWER', child: Text('VIEWER — Apenas visualização')),
              DropdownMenuItem(value: 'OWNER', child: Text('OWNER — Controle total')),
            ],
            onChanged: (v) => setState(() => _role = v!),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Adicionar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final userId = _userIdCtrl.text.trim();
    if (userId.isEmpty) return;

    setState(() => _loading = true);
    final ok = await context.read<UserProductProvider>().addUser(widget.productId, userId, _role);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Usuário adicionado!' : context.read<UserProductProvider>().error ?? 'Erro'),
      ));
    }
  }
}
