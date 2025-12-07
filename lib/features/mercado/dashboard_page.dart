import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/stores/auth_store.dart';
import '../../core/stores/promocao_store.dart';
import '../../core/models/mercado.dart';
import '../admin/widgets/admin_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final AuthStore authStore = Modular.get<AuthStore>();
  final PromocaoStore promocaoStore = Modular.get<PromocaoStore>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    
    // Listener para mudanças de autenticação
    _setupAuthListener();
  }
  
  void _setupAuthListener() {
    // Recarregar dados quando o usuário mudar
    reaction(
      (_) => authStore.currentUser?.id,
      (String? userId) {
        if (userId != null) {
          print('🔄 [Dashboard] Usuário mudou, recarregando dados...');
          _loadUserData();
        }
      },
    );
  }

  Future<void> _refreshData() async {
    print('🔄 [Dashboard] Refresh manual solicitado');
    await _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    print('🔄 [Dashboard] Iniciando carregamento de dados...');
    
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      // Verificar se o usuário está logado
      if (authStore.currentUser == null) {
        print('👤 [Dashboard] Usuário não encontrado, verificando autenticação...');
        await authStore.checkCurrentUser();
      }

      if (authStore.currentUser == null) {
        print('❌ [Dashboard] Nenhum usuário autenticado');
        return;
      }

      print('👤 [Dashboard] Usuário encontrado: ${authStore.currentUser!.nome}');
      print('🏪 [Dashboard] Tipo: ${authStore.currentUser!.tipo}');
      print('🆔 [Dashboard] MercadoId: ${authStore.currentUser!.mercadoId ?? 'Não definido'}');

      if (authStore.currentUser!.mercadoId != null) {
        // Carregar dados do mercado se ainda não foram carregados
        if (authStore.currentMercado == null) {
          print('🏪 [Dashboard] Carregando dados do mercado...');
          await authStore.loadCurrentMercado();
        }

        // Limpar promoções antigas antes de carregar novas
        promocaoStore.clearPromocoes();
        
        print('🛒 [Dashboard] Carregando promoções do mercado...');
        print('🔑 [Dashboard] ID do usuário: ${authStore.currentUser!.id}');
        print('🏪 [Dashboard] ID do mercado: ${authStore.currentUser!.mercadoId}');
        await promocaoStore.loadPromocoesByMercado(
          authStore.currentUser!.mercadoId!,
        );
        
        print('✅ [Dashboard] Dados carregados com sucesso');
      } else {
        print('⚠️ [Dashboard] Usuário sem mercadoId associado');
        print('   Dados do usuário: ${authStore.currentUser.toString()}');
      }
    } catch (e) {
      print('❌ [Dashboard] Erro ao carregar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Observer(
          builder: (_) {
            if (authStore.currentUser == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando dados do usuário...'),
                  ],
                ),
              );
            }

            if (!authStore.isMercado) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Acesso negado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Apenas supermercados podem acessar esta área.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.navigate('/mercado/home');
                      },
                      child: const Text('Voltar à Home'),
                    ),
                  ],
                ),
              );
            }

            if (promocaoStore.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando promoções...'),
                  ],
                ),
              );
            }

            // Verificar se o supermercado está pendente de aprovação
            if (authStore.currentMercado?.status == StatusMercado.pendente) {
              return _buildPendingApprovalScreen();
            }

            // Verificar se o supermercado foi reprovado
            if (authStore.currentMercado?.status == StatusMercado.reprovado) {
              return _buildRejectedScreen();
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        child: authStore.currentMercado?.imagem != null &&
                                authStore.currentMercado!.imagem!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: authStore.currentMercado!.imagem!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.store,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.store,
                                size: 80,
                                color: Colors.grey,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Olá',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Observer(
                              builder: (_) => Text(
                                authStore.currentMercado?.nome ?? authStore.currentUser?.nome ?? 'Super Mercado',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () {
                          _showLogoutBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Seção de promoções com abas
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Promoções',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          dividerHeight: 0,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF4CAF50),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          tabs: [
                            Tab(
                              text:
                                  'Ativas (${promocaoStore.promocoesAtivas.length})',
                            ),
                            Tab(
                              text:
                                  'Expiradas (${promocaoStore.promocoesExpiradas.length})',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de promoções com TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Aba Ativas
                      RefreshIndicator(
                        onRefresh: _refreshData,
                        child: _buildPromocoesList(promocaoStore.promocoesAtivas, true),
                      ),
                      // Aba Expiradas
                      RefreshIndicator(
                        onRefresh: _refreshData,
                        child: _buildPromocoesList(
                          promocaoStore.promocoesExpiradas,
                          false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: authStore.currentMercado?.status == StatusMercado.aprovado
          ? Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Modular.to.pushNamed('/promocao/create');
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: Color(0xFF4CAF50), size: 28),
              ),
            )
          : null,
    );
  }

  Widget _buildPromocoesList(List<dynamic> promocoes, bool isAtiva) {
    if (promocoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAtiva ? Icons.local_offer_outlined : Icons.schedule,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isAtiva ? 'Nenhuma promoção ativa' : 'Nenhuma promoção expirada',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (isAtiva && authStore.currentMercado?.status == StatusMercado.aprovado) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Modular.to.pushNamed('/promocao/create');
                },
                icon: const Icon(Icons.add),
                label: const Text('Criar Primeira Promoção'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: promocoes.length,
      itemBuilder: (context, index) {
        final promocao = promocoes[index];
        final isExpired =
            promocao.validade != null &&
            promocao.validade!.isBefore(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: promocao.relampago 
                  ? const Color(0xFFFF6F00).withOpacity(0.5) 
                  : const Color(0xFF4CAF50).withOpacity(0.3),
              width: promocao.relampago ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Badge de promoção relâmpago (se aplicável)
              if (promocao.relampago)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6F00),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'PROMOÇÃO RELÂMPAGO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Conteúdo principal do card
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                // Imagem do produto
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: promocao.imagem != null && promocao.imagem!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: promocao.imagem!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(
                              Icons.shopping_cart,
                              color: Color(0xFF4CAF50),
                              size: 32,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.shopping_cart,
                              color: Color(0xFF4CAF50),
                              size: 32,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.shopping_cart,
                          color: Color(0xFF4CAF50),
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                // Informações do produto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promocao.nome ?? 'Sem nome',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promocao.unidade ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${promocao.preco.toStringAsFixed(2)}/${promocao.unidade ?? 'kg'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (promocao.validade != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          isExpired
                              ? 'Expirou ${_formatDaysAgo(promocao.validade!)}'
                              : 'Expira em ${_formatDaysRemaining(promocao.validade!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isExpired
                                ? Colors.red
                                : const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Ações (só mostra se o mercado estiver aprovado)
                if (authStore.currentMercado?.status == StatusMercado.aprovado) 
                  Column(
                    children: [
                      if (!isExpired) ...[
                        IconButton(
                          onPressed: () {
                            Modular.to.pushNamed('/promocao/edit/${promocao.id}');
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF2196F3).withOpacity(0.3),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xFF2196F3),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                      IconButton(
                        onPressed: () {
                          _showDeleteDialog(promocao.id!);
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.red.withOpacity(0.3),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDaysRemaining(DateTime validade) {
    final now = DateTime.now();
    final difference = validade.difference(now).inDays;

    if (difference <= 0) {
      return '1 dia';
    } else if (difference == 1) {
      return '1 dia';
    } else {
      return '$difference dias';
    }
  }

  String _formatDaysAgo(DateTime validade) {
    final now = DateTime.now();
    final difference = now.difference(validade).inDays;

    if (difference <= 0) {
      return 'hoje';
    } else if (difference == 1) {
      return 'há 1 dia';
    } else {
      return 'há $difference dias';
    }
  }

  void _showDeleteDialog(String promocaoId) async {
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
      await promocaoStore.deletePromocao(promocaoId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Promoção excluída com sucesso'),
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual do modal
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Ícone de logout
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              
              // Título
              const Text(
                'Fazer logout?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              
              // Descrição
              const Text(
                'Você será desconectado da sua conta e precisará fazer login novamente.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Botões
              Row(
                children: [
                  // Botão Cancelar
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Botão Confirmar
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sair',
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
              
              // Espaço extra para dispositivos com notch
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingApprovalScreen() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de aguardando
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time,
                size: 60,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            
            // Título
            const Text(
              'Aguardando Aprovação',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pending,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'STATUS: PENDENTE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Descrição
            const Text(
              'Seu supermercado está passando por análise de nossos administradores.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Durante este período, não é possível criar ou gerenciar promoções.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar Status'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showLogoutBottomSheet(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedScreen() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de reprovado
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            
            // Título
            const Text(
              'Cadastro Reprovado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel,
                    size: 16,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'STATUS: REPROVADO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Descrição
            const Text(
              'Infelizmente seu cadastro não foi aprovado pelos nossos administradores.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Entre em contato conosco para mais informações ou realize um novo cadastro.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Botões de ação
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Implementar contato ou suporte
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Em breve: funcionalidade de contato'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Entrar em Contato'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutBottomSheet(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await authStore.signOut();
      if (mounted) {
        Modular.to.navigate('./home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair: $e'),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
