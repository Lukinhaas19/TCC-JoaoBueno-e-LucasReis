import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';

class AdminPermissions {
  static final AuthService _authService = AuthService();
  static final AdminService _adminService = AdminService();

  // Verificar se o usuário atual é admin
  static Future<bool> isCurrentUserAdmin() async {
    return await _authService.isCurrentUserAdmin();
  }

  // Verificar se um usuário específico é admin
  static Future<bool> isUserAdmin(String userId) async {
    return await _adminService.isAdmin(userId);
  }

  // Obter usuário atual e verificar se é admin
  static Future<Usuario?> getCurrentAdminUser() async {
    final usuario = await _authService.getCurrentUser();
    if (usuario != null && usuario.tipo == TipoUsuario.admin) {
      return usuario;
    }
    return null;
  }

  // Verificar permissão e lançar exceção se não for admin
  static Future<void> requireAdminPermission() async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('Acesso negado: permissões de administrador necessárias');
    }
  }

  // Verificar se pode aprovar/reprovar mercados
  static Future<bool> canManageMercados() async {
    return await isCurrentUserAdmin();
  }

  // Verificar se pode gerenciar usuários
  static Future<bool> canManageUsers() async {
    return await isCurrentUserAdmin();
  }

  // Verificar se pode criar outros admins
  static Future<bool> canCreateAdmins() async {
    return await isCurrentUserAdmin();
  }

  // Verificar se pode visualizar estatísticas administrativas
  static Future<bool> canViewAdminStats() async {
    return await isCurrentUserAdmin();
  }

  // Helper para executar ação apenas se for admin
  static Future<T?> executeIfAdmin<T>(Future<T> Function() action) async {
    try {
      await requireAdminPermission();
      return await action();
    } catch (e) {
      throw Exception('Operação não autorizada: $e');
    }
  }

  // Helper para obter dados com verificação de admin
  static Future<T?> getDataIfAdmin<T>(Future<T> Function() getData) async {
    final isAdmin = await isCurrentUserAdmin();
    if (isAdmin) {
      return await getData();
    }
    return null;
  }
}