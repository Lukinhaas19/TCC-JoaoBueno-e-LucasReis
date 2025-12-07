import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';
import 'firebase_service.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Verificar se um usuário é admin
  Future<bool> isAdmin(String userId) async {
    try {
      final doc = await _firestore
          .collection('usuarios')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final usuario = Usuario.fromFirestore(doc);
        return usuario.tipo == TipoUsuario.admin;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obter todos os usuários (apenas para admin)
  Stream<List<Usuario>> getAllUsuarios() {
    return _firestore
        .collection('usuarios')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Usuario.fromFirestore(doc))
            .toList());
  }

  // Obter usuários por tipo
  Stream<List<Usuario>> getUsuariosByTipo(TipoUsuario tipo) {
    return _firestore
        .collection('usuarios')
        .where('tipo', isEqualTo: tipo.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Usuario.fromFirestore(doc))
            .toList());
  }

  // Obter todos os admins
  Stream<List<Usuario>> getAdmins() {
    return getUsuariosByTipo(TipoUsuario.admin);
  }

  // Obter todos os usuários de mercado
  Stream<List<Usuario>> getUsuariosMercado() {
    return getUsuariosByTipo(TipoUsuario.mercado);
  }

  // Promover usuário para admin
  Future<void> promoverParaAdmin(String userId) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .update({'tipo': 'admin'});
    } catch (e) {
      throw Exception('Erro ao promover usuário para admin: $e');
    }
  }

  // Rebaixar admin para usuário comum
  Future<void> rebaixarAdmin(String userId) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .update({'tipo': 'comum'});
    } catch (e) {
      throw Exception('Erro ao rebaixar admin: $e');
    }
  }

  // Alterar tipo de usuário
  Future<void> alterarTipoUsuario(String userId, TipoUsuario novoTipo) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .update({'tipo': novoTipo.toString().split('.').last});
    } catch (e) {
      throw Exception('Erro ao alterar tipo de usuário: $e');
    }
  }

  // Criar usuário admin diretamente
  Future<void> criarUsuarioAdmin(Usuario usuario) async {
    try {
      final usuarioAdmin = usuario.copyWith(tipo: TipoUsuario.admin);
      await _firestore
          .collection('usuarios')
          .doc(usuario.id)
          .set(usuarioAdmin.toFirestore());
    } catch (e) {
      throw Exception('Erro ao criar usuário admin: $e');
    }
  }

  // Deletar usuário (apenas para admin)
  Future<void> deletarUsuario(String userId) async {
    try {
      await _firestore.collection('usuarios').doc(userId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  // Obter estatísticas de usuários
  Future<Map<String, int>> getEstatisticasUsuarios() async {
    try {
      final admins = await _firestore
          .collection('usuarios')
          .where('tipo', isEqualTo: 'admin')
          .get();
      
      final mercados = await _firestore
          .collection('usuarios')
          .where('tipo', isEqualTo: 'mercado')
          .get();
      
      final comuns = await _firestore
          .collection('usuarios')
          .where('tipo', isEqualTo: 'comum')
          .get();

      return {
        'admins': admins.docs.length,
        'mercados': mercados.docs.length,
        'comuns': comuns.docs.length,
        'total': admins.docs.length + mercados.docs.length + comuns.docs.length,
      };
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas de usuários: $e');
    }
  }

  // Buscar usuários por nome ou email
  Future<List<Usuario>> buscarUsuarios(String query) async {
    try {
      // Busca por nome
      final nomeQuery = await _firestore
          .collection('usuarios')
          .where('nome', isGreaterThanOrEqualTo: query)
          .where('nome', isLessThan: query + 'z')
          .get();

      // Busca por email
      final emailQuery = await _firestore
          .collection('usuarios')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + 'z')
          .get();

      final resultados = <Usuario>[];
      final idsAdicionados = <String>{};

      // Adiciona resultados da busca por nome
      for (final doc in nomeQuery.docs) {
        if (!idsAdicionados.contains(doc.id)) {
          resultados.add(Usuario.fromFirestore(doc));
          idsAdicionados.add(doc.id);
        }
      }

      // Adiciona resultados da busca por email
      for (final doc in emailQuery.docs) {
        if (!idsAdicionados.contains(doc.id)) {
          resultados.add(Usuario.fromFirestore(doc));
          idsAdicionados.add(doc.id);
        }
      }

      return resultados;
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }
}