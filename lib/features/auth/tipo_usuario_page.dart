import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TipoUsuarioPage extends StatelessWidget {
  const TipoUsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF66BB6A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo e título
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 50,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bem-vindo!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Como você gostaria de usar o app?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                
                // Botão para visitante (sem login)
                _buildUserTypeCard(
                  context,
                  icon: Icons.visibility,
                  title: 'Ver Promoções',
                  subtitle: 'Navegar e ver todas as promoções disponíveis',
                  onTap: () => Modular.to.navigate('/mercado/home'),
                ),
                
                const SizedBox(height: 16),
                
                // Botão para mercado
                _buildUserTypeCard(
                  context,
                  icon: Icons.store,
                  title: 'Login Supermercado',
                  subtitle: 'Fazer login para cadastrar e gerenciar promoções',
                  onTap: () => Modular.to.pushNamed('/auth/login?tipo=mercado'),
                ),
                
                const Spacer(),
                
                // Botão Debug (apenas em desenvolvimento)
                // Container(
                //   width: double.infinity,
                //   margin: const EdgeInsets.only(bottom: 16),
                //   child: OutlinedButton.icon(
                //     onPressed: () {
                //       Modular.to.pushNamed('/debug');
                //     },
                //     icon: const Icon(Icons.bug_report, color: Colors.orange),
                //     label: const Text(
                //       '🛠️ Inserir Dados de Teste',
                //       style: TextStyle(color: Colors.orange),
                //     ),
                //     style: OutlinedButton.styleFrom(
                //       side: const BorderSide(color: Colors.orange),
                //       padding: const EdgeInsets.symmetric(vertical: 12),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
