# Support de plaque rétractable – Stark Varg EX (EU)

![déployé / replié](apercu.png)

Ce support remplace la partie « plaque » du support d'homologation de l'EX. Il **garde le feu arrière d'origine** dans le garde-boue et réutilise **les clignotants EU d'origine, l'éclairage de plaque et le catadioptre**. Seule la plaque pivote :
- **0°** : déployée et bloquée par une goupille, pour la route ;
- **90°** : repliée à plat sous le garde-boue, pour le tout-terrain.

## Ce qui a été vérifié (sources officielles Stark)

| Élément d'origine EX | Info | Utilisation ici |
|---|---|---|
| Feu arrière (garde-boue) | Feu + stop + clignotants intégrés, fixé par 2 vis Delta 6×14. Les clignotants intégrés ne sont **pas conformes UE**. | Reste en place, rien à démonter. |
| Clignotants EU d'origine | Clignotant + feu de position + stop (3 en 1). Une fois branchés, ils désactivent les clignotants intégrés. | Montés sur les 2 pattes latérales (trou Ø10,5). |
| Éclairage de plaque d'origine | LED, fixé par vis Delta 2,5×10. | Sous le « nez », orienté vers la plaque. |
| Catadioptre arrière d'origine | Obligatoire. | Au dos du nez. |
| Support d'homologation EX | Polypropylène chargé fibre de verre, vissé à l'arrière par 2 vis Delta 6×18 T30 (5 N·m). | Ces 2 points servent à fixer le support fixe. |

## Pièces imprimées

| Fichier | Rôle | Orientation |
|---|---|---|
| `gabarit.stl` | **À imprimer en premier** (2 mm, ~15 min). Il sert à vérifier les vis et l'encombrement sous le garde-boue. | à plat |
| `support_fixe.stl` | 140 × 94 mm. Il porte le pivot, les clignotants, l'éclairage et le catadioptre. Le nez est creux pour cacher les connecteurs. | face d'appui sur le plateau |
| `bras.stl` | Bras pivotant, avec un trou de goupille à 0° et un à 90°. | à plat |
| `porte_plaque.stl` | Dos de plaque 208 × 128 mm, invisible derrière une plaque FR 210 × 130. 4 trous de rivets Ø4,2. | face avant sur le plateau |

- **Matière** : PETG ou ASA.
- **Réglages** : 5 parois et 40 % de remplissage gyroïde pour le support et le bras ; 4 parois et 25 % pour le porte-plaque.
- Pas de supports. Les trous horizontaux peuvent s'affaisser légèrement : repasse un foret si besoin.

## Quincaillerie

- 2 vis Delta PT 6×20 T30 pour fixer le support sur le garde-boue (les 6×18 d'origine conviennent si elles mordent encore d'au moins 10 mm).
- 1 vis M5 × 60, 2 rondelles et 1 écrou nylstop pour l'axe de pivot.
- 1 goupille à bille Ø5 × 50 (goupille de sécurité / push-pull pin), idéalement avec un câble pour ne pas la perdre.
- 3 vis M5 × 20 tête bombée et 3 écrous nylstop pour fixer la plaque au bras.
- 4 rivets Ø4 avec rondelles larges pour la plaque. Le rivetage est obligatoire en France.
- Vis M2,5 + écrous (ou les vis Delta 2,5 d'origine) pour l'éclairage de plaque.
- Écrou M5 pour le catadioptre, s'il a un goujon. Sinon, colle-le.
- Colliers fins pour les fils.

## Mesures à faire sur ta moto avant d'imprimer

Je n'ai trouvé aucune cote publique pour ces points. Les valeurs par défaut sont estimées.

1. **Entraxe des 2 vis** qui tiennent l'arrière du support d'homologation au garde-boue. Paramètres `fix_min` et `fix_max` (par défaut 30 à 60 mm), plus `fix_y`.
2. **Pente du dessous du garde-boue** à cet endroit, mesurée avec l'appli niveau d'un téléphone. Paramètre `angle_deploye`, pour que la plaque soit verticale.
3. **Diamètre de la tige des clignotants EU**. Paramètre `cligno_d` : 10,5 pour Ø10, 8,5 pour M8.
4. **Entraxe des vis de l'éclairage de plaque**. Paramètre `eclairage_entraxe` ; à 0, tu perces au gabarit en te servant de l'éclairage.

Ensuite :
- imprime `gabarit.stl` ;
- présente-le sous le garde-boue ;
- ajuste les paramètres dans `support_plaque_pliable.scad` (OpenSCAD ou Parametric Model Maker de MakerWorld) ;
- relance `python3 verifier.py`.

## Montage

1. Débranche et démonte le support d'homologation. Coupe sa partie arrière (zone de la plaque) pour laisser passer la plaque repliée, comme pour le support FL Specialparts du commerce.
2. Monte les clignotants EU sur les pattes, écrous à l'intérieur. Passe les fils par les trous du nez.
3. Monte l'éclairage sous le nez, fil vers le haut, et le catadioptre au dos.
4. Fais les connexions **dans le nez**, puis visse le support sous le garde-boue.
5. Assemble la plaque :
   - rivete la plaque sur le porte-plaque ;
   - visse le porte-plaque sur le bras avec les 3 vis M5 ;
   - monte le bras entre les joues avec la vis M5 × 60.
6. Mets la goupille en position déployée.

## Légalité (France / UE)

- **Plaque** : 210 × 130 mm, rivetée, inclinée de 30° au plus, éclairée, avec catadioptre.
- **Clignotants arrière** (R53) : au moins **180 mm entre les bords intérieurs des zones éclairées**, entre 350 et 1200 mm du sol, et à 300 mm au plus de l'arrière de la moto. Mesure-le une fois monté et ajuste `cligno_ecart` (140 mm par défaut entre les faces extérieures des pattes).
- **Sur route**, la plaque doit être **déployée et goupillée**. Le support ne doit pas pivoter en roulant.
- **Pièce artisanale** : ce support n'est pas homologué. En cas de contrôle, c'est l'équipement d'origine qui fait foi.
