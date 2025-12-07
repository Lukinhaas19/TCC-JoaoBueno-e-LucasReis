import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mercado_promocoes_app/core/models/mercado.dart';
import '../../core/models/promocao.dart';
import '../../core/stores/auth_store.dart';
import '../../core/stores/mercado_store.dart';
import '../../core/services/promocao_service.dart';
import '../../core/services/mercado_service.dart';

class _SearchResult {
  final String type; // 'mercado' or 'promocao'
  final Mercado? mercado;
  final Promocao? promocao;

  _SearchResult.mercado(this.mercado)
      : type = 'mercado',
        promocao = null;

  _SearchResult.promocao(this.promocao, {this.mercado}) : type = 'promocao';
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AuthStore authStore = Modular.get<AuthStore>();
  final MercadoStore mercadoStore = Modular.get<MercadoStore>();
  final PromocaoService _promocaoService = PromocaoService();
  final MercadoService _mercadoService = MercadoService();

  bool _isSearching = false;
  List<_SearchResult> _searchResults = [];

  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    mercadoStore.loadMercados();
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
        // Limpar filtro de busca
        mercadoStore.searchMercados('');
        _isSearching = false;
        _searchResults.clear();
      }
    });
  }

  Future<void> _performCombinedSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    

    try {
      final futures = await Future.wait([
        _mercadoService.searchMercados(q).first,
        _promocaoService.searchPromocoes(q).first,
      ]);

      final mercadosByName = futures[0] as List<Mercado>;
      final promocoes = futures[1] as List<Promocao>;

      

      // Map mercados by id for quick lookup
      final mapaMercados = <String?, Mercado?>{for (var m in mercadosByName) m.id: m};

      final results = <_SearchResult>[];

      // Add mercados first
      for (final m in mercadosByName) {
        results.add(_SearchResult.mercado(m));
      }

      // Add promotions; attach mercado if available locally
      for (final p in promocoes) {
        Mercado? mercado;
        for (final m in mercadoStore.mercados) {
          if (m.id == p.customerId) {
            mercado = m;
            break;
          }
        }
        if (mercado == null && mapaMercados.containsKey(p.customerId)) {
          mercado = mapaMercados[p.customerId];
        }
        results.add(_SearchResult.promocao(p, mercado: mercado));
      }

      

      setState(() {
        _searchResults = results;
      });
    } catch (e, st) {
      print('❌ [HomePage] Error during combined search: $e');
      print(st);
      // on error, show empty results but keep searching flag
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CitySelectionModal(
        selectedCity: mercadoStore.selectedCity,
        onCitySelected: (city) {
          mercadoStore.filterByCity(city);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _searchAnimation,
          builder: (context, child) {
            return Row(
              children: [
                IconButton(
                  icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
                if (!_isSearchExpanded) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: _showCitySelector,
                      child: Observer(
                        builder: (_) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.navigation_outlined,
                                color: Colors.white.withValues(alpha: .9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                mercadoStore.selectedCity,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Buscar mercado ou promoção',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        onChanged: (value) {
                          // Buscar mercados e promoções correspondentes
                          _performCombinedSearch(value);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          Observer(
            builder: (_) {
              if (authStore.isLoggedIn) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authStore.signOut();
                    if (mounted) {
                      // Após logout, permanecer na home como visitante
                      setState(() {});
                    }
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.store),
                  tooltip: 'Login Supermercado',
                  onPressed: () {
                    Modular.to.pushNamed('/auth/login?tipo=mercado');
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (mercadoStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mercadoStore.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar mercados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      mercadoStore.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => mercadoStore.loadMercados(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (mercadoStore.mercados.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum mercado encontrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => mercadoStore.loadMercados(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                  // const SizedBox(height: 8),
                  // TextButton.icon(
                  //   onPressed: () {
                  //     Modular.to.pushNamed('/debug');
                  //   },
                  //   icon: const Icon(Icons.bug_report, color: Colors.orange),
                  //   label: const Text(
                  //     'Inserir Dados de Teste',
                  //     style: TextStyle(color: Colors.orange),
                  //   ),
                  // ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => mercadoStore.loadMercados(),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Card de Promoção Relâmpago
                GestureDetector(
                  onTap: () {
                    Modular.to.pushNamed('/promocao/relampago');
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6F00), Color(0xFFFF6F00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF6F00).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background decoration
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: -10,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Promoção relâmpago',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Descubra as promoções \nrolando agora!',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Seção "Explorar"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Explorar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: _isSearching
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final r = _searchResults[index];
                            if (r.type == 'mercado') {
                              return _buildMarketCard(r.mercado!);
                            }
                            return _buildPromotionCard(r.promocao!, r.mercado);
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: mercadoStore.filteredMercados.length,
                          itemBuilder: (context, index) {
                            final mercado = mercadoStore.filteredMercados[index];

                            return _buildMarketCard(mercado);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketCard(Mercado mercado) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Modular.to.pushNamed('/mercado/detail/${mercado.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Imagem do mercado
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 100,
                child: mercado.imagem != null && mercado.imagem!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: mercado.imagem!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.store,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.store,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Informações do mercado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mercado.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (mercado.endereco != null && mercado.endereco!.isNotEmpty)
                    Text(
                      mercado.endereco!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  if (mercado.cidade.isNotEmpty)
                    Text(
                      mercado.cidade,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.sell_outlined,
                          size: 16,
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Ver Promoções',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(Promocao promocao, Mercado? mercado) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          if (promocao.id != null) Modular.to.pushNamed('/promocao/detail/${promocao.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 100,
                child: promocao.imagem != null && promocao.imagem!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: promocao.imagem!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.local_offer,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.local_offer,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promocao.nome ?? 'Promoção',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mercado?.nome ?? 'Mercado',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'R\$ ${promocao.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        promocao.unidade,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CitySelectionModal extends StatelessWidget {
  final String selectedCity;
  final Function(String) onCitySelected;

  const _CitySelectionModal({
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    final cities = [
      'São Paulo, SP',
      'São Luís, MA',
      'Imperatriz, MA',
      'Timon, MA',
      'Codó, MA',
      'Açailândia, MA',
      'Bacabal, MA',
      'Santa Inês, MA',
    ];

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // City selector
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione sua cidades para começar a aproveitar as promoções',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      // border: Border.all(color: const Color(0xFF4CAF50)),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCity,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            onCitySelected(newValue);
                          }
                        },
                        items: cities.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.black),
                              ),
                              decoration: BoxDecoration(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // const Spacer(),
                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Confirmar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
