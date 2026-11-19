// MICROINTERACCIÓN: ESCALA AL PULSAR

// Envuelve cualquier widget para que se "hunda" un poco (escala 0.95)
// mientras el dedo está encima. Es un detalle pequeño que hace que la
// app se sienta mucho más viva y responda al tacto.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Pulsable extends StatefulWidget {
  const Pulsable({
    super.key,
    required this.child,
    required this.onTap,
    this.etiqueta,
  });

  final Widget child;
  final VoidCallback onTap;
  // Texto para lectores de pantalla (accesibilidad).
  final String? etiqueta;

  @override
  State<Pulsable> createState() => _PulsableState();
}

class _PulsableState extends State<Pulsable> {
  bool _pulsado = false;

  void _cambiar(bool valor) {
    if (_pulsado != valor) setState(() => _pulsado = valor);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.etiqueta,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _cambiar(true),
        onTapUp: (_) => _cambiar(false),
        onTapCancel: () => _cambiar(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pulsado ? 0.95 : 1,
          duration: AppDuraciones.rapida,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
