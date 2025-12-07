import 'dart:io';
import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../models/usuario.dart';
import '../models/mercado.dart';
import '../services/auth_service.dart';
import '../services/mercado_service.dart';
import 'promocao_store.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  final AuthService _authService = AuthService();
  final MercadoService _mercadoService = MercadoService();

  @observable
  Usuario? currentUser;

  @observable
  Mercado? currentMercado;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get isLoggedIn => currentUser != null;

  @computed
  bool get isMercado => currentUser?.tipo == TipoUsuario.mercado;

  @action
  Future<bool> signIn(String email, String password) async {
    print('🔑 [AuthStore] Iniciando login...');
    
    try {
      isLoading = true;
      errorMessage = null;
      
      final userCredential = await _authService.signInWithEmailAndPassword(
        email, 
        password,
      );
      
      if (userCredential.user != null) {
        print('✅ [AuthStore] Login Firebase bem-sucedido');
        
        // Buscar dados reais do usuário no Firestore
        currentUser = await _authService.getCurrentUser();
        print('👤 [AuthStore] Dados do usuário carregados: ${currentUser?.nome}');
        
        // Se é mercado, carregar dados do mercado
        if (currentUser?.mercadoId != null) {
          print('🏪 [AuthStore] Carregando dados do mercado...');
          await loadCurrentMercado();
          print('🏪 [AuthStore] Mercado carregado: ${currentMercado?.nome}');
        }
        
        // Aguardar um momento para garantir que tudo está carregado
        await Future.delayed(const Duration(milliseconds: 200));
        
        print('🎉 [AuthStore] Login completo com sucesso');
        return currentUser != null;
      }
      return false;
    } catch (e) {
      print('❌ [AuthStore] Erro no login: $e');
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> signUp(String email, String password, String nome, TipoUsuario tipo, String telefone) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email, 
        password,
      );
      
      if (userCredential.user != null) {
        final usuario = Usuario(
          id: userCredential.user!.uid,
          email: email,

          telefone: telefone,
          nome: nome,
          tipo: tipo,
          dataCriacao: DateTime.now(),
        );
        
        await _authService.createUserProfile(usuario);
        currentUser = usuario;
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> signUpMercadoWithImage({
    required String email,
    required String password,
    required String nome,
    required String cnpj,
    String? endereco,
    String? telefone,
    String? cidade,
    File? imagemFile,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email, 
        password,
      );
      
      if (userCredential.user != null) {
        final usuario = Usuario(
          id: userCredential.user!.uid,
          email: email,
          nome: nome,
          telefone: telefone,
          tipo: TipoUsuario.mercado,
          dataCriacao: DateTime.now(),
        );
        
        await _authService.createMercadoWithImage(
          usuario: usuario,
          nome: nome,
          cnpj: cnpj,
          email: email,
          endereco: endereco,
          telefone: telefone,
          cidade: cidade,
          imagemFile: imagemFile,
        );
        
        // Recarregar dados do usuário do Firestore para obter o mercadoId
        currentUser = await _authService.getCurrentUser();
        
        // Se é mercado, carregar dados do mercado
        if (currentUser?.mercadoId != null) {
          await loadCurrentMercado();
        }
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      currentUser = null;
      currentMercado = null;
      
      // Limpar dados relacionados
      _clearRelatedStores();
    } catch (e) {
      errorMessage = e.toString();
    }
  }
  
  void _clearRelatedStores() {
    try {
      // Limpar PromocaoStore
      final promocaoStore = Modular.get<PromocaoStore>();
      promocaoStore.clearPromocoes();
      print('🧹 [AuthStore] Stores relacionados limpos');
    } catch (e) {
      print('❌ [AuthStore] Erro ao limpar stores relacionados: $e');
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  Future<void> checkCurrentUser() async {
    try {
      isLoading = true;
      final user = await _authService.getCurrentUser();
      if (user != null) {
        currentUser = user;
        // Se é mercado, carregar dados do mercado
        if (user.mercadoId != null) {
          await loadCurrentMercado();
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadCurrentMercado() async {
    if (currentUser?.mercadoId != null) {
      try {
        final mercado = await _mercadoService.getMercadoById(currentUser!.mercadoId!);
        currentMercado = mercado;
      } catch (e) {
        print('Erro ao carregar mercado: $e');
      }
    }
  }

  @action
  Future<void> forceReloadUserData() async {
    print('🔄 [AuthStore] Forçando recarregamento completo dos dados...');
    
    try {
      isLoading = true;
      
      // Limpar dados atuais
      currentUser = null;
      currentMercado = null;
      _clearRelatedStores();
      
      // Recarregar do Firebase
      await checkCurrentUser();
      
      print('✅ [AuthStore] Recarregamento completo concluído');
    } catch (e) {
      print('❌ [AuthStore] Erro no recarregamento: $e');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
