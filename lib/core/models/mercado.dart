import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusMercado { pendente, aprovado, reprovado }

class Mercado {
  final String? id;
  final String nome;
  final String cnpj;
  final String? email;
  final String? endereco;
  final String? telefone;
  final String cidade; // Campo obrigatório agora
  final String? imagem;
  final StatusMercado status;
  final DateTime? dataAprovacao;
  final String? adminAprovadorId;

  Mercado({
    this.id,
    required this.nome,
    required this.cnpj,
    this.email,
    this.endereco,
    this.telefone,
    required this.cidade, // Campo obrigatório agora
    this.imagem,
    this.status = StatusMercado.pendente,
    this.dataAprovacao,
    this.adminAprovadorId,
  });

  factory Mercado.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Converte string para enum de status
    StatusMercado status = StatusMercado.pendente;
    if (data['status'] != null) {
      switch (data['status']) {
        case 'pendente':
          status = StatusMercado.pendente;
          break;
        case 'aprovado':
          status = StatusMercado.aprovado;
          break;
        case 'reprovado':
          status = StatusMercado.reprovado;
          break;
        default:
          status = StatusMercado.pendente;
      }
    }
    
    return Mercado(
      id: doc.id,
      nome: data['nome'] ?? '',
      cnpj: data['cnpj'] ?? '',
      email: data['email'],
      endereco: data['endereco'],
      telefone: data['telefone'],
      cidade: data['cidade'] ?? 'São Paulo, SP', // Valor padrão se não existir
      imagem: data['imagem'],
      status: status,
      dataAprovacao: data['data_aprovacao'] != null
          ? (data['data_aprovacao'] as Timestamp).toDate()
          : null,
      adminAprovadorId: data['admin_aprovador_id'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'cnpj': cnpj,
      'email': email,
      'endereco': endereco,
      'telefone': telefone,
      'cidade': cidade,
      'imagem': imagem,
      'status': status.toString().split('.').last,
      'data_aprovacao': dataAprovacao != null ? Timestamp.fromDate(dataAprovacao!) : null,
      'admin_aprovador_id': adminAprovadorId,
    };
  }

  Mercado copyWith({
    String? id,
    String? nome,
    String? cnpj,
    String? email,
    String? endereco,
    String? telefone,
    String? cidade,
    String? imagem,
    StatusMercado? status,
    DateTime? dataAprovacao,
    String? adminAprovadorId,
  }) {
    return Mercado(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      telefone: telefone ?? this.telefone,
      cidade: cidade ?? this.cidade,
      imagem: imagem ?? this.imagem,
      status: status ?? this.status,
      dataAprovacao: dataAprovacao ?? this.dataAprovacao,
      adminAprovadorId: adminAprovadorId ?? this.adminAprovadorId,
    );
  }
}
