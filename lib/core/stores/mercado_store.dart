import 'package:mobx/mobx.dart';
import '../models/mercado.dart';
import '../services/mercado_service.dart';

part 'mercado_store.g.dart';

class MercadoStore = _MercadoStore with _$MercadoStore;

abstract class _MercadoStore with Store {
  final MercadoService _mercadoService = MercadoService();

  @observable
  ObservableList<Mercado> mercados = ObservableList<Mercado>();

  @observable
  Mercado? selectedMercado;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String _searchQuery = '';

  @observable
  String _selectedCity = 'São Paulo, SP';

  @computed
  List<Mercado> get filteredMercados {
    var filtered = mercados.where((mercado) => mercado.status == StatusMercado.aprovado).toList();
    
    // Filtrar por cidade
    if (_selectedCity.isNotEmpty) {
      final cityName = _selectedCity.split(',')[0].trim().toLowerCase();
      filtered = filtered.where((mercado) =>
        mercado.cidade.toLowerCase().contains(cityName) ||
        mercado.cidade.toLowerCase().contains(_selectedCity.toLowerCase()) ||
        (mercado.endereco?.toLowerCase().contains(cityName) ?? false) ||
        (mercado.endereco?.toLowerCase().contains(_selectedCity.toLowerCase()) ?? false)
      ).toList();
    }
    
    // Filtrar por busca
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((mercado) =>
        mercado.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        mercado.cidade.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (mercado.endereco?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    
    return filtered;
  }

  String get selectedCity => _selectedCity;

  @action
  Future<void> loadMercados() async {
    if (isLoading) return; // Evita chamadas múltiplas
    
    try {
      isLoading = true;
      errorMessage = null;
      
      // Para carregamento inicial, vamos usar um get() em vez de stream
      final snapshot = await _mercadoService.getMercadosOnce();
      mercados.clear();
      mercados.addAll(snapshot);
      
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> searchMercados(String query) async {
    _searchQuery = query;
    // Não precisa carregar novamente, o computed já vai filtrar
  }

  @action
  void filterByCity(String city) {
    _selectedCity = city;
  }

  @action
  Future<void> searchMercadosFromService(String query) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      if (query.isEmpty) {
        await loadMercados();
      } else {
        await _mercadoService.searchMercados(query).listen((mercadosList) {
          mercados.clear();
          mercados.addAll(mercadosList);
        }).asFuture();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> createMercado(Mercado mercado) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      final id = await _mercadoService.createMercado(mercado);
      final newMercado = mercado.copyWith(id: id);
      mercados.add(newMercado);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> updateMercado(Mercado mercado) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      await _mercadoService.updateMercado(mercado);
      
      final index = mercados.indexWhere((m) => m.id == mercado.id);
      if (index != -1) {
        mercados[index] = mercado;
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
  Future<bool> deleteMercado(String id) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      await _mercadoService.deleteMercado(id);
      mercados.removeWhere((m) => m.id == id);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<Mercado?> getMercadoById(String id) async {
    try {
      isLoading = true;
      errorMessage = null;
      
      final mercado = await _mercadoService.getMercadoById(id);
      return mercado;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
    }
  }

  @action
  void selectMercado(Mercado? mercado) {
    selectedMercado = mercado;
  }

  @action
  void clearError() {
    errorMessage = null;
  }
}
