// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStore, Store {
  Computed<bool>? _$isLoggedInComputed;

  @override
  bool get isLoggedIn => (_$isLoggedInComputed ??= Computed<bool>(
    () => super.isLoggedIn,
    name: '_AuthStore.isLoggedIn',
  )).value;
  Computed<bool>? _$isMercadoComputed;

  @override
  bool get isMercado => (_$isMercadoComputed ??= Computed<bool>(
    () => super.isMercado,
    name: '_AuthStore.isMercado',
  )).value;

  late final _$currentUserAtom = Atom(
    name: '_AuthStore.currentUser',
    context: context,
  );

  @override
  Usuario? get currentUser {
    _$currentUserAtom.reportRead();
    return super.currentUser;
  }

  @override
  set currentUser(Usuario? value) {
    _$currentUserAtom.reportWrite(value, super.currentUser, () {
      super.currentUser = value;
    });
  }

  late final _$currentMercadoAtom = Atom(
    name: '_AuthStore.currentMercado',
    context: context,
  );

  @override
  Mercado? get currentMercado {
    _$currentMercadoAtom.reportRead();
    return super.currentMercado;
  }

  @override
  set currentMercado(Mercado? value) {
    _$currentMercadoAtom.reportWrite(value, super.currentMercado, () {
      super.currentMercado = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_AuthStore.isLoading',
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
    name: '_AuthStore.errorMessage',
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

  late final _$signInAsyncAction = AsyncAction(
    '_AuthStore.signIn',
    context: context,
  );

  @override
  Future<bool> signIn(String email, String password) {
    return _$signInAsyncAction.run(() => super.signIn(email, password));
  }

  late final _$signUpAsyncAction = AsyncAction(
    '_AuthStore.signUp',
    context: context,
  );

  @override
  Future<bool> signUp(
    String email,
    String password,
    String nome,
    TipoUsuario tipo,
    String telefone,
  ) {
    return _$signUpAsyncAction.run(
      () => super.signUp(email, password, nome, tipo, telefone),
    );
  }

  late final _$signUpMercadoWithImageAsyncAction = AsyncAction(
    '_AuthStore.signUpMercadoWithImage',
    context: context,
  );

  @override
  Future<bool> signUpMercadoWithImage({
    required String email,
    required String password,
    required String nome,
    required String cnpj,
    String? endereco,
    String? telefone,
    String? cidade,
    File? imagemFile,
  }) {
    return _$signUpMercadoWithImageAsyncAction.run(
      () => super.signUpMercadoWithImage(
        email: email,
        password: password,
        nome: nome,
        cnpj: cnpj,
        endereco: endereco,
        telefone: telefone,
        cidade: cidade,
        imagemFile: imagemFile,
      ),
    );
  }

  late final _$signOutAsyncAction = AsyncAction(
    '_AuthStore.signOut',
    context: context,
  );

  @override
  Future<void> signOut() {
    return _$signOutAsyncAction.run(() => super.signOut());
  }

  late final _$checkCurrentUserAsyncAction = AsyncAction(
    '_AuthStore.checkCurrentUser',
    context: context,
  );

  @override
  Future<void> checkCurrentUser() {
    return _$checkCurrentUserAsyncAction.run(() => super.checkCurrentUser());
  }

  late final _$loadCurrentMercadoAsyncAction = AsyncAction(
    '_AuthStore.loadCurrentMercado',
    context: context,
  );

  @override
  Future<void> loadCurrentMercado() {
    return _$loadCurrentMercadoAsyncAction.run(
      () => super.loadCurrentMercado(),
    );
  }

  late final _$forceReloadUserDataAsyncAction = AsyncAction(
    '_AuthStore.forceReloadUserData',
    context: context,
  );

  @override
  Future<void> forceReloadUserData() {
    return _$forceReloadUserDataAsyncAction.run(
      () => super.forceReloadUserData(),
    );
  }

  late final _$_AuthStoreActionController = ActionController(
    name: '_AuthStore',
    context: context,
  );

  @override
  void clearError() {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
      name: '_AuthStore.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentUser: ${currentUser},
currentMercado: ${currentMercado},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isLoggedIn: ${isLoggedIn},
isMercado: ${isMercado}
    ''';
  }
}
