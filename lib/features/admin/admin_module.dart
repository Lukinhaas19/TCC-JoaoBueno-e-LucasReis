import 'package:flutter_modular/flutter_modular.dart';
import '../../core/guards/admin_guard.dart';
import 'screens/admin_dashboard_screen.dart';

class AdminModule extends Module {
  @override
  void binds(i) {
    // AdminStore é gerenciado globalmente no AppModule
  }

  @override 
  void routes(r) {
    r.child(
      '/', 
      child: (context) => const AdminPageWrapper(
        child: AdminDashboardScreen(),
      ),
      guards: [AdminGuard()],
    );
  }
}