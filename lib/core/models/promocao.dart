import 'package:cloud_firestore/cloud_firestore.dart';

class Promocao {
  final String? id;
  final String customerId; // ID do mercado
  final String? nome;
  final double preco;
  final String unidade;
  final DateTime? validade;
  final bool limite;
  final bool promocao;
  final String? imagem;
  final int? quantidade; // Quantidade limite por CPF
  final bool relampago; // Nova propriedade para promoção relâmpago

  Promocao({
    this.id,
    required this.customerId,
    this.nome,
    required this.preco,
    required this.unidade,
    this.validade,
    required this.limite,
    required this.promocao,
    this.imagem,
    this.quantidade,
    this.relampago = false, // Default false para promoções existentes
  });

  factory Promocao.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Promocao(
      id: doc.id,
      customerId: data['customer_id'] ?? '',
      nome: data['nome'],
      preco: (data['preco'] ?? 0.0).toDouble(),
      unidade: data['unidade'] ?? '',
      validade: data['validade'] != null 
          ? (data['validade'] as Timestamp).toDate() 
          : null,
      limite: data['limite'] ?? false,
      promocao: data['promocao'] ?? false,
      imagem: data['imagem'],
      quantidade: data['quantidade'] != null ? (data['quantidade'] as num).toInt() : null,
      relampago: data['relampago'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customer_id': customerId,
      'nome': nome,
      'preco': preco,
      'unidade': unidade,
      'validade': validade != null ? Timestamp.fromDate(validade!) : null,
      'limite': limite,
      'promocao': promocao,
      'imagem': imagem,
      'quantidade': quantidade,
      'relampago': relampago,
    };
  }

  Promocao copyWith({
    String? id,
    String? customerId,
    String? nome,
    double? preco,
    String? unidade,
    DateTime? validade,
    bool? limite,
    bool? promocao,
    String? imagem,
    int? quantidade,
    bool? relampago,
  }) {
    return Promocao(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      unidade: unidade ?? this.unidade,
      validade: validade ?? this.validade,
      limite: limite ?? this.limite,
      promocao: promocao ?? this.promocao,
      imagem: imagem ?? this.imagem,
      quantidade: quantidade ?? this.quantidade,
      relampago: relampago ?? this.relampago,
    );
  }
}
