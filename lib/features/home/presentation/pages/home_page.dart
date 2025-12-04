import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../estufa/presentation/providers/estufa_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggingOut = false;

  void _handleLogout() async {
    setState(() => _isLoggingOut = true);
    
    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      context.read<AuthProvider>().logout();
      context.go('/login');
    }
  }

  void _showVincularEstufaDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular Estufa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Código da Estufa'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final codigo = controller.text;
              if (codigo.isNotEmpty) {
                final token = context.read<AuthProvider>().token;
                if (token != null) {
                  final success = await context.read<EstufaProvider>().vincularEstufa(codigo, token);
                  if (success) {
                    if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estufa vinculada com sucesso!')));
                    }
                  } else {
                    if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<EstufaProvider>().error ?? 'Erro ao vincular')));
                    }
                  }
                }
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.read<AuthProvider>().user;

    // If logging out, show the exit animation overlay
    if (_isLoggingOut) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.handSpock, size: 80, color: Colors.amber)
                  .animate()
                  .shake(duration: 500.ms)
                  .fadeOut(delay: 500.ms, duration: 300.ms),
              const SizedBox(height: 20),
              Text(
                'Até logo!',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeOut(delay: 500.ms, duration: 300.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(FontAwesomeIcons.leaf, size: 48, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    'SICA',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            if (user?['role'] == 'ADMIN')
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Usuários'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/usuarios');
                },
              ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.plantWilt),
              title: const Text('Estufas'),
              onTap: () {
                Navigator.pop(context);
                context.push('/estufas');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Adicionar Estufa'),
              onTap: () {
                Navigator.pop(context);
                _showVincularEstufaDialog(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Painel SICA'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(!isDark),
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowRightFromBracket, size: 20),
            onPressed: _handleLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [Colors.green[900]!, Colors.green[800]!]
                      : [Colors.green[100]!, Colors.green[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.plantWilt, size: 32, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        'Olá, ${user?['name'] ?? 'Usuário'}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.green[900],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sua estufa está operando de forma ideal.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.green[100] : Colors.green[800],
                        ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad),

            const SizedBox(height: 32),

            // Dashboard Grid
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: FontAwesomeIcons.temperatureThreeQuarters,
                    title: 'Temperatura',
                    value: '24°C',
                    color: Colors.orange,
                    delay: 300,
                  ),
                  _buildDashboardCard(
                    context,
                    icon: FontAwesomeIcons.droplet,
                    title: 'Umidade',
                    value: '65%',
                    color: Colors.blue,
                    delay: 400,
                  ),
                  _buildDashboardCard(
                    context,
                    icon: FontAwesomeIcons.sun,
                    title: 'Luminosidade',
                    value: '850 lux',
                    color: Colors.amber,
                    delay: 500,
                  ),
                  _buildDashboardCard(
                    context,
                    icon: FontAwesomeIcons.seedling,
                    title: 'Umidade do Solo',
                    value: 'Alta',
                    color: Colors.brown,
                    delay: 600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required int delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).scale(delay: delay.ms, curve: Curves.easeOutBack);
  }
}
