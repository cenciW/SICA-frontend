import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_page.dart';

import 'features/usuario/data/datasources/usuario_remote_datasource.dart';
import 'features/usuario/data/repositories/usuario_repository_impl.dart';
import 'features/usuario/presentation/providers/usuario_provider.dart';
import 'features/usuario/presentation/pages/usuario_list_page.dart';
import 'features/usuario/presentation/pages/usuario_form_page.dart';

import 'features/estufa/data/datasources/estufa_remote_datasource.dart';
import 'features/estufa/data/repositories/estufa_repository_impl.dart';
import 'features/estufa/presentation/providers/estufa_provider.dart';
import 'features/estufa/presentation/pages/estufa_list_page.dart';
import 'features/estufa/presentation/pages/estufa_form_page.dart';

import 'features/estufa_usuario/data/datasources/estufa_usuario_remote_datasource.dart';
import 'features/estufa_usuario/data/repositories/estufa_usuario_repository_impl.dart';
import 'features/estufa_usuario/presentation/providers/estufa_usuario_provider.dart';
import 'features/estufa_usuario/presentation/pages/estufa_usuario_list_page.dart';
import 'features/estufa_usuario/presentation/pages/estufa_usuario_form_page.dart';

import 'features/modulo/data/datasources/modulo_remote_datasource.dart';
import 'features/modulo/data/repositories/modulo_repository_impl.dart';
import 'features/modulo/presentation/providers/modulo_provider.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    // Usuario Routes
    GoRoute(
      path: '/usuarios',
      builder: (context, state) => const UsuarioListPage(),
    ),
    GoRoute(
      path: '/usuarios/novo',
      builder: (context, state) => const UsuarioFormPage(),
    ),
    // Estufa Routes
    GoRoute(
      path: '/estufas',
      builder: (context, state) => const EstufaListPage(),
    ),
    GoRoute(
      path: '/estufas/novo',
      builder: (context, state) => const EstufaFormPage(),
    ),
    // EstufaUsuario Routes
    GoRoute(
      path: '/estufa-usuarios',
      builder: (context, state) => const EstufaUsuarioListPage(),
    ),
    GoRoute(
      path: '/estufa-usuarios/novo',
      builder: (context, state) => const EstufaUsuarioFormPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseUrl = 'http://192.168.1.104:3000';
    final httpClient = http.Client();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthRepositoryImpl(AuthRemoteDataSource()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UsuarioProvider(
            repository: UsuarioRepositoryImpl(
              remoteDataSource: UsuarioRemoteDataSource(
                baseUrl: baseUrl,
                client: httpClient,
              ),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EstufaProvider(
            repository: EstufaRepositoryImpl(
              remoteDataSource: EstufaRemoteDataSource(
                baseUrl: baseUrl,
                client: httpClient,
              ),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => EstufaUsuarioProvider(
            repository: EstufaUsuarioRepositoryImpl(
              remoteDataSource: EstufaUsuarioRemoteDataSource(
                baseUrl: baseUrl,
                client: httpClient,
              ),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ModuloProvider(
            repository: ModuloRepositoryImpl(
              remoteDataSource: ModuloRemoteDataSource(http.Client()),
            ),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'SICA',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
