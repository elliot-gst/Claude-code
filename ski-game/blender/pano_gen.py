# Panorama de montagnes rendu par Cycles dans Blender : bande d'horizon équirectangulaire (latitude -12° à +30°),
# ciel transparent (le ciel procédural du jeu — étoiles, lune, nuages — reste visible au-dessus des crêtes).
# Relief : bruit fractal à crêtes (numpy), vallée du domaine skiable au centre qui s'ouvre vers l'aval.
# Repère : Blender z en haut ; l'aval du jeu (+z) correspond à -y Blender ; l'image est centrée sur l'aval, +x du jeu au quart gauche.
# Usage : bl/bin/python pano_gen.py day|night sortie.png [largeur] [marqueurs]
import bpy, math, sys
import numpy as np
from mathutils import Vector

mode, out = sys.argv[1], sys.argv[2]
WPX = int(sys.argv[3]) if len(sys.argv) > 3 else 4096
markers = len(sys.argv) > 4
LAT0, LAT1 = -12.0, 30.0
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene

# ---------- relief
rg = np.random.default_rng(7)
LATT = rg.random((257, 257)).astype(np.float64); LATT[256, :] = LATT[0, :]; LATT[:, 256] = LATT[:, 0]  # réseau périodique : pas de cassure au passage de zéro
def vnoise(x, y):
    xi = np.floor(x).astype(np.int64); yi = np.floor(y).astype(np.int64); fx = x - xi; fy = y - yi
    u = fx * fx * (3 - 2 * fx); v = fy * fy * (3 - 2 * fy); xi &= 255; yi &= 255
    a = LATT[xi, yi]; b = LATT[xi + 1, yi]; c = LATT[xi, yi + 1]; d = LATT[xi + 1, yi + 1]
    return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v
def ridged(x, y, octaves=8):
    s = np.zeros_like(x); amp = 1.0; w = np.ones_like(x)
    for _ in range(octaves):
        k = 1 - np.abs(vnoise(x, y) * 2 - 1); k = k * k * w; w = np.clip(k * 1.8, 0, 1); s += k * amp; amp *= 0.5
        x = x * 2.03 + 5.3; y = y * 2.03 + 1.7
    return s

N, S = 1000, 22000.0
xs = np.linspace(-S / 2, S / 2, N); X, Y = np.meshgrid(xs, xs, indexing='xy')
R = np.hypot(X, Y)
m = np.clip((R - 1100) / 2600, 0, 1); m = m * m * (3 - 2 * m)                 # vallée plate au centre
ang = np.arctan2(X, -Y)                                                       # 0 = vers l'aval
valley = np.exp(-(ang / 0.5) ** 2) * np.clip(1 - R / 15000, 0, 1)            # la vallée descend vers l'aval
peaks = np.exp(-((ang - math.pi) / 0.9) ** 2)                                 # sommets plus hauts en amont
Hgt = (ridged(X / 3000, Y / 3000) * 1050 - 260) * m * (1 - 0.7 * valley) * (1 + 0.45 * peaks) + 0.025 * R
Hgt = np.maximum(Hgt, -40.0)

# couleurs par sommet : forêt en bas, neige sur les pentes douces, roche dans les raides
gx = np.gradient(Hgt, xs, axis=1); gy = np.gradient(Hgt, xs, axis=0); nz = 1 / np.sqrt(1 + gx * gx + gy * gy)
jit = vnoise(X / 140, Y / 140) * 0.22 - 0.11
# hiver : neige partout sauf la roche raide ; forêts en taches sur les pentes basses (sapins chargés de neige vus de loin)
snow = np.clip((nz + jit - 0.58) / 0.14, 0, 1)
patch = np.clip((vnoise(X / 900 + 40, Y / 900 + 7) - 0.42) / 0.12, 0, 1)
forest = np.clip((nz - 0.78) / 0.08, 0, 1) * np.clip((0.995 - nz) / 0.02, 0, 1) * np.clip((420 - Hgt + jit * 300) / 150, 0, 1) * patch
SNOW, ROCK, FOREST = np.array([0.86, 0.89, 0.94]), np.array([0.13, 0.12, 0.115]), np.array([0.05, 0.075, 0.06])
col = ROCK * (1 - snow[..., None]) + SNOW * snow[..., None]
col = col * (1 - 0.85 * forest[..., None]) + (FOREST * 0.7 + SNOW * 0.3) * 0.85 * forest[..., None]

# ---------- maillage (foreach_set : rapide pour ~800 000 sommets)
me = bpy.data.meshes.new('relief')
nv = N * N; me.vertices.add(nv)
me.vertices.foreach_set('co', np.stack([X.ravel(), Y.ravel(), Hgt.ravel()], 1).astype(np.float32).ravel())
ii, jj = np.meshgrid(np.arange(N - 1), np.arange(N - 1), indexing='xy'); a = (jj * N + ii).ravel()
quads = np.stack([a, a + 1, a + N + 1, a + N], 1).astype(np.int32)
nf = len(quads); me.loops.add(nf * 4); me.polygons.add(nf)
me.loops.foreach_set('vertex_index', quads.ravel())
me.polygons.foreach_set('loop_start', (np.arange(nf) * 4).astype(np.int32)); me.polygons.foreach_set('loop_total', np.full(nf, 4, np.int32))
me.update(); me.validate()
ca = me.color_attributes.new('Col', 'FLOAT_COLOR', 'POINT')
ca.data.foreach_set('color', np.concatenate([col.reshape(-1, 3), np.ones((nv, 1))], 1).astype(np.float32).ravel())
me.shade_smooth() if hasattr(me, 'shade_smooth') else None
ob = bpy.data.objects.new('relief', me); sc.collection.objects.link(ob)

# ---------- matériau : couleur de sommet + voile atmosphérique selon la distance à la caméra
srgb2lin = lambda c: tuple(((x / 255 + 0.055) / 1.055) ** 2.4 for x in c)
haze = srgb2lin((0xdd, 0xe8, 0xf2)) if mode == 'day' else srgb2lin((0x22, 0x31, 0x56))
mat = bpy.data.materials.new('relief'); mat.use_nodes = True; nt = mat.node_tree; me.materials.append(mat)
bsdf = nt.nodes['Principled BSDF']; bsdf.inputs['Roughness'].default_value = 0.92
vc = nt.nodes.new('ShaderNodeVertexColor'); vc.layer_name = 'Col'; nt.links.new(vc.outputs['Color'], bsdf.inputs['Base Color'])
camd = nt.nodes.new('ShaderNodeCameraData'); mth = nt.nodes.new('ShaderNodeMath'); mth.operation = 'MULTIPLY'; mth.inputs[1].default_value = -1 / (8500 if mode == 'day' else 6000)
ex = nt.nodes.new('ShaderNodeMath'); ex.operation = 'EXPONENT'; inv = nt.nodes.new('ShaderNodeMath'); inv.operation = 'SUBTRACT'; inv.inputs[0].default_value = 1.0
nt.links.new(camd.outputs['View Distance'], mth.inputs[0]); nt.links.new(mth.outputs[0], ex.inputs[0]); nt.links.new(ex.outputs[0], inv.inputs[1])
em = nt.nodes.new('ShaderNodeEmission'); em.inputs['Color'].default_value = (*haze, 1); em.inputs['Strength'].default_value = 1.0
mix = nt.nodes.new('ShaderNodeMixShader'); nt.links.new(inv.outputs[0], mix.inputs['Fac']); nt.links.new(bsdf.outputs[0], mix.inputs[1]); nt.links.new(em.outputs[0], mix.inputs[2])
nt.links.new(mix.outputs[0], nt.nodes['Material Output'].inputs['Surface'])

# ---------- lumières : soleil du jeu (jour) ou lune (nuit) ; ambiance du ciel
def g2b(v): return Vector((v[0], -v[2], v[1])).normalized()   # repère du jeu -> Blender
sun_dir = g2b((-0.6, 0.45, 0.6)) if mode == 'day' else g2b((-0.35, 0.38, 0.86))
lamp = bpy.data.objects.new('astre', bpy.data.lights.new('astre', 'SUN')); sc.collection.objects.link(lamp)
lamp.rotation_mode = 'QUATERNION'; lamp.rotation_quaternion = (-sun_dir).to_track_quat('-Z', 'Y')
lamp.data.angle = math.radians(1.0)
if mode == 'day': lamp.data.energy, lamp.data.color = 4.2, (1.0, 0.95, 0.88)
else: lamp.data.energy, lamp.data.color = 0.55, (0.62, 0.72, 1.0)
world = bpy.data.worlds.new('ciel'); world.use_nodes = True; sc.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.42, 0.56, 0.85, 1) if mode == 'day' else (0.018, 0.028, 0.06, 1)
bg.inputs['Strength'].default_value = 0.75 if mode == 'day' else 1.0

if markers: # repères d'orientation : rouge vers l'aval (+z jeu), vert vers +x jeu
    for pos, c in [((0, -3000, 0), (1, 0, 0, 1)), ((3000, 0, 0), (0, 1, 0, 1))]:
        bpy.ops.mesh.primitive_cylinder_add(radius=120, depth=3000, location=(pos[0], pos[1], 1500)); o = bpy.context.active_object
        mm = bpy.data.materials.new('mk'); mm.use_nodes = True; e = mm.node_tree.nodes.new('ShaderNodeEmission'); e.inputs['Color'].default_value = c
        mm.node_tree.links.new(e.outputs[0], mm.node_tree.nodes['Material Output'].inputs['Surface']); o.data.materials.append(mm)

# ---------- caméra panoramique au fond de la vallée
cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam')); sc.collection.objects.link(cam); sc.camera = cam
cam.location = (0, 0, 70); cam.rotation_euler = (math.pi / 2, 0, math.pi)  # centre de l'image = l'aval, raccord derrière le joueur
cd = cam.data; cd.type = 'PANO'; cd.panorama_type = 'EQUIRECTANGULAR'
cd.latitude_min, cd.latitude_max = math.radians(LAT0), math.radians(LAT1); cd.longitude_min, cd.longitude_max = -math.pi, math.pi
cd.clip_end = 40000
sc.render.engine = 'CYCLES'; sc.cycles.device = 'CPU'; sc.cycles.samples = 40
try: sc.cycles.use_denoising = True
except Exception: pass
sc.render.film_transparent = True
sc.render.resolution_x = WPX; sc.render.resolution_y = int(round(WPX * (LAT1 - LAT0) / 360)); sc.render.resolution_percentage = 100
try: sc.view_settings.view_transform = 'Standard'
except Exception as e: print('view transform', e)
sc.render.image_settings.file_format = 'PNG'; sc.render.image_settings.color_mode = 'RGBA'
sc.render.filepath = out
bpy.ops.render.render(write_still=True)
print('panorama', mode, sc.render.resolution_x, 'x', sc.render.resolution_y, 'hauteur max', float(Hgt.max()))
