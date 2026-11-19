# Modèles Blender du jeu

Scripts Blender (module Python `bpy` 5.3) qui fabriquent les modèles embarqués dans `index.html`.

- `tree_gen.py` : sapin enneigé (branches tombantes, neige sur le dessus, occlusion ambiante cuite par Cycles dans les couleurs de sommets), exporté en binaire compact.
  - `python tree_gen.py 11 tree_a.bin - 1.0` (variante A)
  - `python tree_gen.py 23 tree_b.bin - 0.8` (variante B, plus élancée)
- `pano_gen.py` : panorama de montagnes rendu par Cycles (bande d'horizon équirectangulaire de -12° à +30°, ciel transparent).
  - `python pano_gen.py day pano_day.png 4096` puis `python pano_gen.py night pano_night.png 4096`
  - converties ensuite en WebP (qualité 88) et embarquées en base64.

Installation : `uv venv bl && uv pip install --python bl/bin/python bpy numpy`.
