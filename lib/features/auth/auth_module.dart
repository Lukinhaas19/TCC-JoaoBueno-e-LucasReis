import 'package:flutter_modular/flutter_modular.dart';
import 'login_page.dart';
import 'cadastro_page.dart';
// import 'tipo_usuario_page.dart';

class AuthModule extends Module {
  @override
  void routes(r) {
    r.child('/login', child: (context) => const LoginPage());
    r.child('/cadastro', child: (context) => const CadastroPage());
    // r.child('/tipo-usuario', child: (context) => const TipoUsuarioPage());
  }
}
