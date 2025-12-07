import 'package:flutter_modular/flutter_modular.dart';
import 'core/stores/auth_store.dart';
import 'core/stores/mercado_store.dart';
import 'core/stores/promocao_store.dart';
import 'core/stores/admin_store.dart';
import 'features/auth/auth_module.dart';
import 'features/mercado/mercado_module.dart';
import 'features/promocao/promocao_module.dart';
import 'features/admin/admin_module.dart';
import 'features/splash/splash_page.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    // Stores globais
    i.addSingleton(AuthStore.new);
    i.addSingleton(MercadoStore.new);
    i.addSingleton(PromocaoStore.new);
    i.addSingleton(AdminStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const SplashPage());
    r.module('/auth', module: AuthModule());
    r.module('/mercado', module: MercadoModule());
    r.module('/promocao', module: PromocaoModule());
    r.module('/admin', module: AdminModule());
  }
}
