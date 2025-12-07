import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../utils/admin_permissions.dart';

class UserTypeNavigator {
  static final AuthService _authService = AuthService();

  static Future<void> navigateBasedOnUserType(BuildContext context) async {
    try {
      final usuario = await _authService.getCurrentUser();

      if (usuario == null) {
        // Usuário não logado, vai para login
        Modular.to.navigate('/auth/login');
        return;
      }

      switch (usuario.tipo) {
        case TipoUsuario.admin:
          // Admin vai para painel administrativo
          Modular.to.navigate('/admin/');
          break;
        case TipoUsuario.mercado:
          // Usuário de mercado vai para dashboard do mercado
          Modular.to.navigate('/mercado/dashboard');
          break;
      }
    } catch (e) {
      // Em caso de erro, vai para login
      print('Erro ao navegar baseado no tipo de usuário: $e');
      Modular.to.navigate('/auth/login');
    }
  }

  static Future<Widget> getHomeScreenForUserType() async {
    try {
      final usuario = await _authService.getCurrentUser();

      if (usuario == null) {
        return const UserTypeRedirectScreen(destination: '/auth/login');
      }

      switch (usuario.tipo) {
        case TipoUsuario.admin:
          return const UserTypeRedirectScreen(destination: '/admin/');
        case TipoUsuario.mercado:
          return const UserTypeRedirectScreen(destination: '/mercado/dashboard');
      }
    } catch (e) {
      // Fallback em caso de erro
      return const UserTypeRedirectScreen(destination: '/auth/login');
    }
  }

  static Future<bool> isCurrentUserAdmin() async {
    return await AdminPermissions.isCurrentUserAdmin();
  }

  static Future<String> getCurrentUserTypeLabel() async {
    try {
      final usuario = await _authService.getCurrentUser();

      if (usuario == null) return 'Não logado';

      switch (usuario.tipo) {
        case TipoUsuario.admin:
          return 'Administrador';
        case TipoUsuario.mercado:
          return 'Mercado';
      }
    } catch (e) {
      return 'Erro';
    }
  }
}

class UserTypeRedirectScreen extends StatefulWidget {
  final String destination;

  const UserTypeRedirectScreen({
    super.key,
    required this.destination,
  });

  @override
  State<UserTypeRedirectScreen> createState() => _UserTypeRedirectScreenState();
}

class _UserTypeRedirectScreenState extends State<UserTypeRedirectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Modular.to.navigate(widget.destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}