import 'package:flutter/foundation.dart';
import '../models/mercado.dart';
import '../models/usuario.dart';
import '../services/admin_service.dart';
import '../services/mercado_service.dart';
import '../services/auth_service.dart';
import '../utils/admin_permissions.dart';

class AdminStore extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  final MercadoService _mercadoService = MercadoService();
  final AuthService _authService = AuthService();

  // Estado do usuário admin atual
  Usuario? _currentAdmin;
  Usuario? get currentAdmin => _currentAdmin;

  // Estado dos mercados pendentes
  List<Mercado> _mercadosPendentes = [];
  List<Mercado> get mercadosPendentes => _mercadosPendentes;

  // Estado de todos os mercados
  List<Mercado> _todosMercados = [];
  List<Mercado> get todosMercados => _todosMercados;

  // Estado dos usuários
  List<Usuario> _todosUsuarios = [];
  List<Usuario> get todosUsuarios => _todosUsuarios;

  List<Usuario> _usuariosAdmin = [];
  List<Usuario> get usuariosAdmin => _usuariosAdmin;

  List<Usuario> _usuariosMercado = [];
  List<Usuario> get usuariosMercado => _usuariosMercado;

  // Estados de carregamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMercados = false;
  bool get isLoadingMercados => _isLoadingMercados;

  bool _isLoadingUsuarios = false;
  bool get isLoadingUsuarios => _isLoadingUsuarios;

  // Estatísticas
  Map<String, int> _estatisticasMercados = {};
  Map<String, int> get estatisticasMercados => _estatisticasMercados;

  Map<String, int> _estatisticasUsuarios = {};
  Map<String, int> get estatisticasUsuarios => _estatisticasUsuarios;

  // Erro
  String? _erro;
  String? get erro => _erro;

  // Disposal tracking
  bool _disposed = false;
  bool get isDisposed => _disposed;

  // Inicializar dados do admin
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _erro = null;
      _safeNotifyListeners();

      // Verificar se o usuário atual é admin
      await AdminPermissions.requireAdminPermission();
      _currentAdmin = await AdminPermissions.getCurrentAdminUser();

      // Carregar dados iniciais
      await Future.wait([
        loadMercadosPendentes(),
        loadEstatisticas(),
      ]);

    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Carregar mercados pendentes
  Future<void> loadMercadosPendentes() async {
    try {
      _isLoadingMercados = true;
      _safeNotifyListeners();

      _mercadoService.getMercadosPendentes().listen((mercados) {
        _mercadosPendentes = mercados;
        _safeNotifyListeners();
      });

    } catch (e) {
      _erro = 'Erro ao carregar mercados pendentes: $e';
    } finally {
      _isLoadingMercados = false;
      _safeNotifyListeners();
    }
  }

  // Carregar todos os mercados
  Future<void> loadTodosMercados() async {
    try {
      _isLoadingMercados = true;
      _safeNotifyListeners();

      _mercadoService.getMercados().listen((mercados) {
        _todosMercados = mercados;
        _safeNotifyListeners();
      });

    } catch (e) {
      _erro = 'Erro ao carregar mercados: $e';
    } finally {
      _isLoadingMercados = false;
      _safeNotifyListeners();
    }
  }

  // Carregar todos os usuários
  Future<void> loadTodosUsuarios() async {
    try {
      _isLoadingUsuarios = true;
      _safeNotifyListeners();

      _adminService.getAllUsuarios().listen((usuarios) {
        _todosUsuarios = usuarios;
        _safeNotifyListeners();
      });

      _adminService.getAdmins().listen((admins) {
        _usuariosAdmin = admins;
        _safeNotifyListeners();
      });

      _adminService.getUsuariosMercado().listen((mercados) {
        _usuariosMercado = mercados;
        _safeNotifyListeners();
      });

    } catch (e) {
      _erro = 'Erro ao carregar usuários: $e';
    } finally {
      _isLoadingUsuarios = false;
      _safeNotifyListeners();
    }
  }

  // Aprovar mercado
  Future<void> aprovarMercado(String mercadoId) async {
    try {
      await AdminPermissions.requireAdminPermission();
      await _mercadoService.aprovarMercado(mercadoId, _currentAdmin!.id!);
      await loadEstatisticas();
    } catch (e) {
      _erro = 'Erro ao aprovar mercado: $e';
      _safeNotifyListeners();
    }
  }

  // Reprovar mercado
  Future<void> reprovarMercado(String mercadoId) async {
    try {
      await AdminPermissions.requireAdminPermission();
      await _mercadoService.reprovarMercado(mercadoId, _currentAdmin!.id!);
      await loadEstatisticas();
    } catch (e) {
      _erro = 'Erro ao reprovar mercado: $e';
      _safeNotifyListeners();
    }
  }

  // Promover usuário para admin
  Future<void> promoverParaAdmin(String userId) async {
    try {
      await AdminPermissions.requireAdminPermission();
      await _adminService.promoverParaAdmin(userId);
      await loadEstatisticas();
    } catch (e) {
      _erro = 'Erro ao promover usuário: $e';
      _safeNotifyListeners();
    }
  }

  // Rebaixar admin
  Future<void> rebaixarAdmin(String userId) async {
    try {
      await AdminPermissions.requireAdminPermission();
      await _adminService.rebaixarAdmin(userId);
      await loadEstatisticas();
    } catch (e) {
      _erro = 'Erro ao rebaixar admin: $e';
      _safeNotifyListeners();
    }
  }

  // Alterar tipo de usuário
  Future<void> alterarTipoUsuario(String userId, TipoUsuario novoTipo) async {
    try {
      await AdminPermissions.requireAdminPermission();
      await _adminService.alterarTipoUsuario(userId, novoTipo);
      await loadEstatisticas();
    } catch (e) {
      _erro = 'Erro ao alterar tipo de usuário: $e';
      _safeNotifyListeners();
    }
  }

  // Criar usuário admin
  Future<void> criarUsuarioAdmin(String email, String password, String nome, String telefone) async {
    try {
      await AdminPermissions.requireAdminPermission();
      await _authService.createAdminUser(email, password, nome, telefone);
      await loadEstatisticas();
    } catch (e) {
      _erro = 'Erro ao criar usuário admin: $e';
      _safeNotifyListeners();
    }
  }

  // Deletar usuário
  Future<void> deletarUsuario(String userId) async {
    try {
      await AdminPermissions.requireAdminPermission();
      await _adminService.deletarUsuario(userId);
      await loadEstatisticas();
    } catch (e) {
      _erro = 'Erro ao deletar usuário: $e';
      _safeNotifyListeners();
    }
  }

  // Buscar usuários
  Future<List<Usuario>> buscarUsuarios(String query) async {
    try {
      await AdminPermissions.requireAdminPermission();
      return await _adminService.buscarUsuarios(query);
    } catch (e) {
      _erro = 'Erro ao buscar usuários: $e';
      _safeNotifyListeners();
      return [];
    }
  }

  // Carregar estatísticas
  Future<void> loadEstatisticas() async {
    try {
      final estatsMercados = await _mercadoService.getEstatisticasAdmin();
      final estatsUsuarios = await _adminService.getEstatisticasUsuarios();
      
      _estatisticasMercados = estatsMercados;
      _estatisticasUsuarios = estatsUsuarios;
      _safeNotifyListeners();
    } catch (e) {
      _erro = 'Erro ao carregar estatísticas: $e';
      _safeNotifyListeners();
    }
  }

  // Limpar erro
  void clearError() {
    _erro = null;
    _safeNotifyListeners();
  }

  // Verificar se é admin
  Future<bool> isAdmin() async {
    return await AdminPermissions.isCurrentUserAdmin();
  }

  // Safe notifyListeners que verifica se não foi disposed
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}