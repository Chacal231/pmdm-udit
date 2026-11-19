// PEQUEÑAS ETIQUETAS DE METADATOS

// Las "chapitas" que acompañan a cada título: la edad recomendada,
// el sello HD, el sello TOP 10 y el porcentaje de coincidencia en verde.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Edad recomendada dentro de un recuadro, por ejemplo "16+".
class BadgeEdad extends StatelessWidget {
  const BadgeEdad(this.edad, {super.key});

  final String edad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspacios.s - 2,
        vertical: AppEspacios.xxs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColores.textoSecundario),
        borderRadius: AppRadios.boton,
      ),
      child: Text(
        edad,
        style: AppTexto.pequeno.copyWith(color: AppColores.texto),
      ),
    );
  }
}

// Sello de alta definición.
class BadgeHD extends StatelessWidget {
  const BadgeHD({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspacios.xs,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColores.textoSecundario),
        borderRadius: AppRadios.boton,
      ),
      child: Text(
        'HD',
        style: AppTexto.pequeno.copyWith(
          color: AppColores.textoSecundario,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// Cuadrado rojo "TOP 10".
class BadgeTop10 extends StatelessWidget {
  const BadgeTop10({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: AppColores.rojo,
        borderRadius: BorderRadius.all(Radius.circular(AppRadios.s / 2)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'TOP\n10',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 8,
          height: 1.05,
          fontWeight: FontWeight.w900,
          color: AppColores.texto,
        ),
      ),
    );
  }
}

// "97 % para ti" en verde.
class TextoCoincidencia extends StatelessWidget {
  const TextoCoincidencia(this.porcentaje, {super.key});

  final int porcentaje;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$porcentaje % para ti',
      style: AppTexto.etiqueta.copyWith(
        color: AppColores.coincidencia,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
