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
import 'features/splash/presentation/pages/splash_page.dart';

import 'features/user/data/datasources/user_remote_datasource.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/presentation/providers/user_provider.dart';
import 'features/user/presentation/pages/user_list_page.dart';

import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/presentation/providers/product_provider.dart';
import 'features/product/presentation/pages/product_list_page.dart';

import 'features/user_product/data/datasources/user_product_remote_datasource.dart';
import 'features/user_product/presentation/providers/user_product_provider.dart';

import 'features/reading/data/datasources/reading_remote_datasource.dart';
import 'features/reading/presentation/providers/reading_provider.dart';

import 'features/alert/data/datasources/alert_remote_datasource.dart';
import 'features/alert/presentation/providers/alert_provider.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/users', builder: (_, __) => const UserListPage()),
    GoRoute(path: '/products', builder: (_, __) => const ProductListPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepositoryImpl(AuthRemoteDataSource())),
        ),

        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(
            repository: UserRepositoryImpl(
              dataSource: UserRemoteDataSource(client: httpClient, token: ''),
            ),
          ),
          update: (_, auth, prev) {
            prev!.updateToken(auth.token ?? '');
            return prev;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(
            repository: ProductRepositoryImpl(
              dataSource: ProductRemoteDataSource(client: httpClient, token: ''),
            ),
          ),
          update: (_, auth, prev) {
            prev!.updateToken(auth.token ?? '');
            return prev;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, UserProductProvider>(
          create: (_) => UserProductProvider(
            dataSource: UserProductRemoteDataSource(client: httpClient, token: ''),
          ),
          update: (_, auth, prev) {
            prev!.updateToken(auth.token ?? '');
            return prev;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, ReadingProvider>(
          create: (_) => ReadingProvider(
            dataSource: ReadingRemoteDataSource(client: httpClient, token: ''),
          ),
          update: (_, auth, prev) {
            prev!.updateToken(auth.token ?? '');
            return prev;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, AlertProvider>(
          create: (_) => AlertProvider(
            dataSource: AlertRemoteDataSource(client: httpClient, token: ''),
          ),
          update: (_, auth, prev) {
            prev!.updateToken(auth.token ?? '');
            return prev;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'SICA',
            debugShowCheckedModeBanner: false,
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
