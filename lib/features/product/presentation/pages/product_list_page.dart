import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().loadProducts();
  }

  void _showLinkProductDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vincular Produto'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Código do Produto',
            hintText: 'Ex: DEMO-001',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.isEmpty) return;
              final product = await ctx.read<ProductProvider>().linkProduct(code);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(product != null
                        ? 'Produto vinculado com sucesso!'
                        : ctx.read<ProductProvider>().error ?? 'Erro ao vincular'),
                  ),
                );
              }
            },
            child: const Text('Vincular'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(context.read<AuthProvider>().user?['role'] == 'ADMIN'
            ? 'Catálogo de Produtos'
            : 'Meus Produtos'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final isAdmin = context.read<AuthProvider>().user?['role'] == 'ADMIN';

          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${provider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _onRefresh, child: const Text('Tentar novamente')),
                ],
              ),
            );
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.leaf, size: 64, color: Color(0xFF2C5F8D)),
                  const SizedBox(height: 16),
                  Text(
                    isAdmin ? 'Nenhum produto cadastrado.' : 'Nenhum produto encontrado.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (!isAdmin) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showLinkProductDialog,
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Vincular Produto'),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ProductCard(product: product, adminMode: isAdmin)
                      .animate()
                      .fadeIn(delay: (index * 80).ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0, delay: (index * 80).ms, curve: Curves.easeOut),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final isAdmin = context.read<AuthProvider>().user?['role'] == 'ADMIN';
          if (isAdmin) {
            return FloatingActionButton(
              heroTag: 'new',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormPage()),
              ),
              backgroundColor: const Color(0xFF1E3A5F),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'link',
                onPressed: _showLinkProductDialog,
                backgroundColor: const Color(0xFF2C5F8D),
                child: const Icon(Icons.qr_code, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool adminMode;

  const _ProductCard({required this.product, this.adminMode = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (product.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              product.description!,
                              style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (adminMode && product.linkCode != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.qr_code, size: 13, color: Color(0xFF90CAF9)),
                                const SizedBox(width: 4),
                                Text(
                                  product.linkCode!,
                                  style: const TextStyle(
                                    color: Color(0xFF90CAF9),
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // No modo admin mostra ícone de catálogo; no modo normal mostra relay toggle
                    if (adminMode)
                      const Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 20)
                    else
                      _RelayToggle(product: product),
                  ],
                ),
                const SizedBox(height: 16),

                // pH and PPM sensors
                Row(
                  children: [
                    Expanded(child: _SensorChip(
                      label: 'pH',
                      value: product.phCurrent,
                      min: product.phMin,
                      max: product.phMax,
                      unit: '',
                      isNormal: product.phNormal,
                      hasValue: product.phCurrent != null,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _SensorChip(
                      label: 'PPM',
                      value: product.ppmCurrent,
                      min: product.ppmMin,
                      max: product.ppmMax,
                      unit: ' ppm',
                      isNormal: product.ppmNormal,
                      hasValue: product.ppmCurrent != null,
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer
                Row(
                  children: [
                    if (!adminMode) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.isOwner
                              ? const Color(0xFFF39C12).withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: product.isOwner
                                ? const Color(0xFFF39C12)
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          product.isOwner ? 'OWNER' : 'VIEWER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product.isOwner ? const Color(0xFFF39C12) : Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (product.lastReadingAt != null)
                      Text(
                        _formatLastReading(product.lastReadingAt!),
                        style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11),
                      ),
                    const Spacer(),
                    // Admin: sempre pode editar e deletar. Usuário normal: só OWNER
                    if (adminMode) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFFE67E22), size: 20),
                        tooltip: 'Editar',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFE74C3C), size: 20),
                        tooltip: 'Excluir',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: () => _confirmDelete(context, provider),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastReading(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }

  Future<void> _confirmDelete(BuildContext context, ProductProvider provider) async {
    final linkedCount = product.userProductsCount ?? 0;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja excluir "${product.name}"?'),
            if (adminMode && linkedCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$linkedCount usuário(s) possuem este produto vinculado. A exclusão será bloqueada.',
                      style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final ok = await provider.deleteProduct(product.id);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erro ao excluir produto'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }
}

/// Indicador (somente leitura) do estado do LED reportado pelo firmware.
/// O controle é feito na tela de detalhe — clicar aqui não altera nada,
/// evitando sobrescrever um ciclo configurado por engano.
class _RelayToggle extends StatelessWidget {
  final Product product;

  const _RelayToggle({required this.product});

  @override
  Widget build(BuildContext context) {
    final pending = context.watch<ProductProvider>().isTogglePending(product.id, 'led');
    final isOn = product.relayState;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isOn
              ? const Color(0xFFFFB300).withOpacity(0.2)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOn ? const Color(0xFFFFB300) : Colors.white30,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: pending
              ? const [
                  SizedBox(
                    height: 14, width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFB300)),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '...',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB300),
                    ),
                  ),
                ]
              : [
                  Icon(
                    isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    size: 16,
                    color: isOn ? const Color(0xFFFFB300) : Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isOn ? const Color(0xFFFFB300) : Colors.white54,
                    ),
                  ),
                ],
        ),
    );
  }
}

class _SensorChip extends StatelessWidget {
  final String label;
  final double? value;
  final double? min;
  final double? max;
  final String unit;
  final bool isNormal;
  final bool hasValue;

  const _SensorChip({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.isNormal,
    required this.hasValue,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = !hasValue
        ? Colors.white24
        : (min == null && max == null)
            ? Colors.white38
            : isNormal
                ? const Color(0xFF00C853)
                : const Color(0xFFFF3D00);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (hasValue && min != null && max != null)
                Icon(
                  isNormal ? Icons.check_circle : Icons.warning,
                  size: 14,
                  color: statusColor,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hasValue ? '${value!.toStringAsFixed(1)}$unit' : '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (min != null && max != null)
            Text(
              '${min!.toStringAsFixed(1)} – ${max!.toStringAsFixed(1)}',
              style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 10),
            ),
        ],
      ),
    );
  }
}
