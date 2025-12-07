import 'package:flutter_modular/flutter_modular.dart';
import 'home_page.dart';
import 'dashboard_page.dart';
import 'mercado_detail_page.dart';

class MercadoModule extends Module {
  @override
  void routes(r) {
    r.child('/home', child: (context) => const HomePage());
    r.child('/dashboard', child: (context) => const DashboardPage());
    r.child('/detail/:id', child: (context) => MercadoDetailPage(
      mercadoId: r.args.params['id'],
    ));
  }
}
