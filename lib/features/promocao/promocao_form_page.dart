import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../core/stores/auth_store.dart';
import '../../core/stores/promocao_store.dart';
import '../../core/models/promocao.dart';

class PromocaoFormPage extends StatefulWidget {
  final String? promocaoId;

  const PromocaoFormPage({super.key, this.promocaoId});

  @override
  State<PromocaoFormPage> createState() => _PromocaoFormPageState();
}

class _PromocaoFormPageState extends State<PromocaoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _unidadeController = TextEditingController();
  final _validadeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  
  final AuthStore authStore = Modular.get<AuthStore>();
  final PromocaoStore promocaoStore = Modular.get<PromocaoStore>();
  final ImagePicker _picker = ImagePicker();
  
  bool _limite = false;
  bool _promocao = true;
  bool _relampago = false;
  DateTime? _dataValidade;
  File? _imagemSelecionada;
  Promocao? _promocaoEditando;

  bool get isEditing => widget.promocaoId != null;

  @override
  void initState() {
    super.initState();
    _verificarFirebase();
    if (isEditing) {
      _loadPromocao();
    }
  }

  void _loadPromocao() {
    _promocaoEditando = promocaoStore.promocoes.firstWhere(
      (p) => p.id == widget.promocaoId,
      orElse: () => promocaoStore.promocoes.first, // fallback temporário
    );
    
    if (_promocaoEditando != null) {
      _nomeController.text = _promocaoEditando!.nome ?? '';
      // Formatar o preço para o formato brasileiro (com vírgula)
      _precoController.text = _promocaoEditando!.preco.toStringAsFixed(2).replaceAll('.', ',');
      _unidadeController.text = _promocaoEditando!.unidade;
      _limite = _promocaoEditando!.limite;
      _promocao = _promocaoEditando!.promocao;
      _relampago = _promocaoEditando!.relampago;
      _quantidadeController.text = _promocaoEditando!.quantidade?.toString() ?? '';
      
      if (_promocaoEditando!.validade != null) {
        _dataValidade = _promocaoEditando!.validade;
        _validadeController.text = DateFormat('dd/MM/yyyy').format(_dataValidade!);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _unidadeController.dispose();
    _validadeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _imagemSelecionada = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _salvarPromocao() async {
    if (_formKey.currentState!.validate()) {
      // Verificar se o usuário está autenticado e tem mercadoId
      if (authStore.currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário não autenticado. Faça login novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (authStore.currentUser!.mercadoId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mercado não associado ao usuário. Tente fazer login novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      print('🔄 Iniciando salvamento da promoção...');
      print('📊 Dados da promoção:');
      print('   - Nome: ${_nomeController.text.trim()}');
      print('   - Preço: ${_precoController.text} -> ${double.parse(_precoController.text.replaceAll(',', '.'))}');
      print('   - Unidade: ${_unidadeController.text.trim()}');
      print('   - Validade: $_dataValidade');
      print('   - Limite: $_limite');
      print('   - Quantidade: ${_quantidadeController.text}');
      // print('   - Promoção: $_promocao');
      print('   - Imagem selecionada: ${_imagemSelecionada?.path ?? 'Nenhuma'}');
      print('   - Customer ID (Mercado): ${authStore.currentUser!.mercadoId}');
      print('   - User ID: ${authStore.currentUser!.id}');
      
      final promocao = Promocao(
        id: isEditing ? widget.promocaoId : null,
        customerId: authStore.currentUser!.mercadoId!,
        nome: _nomeController.text.trim(),
        preco: double.parse(_precoController.text.replaceAll(',', '.')),
        unidade: _unidadeController.text.trim(),
        validade: _dataValidade,
        limite: _limite,
        promocao: _promocao,
        relampago: _relampago,
        imagem: _promocaoEditando?.imagem, // Manter imagem atual se não alterada
        quantidade: _limite && _quantidadeController.text.isNotEmpty 
            ? int.tryParse(_quantidadeController.text) 
            : null,
      );

      print('🏪 Objeto Promocao criado: ${promocao.toFirestore()}');

      bool success;
      if (isEditing) {
        print('✏️ Modo edição - ID: ${widget.promocaoId}');
        // Se está editando, usar método com imagem se foi selecionada uma nova
        if (_imagemSelecionada != null) {
          print('🖼️ Atualizando com nova imagem...');
          success = await promocaoStore.updatePromocaoWithImage(promocao, _imagemSelecionada);
        } else {
          print('📝 Atualizando sem nova imagem...');
          success = await promocaoStore.updatePromocao(promocao);
        }
      } else {
        print('➕ Modo criação...');
        // Se está criando, usar método com imagem
        if (_imagemSelecionada != null) {
          print('🖼️ Criando com imagem...');
        } else {
          print('📝 Criando sem imagem...');
        }
        success = await promocaoStore.createPromocaoWithImage(promocao, _imagemSelecionada);
      }

      print('📊 Resultado do salvamento: ${success ? '✅ Sucesso' : '❌ Falha'}');
      
      if (promocaoStore.errorMessage != null) {
        print('❌ Erro: ${promocaoStore.errorMessage}');
      }

      if (mounted && success) {
        print('🎉 Promoção salva com sucesso! Navegando de volta...');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                  ? 'Promoção atualizada com sucesso!'
                  : 'Promoção criada com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Modular.to.pop();
      } else if (mounted) {
        print('⚠️ Falha ao salvar promoção');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              promocaoStore.errorMessage ?? 'Erro desconhecido ao salvar promoção',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('❌ Validação do formulário falhou');
    }
  }

  Future<void> _verificarFirebase() async {
    print('🧪 [Debug] Verificando estado do Firebase...');
    print('👤 Usuário atual: ${authStore.currentUser?.id ?? 'Nenhum'}');
    print('🏪 Mercado ID: ${authStore.currentUser?.mercadoId ?? 'Nenhum'}');
    print('📱 App: ${promocaoStore.isLoading ? 'Carregando' : 'Pronto'}');
    
    if (authStore.currentUser == null) {
      print('❌ [Erro] Usuário não autenticado!');
      return;
    }
    
    if (authStore.currentUser!.mercadoId == null) {
      print('⚠️ [Aviso] MercadoId não encontrado, tentando recarregar dados do usuário...');
      await authStore.checkCurrentUser();
      
      if (authStore.currentUser?.mercadoId == null) {
        print('❌ [Erro] MercadoId ainda não disponível após recarregamento!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: Mercado não associado. Faça logout e login novamente.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        print('✅ [Sucesso] MercadoId carregado: ${authStore.currentUser!.mercadoId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar promoção' : 'Criar promoção'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Modular.to.pop(),
        ),
        actions: [
          // Debug indicator para mostrar se mercadoId está disponível
          Observer(
            builder: (_) => authStore.currentUser?.mercadoId == null
                ? IconButton(
                    icon: const Icon(Icons.warning, color: Colors.orange),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aviso: ID do mercado não disponível'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seleção de imagem
              Center(
                child: GestureDetector(
                  onTap: _selecionarImagem,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                    ),
                    child: _imagemSelecionada != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              _imagemSelecionada!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_promocaoEditando?.imagem != null && _promocaoEditando!.imagem!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  _promocaoEditando!.imagem!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Título da seção
              const Text(
                'Mais informações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  hintText: 'Nome do produto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do produto';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Campo Preço
              TextFormField(
                controller: _precoController,
                decoration: InputDecoration(
                  hintText: '0,00',
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) return newValue;
                    
                    // Remove todos os caracteres não numéricos
                    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
                    
                    // Se não tem dígitos, retorna vazio
                    if (digits.isEmpty) return const TextEditingValue(text: '');
                    
                    // Converte para centavos
                    int value = int.parse(digits);
                    double amount = value / 100;
                    
                    // Formata com vírgula decimal
                    String formatted = amount.toStringAsFixed(2).replaceAll('.', ',');
                    
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o preço';
                  }
                  try {
                    // Converte vírgula para ponto para validação
                    double.parse(value.replaceAll(',', '.'));
                  } catch (e) {
                    return 'Digite um preço válido';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Campo Unidade
              TextFormField(
                controller: _unidadeController,
                decoration: InputDecoration(
                  hintText: 'Unidade (Kg, L, Un, M)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a unidade';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Título da seção Validade
              const Text(
                'Validade',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Campo Validade
              TextFormField(
                controller: _validadeController,
                decoration: InputDecoration(
                  hintText: 'dd/mm/aaaa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String text = newValue.text.replaceAll('/', '');
                    String formatted = '';
                    
                    if (text.length >= 1) {
                      formatted += text.substring(0, text.length > 2 ? 2 : text.length);
                      if (text.length >= 3) {
                        formatted += '/';
                        formatted += text.substring(2, text.length > 4 ? 4 : text.length);
                        if (text.length >= 5) {
                          formatted += '/';
                          formatted += text.substring(4, text.length > 8 ? 8 : text.length);
                        }
                      }
                    }
                    
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                onChanged: (value) {
                  // Validar e converter para DateTime quando o campo estiver completo
                  if (value.length == 10) {
                    try {
                      final parts = value.split('/');
                      if (parts.length == 3) {
                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]);
                        _dataValidade = DateTime(year, month, day);
                      }
                    } catch (e) {
                      _dataValidade = null;
                    }
                  } else {
                    _dataValidade = null;
                  }
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length != 10) {
                      return 'Digite uma data válida no formato dd/mm/aaaa';
                    }
                    try {
                      final parts = value.split('/');
                      final day = int.parse(parts[0]);
                      final month = int.parse(parts[1]);
                      final year = int.parse(parts[2]);
                      
                      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 2024) {
                        return 'Digite uma data válida';
                      }
                      
                      final date = DateTime(year, month, day);
                      if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                        return 'A data deve ser futura';
                      }
                    } catch (e) {
                      return 'Digite uma data válida';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Validar por CPF
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Validar por CPF',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _limite = !_limite;
                        // Limpar quantidade quando desativar o limite
                        if (!_limite) {
                          _quantidadeController.clear();
                        }
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: _limite ? const Color(0xFF4CAF50) : Colors.grey[300],
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: _limite ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Campo quantidade se limite estiver ativo
              if (_limite) ...[
                TextFormField(
                  controller: _quantidadeController,
                  decoration: InputDecoration(
                    hintText: 'Quantidade limite por CPF',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (_limite && (value == null || value.isEmpty)) {
                      return 'Digite a quantidade limite';
                    }
                    if (_limite && value != null && value.isNotEmpty) {
                      final quantidade = int.tryParse(value);
                      if (quantidade == null || quantidade <= 0) {
                        return 'Digite uma quantidade válida';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // Promoção Relâmpago
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Promoção Relâmpago',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Destacar como oferta por tempo limitado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _relampago = !_relampago;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: _relampago ? const Color(0xFFFF6F00) : Colors.grey[300],
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: _relampago ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Botão Confirmar
              SizedBox(
                width: double.infinity,
                child: Observer(
                  builder: (_) => ElevatedButton(
                    onPressed: promocaoStore.isLoading ? null : _salvarPromocao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: promocaoStore.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Confirmar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Erro
              Observer(
                builder: (_) => promocaoStore.errorMessage != null
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                promocaoStore.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
