import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:provider/provider.dart';
import '../../core/stores/admin_store.dart';
import '../../core/utils/admin_permissions.dart';

class AdminGuard extends RouteGuard {
  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    try {
      // Verificar se o usuário atual é admin
      final isAdmin = await AdminPermissions.isCurrentUserAdmin();
      
      if (!isAdmin) {
        // Se não for admin, redireciona para home
        Modular.to.navigate('/');
        return false;
      }
      
      return true;
    } catch (e) {
      print('Erro na verificação de admin: $e');
      Modular.to.navigate('/auth/login');
      return false;
    }
  }
}

class AdminWrapper extends StatelessWidget {
  final Widget child;

  const AdminWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AdminPermissions.isCurrentUserAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Acesso Negado'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Acesso Negado',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Você não tem permissões de administrador',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ChangeNotifierProvider(
          create: (_) => AdminStore(),
          child: child,
        );
      },
    );
  }
}

class AdminPageWrapper extends StatelessWidget {
  final Widget child;

  const AdminPageWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AdminWrapper(child: child);
  }
}