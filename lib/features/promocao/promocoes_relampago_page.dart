import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/stores/promocao_store.dart';
import '../../core/stores/mercado_store.dart';
import '../../core/models/promocao.dart';

class PromocoesRelampagoPage extends StatefulWidget {
  const PromocoesRelampagoPage({super.key});

  @override
  State<PromocoesRelampagoPage> createState() => _PromocoesRelampagoPageState();
}

class _PromocoesRelampagoPageState extends State<PromocoesRelampagoPage> {
  final PromocaoStore promocaoStore = Modular.get<PromocaoStore>();
  final MercadoStore mercadoStore = Modular.get<MercadoStore>();

  @override
  void initState() {
    super.initState();
    _loadPromocoesRelampago();
  }

  Future<void> _loadPromocoesRelampago() async {
    await promocaoStore.loadPromocoesRelampago();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6F00),
        foregroundColor: Colors.white,
        title: const Text(
          'Promoções Relâmpago',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        elevation: 0,
      ),
      body: Observer(
        builder: (_) {
          if (promocaoStore.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF6F00)),
                  SizedBox(height: 16),
                  Text(
                    'Carregando promoções relâmpago...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (promocaoStore.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar promoções',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promocaoStore.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadPromocoesRelampago,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final promocoesRelampago = promocaoStore.promocoes
              .where((p) => p.relampago)
              .toList();

          if (promocoesRelampago.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma promoção relâmpago disponível',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Volte em breve para conferir novas ofertas!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadPromocoesRelampago,
            color: const Color(0xFFFF6F00),
            child: Column(
              children: [
                // Header com informações
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 0,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${promocoesRelampago.length} ofertas encontradas',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de promoções
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: promocoesRelampago.length,
                    itemBuilder: (context, index) {
                      final promocao = promocoesRelampago[index];
                      return _buildPromocaoRelampagoCard(promocao);
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

  Widget _buildPromocaoRelampagoCard(Promocao promocao) {
    final mercados = mercadoStore.mercados
        .where((m) => m.id == promocao.customerId)
        .toList();
    final mercado = mercados.isNotEmpty ? mercados.first : null;

    final isExpiringSoon =
        promocao.validade != null &&
        promocao.validade!.difference(DateTime.now()).inHours < 24;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6F00), width: 1.3),
        boxShadow: [],
      ),
      child: Column(
        children: [
          // Badge de promoção relâmpago
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6F00),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'PROMOÇÃO RELÂMPAGO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ÚLTIMAS HORAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Conteúdo da promoção
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Imagem do produto
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                                Icons.local_offer,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.local_offer,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Informações do produto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promocao.nome ?? 'Produto sem nome',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (mercado != null)
                        Text(
                          mercado.nome,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),

                      // Preço
                      Row(
                        children: [
                          Text(
                            'R\$ ${promocao.preco.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6F00),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ ${promocao.unidade}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      // Validade
                      if (promocao.validade != null)
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: isExpiringSoon
                                  ? Colors.red
                                  : Colors.orange[800],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Válido até ${DateFormat('dd/MM/yyyy HH:mm').format(promocao.validade!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isExpiringSoon
                                    ? Colors.red
                                    : Colors.orange[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
