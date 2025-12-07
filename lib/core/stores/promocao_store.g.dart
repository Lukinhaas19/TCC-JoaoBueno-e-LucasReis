// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promocao_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PromocaoStore on _PromocaoStore, Store {
  Computed<List<Promocao>>? _$filteredPromocoesComputed;

  @override
  List<Promocao> get filteredPromocoes =>
      (_$filteredPromocoesComputed ??= Computed<List<Promocao>>(
        () => super.filteredPromocoes,
        name: '_PromocaoStore.filteredPromocoes',
      )).value;
  Computed<List<Promocao>>? _$promocoesAtivasComputed;

  @override
  List<Promocao> get promocoesAtivas =>
      (_$promocoesAtivasComputed ??= Computed<List<Promocao>>(
        () => super.promocoesAtivas,
        name: '_PromocaoStore.promocoesAtivas',
      )).value;
  Computed<List<Promocao>>? _$promocoesExpiradasComputed;

  @override
  List<Promocao> get promocoesExpiradas =>
      (_$promocoesExpiradasComputed ??= Computed<List<Promocao>>(
        () => super.promocoesExpiradas,
        name: '_PromocaoStore.promocoesExpiradas',
      )).value;
  Computed<List<Promocao>>? _$promocoesRelampagoComputed;

  @override
  List<Promocao> get promocoesRelampago =>
      (_$promocoesRelampagoComputed ??= Computed<List<Promocao>>(
        () => super.promocoesRelampago,
        name: '_PromocaoStore.promocoesRelampago',
      )).value;

  late final _$promocoesAtom = Atom(
    name: '_PromocaoStore.promocoes',
    context: context,
  );

  @override
  ObservableList<Promocao> get promocoes {
    _$promocoesAtom.reportRead();
    return super.promocoes;
  }

  @override
  set promocoes(ObservableList<Promocao> value) {
    _$promocoesAtom.reportWrite(value, super.promocoes, () {
      super.promocoes = value;
    });
  }

  late final _$selectedPromocaoAtom = Atom(
    name: '_PromocaoStore.selectedPromocao',
    context: context,
  );

  @override
  Promocao? get selectedPromocao {
    _$selectedPromocaoAtom.reportRead();
    return super.selectedPromocao;
  }

  @override
  set selectedPromocao(Promocao? value) {
    _$selectedPromocaoAtom.reportWrite(value, super.selectedPromocao, () {
      super.selectedPromocao = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_PromocaoStore.isLoading',
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
    name: '_PromocaoStore.errorMessage',
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

  late final _$loadPromocoesAsyncAction = AsyncAction(
    '_PromocaoStore.loadPromocoes',
    context: context,
  );

  @override
  Future<void> loadPromocoes() {
    return _$loadPromocoesAsyncAction.run(() => super.loadPromocoes());
  }

  late final _$loadPromocoesByMercadoAsyncAction = AsyncAction(
    '_PromocaoStore.loadPromocoesByMercado',
    context: context,
  );

  @override
  Future<void> loadPromocoesByMercado(String mercadoId) {
    return _$loadPromocoesByMercadoAsyncAction.run(
      () => super.loadPromocoesByMercado(mercadoId),
    );
  }

  late final _$searchPromocoesAsyncAction = AsyncAction(
    '_PromocaoStore.searchPromocoes',
    context: context,
  );

  @override
  Future<void> searchPromocoes(String query) {
    return _$searchPromocoesAsyncAction.run(() => super.searchPromocoes(query));
  }

  late final _$loadPromocoesRelampagoAsyncAction = AsyncAction(
    '_PromocaoStore.loadPromocoesRelampago',
    context: context,
  );

  @override
  Future<void> loadPromocoesRelampago() {
    return _$loadPromocoesRelampagoAsyncAction.run(
      () => super.loadPromocoesRelampago(),
    );
  }

  late final _$createPromocaoAsyncAction = AsyncAction(
    '_PromocaoStore.createPromocao',
    context: context,
  );

  @override
  Future<bool> createPromocao(Promocao promocao) {
    return _$createPromocaoAsyncAction.run(
      () => super.createPromocao(promocao),
    );
  }

  late final _$createPromocaoWithImageAsyncAction = AsyncAction(
    '_PromocaoStore.createPromocaoWithImage',
    context: context,
  );

  @override
  Future<bool> createPromocaoWithImage(Promocao promocao, File? imagemFile) {
    return _$createPromocaoWithImageAsyncAction.run(
      () => super.createPromocaoWithImage(promocao, imagemFile),
    );
  }

  late final _$updatePromocaoAsyncAction = AsyncAction(
    '_PromocaoStore.updatePromocao',
    context: context,
  );

  @override
  Future<bool> updatePromocao(Promocao promocao) {
    return _$updatePromocaoAsyncAction.run(
      () => super.updatePromocao(promocao),
    );
  }

  late final _$updatePromocaoWithImageAsyncAction = AsyncAction(
    '_PromocaoStore.updatePromocaoWithImage',
    context: context,
  );

  @override
  Future<bool> updatePromocaoWithImage(
    Promocao promocao,
    File? novaImagemFile,
  ) {
    return _$updatePromocaoWithImageAsyncAction.run(
      () => super.updatePromocaoWithImage(promocao, novaImagemFile),
    );
  }

  late final _$deletePromocaoAsyncAction = AsyncAction(
    '_PromocaoStore.deletePromocao',
    context: context,
  );

  @override
  Future<bool> deletePromocao(String id) {
    return _$deletePromocaoAsyncAction.run(() => super.deletePromocao(id));
  }

  late final _$loadPromocoesByMercadoWithFallbackAsyncAction = AsyncAction(
    '_PromocaoStore.loadPromocoesByMercadoWithFallback',
    context: context,
  );

  @override
  Future<void> loadPromocoesByMercadoWithFallback(String mercadoId) {
    return _$loadPromocoesByMercadoWithFallbackAsyncAction.run(
      () => super.loadPromocoesByMercadoWithFallback(mercadoId),
    );
  }

  late final _$_PromocaoStoreActionController = ActionController(
    name: '_PromocaoStore',
    context: context,
  );

  @override
  void selectPromocao(Promocao? promocao) {
    final _$actionInfo = _$_PromocaoStoreActionController.startAction(
      name: '_PromocaoStore.selectPromocao',
    );
    try {
      return super.selectPromocao(promocao);
    } finally {
      _$_PromocaoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_PromocaoStoreActionController.startAction(
      name: '_PromocaoStore.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_PromocaoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPromocoes() {
    final _$actionInfo = _$_PromocaoStoreActionController.startAction(
      name: '_PromocaoStore.clearPromocoes',
    );
    try {
      return super.clearPromocoes();
    } finally {
      _$_PromocaoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
promocoes: ${promocoes},
selectedPromocao: ${selectedPromocao},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
filteredPromocoes: ${filteredPromocoes},
promocoesAtivas: ${promocoesAtivas},
promocoesExpiradas: ${promocoesExpiradas},
promocoesRelampago: ${promocoesRelampago}
    ''';
  }
}
