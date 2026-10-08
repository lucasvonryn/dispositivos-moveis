import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../formatacao.dart';
import '../models/solicitacao.dart';
import '../widgets/app_background.dart';

class _ComentarioDialog extends StatefulWidget {
  const _ComentarioDialog();

  @override
  State<_ComentarioDialog> createState() => _ComentarioDialogState();
}

class _ComentarioDialogState extends State<_ComentarioDialog> {
  final _controller = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo comentário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Escreva seu comentário',
            ),
          ),
          if (_erro != null) ...[
            const SizedBox(height: 8),
            Text(
              _erro!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final valor = _controller.text.trim();
            if (valor.isEmpty) {
              setState(() => _erro = 'Informe o texto do comentário.');
              return;
            }
            Navigator.pop(context, valor);
          },
          child: const Text('Salvar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class SolicitacaoDetalhePage extends StatefulWidget {
  final String solicitacaoId;

  const SolicitacaoDetalhePage({super.key, required this.solicitacaoId});

  @override
  State<SolicitacaoDetalhePage> createState() => _SolicitacaoDetalhePageState();
}

class _SolicitacaoDetalhePageState extends State<SolicitacaoDetalhePage> {
  Solicitacao? _solicitacao;
  String? _tokenFoto;
  bool _carregando = true;
  bool _excluindo = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final item = await AppState.instance.solicitacoes
          .buscarRemoto(widget.solicitacaoId);
      String? token;
      if (item.foto.isNotEmpty) {
        token = await AppState.instance.pb.files.getToken();
      }
      await AppState.instance.comentarios.carregar(widget.solicitacaoId);
      if (!mounted) return;
      setState(() {
        _solicitacao = item;
        _tokenFoto = token;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = 'Solicitação não encontrada.';
      });
    }
  }

  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir solicitação'),
        content: const Text('Deseja excluir esta solicitação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _excluindo = true);
    final erro =
        await AppState.instance.solicitacoes.excluir(widget.solicitacaoId);
    if (!mounted) return;
    if (erro != null) {
      setState(() => _excluindo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red.shade700),
      );
      return;
    }
    context.go('/');
  }

  Future<void> _novoComentario() async {
    final texto = await showDialog<String>(
      context: context,
      builder: (context) => const _ComentarioDialog(),
    );
    if (texto == null || !mounted) return;

    final autor = AppState.instance.sessao.usuarioAtual;
    if (autor == null) return;

    final erro = await AppState.instance.comentarios.adicionar(
      solicitacaoId: widget.solicitacaoId,
      texto: texto,
      autor: autor,
    );
    if (!mounted || erro == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(erro), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final comentariosRepo = AppState.instance.comentarios;

    return Scaffold(
      floatingActionButton: _solicitacao == null
          ? null
          : FloatingActionButton(
              tooltip: 'Novo comentário',
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              onPressed: _novoComentario,
              child: const Icon(Icons.add_comment),
            ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Voltar',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/'),
                ),
              ),
              Expanded(
                child: _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : _erro != null
                        ? Center(child: Text(_erro!))
                        : AnimatedBuilder(
                            animation: comentariosRepo,
                            builder: (context, _) {
                              final item = _solicitacao!;
                              final usuario =
                                  AppState.instance.sessao.usuarioAtual;
                              final dono = item.pertenceA(usuario?.id);
                              final comentarios = comentariosRepo.itens;

                              return ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 96),
                                children: [
                                  if (item.foto.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        item
                                            .urlFoto(
                                              AppState.instance.pb,
                                              token: _tokenFoto,
                                            )
                                            .toString(),
                                        height: 240,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const SizedBox(
                                          height: 120,
                                          child: Center(
                                            child: Text(
                                              'Não foi possível exibir a foto.',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  Card(
                                    elevation: 0,
                                    color: colors.surface.withValues(alpha: 0.94),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: colors.outlineVariant,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.titulo,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(item.descricao),
                                          const SizedBox(height: 16),
                                          Text('Autor: ${item.nomeUsuario}'),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Data: ${formatarData(item.criadaEm)}',
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Localização: ${formatarCoordenadas(item.latitude, item.longitude)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (dono) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: _excluindo
                                                ? null
                                                : () => context.go(
                                                      '/solicitacoes/${item.id}/editar',
                                                    ),
                                            icon: const Icon(Icons.edit),
                                            label: const Text('Editar'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                _excluindo ? null : _excluir,
                                            icon: const Icon(Icons.delete_outline),
                                            label: const Text('Excluir'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  Text(
                                    'Comentários',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  if (comentariosRepo.carregando)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else if (comentariosRepo.erro != null)
                                    Text(comentariosRepo.erro!)
                                  else if (comentarios.isEmpty)
                                    Text(
                                      'Nenhum comentário ainda.',
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    )
                                  else
                                    ...comentarios.map(
                                      (comentario) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Card(
                                          elevation: 0,
                                          color: colors.surface
                                              .withValues(alpha: 0.94),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            side: BorderSide(
                                              color: colors.outlineVariant,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comentario.nomeUsuario,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(comentario.texto),
                                                const SizedBox(height: 8),
                                                Text(
                                                  formatarData(
                                                    comentario.criadoEm,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: colors
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
