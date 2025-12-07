import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';
import '../models/mercado.dart';
import 'firebase_service.dart';
import 'storage_service.dart';
import 'mercado_service.dart';
import 'admin_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final StorageService _storageService = StorageService();
  final MercadoService _mercadoService = MercadoService();
  final AdminService _adminService = AdminService();

  // Login com email e senha
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erro no login: $e');
    }
  }

  // Cadastro com email e senha
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erro no cadastro: $e');
    }
  }

  // Criar perfil de usuário
  Future<void> createUserProfile(Usuario usuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuario.id)
          .set(usuario.toFirestore());
    } catch (e) {
      throw Exception('Erro ao criar perfil: $e');
    }
  }

  // Criar perfil de mercado com imagem
  Future<String> createMercadoWithImage({
    required Usuario usuario,
    required String nome,
    required String cnpj,
    required String email,
    String? endereco,
    String? telefone,
    String? cidade,
    File? imagemFile,
  }) async {
    try {
      // 1. Criar o perfil do usuário primeiro
      await createUserProfile(usuario);

      // 2. Criar mercado
      final mercado = Mercado(
        nome: nome,
        cnpj: cnpj,
        email: email,
        endereco: endereco,
        telefone: telefone,
        cidade: cidade ?? 'São Paulo, SP', // Valor padrão se não fornecido
      );

      // 3. Salvar mercado no Firestore e obter ID
      final mercadoId = await _mercadoService.createMercado(mercado);

      // 4. Se tem imagem, fazer upload e atualizar mercado
      if (imagemFile != null) {
        final imageUrl = await _storageService.uploadMercadoImage(imagemFile, mercadoId);
        
        final mercadoComImagem = mercado.copyWith(
          id: mercadoId,
          imagem: imageUrl,
        );
        
        await _mercadoService.updateMercado(mercadoComImagem);
      }

      // 5. Atualizar usuário com mercado_id
      await _firestore
          .collection('usuarios')
          .doc(usuario.id)
          .update({'mercado_id': mercadoId});

      return mercadoId;
    } catch (e) {
      throw Exception('Erro ao criar mercado com imagem: $e');
    }
  }

  // Obter usuário atual
  Future<Usuario?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          return Usuario.fromFirestore(doc);
        } else {
          // Se o documento não existe no Firestore, retorna null
          print('Usuário ${user.uid} não encontrado no Firestore');
          return null;
        }
      } catch (e) {
        print('Erro ao buscar usuário no Firestore: $e');
        // Se não conseguir buscar no Firestore, retorna dados básicos
        return Usuario(
          id: user.uid,
          email: user.email ?? '',
          telefone: user.phoneNumber ?? '',
          nome: user.displayName ?? '',
          tipo: TipoUsuario.mercado,
          dataCriacao: DateTime.now(),
        );
      }
    }
    return null;
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Verificar se usuário está logado
  bool get isLoggedIn => _auth.currentUser != null;

  // ========== FUNCIONALIDADES ADMIN ==========

  // Criar usuário admin
  Future<UserCredential> createAdminUser(String email, String password, String nome, String telefone) async {
    try {
      final credential = await createUserWithEmailAndPassword(email, password);
      
      final adminUser = Usuario(
        id: credential.user!.uid,
        email: email,
        telefone: telefone,
        nome: nome,
        tipo: TipoUsuario.admin,
        dataCriacao: DateTime.now(),
      );

      await _adminService.criarUsuarioAdmin(adminUser);
      
      return credential;
    } catch (e) {
      throw Exception('Erro ao criar usuário admin: $e');
    }
  }

  // Verificar se usuário atual é admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _adminService.isAdmin(user.uid);
    }
    return false;
  }

  // Obter usuário atual com verificação de tipo
  Future<Usuario?> getCurrentUserWithType() async {
    final usuario = await getCurrentUser();
    return usuario;
  }
}
