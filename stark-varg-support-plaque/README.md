# Support de plaque rétractable – Stark Varg EX/SM

![déployé / replié](apercu.png)

Inspiré du *retractable plateholder* FL Specialparts : le support fixe garde les clignotants et l'éclairage de plaque, seule la plaque pivote de 0° (déployée) à 180° (repliée sous le garde-boue).

- `support_fixe.stl` (226 × 78 mm), avec :
  - 2 lumières M6 pour la fixation au garde-boue (entraxe réglable de 30 à 70 mm) ;
  - 2 trous Ø10,5 pour les clignotants à tige Ø10 (entraxe 200 mm) ;
  - 2 lumières M4 pour l'éclairage de plaque.
- `porte_plaque.stl` : dos de plaque 210 × 130 mm (format moto FR), avec 4 trous Ø4,5 pour rivets ou vis M4.
- `support_plaque_pliable.scad` : modèle paramétrique (OpenSCAD ou Parametric Model Maker de MakerWorld).

## Quincaillerie
- Vis M5 × 70, 2 rondelles et 1 écrou nylstop pour l'axe. Le serrage de l'écrou règle la friction.
- 1 piston à bille M6 (~15 mm), vissé directement dans le trou Ø5,2 du charnon droit. Il donne des crans à 0°, 90° et 180°.

## Impression (Bambu Lab X1 / P1 / A1, plateau 256 mm)
- Matière : **PETG ou ASA**.
- Les pièces s'impriment à plat, telles quelles, sans supports.
- 4 parois, 30 % de remplissage gyroïde.
- L'A1 mini (180 mm) est trop petite : réduis `cligno_entraxe` et `plaque_l`.

## À vérifier sur la moto
- Mesure l'entraxe des points de fixation du support de plaque d'origine.
- Vérifie l'espace sous le garde-boue pour la plaque repliée. Comme pour le modèle du commerce, le garde-boue inférieur devra probablement être découpé.
- Vérifie l'écartement légal des clignotants.
