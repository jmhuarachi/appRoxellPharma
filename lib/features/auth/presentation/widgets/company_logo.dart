// lib/screens/auth/widgets/company_logo.dart
import 'package:flutter/material.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contenedor principal para "LABORATORIOS" y "roxell"
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Columna para "LABORATORIOS" y "roxe"
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texto "LABORATORIOS"
                Text(
                  'LABORATORIOS',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2,
                    height: 0.1,
                  ),
                ),
                
                // Texto "roxe"
                Text(
                  'roxe',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.orange500,
                    fontFamily: 'Bauhaus93',
                    height: 0.9,
                  ),
                ),
              ],
            ),
            
            // Texto "ll"
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Text(
                'll',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w400,
                  color: AppColors.orange500,
                  fontFamily: 'Bauhaus93',
                  height: 0.8,
                ),
              ),
            ),
            
            // Símbolo de registro
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Text(
                '®',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange400,
                ),
              ),
            ),
          ],
        ),
        
        // Texto "PHARMA S.R.L."
        Container(
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.orange600, AppColors.orange500],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'PHARMA ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'BerlinSansFB', 
                  ),
                ),
                TextSpan(
                  text: 'S.R.L.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'BerlinSansFB',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}