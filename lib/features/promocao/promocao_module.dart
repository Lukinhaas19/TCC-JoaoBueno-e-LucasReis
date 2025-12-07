import 'package:flutter_modular/flutter_modular.dart';
import 'promocao_form_page.dart';
import 'promocao_detail_page.dart';
import 'promocoes_relampago_page.dart';

class PromocaoModule extends Module {
  @override
  void routes(r) {
    r.child('/create', child: (context) => const PromocaoFormPage());
    r.child('/edit/:id', child: (context) => PromocaoFormPage(
      promocaoId: r.args.params['id'],
    ));
    r.child('/detail/:id', child: (context) => PromocaoDetailPage(
      promocaoId: r.args.params['id'],
    ));
    r.child('/relampago', child: (context) => const PromocoesRelampagoPage());
  }
}
