// Parte superior del archivo decorative_graphics.dart
import 'package:flutter/material.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';

class TopLeftGraphic extends StatelessWidget {
  const TopLeftGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -50,
      left: -100,
      child: SizedBox(
        width: 400,
        height: 300,
        child: CustomPaint(
          painter: _TopLeftCirclePainter(),
        ),
      ),
    );
  }
}

class _TopLeftCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Círculo principal con gradiente usando colores de la paleta
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold300, // Amarillo claro de la paleta
          AppColors.gold500, // Amarillo dorado de la paleta
          AppColors.orange500, // Naranja principal de la paleta
        ],
        stops: const [0.0, 0.6, 1.0],
        center: Alignment.center,
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.4),
        radius: size.width * 0.35,
      ));

    // Dibujar el círculo principal
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.35,
      paint,
    );

    // Borde azul del círculo usando color de la paleta
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = AppColors.blue600; // Azul de la paleta

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.35,
      borderPaint,
    );

    // Pequeño círculo decorativo (brillo)
    final highlightPaint = Paint()
      ..color = AppColors.white.withOpacity(0.6);

    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.25),
      15,
      highlightPaint,
    );

    // Líneas decorativas adicionales con colores de la paleta
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.blue400.withOpacity(0.6);

    // Dibujar líneas decorativas
    final linePath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.2,
        size.width * 0.4, size.height * 0.25,
      )
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.3,
        size.width * 0.6, size.height * 0.35,
      );

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BottomRightGraphic extends StatelessWidget {
  const BottomRightGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -20,
      right: -50,
      child: SizedBox(
        width: MediaQuery.of(context).size.width + 100,
        height: 200,
        child: CustomPaint(
          painter: _BottomWavePainter(),
        ),
      ),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradiente para las ondas usando colores de la paleta
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.gold300, // Amarillo claro de la paleta
          AppColors.gold500, // Amarillo dorado de la paleta
          AppColors.orange500, // Naranja principal de la paleta
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Crear el path de las ondas
    final path = Path();
    
    // Primera onda (más alta)
    path.moveTo(size.width * 0.3, size.height);
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.4,
      size.width * 0.5, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.8,
      size.width * 0.7, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.2,
      size.width * 0.9, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.95, size.height * 0.5,
      size.width, size.height * 0.6,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Segunda onda con gradiente de la paleta
    final paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.orange500, // Naranja principal
          AppColors.orange400, // Naranja claro
          AppColors.gold400, // Amarillo dorado
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path();
    path2.moveTo(size.width * 0.5, size.height);
    path2.quadraticBezierTo(
      size.width * 0.6, size.height * 0.7,
      size.width * 0.7, size.height * 0.8,
    );
    path2.quadraticBezierTo(
      size.width * 0.8, size.height * 0.9,
      size.width * 0.85, size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.9, size.height * 0.5,
      size.width * 0.95, size.height * 0.6,
    );
    path2.quadraticBezierTo(
      size.width * 0.98, size.height * 0.7,
      size.width, size.height * 0.8,
    );
    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);

    // Borde azul para las ondas usando color de la paleta
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = AppColors.blue700; // Azul oscuro de la paleta

    // Dibujar solo el borde superior de la primera onda
    final borderPath = Path();
    borderPath.moveTo(size.width * 0.3, size.height);
    borderPath.quadraticBezierTo(
      size.width * 0.4, size.height * 0.4,
      size.width * 0.5, size.height * 0.6,
    );
    borderPath.quadraticBezierTo(
      size.width * 0.6, size.height * 0.8,
      size.width * 0.7, size.height * 0.5,
    );
    borderPath.quadraticBezierTo(
      size.width * 0.8, size.height * 0.2,
      size.width * 0.9, size.height * 0.4,
    );
    borderPath.quadraticBezierTo(
      size.width * 0.95, size.height * 0.5,
      size.width, size.height * 0.6,
    );

    canvas.drawPath(borderPath, borderPaint);

    // Líneas decorativas adicionales con colores de la paleta
    final decorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.blue500.withOpacity(0.4);

    // Línea decorativa 1
    final decorPath1 = Path()
      ..moveTo(size.width * 0.4, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.7,
        size.width * 0.6, size.height * 0.75,
      );

    // Línea decorativa 2
    final decorPath2 = Path()
      ..moveTo(size.width * 0.6, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.7, size.height * 0.85,
        size.width * 0.8, size.height * 0.95,
      );

    canvas.drawPath(decorPath1, decorPaint);
    canvas.drawPath(decorPath2, decorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
