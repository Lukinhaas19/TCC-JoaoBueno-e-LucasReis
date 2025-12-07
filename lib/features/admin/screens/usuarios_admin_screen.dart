import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/stores/admin_store.dart';
import '../../../core/models/usuario.dart';
import '../widgets/admin_widgets.dart';

class UsuariosAdminScreen extends StatefulWidget {
  const UsuariosAdminScreen({super.key});

  @override
  State<UsuariosAdminScreen> createState() => _UsuariosAdminScreenState();
}

class _UsuariosAdminScreenState extends State<UsuariosAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Usuario> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStore>().loadTodosUsuarios();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(
      builder: (context, adminStore, child) {
        return Column(
          children: [
            // Barra de pesquisa
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar usuários por nome ou email...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                              _searchResults.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _performSearch(value, adminStore);
                  } else {
                    setState(() {
                      _isSearching = false;
                      _searchResults.clear();
                    });
                  }
                },
              ),
            ),

            // Tabs
            if (!_isSearching) ...[
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Todos'),
                  Tab(text: 'Admins'),
                  Tab(text: 'Mercados'),
                ],
                labelColor: Colors.indigo,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.indigo,
              ),
            ],

            // Conteúdo
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUsuariosList(
                          adminStore.todosUsuarios,
                          adminStore.isLoadingUsuarios,
                          adminStore,
                        ),
                        _buildUsuariosList(
                          adminStore.usuariosAdmin,
                          adminStore.isLoadingUsuarios,
                          adminStore,
                        ),
                        _buildUsuariosList(
                          adminStore.usuariosMercado,
                          adminStore.isLoadingUsuarios,
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

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum usuário encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final usuario = _searchResults[index];
        return _buildUsuarioCard(usuario, context.read<AdminStore>());
      },
    );
  }

  Widget _buildUsuariosList(
    List<Usuario> usuarios,
    bool isLoading,
    AdminStore adminStore,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (usuarios.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum usuário encontrado',
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
      onRefresh: () => adminStore.loadTodosUsuarios(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          return _buildUsuarioCard(usuario, adminStore);
        },
      ),
    );
  }

  Widget _buildUsuarioCard(Usuario usuario, AdminStore adminStore) {
    return AdminWidgets.buildCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getTipoColor(usuario.tipo),
                  child: Icon(
                    _getTipoIcon(usuario.tipo),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usuario.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cadastrado em ${_formatDate(usuario.dataCriacao)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTipoChip(usuario.tipo),
              ],
            ),
            const SizedBox(height: 16),

            // Ações
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUsuarioDetails(usuario),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detalhes'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (usuario.tipo != TipoUsuario.admin)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showChangeTypeDialog(usuario, adminStore),
                      icon: const Icon(Icons.edit),
                      label: const Text('Alterar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                if (usuario.tipo == TipoUsuario.admin &&
                    usuario.id != adminStore.currentAdmin?.id)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRebaixarAdminDialog(usuario, adminStore),
                      icon: const Icon(Icons.remove_moderator),
                      label: const Text('Rebaixar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (usuario.id != adminStore.currentAdmin?.id)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _showDeleteUserDialog(usuario, adminStore),
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _buildTipoChip(TipoUsuario tipo) {
    return AdminWidgets.buildStatusChip(
      label: _getTipoLabel(tipo),
      color: _getTipoColor(tipo),
      icon: _getTipoIcon(tipo),
    );
  }

  Color _getTipoColor(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.admin:
        return Colors.indigo;
      case TipoUsuario.mercado:
        return Colors.teal;
    }
  }

  IconData _getTipoIcon(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.admin:
        return Icons.admin_panel_settings;
      case TipoUsuario.mercado:
        return Icons.business;

    }
  }

  String _getTipoLabel(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.admin:
        return 'Admin';
      case TipoUsuario.mercado:
        return 'Mercado';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _performSearch(String query, AdminStore adminStore) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await adminStore.buscarUsuarios(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na busca: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUsuarioDetails(Usuario usuario) {
    AdminWidgets.showBottomSheetModal(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar e título
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _getTipoColor(usuario.tipo),
                  child: Icon(
                    _getTipoIcon(usuario.tipo),
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AdminWidgets.buildStatusChip(
                        label: _getTipoLabel(usuario.tipo),
                        color: _getTipoColor(usuario.tipo),
                        icon: _getTipoIcon(usuario.tipo),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Detalhes do usuário
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRowUser('Nome', usuario.nome),
                  _buildDetailRowUser('Email', usuario.email),
                  if (usuario.telefone != null && usuario.telefone!.isNotEmpty)
                    _buildDetailRowUser('Telefone', usuario.telefone!),
                  _buildDetailRowUser('Tipo', _getTipoLabel(usuario.tipo)),
                  _buildDetailRowUser('Data de Cadastro', _formatDate(usuario.dataCriacao)),
                  if (usuario.mercadoId != null)
                    _buildDetailRowUser('Mercado ID', usuario.mercadoId!),
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

  Widget _buildDetailRowUser(String label, String value) {
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

  void _showChangeTypeDialog(Usuario usuario, AdminStore adminStore) {
    AdminWidgets.showBottomSheetModal(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Alterar Tipo de Usuário',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              usuario.nome,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            
            // Lista de tipos
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: TipoUsuario.values.map((tipo) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: usuario.tipo == tipo ? _getTipoColor(tipo).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: usuario.tipo == tipo ? Border.all(color: _getTipoColor(tipo)) : null,
                    ),
                    child: ListTile(
                      title: Text(
                        _getTipoLabel(tipo),
                        style: TextStyle(
                          fontWeight: usuario.tipo == tipo ? FontWeight.w600 : FontWeight.normal,
                          color: usuario.tipo == tipo ? _getTipoColor(tipo) : Colors.black87,
                        ),
                      ),
                      leading: Icon(
                        _getTipoIcon(tipo), 
                        color: _getTipoColor(tipo),
                        size: 24,
                      ),
                      trailing: usuario.tipo == tipo 
                        ? Icon(Icons.check_circle, color: _getTipoColor(tipo), size: 20)
                        : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        if (tipo != usuario.tipo) {
                          try {
                            await adminStore.alterarTipoUsuario(usuario.id!, tipo);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Usuário alterado para ${_getTipoLabel(tipo)} com sucesso!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao alterar usuário: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Botão cancelar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRebaixarAdminDialog(Usuario usuario, AdminStore adminStore) async {
    final confirmed = await AdminWidgets.showConfirmationDialog(
      context: context,
      title: 'Rebaixar Administrador',
      message: 'Deseja rebaixar "${usuario.nome}" de administrador para usuário comum?\n\nEsta ação remove todos os privilégios administrativos.',
      confirmText: 'Rebaixar',
      cancelText: 'Cancelar',
      confirmColor: Colors.orange,
      icon: Icons.admin_panel_settings_outlined,
    );

    if (confirmed == true) {
      try {
        await adminStore.rebaixarAdmin(usuario.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin rebaixado com sucesso!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao rebaixar admin: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteUserDialog(Usuario usuario, AdminStore adminStore) async {
    final confirmed = await AdminWidgets.showConfirmationDialog(
      context: context,
      title: 'Deletar Usuário',
      message: 'Deseja deletar permanentemente o usuário "${usuario.nome}"?\n\nEsta ação não pode ser desfeita.',
      confirmText: 'Deletar',
      confirmColor: Colors.red,
      icon: Icons.delete_forever,
    );

    if (confirmed == true) {
      try {
        await adminStore.deletarUsuario(usuario.id!);
        if (mounted) {
          AdminWidgets.showSnackBar(
            context: context,
            message: 'Usuário deletado com sucesso!',
            backgroundColor: Colors.red,
            icon: Icons.delete,
          );
        }
      } catch (e) {
        if (mounted) {
          AdminWidgets.showSnackBar(
            context: context,
            message: 'Erro ao deletar usuário: $e',
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      }
    }
  }
}