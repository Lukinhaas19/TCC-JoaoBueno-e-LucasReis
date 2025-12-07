// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mercado_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MercadoStore on _MercadoStore, Store {
  Computed<List<Mercado>>? _$filteredMercadosComputed;

  @override
  List<Mercado> get filteredMercados =>
      (_$filteredMercadosComputed ??= Computed<List<Mercado>>(
        () => super.filteredMercados,
        name: '_MercadoStore.filteredMercados',
      )).value;

  late final _$mercadosAtom = Atom(
    name: '_MercadoStore.mercados',
    context: context,
  );

  @override
  ObservableList<Mercado> get mercados {
    _$mercadosAtom.reportRead();
    return super.mercados;
  }

  @override
  set mercados(ObservableList<Mercado> value) {
    _$mercadosAtom.reportWrite(value, super.mercados, () {
      super.mercados = value;
    });
  }

  late final _$selectedMercadoAtom = Atom(
    name: '_MercadoStore.selectedMercado',
    context: context,
  );

  @override
  Mercado? get selectedMercado {
    _$selectedMercadoAtom.reportRead();
    return super.selectedMercado;
  }

  @override
  set selectedMercado(Mercado? value) {
    _$selectedMercadoAtom.reportWrite(value, super.selectedMercado, () {
      super.selectedMercado = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_MercadoStore.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_MercadoStore.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$_searchQueryAtom = Atom(
    name: '_MercadoStore._searchQuery',
    context: context,
  );

  @override
  String get _searchQuery {
    _$_searchQueryAtom.reportRead();
    return super._searchQuery;
  }

  @override
  set _searchQuery(String value) {
    _$_searchQueryAtom.reportWrite(value, super._searchQuery, () {
      super._searchQuery = value;
    });
  }

  late final _$_selectedCityAtom = Atom(
    name: '_MercadoStore._selectedCity',
    context: context,
  );

  @override
  String get _selectedCity {
    _$_selectedCityAtom.reportRead();
    return super._selectedCity;
  }

  @override
  set _selectedCity(String value) {
    _$_selectedCityAtom.reportWrite(value, super._selectedCity, () {
      super._selectedCity = value;
    });
  }

  late final _$loadMercadosAsyncAction = AsyncAction(
    '_MercadoStore.loadMercados',
    context: context,
  );

  @override
  Future<void> loadMercados() {
    return _$loadMercadosAsyncAction.run(() => super.loadMercados());
  }

  late final _$searchMercadosAsyncAction = AsyncAction(
    '_MercadoStore.searchMercados',
    context: context,
  );

  @override
  Future<void> searchMercados(String query) {
    return _$searchMercadosAsyncAction.run(() => super.searchMercados(query));
  }

  late final _$searchMercadosFromServiceAsyncAction = AsyncAction(
    '_MercadoStore.searchMercadosFromService',
    context: context,
  );

  @override
  Future<void> searchMercadosFromService(String query) {
    return _$searchMercadosFromServiceAsyncAction.run(
      () => super.searchMercadosFromService(query),
    );
  }

  late final _$createMercadoAsyncAction = AsyncAction(
    '_MercadoStore.createMercado',
    context: context,
  );

  @override
  Future<bool> createMercado(Mercado mercado) {
    return _$createMercadoAsyncAction.run(() => super.createMercado(mercado));
  }

  late final _$updateMercadoAsyncAction = AsyncAction(
    '_MercadoStore.updateMercado',
    context: context,
  );

  @override
  Future<bool> updateMercado(Mercado mercado) {
    return _$updateMercadoAsyncAction.run(() => super.updateMercado(mercado));
  }

  late final _$deleteMercadoAsyncAction = AsyncAction(
    '_MercadoStore.deleteMercado',
    context: context,
  );

  @override
  Future<bool> deleteMercado(String id) {
    return _$deleteMercadoAsyncAction.run(() => super.deleteMercado(id));
  }

  late final _$getMercadoByIdAsyncAction = AsyncAction(
    '_MercadoStore.getMercadoById',
    context: context,
  );

  @override
  Future<Mercado?> getMercadoById(String id) {
    return _$getMercadoByIdAsyncAction.run(() => super.getMercadoById(id));
  }

  late final _$_MercadoStoreActionController = ActionController(
    name: '_MercadoStore',
    context: context,
  );

  @override
  void filterByCity(String city) {
    final _$actionInfo = _$_MercadoStoreActionController.startAction(
      name: '_MercadoStore.filterByCity',
    );
    try {
      return super.filterByCity(city);
    } finally {
      _$_MercadoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectMercado(Mercado? mercado) {
    final _$actionInfo = _$_MercadoStoreActionController.startAction(
      name: '_MercadoStore.selectMercado',
    );
    try {
      return super.selectMercado(mercado);
    } finally {
      _$_MercadoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_MercadoStoreActionController.startAction(
      name: '_MercadoStore.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_MercadoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
mercados: ${mercados},
selectedMercado: ${selectedMercado},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
filteredMercados: ${filteredMercados}
    ''';
  }
}
