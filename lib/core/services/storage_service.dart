import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseService.storage;

  /// Upload de imagem de mercado
  /// Retorna a URL de download da imagem
  Future<String> uploadMercadoImage(File imageFile, String mercadoId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('mercados/$mercadoId/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem do mercado: $e');
    }
  }

  /// Upload de imagem de promoção
  /// Retorna a URL de download da imagem
  Future<String> uploadPromocaoImage(File imageFile, String mercadoId, String promocaoId) async {
    try {
      print('📤 [StorageService] Iniciando upload...');
      print('📁 Arquivo: ${imageFile.path}');
      print('🏪 Mercado ID: $mercadoId');
      print('🎯 Promoção ID: $promocaoId');
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final storagePath = 'promocoes/$mercadoId/$promocaoId/$fileName';
      print('🗂️ Caminho no Storage: $storagePath');
      
      final ref = _storage.ref().child(storagePath);
      
      print('⬆️ Iniciando upload...');
      final uploadTask = ref.putFile(imageFile);
      
      // Monitor do progresso
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📊 Progresso: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      final snapshot = await uploadTask;
      print('✅ Upload concluído!');
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('🔗 URL de download: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('❌ [StorageService] Erro no upload: $e');
      throw Exception('Erro ao fazer upload da imagem da promoção: $e');
    }
  }

  /// Upload de imagem de usuário/perfil
  /// Retorna a URL de download da imagem
  Future<String> uploadUserImage(File imageFile, String userId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('usuarios/$userId/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem do usuário: $e');
    }
  }

  /// Deletar imagem do Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Não lança exceção se a imagem não existir
      print('Aviso: Não foi possível deletar a imagem: $e');
    }
  }

  /// Upload genérico de imagem com progresso
  Future<String> uploadImageWithProgress(
    File imageFile,
    String folder,
    String subFolder, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('$folder/$subFolder/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      
      // Monitorar progresso se callback fornecido
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }
}
