import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../formatacao.dart';
import '../tema.dart';
import '../widgets/app_background.dart';

class SolicitacoesPage extends StatefulWidget {
  const SolicitacoesPage({super.key});

  @override
  State<SolicitacoesPage> createState() => _SolicitacoesPageState();
}

class _SolicitacoesPageState extends State<SolicitacoesPage> {
  @override
  void initState() {
    super.initState();
    AppState.instance.solicitacoes.carregar();
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = AppState.instance.solicitacoes;

    return AnimatedBuilder(
      animation: repositorio,
      builder: (context, _) {
        final itens = repositorio.itens;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Solicitações Públicas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: azulEscuro,
            foregroundColor: Colors.white,
            surfaceTintColor: azulEscuro,
            actions: [
              IconButton(
                tooltip: 'Sair',
                icon: const Icon(Icons.logout),
                onPressed: () {
                  AppState.instance.sessao.logout();
                  context.go('/login');
                },
              ),
              IconButton(
                tooltip: 'Adicionar',
                icon: const Icon(Icons.add),
                onPressed: () => context.go('/solicitacoes/nova'),
              ),
            ],
          ),
          body: AppBackground(
            child: repositorio.carregando && itens.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: repositorio.carregar,
                    child: repositorio.erro != null && itens.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 80),
                              Text(
                                repositorio.erro!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: repositorio.carregar,
                                  child: const Text('Tentar de novo'),
                                ),
                              ),
                            ],
                          )
                        : itens.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(24),
                                children: const [
                                  SizedBox(height: 120),
                                  Text(
                                    'Ainda não há solicitações realizadas',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: itens.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = itens[index];
                                  return Card(
                                    elevation: 0,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant,
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        item.titulo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(formatarData(item.criadaEm)),
                                      onTap: () => context
                                          .go('/solicitacoes/${item.id}'),
                                    ),
                                  );
                                },
                              ),
                  ),
          ),
        );
      },
    );
  }
}
