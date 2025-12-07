import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';
import '../../core/models/promocao.dart';
import '../../core/stores/mercado_store.dart';
import '../../core/stores/promocao_store.dart';
import '../../core/models/mercado.dart';

class MercadoDetailPage extends StatefulWidget {
  final String mercadoId;

  const MercadoDetailPage({super.key, required this.mercadoId});

  @override
  State<MercadoDetailPage> createState() => _MercadoDetailPageState();
}

class _MercadoDetailPageState extends State<MercadoDetailPage> {
  final MercadoStore mercadoStore = Modular.get<MercadoStore>();
  final PromocaoStore promocaoStore = Modular.get<PromocaoStore>();

  Mercado? mercado;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print(
      '🏪 [MercadoDetail] Carregando dados do mercado: ${widget.mercadoId}',
    );

    // Buscar mercado específico
    mercado = mercadoStore.mercados.firstWhere(
      (m) => m.id == widget.mercadoId,
      orElse: () => mercadoStore.mercados.first, // fallback temporário
    );

    print('🛒 [MercadoDetail] Carregando promoções do mercado...');
    // Carregar promoções do mercado (busca diretamente pelo ID do mercado)
    await promocaoStore.loadPromocoesByMercado(widget.mercadoId);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mercado == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: GestureDetector(
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
                          Icons.store,
                          color: Colors.white.withValues(alpha: .9),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mercado?.nome ?? 'Sem nome',
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
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Ver no Mapa',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final query =
                  '${mercado!.nome} ${mercado!.endereco ?? ''} ${mercado!.cidade}';
              final encoded = Uri.encodeComponent(query);

              final webMaps = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=$encoded',
              );

              try {
                bool launched = false;

                launched = await launchUrl(
                  webMaps,
                  mode: LaunchMode.externalApplication,
                );

                if (!launched) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Não foi possível abrir o Google Maps nem o navegador.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Erro ao abrir o mapa: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // App Bar com imagem
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              height: 280,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  mercado!.imagem != null && mercado!.imagem!.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            imageUrl: mercado!.imagem!,
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
                                Icons.store,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF4CAF50),
                          child: const Icon(
                            Icons.store,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                  // Gradiente sobreposto
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações do mercado
                  if (mercado!.endereco != null &&
                      mercado!.endereco!.isNotEmpty)
                    Text(
                      mercado!.endereco!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  if (mercado!.cidade.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mercado!.cidade,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Seção de promoções
                  Text(
                    'Promoções',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Lista de promoções
          Observer(
            builder: (_) {
              if (promocaoStore.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (promocaoStore.promocoes.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Este mercado ainda não tem promoções',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final promocao = promocaoStore.promocoes[index];
                    return _buildPromocaoCard(promocao);
                  }, childCount: promocaoStore.promocoes.length),
                ),
              );
            },
          ),

          // Espaçamento final
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildPromocaoCard(Promocao promocao) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: promocao.relampago
            ? Border.all(
                color: const Color(0xFFFF6F00).withOpacity(0.5),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: promocao.relampago
                ? const Color(0xFFFF6F00).withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge de promoção relâmpago (se aplicável)
          if (promocao.relampago)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6F00),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'PROMOÇÃO RELÂMPAGO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Conteúdo principal do card
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                // Modular.to.pushNamed('/mercado/detail/${mercado.id}');
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
                      child:
                          promocao.imagem != null && promocao.imagem!.isNotEmpty
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promocao.nome ?? 'Sem nome',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${promocao.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'por ${promocao.unidade}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      if (promocao.limite && promocao.quantidade != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Limite: ${promocao.quantidade} por CPF',
                          style: TextStyle(color: Colors.orange, fontSize: 14),
                        ),
                      ],
                    ],
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
