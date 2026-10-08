import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../pages/cadastro_page.dart';
import '../pages/login_page.dart';
import '../pages/solicitacao_detalhe_page.dart';
import '../pages/solicitacao_form_page.dart';
import '../pages/solicitacoes_page.dart';
import '../tema.dart';

GoRouter criarAppRouter() {
  final sessao = AppState.instance.sessao;

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: sessao,
    redirect: (context, state) {
      final logado = sessao.estaLogado;
      final path = state.matchedLocation;
      final rotaPublica = path == '/login' || path == '/cadastro';

      if (!logado && !rotaPublica) return '/login';
      if (logado && rotaPublica) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SolicitacoesPage(),
      ),
      GoRoute(
        path: '/solicitacoes/nova',
        builder: (context, state) => const SolicitacaoFormPage(),
      ),
      GoRoute(
        path: '/solicitacoes/:id/editar',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SolicitacaoFormPage(solicitacaoId: id);
        },
      ),
      GoRoute(
        path: '/solicitacoes/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SolicitacaoDetalhePage(solicitacaoId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
        backgroundColor: azulEscuro,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error?.toString() ?? 'Rota inválida'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );
}
