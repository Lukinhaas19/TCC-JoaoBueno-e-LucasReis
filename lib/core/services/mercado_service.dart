import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mercado.dart';
import 'firebase_service.dart';

class MercadoService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Obter todos os mercados
  Stream<List<Mercado>> getMercados() {
    return _firestore
        .collection('mercados')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mercado.fromFirestore(doc))
            .toList());
  }

  // Obter todos os mercados uma vez (para carregamento inicial)
  Future<List<Mercado>> getMercadosOnce() async {
    try {
      final snapshot = await _firestore.collection('mercados').get();
      return snapshot.docs
          .map((doc) => Mercado.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar mercados: $e');
    }
  }

  // Obter mercado por ID
  Future<Mercado?> getMercadoById(String id) async {
    try {
      final doc = await _firestore.collection('mercados').doc(id).get();
      if (doc.exists) {
        return Mercado.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar mercado: $e');
    }
  }

  // Criar mercado
  Future<String> createMercado(Mercado mercado) async {
    try {
      final docRef = await _firestore
          .collection('mercados')
          .add(mercado.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar mercado: $e');
    }
  }

  // Atualizar mercado
  Future<void> updateMercado(Mercado mercado) async {
    try {
      await _firestore
          .collection('mercados')
          .doc(mercado.id)
          .update(mercado.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar mercado: $e');
    }
  }

  // Deletar mercado
  Future<void> deleteMercado(String id) async {
    try {
      await _firestore.collection('mercados').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar mercado: $e');
    }
  }

  // Buscar mercados por nome
  Stream<List<Mercado>> searchMercados(String query) {
    // Normalize helper to lower and remove common diacritics
    String _normalize(String? s) {
      if (s == null) return '';
      var r = s.toLowerCase();
      const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
      const to   = 'aaaaaeeeeiiiiooooouuuucn';
      for (var i = 0; i < from.length; i++) {
        r = r.replaceAll(from[i], to[i]);
      }
      return r;
    }

    final search = _normalize(query);

    // Get all mercados once and filter client-side to avoid orderBy/index issues
    final futureList = _firestore.collection('mercados').get().then((snapshot) {
      final list = snapshot.docs.map((doc) => Mercado.fromFirestore(doc)).toList();
      final filtered = list.where((m) {
        final nome = _normalize(m.nome);
        final cidade = _normalize(m.cidade);
        final endereco = _normalize(m.endereco);
        return nome.contains(search) || cidade.contains(search) || endereco.contains(search);
      }).toList();
      return filtered;
    }).catchError((e) {
      print('❌ [MercadoService] Error fetching mercados for client-side search: $e');
      return <Mercado>[];
    });

    return Stream.fromFuture(futureList);
  }

  // ========== FUNCIONALIDADES ADMIN ==========

  // Obter mercados por status
  Stream<List<Mercado>> getMercadosByStatus(StatusMercado status) {
    return _firestore
        .collection('mercados')
        .where('status', isEqualTo: status.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mercado.fromFirestore(doc))
            .toList());
  }

  // Obter mercados pendentes
  Stream<List<Mercado>> getMercadosPendentes() {
    return getMercadosByStatus(StatusMercado.pendente);
  }

  // Aprovar mercado
  Future<void> aprovarMercado(String mercadoId, String adminId) async {
    try {
      await _firestore
          .collection('mercados')
          .doc(mercadoId)
          .update({
        'status': StatusMercado.aprovado.toString().split('.').last,
        'data_aprovacao': Timestamp.fromDate(DateTime.now()),
        'admin_aprovador_id': adminId,
      });
    } catch (e) {
      throw Exception('Erro ao aprovar mercado: $e');
    }
  }

  // Reprovar mercado
  Future<void> reprovarMercado(String mercadoId, String adminId) async {
    try {
      await _firestore
          .collection('mercados')
          .doc(mercadoId)
          .update({
        'status': StatusMercado.reprovado.toString().split('.').last,
        'data_aprovacao': Timestamp.fromDate(DateTime.now()),
        'admin_aprovador_id': adminId,
      });
    } catch (e) {
      throw Exception('Erro ao reprovar mercado: $e');
    }
  }

  // Obter mercados apenas aprovados (para usuários comuns)
  Stream<List<Mercado>> getMercadosAprovados() {
    return getMercadosByStatus(StatusMercado.aprovado);
  }

  // Obter estatísticas para admin
  Future<Map<String, int>> getEstatisticasAdmin() async {
    try {
      final pendentes = await _firestore
          .collection('mercados')
          .where('status', isEqualTo: 'pendente')
          .get();
      
      final aprovados = await _firestore
          .collection('mercados')
          .where('status', isEqualTo: 'aprovado')
          .get();
      
      final reprovados = await _firestore
          .collection('mercados')
          .where('status', isEqualTo: 'reprovado')
          .get();

      return {
        'pendentes': pendentes.docs.length,
        'aprovados': aprovados.docs.length,
        'reprovados': reprovados.docs.length,
        'total': pendentes.docs.length + aprovados.docs.length + reprovados.docs.length,
      };
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: $e');
    }
  }
}
