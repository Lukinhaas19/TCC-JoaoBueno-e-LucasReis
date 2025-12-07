import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promocao.dart';
import 'firebase_service.dart';
import 'storage_service.dart';

class PromocaoService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final StorageService _storageService = StorageService();

  // Obter todas as promoções
  Stream<List<Promocao>> getPromocoes() {
    return _firestore
        .collection('promocoes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Promocao.fromFirestore(doc))
            .toList());
  }

  // Obter promoções de um mercado específico
  Stream<List<Promocao>> getPromocoesByMercado(String mercadoId) {
    return _firestore
        .collection('promocoes')
        .where('customer_id', isEqualTo: mercadoId)
        .snapshots()
        .map((snapshot) {
          final promocoes = snapshot.docs
              .map((doc) {
                try {
                  return Promocao.fromFirestore(doc);
                } catch (e) {
                  print('⚠️ [PromocaoService] Erro ao converter documento ${doc.id}: $e');
                  return null;
                }
              })
              .where((p) => p != null)
              .cast<Promocao>()
              .toList();
          
          // Ordenar localmente por nome para manter a consistência
          promocoes.sort((a, b) => (a.nome ?? '').compareTo(b.nome ?? ''));
              
          return promocoes;
        });
  }

  // Obter promoção por ID
  Future<Promocao?> getPromocaoById(String id) async {
    try {
      final doc = await _firestore.collection('promocoes').doc(id).get();
      if (doc.exists) {
        return Promocao.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar promoção: $e');
    }
  }

  // Criar promoção
  Future<String> createPromocao(Promocao promocao) async {
    try {
      final docRef = await _firestore
          .collection('promocoes')
          .add(promocao.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar promoção: $e');
    }
  }

  // Criar promoção com imagem
  Future<String> createPromocaoWithImage(Promocao promocao, File? imagemFile) async {
    try {
      print('🔥 [PromocaoService] Iniciando criação da promoção...');
      print('📊 Dados para Firestore: ${promocao.toFirestore()}');
      
      // 1. Criar promoção sem imagem primeiro
      final docRef = await _firestore
          .collection('promocoes')
          .add(promocao.toFirestore());
      
      final promocaoId = docRef.id;
      print('✅ [Firestore] Promoção criada com ID: $promocaoId');

      // 2. Se tem imagem, fazer upload e atualizar
      if (imagemFile != null) {
        print('🖼️ [Storage] Iniciando upload da imagem...');
        print('📁 Caminho da imagem: ${imagemFile.path}');
        print('📏 Tamanho do arquivo: ${await imagemFile.length()} bytes');
        
        final imageUrl = await _storageService.uploadPromocaoImage(
          imagemFile, 
          promocao.customerId, 
          promocaoId,
        );
        
        print('✅ [Storage] Upload concluído. URL: $imageUrl');
        print('🔄 [Firestore] Atualizando documento com URL da imagem...');
        
        await docRef.update({'imagem': imageUrl});
        print('✅ [Firestore] Documento atualizado com sucesso');
      } else {
        print('ℹ️ Nenhuma imagem para upload');
      }

      print('🎉 [PromocaoService] Processo completo! ID: $promocaoId');
      return promocaoId;
    } catch (e) {
      print('❌ [PromocaoService] Erro: $e');
      throw Exception('Erro ao criar promoção com imagem: $e');
    }
  }

  // Atualizar promoção
  Future<void> updatePromocao(Promocao promocao) async {
    try {
      await _firestore
          .collection('promocoes')
          .doc(promocao.id)
          .update(promocao.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar promoção: $e');
    }
  }

  // Atualizar promoção com nova imagem
  Future<void> updatePromocaoWithImage(Promocao promocao, File? novaImagemFile) async {
    try {
      // 1. Se tem nova imagem, fazer upload
      String? novaImagemUrl;
      if (novaImagemFile != null) {
        // Deletar imagem antiga se existir
        if (promocao.imagem != null && promocao.imagem!.isNotEmpty) {
          await _storageService.deleteImage(promocao.imagem!);
        }
        
        // Upload nova imagem
        novaImagemUrl = await _storageService.uploadPromocaoImage(
          novaImagemFile,
          promocao.customerId,
          promocao.id!,
        );
      }

      // 2. Atualizar promoção
      final promocaoAtualizada = promocao.copyWith(
        imagem: novaImagemUrl ?? promocao.imagem,
      );

      await _firestore
          .collection('promocoes')
          .doc(promocao.id)
          .update(promocaoAtualizada.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar promoção com imagem: $e');
    }
  }

  // Deletar promoção
  Future<void> deletePromocao(String id) async {
    try {
      await _firestore.collection('promocoes').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar promoção: $e');
    }
  }

  // Buscar promoções por nome
  Stream<List<Promocao>> searchPromocoes(String query) {
    

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

    final futureList = _firestore.collection('promocoes').get().then((snapshot) {
      final list = snapshot.docs.map((doc) => Promocao.fromFirestore(doc)).toList();
      final filtered = list.where((p) {
        final nome = _normalize(p.nome);
        return nome.contains(search);
      }).toList();
      
      return filtered;
    }).catchError((e) {
      return <Promocao>[];
    });

    return Stream.fromFuture(futureList);
  }

  // Método alternativo para buscar promoções (mesmo que getPromocoesByMercado)
  Stream<List<Promocao>> getPromocoesByMercadoPublic(String mercadoId) {
    // Como customer_id agora é mercadoId, podemos usar o método padrão
    return getPromocoesByMercado(mercadoId);
  }

  // Obter promoções ativas (não expiradas)
  Stream<List<Promocao>> getPromocoesAtivas() {
    final now = DateTime.now();
    return _firestore
        .collection('promocoes')
        .where('validade', isGreaterThan: Timestamp.fromDate(now))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Promocao.fromFirestore(doc))
            .toList());
  }

  // Obter promoções relâmpago (ativas e marcadas como relâmpago)
  Stream<List<Promocao>> getPromocoesRelampago() {
    final now = DateTime.now();
    _firestore.collection('promocoes')
        .where('validade', isGreaterThan: Timestamp.fromDate(now))
        .get()
        .then((snapshot) {
        });
    return _firestore
        .collection('promocoes')
        .where('relampago', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final promocoes = snapshot.docs
              .map((doc) => Promocao.fromFirestore(doc))
              .toList();
          return promocoes;
        });
  }

  // Método futuro com índice (desabilitado até criar o índice)
  Stream<List<Promocao>> getPromocoesByMercadoWithIndex(String mercadoId) {
    
    return _firestore
        .collection('promocoes')
        .where('customer_id', isEqualTo: mercadoId)
        .orderBy('nome') // Requer índice composto: customer_id + nome
        .snapshots()
        .map((snapshot) {
          final promocoes = snapshot.docs
              .map((doc) => Promocao.fromFirestore(doc))
              .toList();
          
          print('✅ [PromocaoService] ${promocoes.length} promoções carregadas com índice');
          return promocoes;
        });
  }
}
