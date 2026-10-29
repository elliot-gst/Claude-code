# Support de plaque rétractable – Stark Varg EX/SM

![déployé / replié](apercu.png)

Inspiré du *retractable plateholder* FL Specialparts (vendu par Movetronix) :
- un support plat se visse sous le garde-boue ;
- deux joues portent l'axe ;
- un bras pivotant tient la plaque par 3 vis en triangle ;
- une platine arrière **fixe** porte le **feu arrière** (avec éclairage de plaque) et les **2 clignotants**. Ils restent en place quand la plaque se replie.

La plaque passe de **déployée (0°)** à **repliée à plat sous le garde-boue (90°)**, avec un cran à chaque position.

| Pièce | Rôle |
|---|---|
| `support_fixe.stl` (244 × 75 mm) | Se fixe sous le garde-boue par 2 lumières M6 (entraxe réglable de 30 à 50 mm). La platine arrière a 2 lumières M5 pour le feu (entraxe de 20 à 60 mm), un passage de fils Ø8 et 2 trous Ø10,5 pour les clignotants, à 220 mm d'entraxe. |
| `bras.stl` | Pivote entre les joues et porte la plaque. |
| `porte_plaque.stl` | Dos de plaque 210 × 130 mm (format moto FR), à boulonner sur le bras. 4 trous Ø4,5 pour riveter la plaque. |
| `support_plaque_pliable.scad` | Modèle paramétrique (OpenSCAD ou Parametric Model Maker de MakerWorld). `part="assemblage"` et `pliage=0..90` affichent l'aperçu. |

## Quincaillerie
- Vis M5 × 70, 2 rondelles et 1 écrou nylstop pour l'axe. Le serrage règle la friction.
- 1 piston à bille M6 (~10 mm), vissé directement dans la joue droite (trou Ø5,2). Il donne les crans à 0° et 90°.
- 3 vis M5 × 20 et 3 écrous nylstop pour fixer la plaque au bras, têtes côté plaque.
- 1 feu arrière LED moto **homologué E** avec éclairage de plaque intégré et 2 goujons M5. S'il n'a pas d'éclairage de plaque, ajoute une petite lampe de plaque homologuée sur les mêmes lumières.
- 2 clignotants LED homologués à tige Ø10. Pour une tige M8, règle `cligno_d = 8.5`. Les clignotants d'origine Stark (3 en 1) ont aussi une tige Ø10.

## Impression (Bambu Lab, sans supports)
- Matière : **PETG ou ASA**.
- Plateau d'au moins 256 mm (X1, P1, A1) pour le support. Sur une A1 mini, réduis `cligno_entraxe`.
- 4 parois, 30 % de remplissage gyroïde.
- Orientation :
  - support : face d'appui sur le plateau, joues et platine vers le haut ;
  - bras : à plat ;
  - porte-plaque : face avant sur le plateau.

## À vérifier sur la moto
- Entraxe des points de fixation sous le feu arrière : paramètres `fix_min` et `fix_max`.
- Hauteur de l'axe sous le support (`axe_bas`, 42 mm) et place pour la plaque repliée. Comme pour le modèle du commerce, le garde-boue inférieur devra probablement être découpé.
- Écartement légal des clignotants arrière (`cligno_entraxe`) et position du feu.
- L'angle déployé est perpendiculaire au support. Si le dessous du garde-boue est incliné, ajuste `crans` (par ex. `[-15, 90]`).
