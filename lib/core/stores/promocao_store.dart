import 'dart:io';
import 'package:mobx/mobx.dart';
import '../models/promocao.dart';
import '../services/promocao_service.dart';

part 'promocao_store.g.dart';

class PromocaoStore = _PromocaoStore with _$PromocaoStore;

abstract class _PromocaoStore with Store {
  final PromocaoService _promocaoService = PromocaoService();

  @observable
  ObservableList<Promocao> promocoes = ObservableList<Promocao>();

  @observable
  Promocao? selectedPromocao;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  List<Promocao> get filteredPromocoes => promocoes.toList();

  @computed
  List<Promocao> get promocoesAtivas => promocoes
      .where((p) => p.validade == null || p.validade!.isAfter(DateTime.now()))
      .toList();

  @computed
  List<Promocao> get promocoesExpiradas => promocoes
      .where((p) => p.validade != null && p.validade!.isBefore(DateTime.now()))
      .toList();

  @computed
  List<Promocao> get promocoesRelampago => promocoes
      .where((p) => p.relampago && (p.validade == null || p.validade!.isAfter(DateTime.now())))
      .toList();

  @action
  Future<void> loadPromocoes() async {
    try {
      isLoading = true;
      errorMessage = null;
      
      final stream = _promocaoService.getPromocoes();
      await for (final promocoesList in stream) {
        promocoes.clear();
        promocoes.addAll(promocoesList);
        break; // Sair após a primeira emissão para evitar loop infinito
      }
      
      isLoading = false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
    }
  }

  @action
  Future<void> loadPromocoesByMercado(String mercadoId) async {
    print('🛒 [PromocaoStore] Carregando promoções para mercado: $mercadoId');
    
    try {
      isLoading = true;
      errorMessage = null;
      
      if (mercadoId.isEmpty) {
        throw Exception('ID do mercado está vazio');
      }
      
      print('🔄 [PromocaoStore] Buscando stream de promoções...');
      final stream = _promocaoService.getPromocoesByMercado(mercadoId);
      
      await for (final promocoesList in stream) {
        print('📦 [PromocaoStore] Recebidas ${promocoesList.length} promoções');
        promocoes.clear();
        promocoes.addAll(promocoesList);
        
        for (final promocao in promocoesList) {
          print('   - ${promocao.nome}: R\$ ${promocao.preco}');
        }
        
        break; // Sair após a primeira emissão para evitar loop infinito
      }
      
      print('✅ [PromocaoStore] Carregamento concluído com sucesso');
      isLoading = false;
    } catch (e) {
      print('❌ [PromocaoStore] Erro ao carregar promoções: $e');
      errorMessage = e.toString();
      isLoading = false;
    }
  }

  @action
  Future<void> searchPromocoes(String query) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      if (query.isEmpty) {
        await loadPromocoes();
      } else {
        final stream = _promocaoService.searchPromocoes(query);
        await for (final promocoesList in stream) {
          promocoes.clear();
          promocoes.addAll(promocoesList);
          break; // Sair após a primeira emissão para evitar loop infinito
        }
        isLoading = false;
      }
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
    }
  }

  @action
  Future<void> loadPromocoesRelampago() async {
    print('⚡ [PromocaoStore] Carregando promoções relâmpago...');
    
    try {
      isLoading = true;
      errorMessage = null;
      
      final stream = _promocaoService.getPromocoesRelampago();
      await for (final promocoesList in stream) {
        print('⚡ [PromocaoStore] Recebidas ${promocoesList.length} promoções relâmpago');
        promocoes.clear();
        promocoes.addAll(promocoesList);
        
        for (final promocao in promocoesList) {
          print('   - ⚡ ${promocao.nome}: R\$ ${promocao.preco}');
        }
        
        break; // Sair após a primeira emissão para evitar loop infinito
      }
      
      print('✅ [PromocaoStore] Carregamento de promoções relâmpago concluído');
      isLoading = false;
    } catch (e) {
      print('❌ [PromocaoStore] Erro ao carregar promoções relâmpago: $e');
      errorMessage = e.toString();
      isLoading = false;
    }
  }

  @action
  Future<bool> createPromocao(Promocao promocao) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      final id = await _promocaoService.createPromocao(promocao);
      final newPromocao = promocao.copyWith(id: id);
      promocoes.add(newPromocao);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> createPromocaoWithImage(Promocao promocao, File? imagemFile) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      final id = await _promocaoService.createPromocaoWithImage(promocao, imagemFile);
      final newPromocao = promocao.copyWith(id: id, imagem: null); // A imagem será atualizada pelo serviço
      promocoes.add(newPromocao);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> updatePromocao(Promocao promocao) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      await _promocaoService.updatePromocao(promocao);
      
      final index = promocoes.indexWhere((p) => p.id == promocao.id);
      if (index != -1) {
        promocoes[index] = promocao;
      }
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> updatePromocaoWithImage(Promocao promocao, File? novaImagemFile) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      await _promocaoService.updatePromocaoWithImage(promocao, novaImagemFile);
      
      final index = promocoes.indexWhere((p) => p.id == promocao.id);
      if (index != -1) {
        promocoes[index] = promocao;
      }
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> deletePromocao(String id) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      await _promocaoService.deletePromocao(id);
      promocoes.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  void selectPromocao(Promocao? promocao) {
    selectedPromocao = promocao;
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void clearPromocoes() {
    promocoes.clear();
    selectedPromocao = null;
    errorMessage = null;
    isLoading = false;
  }

  @action
  Future<void> loadPromocoesByMercadoWithFallback(String mercadoId) async {
    print('🛒 [PromocaoStore] Tentando carregar com índice primeiro...');
    
    try {
      isLoading = true;
      errorMessage = null;
      
      if (mercadoId.isEmpty) {
        throw Exception('ID do mercado está vazio');
      }
      
      // Tentar primeiro com índice
      try {
        final stream = _promocaoService.getPromocoesByMercadoWithIndex(mercadoId);
        await for (final promocoesList in stream) {
          print('📦 [PromocaoStore] Carregamento com índice bem-sucedido: ${promocoesList.length} promoções');
          promocoes.clear();
          promocoes.addAll(promocoesList);
          break;
        }
      } catch (e) {
        if (e.toString().contains('index')) {
          print('⚠️ [PromocaoStore] Índice não disponível, usando fallback...');
          // Fallback para método sem índice
          await loadPromocoesByMercado(mercadoId);
          return;
        } else {
          rethrow;
        }
      }
      
      print('✅ [PromocaoStore] Carregamento concluído com sucesso');
      isLoading = false;
    } catch (e) {
      print('❌ [PromocaoStore] Erro ao carregar promoções: $e');
      errorMessage = e.toString();
      isLoading = false;
    }
  }




}
