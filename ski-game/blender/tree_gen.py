# Sapin enneigé procédural fait dans Blender (bpy) :
#  - tronc effilé, étages de branches en éventail qui retombent (épicéa), neige posée sur le dessus des branches
#  - occlusion ambiante calculée par Cycles et cuite dans les couleurs de sommets (intérieur de l'arbre plus sombre)
#  - export binaire compact pour le jeu : nv, ni, positions f32 (repère du jeu : y en haut), normales i8, couleurs u8, indices u16
# Usage : bl/bin/python tree_gen.py <seed> <sortie.bin> [rendu.png]
import bpy, math, random, struct, sys
import numpy as np

seed, out = int(sys.argv[1]), sys.argv[2]
preview = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '-' else None
slim = float(sys.argv[4]) if len(sys.argv) > 4 else 1.0
rnd = random.Random(seed)
bpy.ops.wm.read_factory_settings(use_empty=True)

V, C, F = [], [], []          # sommets (Blender : z en haut), couleur de base, faces
def v(p, c):
    V.append(p); C.append(c); return len(V) - 1

H = (5.9 + rnd.uniform(-0.3, 0.3)) * (1 + (1 - slim) * 0.5)          # hauteur (le jeu compte ~5,6 m × échelle pour les collisions)
# --- tronc : cylindre effilé à 7 côtés
TR = 7
ring = lambda z, r: [v((r * math.cos(k / TR * math.tau), r * math.sin(k / TR * math.tau), z), (0.22, 0.15, 0.10)) for k in range(TR)]
r0, r1 = ring(0.0, 0.17), ring(H * 0.92, 0.03)
for k in range(TR):
    a, b, c, d = r0[k], r0[(k + 1) % TR], r1[(k + 1) % TR], r1[k]
    F += [(a, b, c), (a, c, d)]

def blade(z0, ang, L, droop, rise, W, green, snowy):
    """Branche en éventail : axe qui monte un peu puis retombe, section en voûte, bords irréguliers ; plaque de neige au-dessus."""
    global F
    d = (math.cos(ang), math.sin(ang)); u = (-d[1], d[0])
    S = [0.0, 0.3, 0.62, 1.0]; Wf = [0.28, 1.0, 0.72, 0.0]
    def axis(s):
        return (d[0] * (0.12 + L * s), d[1] * (0.12 + L * s), z0 + rise * L * s - droop * L * s * s)
    rows = []
    for j, s in enumerate(S):
        cx, cy, cz = axis(s); w = W * Wf[j] * (0.85 + 0.3 * rnd.random())
        dark = 0.72 + 0.28 * s                                  # près du tronc, plus sombre
        col = tuple(ch * dark for ch in green)
        if w < 1e-3:
            rows.append([v((cx, cy, cz), col)]); continue
        arch = 0.16 * w
        L_ = v((cx - u[0] * w / 2 + rnd.uniform(-0.04, 0.04), cy - u[1] * w / 2 + rnd.uniform(-0.04, 0.04), cz - arch - rnd.uniform(0, 0.05)), col)
        C_ = v((cx, cy, cz), col)
        R_ = v((cx + u[0] * w / 2 + rnd.uniform(-0.04, 0.04), cy + u[1] * w / 2 + rnd.uniform(-0.04, 0.04), cz - arch - rnd.uniform(0, 0.05)), col)
        rows.append([L_, C_, R_])
    for j in range(len(rows) - 1):
        a, b = rows[j], rows[j + 1]
        if len(b) == 1:
            F += [(a[0], b[0], a[1]), (a[1], b[0], a[2])]
        else:
            F += [(a[0], b[1], a[1]), (a[0], b[0], b[1]), (a[1], b[2], a[2]), (a[1], b[1], b[2])]
    if not snowy: return
    # neige : plaque irrégulière posée sur le dessus, du tiers intérieur jusqu'aux trois quarts de la branche
    snow = (0.93, 0.95, 0.985)
    s0, s1 = 0.12 + 0.1 * rnd.random(), 0.68 + 0.14 * rnd.random()
    pts = []
    for s in (s0, (s0 + s1) / 2, s1):
        cx, cy, cz = axis(s); j = 1 if s < 0.62 else 2
        w = W * (Wf[1] if s < 0.45 else Wf[2]) * (0.55 + 0.25 * rnd.random()); arch = 0.16 * w
        lift = 0.035 + 0.03 * rnd.random()
        pts.append([v((cx - u[0] * w / 2, cy - u[1] * w / 2, cz - arch * 0.6 + lift), snow), v((cx, cy, cz + lift + 0.02), snow), v((cx + u[0] * w / 2, cy + u[1] * w / 2, cz - arch * 0.6 + lift), snow)])
    for j in range(2):
        a, b = pts[j], pts[j + 1]
        F += [(a[0], b[1], a[1]), (a[0], b[0], b[1]), (a[1], b[2], a[2]), (a[1], b[1], b[2])]

levels = 16
for i in range(levels):
    t = i / (levels - 1)                                         # 0 en bas, 1 en haut
    z0 = 0.75 + (H - 1.15) * t ** 0.95 + rnd.uniform(-0.05, 0.05)
    Lb = (0.25 + 1.75 * (1 - t) ** 1.05) * slim                  # silhouette conique
    nb = max(5, int(round(6 + 4 * (1 - t) + rnd.random())))
    green = rnd.choice([(0.07, 0.15, 0.085), (0.08, 0.165, 0.095), (0.06, 0.135, 0.08), (0.085, 0.16, 0.105)])
    off = rnd.random() * math.tau
    for k in range(nb):
        ang = off + (k + rnd.uniform(-0.25, 0.25)) / nb * math.tau
        L = Lb * (0.82 + 0.32 * rnd.random())
        blade(z0, ang, L, droop=0.42 + 0.25 * (1 - t), rise=0.18, W=0.78 * L + 0.14, green=green, snowy=rnd.random() < 0.92)
# cœur : cône vert foncé autour du tronc (on ne voit plus le tronc entre les étages)
CS = 10; core_b = [v((0.55 * math.cos(k / CS * math.tau), 0.55 * math.sin(k / CS * math.tau), 0.7), (0.045, 0.11, 0.075)) for k in range(CS)]
core_t = v((0, 0, H * 0.97), (0.05, 0.12, 0.08))
for k in range(CS): F.append((core_b[k], core_b[(k + 1) % CS], core_t))
# pointe
tip = v((0, 0, H + 0.35), (0.07, 0.16, 0.11)); base = [v((0.16 * math.cos(k / 4 * math.tau), 0.16 * math.sin(k / 4 * math.tau), H - 0.25), (0.07, 0.16, 0.11)) for k in range(4)]
for k in range(4): F.append((base[k], base[(k + 1) % 4], tip))

me = bpy.data.meshes.new('sapin'); me.from_pydata(V, [], F); me.validate(); me.update()
ob = bpy.data.objects.new('sapin', me); bpy.context.scene.collection.objects.link(ob)
bpy.context.view_layer.objects.active = ob; ob.select_set(True)
# --- occlusion ambiante cuite par Cycles dans un attribut de couleur (par sommet)
mat = bpy.data.materials.new('m'); mat.use_nodes = True; me.materials.append(mat)
ao = me.color_attributes.new('AO', 'FLOAT_COLOR', 'POINT'); me.color_attributes.active_color = ao
sc = bpy.context.scene; sc.render.engine = 'CYCLES'; sc.cycles.device = 'CPU'; sc.cycles.samples = 96
sc.render.bake.target = 'VERTEX_COLORS'
wld = bpy.data.worlds.new('ao'); wld.light_settings.distance = 1.4; sc.world = wld
ground = None
bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 0, -0.02)); ground = bpy.context.active_object   # le sol occulte le bas de l'arbre
bpy.context.view_layer.objects.active = ob; ground.select_set(False); ob.select_set(True)
bpy.ops.object.bake(type='AO')
aoc = np.array([d.color[0] for d in ao.data], dtype=np.float32)

# --- export (repère du jeu : x = x, y = z Blender, z = -y Blender)
me.calc_loop_triangles()
P = np.array([vv.co[:] for vv in me.vertices], dtype=np.float32)
N = np.array([vv.normal[:] for vv in me.vertices], dtype=np.float32)
base = np.array(C, dtype=np.float32)[:len(P)]
col = np.clip(base * (0.32 + 0.78 * aoc[:, None]), 0, 1)
idx = np.array([t.vertices[:] for t in me.loop_triangles], dtype=np.uint16).ravel()
Pg = np.stack([P[:, 0], P[:, 2], -P[:, 1]], 1).astype(np.float32)
Ng = np.stack([N[:, 0], N[:, 2], -N[:, 1]], 1)
with open(out, 'wb') as fh:
    fh.write(struct.pack('<II', len(Pg), len(idx)))
    fh.write(Pg.tobytes())
    fh.write(np.clip(np.round(Ng * 127), -127, 127).astype(np.int8).tobytes())
    fh.write(np.round(col * 255).astype(np.uint8).tobytes())
    if (fh.tell() % 2): fh.write(b'\0')
    fh.write(idx.tobytes())
print(f'sapin {seed}: {len(Pg)} sommets, {len(idx) // 3} triangles, hauteur {H:.2f} m, AO moyen {aoc.mean():.2f}')

if preview:
    # aperçu rendu dans Blender : couleurs finales, soleil rasant, fond bleu nuit
    ca = me.color_attributes.new('Col', 'FLOAT_COLOR', 'POINT')
    for k, c in enumerate(col): ca.data[k].color = (*c, 1.0)
    nt = mat.node_tree; bsdf = nt.nodes['Principled BSDF']; attr = nt.nodes.new('ShaderNodeVertexColor'); attr.layer_name = 'Col'
    nt.links.new(attr.outputs['Color'], bsdf.inputs['Base Color']); bsdf.inputs['Roughness'].default_value = 0.9
    gm = bpy.data.materials.new('g'); gm.use_nodes = True; gm.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (0.9, 0.93, 0.97, 1); ground.data.materials.append(gm)
    sun = bpy.data.objects.new('sun', bpy.data.lights.new('sun', 'SUN')); sun.data.energy = 3.5; sun.rotation_euler = (math.radians(55), 0, math.radians(35)); sc.collection.objects.link(sun)
    w = bpy.data.worlds.new('w'); w.use_nodes = True; w.node_tree.nodes['Background'].inputs['Color'].default_value = (0.35, 0.45, 0.6, 1); w.node_tree.nodes['Background'].inputs['Strength'].default_value = 0.8; sc.world = w
    cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam')); sc.collection.objects.link(cam); sc.camera = cam
    cam.location = (9.5, -9.5, 3.4); cam.rotation_euler = (math.radians(84), 0, math.radians(45))
    sc.render.resolution_x, sc.render.resolution_y = 640, 720; sc.cycles.samples = 48
    sc.render.filepath = preview; bpy.ops.render.render(write_still=True)
