import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import 'product_form_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reading/domain/entities/reading.dart';
import '../../../reading/presentation/providers/reading_provider.dart';
import '../../../alert/domain/entities/alert.dart';
import '../../../alert/presentation/providers/alert_provider.dart';
import '../../../../shared/widgets/decimal_form_field.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AlertProvider>().loadAlerts(_product.id);
      context.read<ReadingProvider>().loadReadings(_product.id, limit: 10);
      // Puxa o estado atual do banco (relay/pump state e última ação),
      // que pode estar desatualizado no snapshot vindo da lista.
      final fresh = await context.read<ProductProvider>().refreshProduct(_product.id);
      if (fresh != null && mounted) setState(() => _product = fresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_product.name),
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
          if (context.read<AuthProvider>().user?['role'] == 'ADMIN')
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductFormPage(product: _product)),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AlertProvider>().loadAlerts(_product.id);
          await context.read<ReadingProvider>().loadReadings(_product.id, limit: 10);
          final updated = context.read<ProductProvider>().products.firstWhere(
            (p) => p.id == _product.id,
            orElse: () => _product,
          );
          if (mounted) setState(() => _product = updated);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SensorSection(product: _product).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
            Consumer<ProductProvider>(
              builder: (context, provider, _) {
                final current = provider.products.firstWhere(
                  (p) => p.id == _product.id,
                  orElse: () => _product,
                );
                return _RelaySection(
                  product: current,
                  ledPending: provider.isTogglePending(_product.id, 'led'),
                  pumpPending: provider.isTogglePending(_product.id, 'pump'),
                  onSaveCycle: (data) async {
                    final ok = await provider.setRelayCycle(_product.id, data);
                    if (mounted) {
                      if (ok) {
                        final updated = provider.products.firstWhere(
                          (p) => p.id == _product.id,
                          orElse: () => _product,
                        );
                        setState(() => _product = updated);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                            provider.error ?? 'Erro ao salvar ciclo')),
                        );
                      }
                    }
                    return ok;
                  },
                );
              },
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 16),
            _InstanceInfoSection(product: _product, onConfigUpdated: (updated) {
              setState(() => _product = updated);
            }).animate().fadeIn(delay: 150.ms, duration: 400.ms),
            const SizedBox(height: 16),
            _AlertsSection(productId: _product.id).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 16),
            _ReadingsSection(productId: _product.id).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SensorSection extends StatelessWidget {
  final Product product;
  const _SensorSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_outlined, color: Color(0xFF2C5F8D)),
                const SizedBox(width: 8),
                Text('Leituras Atuais',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _BigSensorCard(
                  label: 'pH',
                  value: product.phCurrent,
                  min: product.phMin,
                  max: product.phMax,
                  unit: 'pH',
                  isNormal: product.phNormal,
                  icon: Icons.water_drop_outlined,
                )),
                const SizedBox(width: 12),
                Expanded(child: _BigSensorCard(
                  label: 'PPM',
                  value: product.ppmCurrent,
                  min: product.ppmMin,
                  max: product.ppmMax,
                  unit: 'ppm',
                  isNormal: product.ppmNormal,
                  icon: Icons.electrical_services_outlined,
                )),
              ],
            ),
            if (product.lastReadingAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Última leitura: ${_formatDate(product.lastReadingAt!)}',
                style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _BigSensorCard extends StatelessWidget {
  final String label;
  final double? value;
  final double? min;
  final double? max;
  final String unit;
  final bool isNormal;
  final IconData icon;

  const _BigSensorCard({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.isNormal,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final hasThreshold = min != null && max != null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statusColor = value == null
        ? colorScheme.onSurfaceVariant
        : !hasThreshold
            ? const Color(0xFF2C5F8D)
            : isNormal
                ? const Color(0xFF00C853)
                : const Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: statusColor),
              const SizedBox(width: 6),
              Text(label,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  )),
              const Spacer(),
              if (hasThreshold && value != null)
                Icon(
                  isNormal ? Icons.check_circle : Icons.warning_rounded,
                  size: 16,
                  color: statusColor,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value != null ? value!.toStringAsFixed(2) : '--',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          Text(
            unit,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          if (hasThreshold) ...[
            const SizedBox(height: 6),
            Text(
              '${min!.toStringAsFixed(1)} – ${max!.toStringAsFixed(1)}',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modo de operação derivado do par de segundos.
enum _DeviceMode { off, alwaysOn, cycle }

/// Unidade de tempo para os campos de ciclo.
enum _TimeUnit { seconds, minutes, hours }

extension _TimeUnitX on _TimeUnit {
  int get factor => switch (this) {
        _TimeUnit.seconds => 1,
        _TimeUnit.minutes => 60,
        _TimeUnit.hours => 3600,
      };
  String get label => switch (this) {
        _TimeUnit.seconds => 'seg',
        _TimeUnit.minutes => 'min',
        _TimeUnit.hours => 'h',
      };
}

/// Converte segundos para a maior unidade que ainda dá valor inteiro exato.
({int value, _TimeUnit unit}) _bestUnit(int seconds) {
  if (seconds <= 0) return (value: 0, unit: _TimeUnit.minutes);
  if (seconds % 3600 == 0) return (value: seconds ~/ 3600, unit: _TimeUnit.hours);
  if (seconds % 60 == 0) return (value: seconds ~/ 60, unit: _TimeUnit.minutes);
  return (value: seconds, unit: _TimeUnit.seconds);
}

class _RelaySection extends StatelessWidget {
  final Product product;
  final bool ledPending;
  final bool pumpPending;
  final Future<bool> Function(Map<String, dynamic> data) onSaveCycle;

  const _RelaySection({
    required this.product,
    required this.ledPending,
    required this.pumpPending,
    required this.onSaveCycle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.power_settings_new, color: Color(0xFF2C5F8D)),
                const SizedBox(width: 8),
                Text('Controles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _DeviceCycleEditor(
              key: ValueKey('led-${product.ledOnSeconds}-${product.ledOffSeconds}-${product.ledStartOn}'),
              icon: Icons.lightbulb,
              iconOff: Icons.lightbulb_outline,
              label: 'Iluminação LED',
              activeColor: const Color(0xFFFFB300),
              onSeconds: product.ledOnSeconds,
              offSeconds: product.ledOffSeconds,
              startOn: product.ledStartOn,
              isOn: product.relayState,
              pending: ledPending,
              lastActionAt: product.relayLastActionAt,
              hint: 'Ex.: Floração 12h/12h · Vegetativo 18h/6h · Alface 16h/8h',
              onSave: (on, off, startOn) => onSaveCycle({
                'led_on_seconds': on,
                'led_off_seconds': off,
                'led_start_on': startOn,
              }),
            ),
            const Divider(height: 28),
            _DeviceCycleEditor(
              key: ValueKey('pump-${product.pumpOnSeconds}-${product.pumpOffSeconds}-${product.pumpStartOn}'),
              icon: Icons.water,
              iconOff: Icons.water_outlined,
              label: 'Bomba d\'Água',
              activeColor: const Color(0xFF0288D1),
              onSeconds: product.pumpOnSeconds,
              offSeconds: product.pumpOffSeconds,
              startOn: product.pumpStartOn,
              isOn: product.pumpState,
              pending: pumpPending,
              lastActionAt: product.pumpLastActionAt,
              hint: 'Ex.: 15min ligada / 15min desligada',
              onSave: (on, off, startOn) => onSaveCycle({
                'pump_on_seconds': on,
                'pump_off_seconds': off,
                'pump_start_on': startOn,
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceCycleEditor extends StatefulWidget {
  final IconData icon;
  final IconData iconOff;
  final String label;
  final Color activeColor;
  final int onSeconds;
  final int offSeconds;
  final bool startOn;
  final bool isOn;
  final bool pending;
  final DateTime? lastActionAt;
  final String hint;
  final Future<bool> Function(int onSeconds, int offSeconds, bool startOn) onSave;

  const _DeviceCycleEditor({
    super.key,
    required this.icon,
    required this.iconOff,
    required this.label,
    required this.activeColor,
    required this.onSeconds,
    required this.offSeconds,
    required this.startOn,
    required this.isOn,
    required this.pending,
    required this.lastActionAt,
    required this.hint,
    required this.onSave,
  });

  @override
  State<_DeviceCycleEditor> createState() => _DeviceCycleEditorState();
}

class _DeviceCycleEditorState extends State<_DeviceCycleEditor> {
  late _DeviceMode _mode;
  late bool _startOn;
  late final TextEditingController _onCtrl;
  late final TextEditingController _offCtrl;
  late _TimeUnit _onUnit;
  late _TimeUnit _offUnit;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.onSeconds == 0
        ? _DeviceMode.off
        : widget.offSeconds == 0
            ? _DeviceMode.alwaysOn
            : _DeviceMode.cycle;
    _startOn = widget.startOn;

    final on = _bestUnit(widget.onSeconds == 0 ? 0 : widget.onSeconds);
    final off = _bestUnit(widget.offSeconds);
    _onUnit = on.unit;
    _offUnit = off.unit;
    _onCtrl = TextEditingController(text: on.value > 0 ? on.value.toString() : '');
    _offCtrl = TextEditingController(text: off.value > 0 ? off.value.toString() : '');
  }

  @override
  void dispose() {
    _onCtrl.dispose();
    _offCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    int onSeconds;
    int offSeconds;

    switch (_mode) {
      case _DeviceMode.off:
        onSeconds = 0;
        offSeconds = 0;
        break;
      case _DeviceMode.alwaysOn:
        onSeconds = 1;
        offSeconds = 0;
        break;
      case _DeviceMode.cycle:
        final on = int.tryParse(_onCtrl.text.trim()) ?? 0;
        final off = int.tryParse(_offCtrl.text.trim()) ?? 0;
        if (on <= 0 || off <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Informe tempos de ligado e desligado maiores que zero.')),
          );
          return;
        }
        onSeconds = on * _onUnit.factor;
        offSeconds = off * _offUnit.factor;
        break;
    }

    setState(() => _saving = true);
    final ok = await widget.onSave(onSeconds, offSeconds, _startOn);
    if (mounted) setState(() => _saving = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.label}: configuração salva.')),
      );
    }
  }

  String _statusLabel() {
    switch (_mode) {
      case _DeviceMode.off:
        return 'Desligado';
      case _DeviceMode.alwaysOn:
        return 'Sempre ligado';
      case _DeviceMode.cycle:
        return widget.isOn ? 'Em ciclo · ligado agora' : 'Em ciclo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final activeNow = widget.isOn && _mode != _DeviceMode.off;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activeNow ? widget.activeColor.withOpacity(0.15) : colorScheme.onSurface.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                activeNow ? widget.icon : widget.iconOff,
                color: activeNow ? widget.activeColor : colorScheme.onSurfaceVariant,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  if (widget.pending)
                    Row(
                      children: [
                        SizedBox(
                          height: 12, width: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: widget.activeColor),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Aguardando confirmação do dispositivo',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      _statusLabel(),
                      style: textTheme.bodySmall?.copyWith(
                        color: activeNow ? widget.activeColor : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (widget.lastActionAt != null)
                    Text(
                      'Última ação: ${widget.lastActionAt!.day.toString().padLeft(2, '0')}/${widget.lastActionAt!.month.toString().padLeft(2, '0')} ${widget.lastActionAt!.hour.toString().padLeft(2, '0')}:${widget.lastActionAt!.minute.toString().padLeft(2, '0')}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SegmentedButton<_DeviceMode>(
          segments: const [
            ButtonSegment(value: _DeviceMode.off, label: Text('Desligado'), icon: Icon(Icons.power_off, size: 16)),
            ButtonSegment(value: _DeviceMode.alwaysOn, label: Text('Sempre'), icon: Icon(Icons.flash_on, size: 16)),
            ButtonSegment(value: _DeviceMode.cycle, label: Text('Ciclo'), icon: Icon(Icons.loop, size: 16)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
          style: ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        if (_mode == _DeviceMode.cycle) ...[
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DurationField(
                label: 'Ligado por',
                controller: _onCtrl,
                unit: _onUnit,
                onUnitChanged: (u) => setState(() => _onUnit = u),
                color: widget.activeColor,
              )),
              const SizedBox(width: 12),
              Expanded(child: _DurationField(
                label: 'Desligado por',
                controller: _offCtrl,
                unit: _offUnit,
                onUnitChanged: (u) => setState(() => _offUnit = u),
                color: widget.activeColor,
              )),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.hint, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: _startOn,
            activeColor: widget.activeColor,
            title: const Text('Iniciar ligado'),
            subtitle: Text(
              _startOn
                  ? 'Liga imediatamente ao salvar e então cicla.'
                  : 'Aguarda o tempo de desligado antes da 1ª ativação.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            onChanged: (v) => setState(() => _startOn = v),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: widget.activeColor,
              foregroundColor: Colors.black87,
              disabledBackgroundColor: widget.activeColor.withOpacity(0.4),
              disabledForegroundColor: Colors.black54,
            ),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54))
                : const Icon(Icons.send, size: 16),
            label: const Text('Aplicar'),
          ),
        ),
      ],
    );
  }
}

class _DurationField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final _TimeUnit unit;
  final ValueChanged<_TimeUnit> onUnitChanged;
  final Color color;

  const _DurationField({
    required this.label,
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: '0',
                ),
              ),
            ),
            const SizedBox(width: 6),
            DropdownButton<_TimeUnit>(
              value: unit,
              underline: const SizedBox.shrink(),
              onChanged: (u) => u != null ? onUnitChanged(u) : null,
              items: _TimeUnit.values
                  .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}

class _AlertsSection extends StatelessWidget {
  final String productId;
  const _AlertsSection({required this.productId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<AlertProvider>(
      builder: (context, provider, _) {
        final active = provider.alerts.where((a) => !a.resolved).toList();
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('Alertas Ativos',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (active.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${active.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                if (active.isEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF00C853), size: 20),
                      const SizedBox(width: 8),
                      Text('Nenhum alerta ativo',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  ...active.map((alert) => _AlertTile(
                    alert: alert,
                    onResolve: () => provider.resolveAlert(productId, alert.id),
                  )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  final ProductAlert alert;
  final VoidCallback onResolve;

  const _AlertTile({required this.alert, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.severity == AlertSeverity.CRITICAL;
    final color = isCritical ? Colors.red : Colors.orange;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(isCritical ? Icons.error : Icons.warning, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.message,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${alert.sensorType.label}: ${alert.value.toStringAsFixed(2)} ${alert.sensorType.unit}',
                  style: textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onResolve,
            child: const Text('Resolver', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ReadingsSection extends StatelessWidget {
  final String productId;
  const _ReadingsSection({required this.productId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Color(0xFF2C5F8D)),
                    const SizedBox(width: 8),
                    Text('Leituras Recentes',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (provider.isLoading)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.readings.isEmpty)
                  Text('Nenhuma leitura registrada.',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))
                else
                  ...provider.readings.take(10).map((r) => _ReadingRow(reading: r)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReadingRow extends StatelessWidget {
  final Reading reading;
  const _ReadingRow({required this.reading});

  @override
  Widget build(BuildContext context) {
    final isPH = reading.sensorType == SensorType.PH;
    final color = isPH ? const Color(0xFF0288D1) : const Color(0xFF2E7D32);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              reading.sensorType.label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${reading.value.toStringAsFixed(2)} ${reading.unit}',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            _formatTime(reading.recordedAt),
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }
}

class _InstanceInfoSection extends StatefulWidget {
  final Product product;
  final void Function(Product updated) onConfigUpdated;

  const _InstanceInfoSection({required this.product, required this.onConfigUpdated});

  @override
  State<_InstanceInfoSection> createState() => _InstanceInfoSectionState();
}

class _InstanceInfoSectionState extends State<_InstanceInfoSection> {
  bool _editing = false;
  late final TextEditingController _phMinCtrl;
  late final TextEditingController _phMaxCtrl;
  late final TextEditingController _ppmMinCtrl;
  late final TextEditingController _ppmMaxCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _phMinCtrl = TextEditingController(text: p.phMin?.toString() ?? '');
    _phMaxCtrl = TextEditingController(text: p.phMax?.toString() ?? '');
    _ppmMinCtrl = TextEditingController(text: p.ppmMin?.toString() ?? '');
    _ppmMaxCtrl = TextEditingController(text: p.ppmMax?.toString() ?? '');
  }

  @override
  void dispose() {
    _phMinCtrl.dispose();
    _phMaxCtrl.dispose();
    _ppmMinCtrl.dispose();
    _ppmMaxCtrl.dispose();
    super.dispose();
  }

  double? _parse(String text) {
    final t = text.trim();
    return t.isEmpty ? null : double.tryParse(t);
  }

  String? _validateMax(String? maxVal, String minVal) {
    if (maxVal == null || maxVal.trim().isEmpty) return null;
    if (double.tryParse(maxVal.trim()) == null) return 'Inválido';
    final max = double.parse(maxVal.trim());
    final min = double.tryParse(minVal.trim());
    if (min != null && max <= min) return 'Máx > mín';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final instanceId = widget.product.instanceId;
    if (instanceId == null) return;

    final data = <String, dynamic>{};
    final phMin = _parse(_phMinCtrl.text);
    final phMax = _parse(_phMaxCtrl.text);
    final ppmMin = _parse(_ppmMinCtrl.text);
    final ppmMax = _parse(_ppmMaxCtrl.text);
    if (phMin != null) data['ph_min'] = phMin;
    if (phMax != null) data['ph_max'] = phMax;
    if (ppmMin != null) data['ppm_min'] = ppmMin;
    if (ppmMax != null) data['ppm_max'] = ppmMax;

    final provider = context.read<ProductProvider>();
    final ok = await provider.updateInstanceConfig(widget.product.id, instanceId, data);
    if (ok && mounted) {
      final updated = widget.product.copyWith(
        phMin: phMin,
        phMax: phMax,
        ppmMin: ppmMin,
        ppmMax: ppmMax,
      );
      widget.onConfigUpdated(updated);
      setState(() => _editing = false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Erro ao salvar configuração')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final p = widget.product;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_input_component_outlined, color: Color(0xFF2C5F8D)),
                const SizedBox(width: 8),
                Text('Minha Instância',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _editing = !_editing),
                  icon: Icon(_editing ? Icons.close : Icons.edit_outlined, size: 16),
                  label: Text(_editing ? 'Cancelar' : 'Editar'),
                ),
              ],
            ),
            if (p.clientId != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.developer_board, size: 16, color: Color(0xFF2C5F8D)),
                    const SizedBox(width: 8),
                    Text('Client ID: ', style: textTheme.bodySmall),
                    Text(
                      p.clientId!,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        color: const Color(0xFF2C5F8D),
                      ),
                    ),
                    const Spacer(),
                    Tooltip(
                      message: 'Use este ID para autenticar o dispositivo IoT',
                      child: const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
            if (p.instanceName != null) ...[
              const SizedBox(height: 8),
              Text('Nome: ${p.instanceName}',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 16),
            if (!_editing) ...[
              // Exibição dos thresholds
              Row(
                children: [
                  Expanded(child: _ThresholdDisplay(
                    label: 'pH',
                    min: p.phMin,
                    max: p.phMax,
                    color: const Color(0xFF0288D1),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _ThresholdDisplay(
                    label: 'PPM',
                    min: p.ppmMin,
                    max: p.ppmMax,
                    color: const Color(0xFF2E7D32),
                  )),
                ],
              ),
            ] else ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science_outlined, size: 14, color: Color(0xFF0288D1)),
                        const SizedBox(width: 4),
                        Text('pH', style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0288D1),
                          fontSize: 13,
                        )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: DecimalFormField(
                          controller: _phMinCtrl,
                          labelText: 'Mín',
                          hintText: '5.5',
                          suffixText: 'pH',
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: DecimalFormField(
                          controller: _phMaxCtrl,
                          labelText: 'Máx',
                          hintText: '6.5',
                          suffixText: 'pH',
                          validator: (v) => _validateMax(v, _phMinCtrl.text),
                        )),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.water_drop_outlined, size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text('PPM', style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E7D32),
                          fontSize: 13,
                        )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: DecimalFormField(
                          controller: _ppmMinCtrl,
                          labelText: 'Mín',
                          hintText: '700',
                          suffixText: 'ppm',
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: DecimalFormField(
                          controller: _ppmMaxCtrl,
                          labelText: 'Máx',
                          hintText: '1400',
                          suffixText: 'ppm',
                          validator: (v) => _validateMax(v, _ppmMinCtrl.text),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<ProductProvider>(
                      builder: (context, provider, _) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Salvar Parâmetros'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThresholdDisplay extends StatelessWidget {
  final String label;
  final double? min;
  final double? max;
  final Color color;

  const _ThresholdDisplay({
    required this.label,
    required this.min,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasRange = min != null && max != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(
            hasRange
                ? '${min!.toStringAsFixed(1)} – ${max!.toStringAsFixed(1)}'
                : 'Não configurado',
            style: textTheme.bodySmall?.copyWith(
              color: hasRange
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
