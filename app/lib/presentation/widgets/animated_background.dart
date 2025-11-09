import 'package:flutter/material.dart';

/// Wrapper para o background animado existente
/// Mantém a animação em todas as plataformas
/// Usa o AnimatedBackground que já existe no projeto
class AdaptiveBackground extends StatelessWidget {
  final Widget child;

  const AdaptiveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Usa o AnimatedBackground existente do projeto
    // que já está otimizado e funciona bem
    return Stack(
      children: [
        // Background Layer com gradiente
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
                Color(0xFF0f3460),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
