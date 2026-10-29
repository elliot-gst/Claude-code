# Contrôle des STL exportés (valeurs par défaut du .scad).
# Usage : python3 verifier.py   (nécessite trimesh + manifold3d)
import numpy as np
import trimesh
from trimesh.transformations import rotation_matrix as Rm, translation_matrix as T

AXE_BAS, R, EP_TOT, GOUPILLE_R = 42, 12, 7, 8
PAD_X, PAD_Y, CLIGNO_Z = 62, -30, 24
PLATEAU = 256  # Bambu X1 / P1 / A1

s, b, p = (trimesh.load(f"{n}.stl") for n in ("support_fixe", "bras", "porte_plaque"))


def M(a):  # repère bras -> repère support, plié de a degrés
    return T([0, 0, AXE_BAS]) @ Rm(np.radians(-a), [1, 0, 0]) @ Rm(np.radians(-90), [1, 0, 0]) @ T([0, 0, -R])


def vol(a, m):
    i = a.intersection(m)
    return 0 if i.is_empty else i.volume


# 1. solides fermés et taille plateau
for n, m in (("support_fixe", s), ("bras", b), ("porte_plaque", p)):
    ext = m.extents
    assert m.is_watertight, n
    assert ext[0] <= PLATEAU and ext[1] <= PLATEAU, (n, ext)
    print(f"{n:13s} {ext[0]:.0f} x {ext[1]:.0f} x {ext[2]:.0f} mm, {m.volume / 1000:.0f} cm3")

# 2. rotation libre de 0 à 90° (plaque alu 1,5 mm comprise)
plaque = trimesh.creation.box(extents=[210, 130, 1.5], transform=T([0, -15 - 65, -EP_TOT - 0.75]))
for a in np.arange(0, 90.1, 2.5):
    v = sum(vol(s, m.copy().apply_transform(M(a) @ t))
            for m, t in ((b, np.eye(4)), (p, T([0, 0, -EP_TOT])), (plaque, np.eye(4))))
    assert v < 0.01, f"collision à {a}°: {v:.1f} mm3"
print("pivot libre de 0 à 90°")

# 3. goupille : passe à 0° et 90°, bloquée entre les deux
goupille = trimesh.creation.cylinder(radius=2.4, height=30,
                                    transform=T([0, 0, AXE_BAS - GOUPILLE_R]) @ Rm(np.pi / 2, [0, 1, 0]))
for a, libre in ((0, True), (45, False), (90, True)):
    assert (vol(b.copy().apply_transform(M(a)), goupille) < 0.01) == libre, a
print("goupille alignée à 0° et 90°")

# 4. écrou de clignotant (M10, Ø20 x 8) libre sur la face intérieure des pattes
for sx in (-1, 1):
    ecrou = trimesh.creation.cylinder(radius=10, height=8,
                                      transform=T([sx * (PAD_X - 4.05), PAD_Y, CLIGNO_Z]) @ Rm(np.pi / 2, [0, 1, 0]))
    assert vol(s, ecrou) < 0.01, sx
print("écrous de clignotants libres")
print("OK")
