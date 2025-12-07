import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoUsuario { mercado, admin }

class Usuario {
  final String? id;
  final String email;
  final String? telefone;
  final String nome;
  final TipoUsuario tipo;
  final String? mercadoId;
  final DateTime dataCriacao;

  Usuario({
    this.id,
    required this.email,
    required this.nome,
    required this.telefone,
    required this.tipo,
    this.mercadoId,
    required this.dataCriacao,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Converte string para enum
    TipoUsuario tipo = TipoUsuario.mercado;
    if (data['tipo'] != null) {
      switch (data['tipo']) {
        case 'mercado':
          tipo = TipoUsuario.mercado;
          break;
        case 'admin':
          tipo = TipoUsuario.admin;
          break;
        default:
          tipo = TipoUsuario.mercado;
      }
    }

    return Usuario(
      id: doc.id,
      email: data['email'] ?? '',
      telefone: data['telefone'] ?? '',
      nome: data['nome'] ?? '',
      tipo: tipo,
      mercadoId: data['mercado_id'],
      dataCriacao: data['data_criacao'] != null
          ? (data['data_criacao'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'telefone': telefone,
      'nome': nome,
      'tipo': tipo.toString().split('.').last,
      'mercado_id': mercadoId,
      'data_criacao': Timestamp.fromDate(dataCriacao),
    };
  }

  Usuario copyWith({
    String? id,
    String? email,
    String? telefone,
    String? nome,
    TipoUsuario? tipo,
    String? mercadoId,
    DateTime? dataCriacao,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      mercadoId: mercadoId ?? this.mercadoId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
