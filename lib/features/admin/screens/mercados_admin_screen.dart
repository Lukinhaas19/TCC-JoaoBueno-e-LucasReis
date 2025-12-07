import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/stores/admin_store.dart';
import '../../../core/models/mercado.dart';
import '../widgets/admin_widgets.dart';

class MercadosAdminScreen extends StatefulWidget {
  const MercadosAdminScreen({super.key});

  @override
  State<MercadosAdminScreen> createState() => _MercadosAdminScreenState();
}

class _MercadosAdminScreenState extends State<MercadosAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStore>().loadTodosMercados();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(
      builder: (context, adminStore, child) {
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Todos'),
                Tab(text: 'Pendentes'),
                Tab(text: 'Aprovados'),
                Tab(text: 'Reprovados'),
              ],
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMercadosList(
                    adminStore.todosMercados,
                    adminStore.isLoadingMercados,
                    adminStore,
                  ),
                  _buildMercadosList(
                    adminStore.todosMercados
                        .where((m) => m.status == StatusMercado.pendente)
                        .toList(),
                    adminStore.isLoadingMercados,
                    adminStore,
                  ),
                  _buildMercadosList(
                    adminStore.todosMercados
                        .where((m) => m.status == StatusMercado.aprovado)
                        .toList(),
                    adminStore.isLoadingMercados,
                    adminStore,
                  ),
                  _buildMercadosList(
                    adminStore.todosMercados
                        .where((m) => m.status == StatusMercado.reprovado)
                        .toList(),
                    adminStore.isLoadingMercados,
                    adminStore,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMercadosList(
    List<Mercado> mercados,
    bool isLoading,
    AdminStore adminStore,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mercados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum mercado encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => adminStore.loadTodosMercados(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mercados.length,
        itemBuilder: (context, index) {
          final mercado = mercados[index];
          return _buildMercadoCard(mercado, adminStore);
        },
      ),
    );
  }

  Widget _buildMercadoCard(Mercado mercado, AdminStore adminStore) {
    return AdminWidgets.buildCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mercado.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CNPJ: ${mercado.cnpj}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (mercado.email != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Email: ${mercado.email}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        'Cidade: ${mercado.cidade}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(mercado.status),
              ],
            ),
            const SizedBox(height: 16),
            
            // Informações de aprovação
            if (mercado.dataAprovacao != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${mercado.status == StatusMercado.aprovado ? 'Aprovado' : 'Reprovado'} em ${_formatDate(mercado.dataAprovacao!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Ações
            if (mercado.status == StatusMercado.pendente) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _aprovarMercado(mercado, adminStore),
                      icon: const Icon(Icons.check),
                      label: const Text('Aprovar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _reprovarMercado(mercado, adminStore),
                      icon: const Icon(Icons.close),
                      label: const Text('Reprovar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showMercadoDetails(mercado),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver Detalhes'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
  }

  Widget _buildStatusChip(StatusMercado status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case StatusMercado.pendente:
        color = Colors.orange;
        label = 'Pendente';
        icon = Icons.schedule;
        break;
      case StatusMercado.aprovado:
        color = Colors.green;
        label = 'Aprovado';
        icon = Icons.check_circle;
        break;
      case StatusMercado.reprovado:
        color = Colors.red;
        label = 'Reprovado';
        icon = Icons.cancel;
        break;
    }

    return AdminWidgets.buildStatusChip(
      label: label,
      color: color,
      icon: icon,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _aprovarMercado(Mercado mercado, AdminStore adminStore) async {
    final confirmed = await AdminWidgets.showConfirmationDialog(
      context: context,
      title: 'Aprovar Mercado',
      message: 'Deseja aprovar o mercado "${mercado.nome}"?',
      confirmText: 'Aprovar',
      confirmColor: Colors.green,
      icon: Icons.check_circle,
    );

    if (confirmed == true) {
      try {
        await adminStore.aprovarMercado(mercado.id!);
        if (mounted) {
          AdminWidgets.showSnackBar(
            context: context,
            message: 'Mercado aprovado com sucesso!',
            backgroundColor: Colors.green,
            icon: Icons.check_circle,
          );
        }
      } catch (e) {
        if (mounted) {
          AdminWidgets.showSnackBar(
            context: context,
            message: 'Erro ao aprovar mercado: $e',
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      }
    }
  }

  Future<void> _reprovarMercado(Mercado mercado, AdminStore adminStore) async {
    final confirmed = await AdminWidgets.showConfirmationDialog(
      context: context,
      title: 'Reprovar Mercado',
      message: 'Deseja reprovar o mercado "${mercado.nome}"?',
      confirmText: 'Reprovar',
      confirmColor: Colors.red,
      icon: Icons.cancel,
    );

    if (confirmed == true) {
      try {
        await adminStore.reprovarMercado(mercado.id!);
        if (mounted) {
          AdminWidgets.showSnackBar(
            context: context,
            message: 'Mercado reprovado!',
            backgroundColor: Colors.orange,
            icon: Icons.cancel,
          );
        }
      } catch (e) {
        if (mounted) {
          AdminWidgets.showSnackBar(
            context: context,
            message: 'Erro ao reprovar mercado: $e',
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      }
    }
  }

  void _showMercadoDetails(Mercado mercado) {
    AdminWidgets.showBottomSheetModal(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone e título
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 25,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    mercado.nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Detalhes do mercado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRow('CNPJ', mercado.cnpj),
                  if (mercado.email != null)
                    _buildDetailRow('Email', mercado.email!),
                  _buildDetailRow('Cidade', mercado.cidade),
                  if(mercado.telefone != null)
                    _buildDetailRow('Telefone', mercado.telefone!),
                  if (mercado.endereco != null)
                    _buildDetailRow('Endereço', mercado.endereco!),
                  _buildDetailRow('Status', mercado.status.toString().split('.').last),
                  if (mercado.dataAprovacao != null)
                    _buildDetailRow(
                      'Data de ${mercado.status == StatusMercado.aprovado ? 'Aprovação' : 'Reprovação'}',
                      _formatDate(mercado.dataAprovacao!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botão fechar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}