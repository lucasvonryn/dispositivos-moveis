import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import '../app_state.dart';
import '../localizacao.dart';
import '../widgets/app_background.dart';

class SolicitacaoFormPage extends StatefulWidget {
  final String? solicitacaoId;

  const SolicitacaoFormPage({super.key, this.solicitacaoId});

  @override
  State<SolicitacaoFormPage> createState() => _SolicitacaoFormPageState();
}

class _SolicitacaoFormPageState extends State<SolicitacaoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _picker = ImagePicker();

  bool get _edicao => widget.solicitacaoId != null;

  bool _carregando = false;
  bool _salvando = false;
  bool _semPermissao = false;
  String? _falhaCarga;
  String? _erro;
  String? _erroFoto;
  Uint8List? _fotoBytes;
  String? _fotoExistente;
  String? _collectionId;
  String? _tokenFoto;

  @override
  void initState() {
    super.initState();
    if (_edicao) _carregar();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _falhaCarga = null;
    });

    try {
      final item = await AppState.instance.solicitacoes
          .buscarRemoto(widget.solicitacaoId!);
      final usuario = AppState.instance.sessao.usuarioAtual;
      if (!item.pertenceA(usuario?.id)) {
        if (!mounted) return;
        setState(() {
          _carregando = false;
          _semPermissao = true;
        });
        return;
      }

      String? token;
      if (item.foto.isNotEmpty) {
        token = await AppState.instance.pb.files.getToken();
      }
      if (!mounted) return;
      _tituloController.text = item.titulo;
      _descricaoController.text = item.descricao;
      setState(() {
        _fotoExistente = item.foto;
        _collectionId = item.collectionId;
        _tokenFoto = token;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _falhaCarga = 'Não foi possível abrir a solicitação.';
      });
    }
  }

  Future<void> _tirarFoto() async {
    try {
      final arquivo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (arquivo == null || !mounted) return;
      final bytes = await arquivo.readAsBytes();
      if (!mounted) return;
      setState(() {
        _fotoBytes = bytes;
        _erroFoto = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir a câmera. Verifique a permissão e tente de novo.',
          ),
        ),
      );
    }
  }

  Future<void> _salvar() async {
    setState(() {
      _erro = null;
      _erroFoto = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final semFoto = _fotoBytes == null &&
        (_fotoExistente == null || _fotoExistente!.isEmpty);
    if (semFoto) {
      setState(() => _erroFoto = 'Tire uma foto para anexar à solicitação.');
      return;
    }

    final usuario = AppState.instance.sessao.usuarioAtual;
    if (usuario == null) return;

    setState(() => _salvando = true);

    try {
      final String? erro;
      if (!_edicao) {
        final posicao = await obterLocalizacaoAtual();
        erro = await AppState.instance.solicitacoes.criar(
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          foto: _fotoBytes!,
          usuario: usuario,
          latitude: posicao.latitude,
          longitude: posicao.longitude,
        );
      } else {
        erro = await AppState.instance.solicitacoes.atualizar(
          id: widget.solicitacaoId!,
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          foto: _fotoBytes,
        );
      }

      if (!mounted) return;
      if (erro != null) {
        setState(() {
          _salvando = false;
          _erro = erro;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.red.shade700),
        );
        return;
      }

      if (_edicao) {
        context.go('/solicitacoes/${widget.solicitacaoId}');
      } else {
        context.go('/');
      }
    } on LocalizacaoException catch (e) {
      _mostrarErro(e.mensagem);
    } on TimeoutException {
      _mostrarErro('Não foi possível obter a localização. Tente novamente.');
    } catch (_) {
      _mostrarErro('Não foi possível salvar a solicitação.');
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    setState(() {
      _salvando = false;
      _erro = mensagem;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red.shade700),
    );
  }

  void _voltar() {
    if (_edicao) {
      context.go('/solicitacoes/${widget.solicitacaoId}');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: _salvando ? null : _voltar,
        ),
        title: Text(
          _edicao ? 'Editar Solicitação' : 'Nova Solicitação',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _salvando || _carregando || _semPermissao ? null : _salvar,
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
            ),
            child: _salvando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_edicao ? 'Salvar' : 'Cadastrar'),
          ),
        ],
      ),
      body: AppBackground(
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : _semPermissao
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Só quem criou a solicitação pode editá-la.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _falhaCarga != null
                    ? Center(child: Text(_falhaCarga!))
                    : Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Card(
                              elevation: 0,
                              color: colors.surface.withValues(alpha: 0.94),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: colors.outlineVariant),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextFormField(
                                        controller: _tituloController,
                                        decoration: const InputDecoration(
                                          labelText: 'Título',
                                          hintText: 'Ex: Buraco na quadra',
                                          prefixIcon: Icon(Icons.title),
                                        ),
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Informe o título.';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _descricaoController,
                                        decoration: const InputDecoration(
                                          labelText: 'Descrição',
                                          hintText:
                                              'Descreva o que precisa de atendimento',
                                          prefixIcon: Icon(Icons.notes),
                                          alignLabelWithHint: true,
                                        ),
                                        minLines: 4,
                                        maxLines: 8,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Informe a descrição.';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      OutlinedButton.icon(
                                        onPressed:
                                            _salvando ? null : _tirarFoto,
                                        icon: const Icon(Icons.photo_camera),
                                        label: const Text('Tirar Foto'),
                                      ),
                                      if (_erroFoto != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          _erroFoto!,
                                          style: TextStyle(color: colors.error),
                                        ),
                                      ],
                                      if (_fotoBytes != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Image.memory(
                                              _fotoBytes!,
                                              height: 220,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      else if (_fotoExistente != null &&
                                          _fotoExistente!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          child: _FotoExistente(
                                            solicitacaoId:
                                                widget.solicitacaoId!,
                                            collectionId: _collectionId ?? '',
                                            arquivo: _fotoExistente!,
                                            token: _tokenFoto,
                                          ),
                                        ),
                                      if (_erro != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          _erro!,
                                          style: TextStyle(color: colors.error),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
      ),
    );
  }
}

class _FotoExistente extends StatelessWidget {
  final String solicitacaoId;
  final String collectionId;
  final String arquivo;
  final String? token;

  const _FotoExistente({
    required this.solicitacaoId,
    required this.collectionId,
    required this.arquivo,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final url = AppState.instance.pb.files
        .getURL(
          RecordModel({
            'id': solicitacaoId,
            'collectionId': collectionId,
            'collectionName': 'solicitacoes',
          }),
          arquivo,
          token: token,
        )
        .toString();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox(
          height: 120,
          child: Center(child: Text('Não foi possível exibir a foto.')),
        ),
      ),
    );
  }
}
