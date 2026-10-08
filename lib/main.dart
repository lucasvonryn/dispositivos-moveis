import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';
import 'tema.dart';

void main() {
  runApp(UtfprSolicitacoesApp(router: criarAppRouter()));
}

class UtfprSolicitacoesApp extends StatelessWidget {
  final GoRouter router;

  const UtfprSolicitacoesApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Solicitações UTFPR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: azulEscuro),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
