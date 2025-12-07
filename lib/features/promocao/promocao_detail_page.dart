import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/stores/promocao_store.dart';
import '../../core/stores/auth_store.dart';
import '../../core/models/promocao.dart';
import '../../core/services/promocao_service.dart';
import '../admin/widgets/admin_widgets.dart';

class PromocaoDetailPage extends StatefulWidget {
  final String promocaoId;

  const PromocaoDetailPage({super.key, required this.promocaoId});

  @override
  State<PromocaoDetailPage> createState() => _PromocaoDetailPageState();
}

class _PromocaoDetailPageState extends State<PromocaoDetailPage> {
  final PromocaoStore promocaoStore = Modular.get<PromocaoStore>();
  final AuthStore authStore = Modular.get<AuthStore>();
  
  Promocao? promocao;

  @override
  void initState() {
    super.initState();
    _loadPromocao();
  }

  void _loadPromocao() {
    try {
      final matches = promocaoStore.promocoes.where((p) => p.id == widget.promocaoId).toList();
      if (matches.isNotEmpty) {
        promocao = matches.first;
        if (mounted) setState(() {});
        return;
      }

      // Fallback: buscar via service (Firestore) caso não esteja no store
      final service = PromocaoService();
      service.getPromocaoById(widget.promocaoId).then((p) {
        promocao = p;
        if (mounted) setState(() {});
      }).catchError((e, st) {
        print('❌ [PromocaoDetail] Error fetching promocao by id: $e');
        print(st);
      });
    } catch (e, st) {
      print('❌ [PromocaoDetail] Unexpected error while loading promocao: $e');
      print(st);
      if (mounted) setState(() {});
    }
  }

  bool get canEdit => authStore.isMercado && 
      authStore.currentUser?.mercadoId == promocao?.customerId;

  @override
  Widget build(BuildContext context) {
    if (promocao == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar com imagem
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: canEdit ? [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Modular.to.pushNamed('/promocao/edit/${promocao!.id}');
                },
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Excluir', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog();
                  }
                },
              ),
            ] : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  promocao!.imagem != null && promocao!.imagem!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: promocao!.imagem!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF4CAF50),
                            child: const Icon(
                              Icons.local_offer,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF4CAF50),
                          child: const Icon(
                            Icons.local_offer,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                  // Gradiente sobreposto
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e preço
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          promocao!.nome ?? 'Produto sem nome',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${promocao!.preco.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'por ${promocao!.unidade}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tags e badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (promocao!.relampago)
                        Chip(
                          label: const Text('Promoção Relâmpago'),
                          backgroundColor: const Color(0xFFFF6F00).withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: Color(0xFFFF6F00),
                            fontWeight: FontWeight.bold,
                          ),
                          avatar: const Icon(
                            Icons.flash_on,
                            color: Color(0xFFFF6F00),
                            size: 18,
                          ),
                        ),
                      
                      if (promocao!.promocao)
                        Chip(
                          label: const Text('Em Promoção'),
                          backgroundColor: Colors.orange[100],
                          labelStyle: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                          avatar: Icon(
                            Icons.local_offer,
                            color: Colors.orange[800],
                            size: 18,
                          ),
                        ),
                      
                      if (promocao!.limite)
                        Chip(
                          label: const Text('Estoque Limitado'),
                          backgroundColor: Colors.red[100],
                          labelStyle: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                          avatar: Icon(
                            Icons.warning,
                            color: Colors.red[800],
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informações de validade
                  if (promocao!.validade != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: promocao!.validade!.isBefore(DateTime.now())
                                  ? Colors.red
                                  : const Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    promocao!.validade!.isBefore(DateTime.now())
                                        ? 'Promoção Expirada'
                                        : 'Válido até',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: promocao!.validade!.isBefore(DateTime.now())
                                          ? Colors.red
                                          : Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(promocao!.validade!),
                                    style: TextStyle(
                                      color: promocao!.validade!.isBefore(DateTime.now())
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Informações adicionais
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações do Produto',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInfoRow(
                            icon: Icons.attach_money,
                            label: 'Preço por unidade',
                            value: 'R\$ ${promocao!.preco.toStringAsFixed(2)} / ${promocao!.unidade}',
                          ),
                          
                          const SizedBox(height: 12),
                          
                          _buildInfoRow(
                            icon: Icons.category,
                            label: 'Tipo',
                            value: promocao!.promocao ? 'Promoção' : 'Produto Regular',
                          ),
                          
                          if (promocao!.limite) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.inventory,
                              label: 'Disponibilidade',
                              value: 'Estoque Limitado',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog() async {
    final confirmed = await AdminWidgets.showConfirmationDialog(
      context: context,
      title: 'Excluir Promoção',
      message: 'Tem certeza que deseja excluir esta promoção?\n\nEsta ação não pode ser desfeita.',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      confirmColor: Colors.red,
      icon: Icons.delete_outline,
    );

    if (confirmed == true) {
      await promocaoStore.deletePromocao(promocao!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promoção excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        Modular.to.pop();
      }
    }
  }
}
