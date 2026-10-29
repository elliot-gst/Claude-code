// Support de plaque rétractable - Stark Varg EX (version EU)
// Garde le feu arrière d'origine dans le garde-boue. Le support fixe reçoit :
//   - les 2 clignotants EU d'origine (3 en 1 : clignotant + position + stop),
//   - l'éclairage de plaque d'origine (sous le "nez", face à la plaque),
//   - le catadioptre d'origine (dos du nez).
// Seule la plaque pivote : 0° déployée (bloquée par goupille, position route),
// 90° repliée à plat sous le garde-boue (tout-terrain).
// Repères : X latéral, Y vers l'avant, Z vers le bas depuis la face d'appui
// (repère d'impression du support : face d'appui sur le plateau).

part = "assemblage"; // [assemblage, support_fixe, bras, porte_plaque, gabarit]
pliage = 0;          // [0:90] angle de l'aperçu

/* [Fixation sur le garde-boue] */
fix_d   = 6.5;  // vis Delta 6 d'origine (support d'homologation)
fix_min = 30;   // lumières : entraxe mini
fix_max = 60;   // entraxe maxi
fix_y   = 40;   // distance axe / vis, vers l'avant
base_ep = 6;
axe_bas = 42;   // face d'appui / axe de pivot
angle_deploye = 0; // [-30:30] corrige la pente du garde-boue : plaque verticale sur la moto

/* [Clignotants EU d'origine] */
cligno_d = 10.5;      // tige Ø10 (8.5 si M8)
cligno_ecart = 140;   // entre faces extérieures des pattes (bords éclairés ≥ 180 mm)
cligno_z = 24;        // hauteur des tiges sous la face d'appui
passe_fil = 7;        // passage des fils vers l'intérieur du nez

/* [Éclairage de plaque et catadioptre] */
nez_l    = 84;   // largeur du nez
nez_long = 46;   // recul du dos du nez derrière l'axe
nez_h    = 34;   // hauteur du dos (catadioptre)
paroi    = 3;
eclairage_entraxe = 0;  // 0 = percer au gabarit de l'éclairage ; sinon entraxe des vis
eclairage_trou = 2.2;   // Ø avant-trou vis Delta 2,5 d'origine
catadioptre_d = 5.3;    // trou central du catadioptre (0 = collé)

/* [Plaque] */
plaque_l = 210;    // plaque moto FR
plaque_h = 130;
marge    = 1;      // dos de plaque invisible derrière la plaque
plaque_recul = 15; // axe / haut de plaque
dos_ep   = 3;
nervure_h = 4;
rivet_d  = 4.2;    // rivets Ø4 (fixation inamovible obligatoire)

/* [Pivot et blocage] */
axe_d   = 5.4;     // vis M5x60 + nylstop
R       = 12;      // rayon du moyeu
joue_R  = 14;
joue_ep = 8;
moyeu_l = 33.2;
jeu     = 0.4;
bras_ep = 6;
vis_d   = 5.4;     // 3 vis M5 bras / plaque
triangle = [[-14, -38], [14, -38], [0, -62]];
col_y   = -18;     // le bras s'élargit au-delà des joues
goupille_d = 5.3;  // goupille à bille Ø5 x 50
goupille_r = 8;

/* [Hidden] */
$fn = 72;
ep_tot = dos_ep + nervure_h;
xj = moyeu_l / 2 + jeu;           // face intérieure des joues
W  = 2 * (xj + joue_ep);          // 50 mm hors tout
pad_x = cligno_ecart / 2 - 8;     // face intérieure des pattes de clignotant
pad_y = -30;                      // position des tiges (Y)
// éclairage : milieu de la pente du nez, normale vers la plaque
nz = [[-13, 0], [-nez_long, 0], [-nez_long, nez_h], [-nez_long + 6, nez_h], [-14, 8]];
ecl_p = [(nz[3][0] + nz[4][0]) / 2, (nz[3][1] + nz[4][1]) / 2];
ecl_a = atan2(nz[3][1] - nz[4][1], nz[4][0] - nz[3][0]); // pente (°)

module yz() rotate([90, 0, 90]) children(); // 2D (Y,Z) extrudé selon X

// ---------------- support fixe ----------------
module joue()
    yz() linear_extrude(joue_ep) hull() {
        translate([0, axe_bas]) circle(joue_R);
        translate([-joue_R, 0]) square([2 * joue_R + 20, base_ep]);
    }

module nez() // coque ouverte côté garde-boue : connecteurs cachés dedans
    translate([-nez_l / 2, 0, 0]) difference() {
        yz() linear_extrude(nez_l) polygon(nz);
        translate([paroi, 0, 0]) yz() linear_extrude(nez_l - 2 * paroi) {
            offset(delta = -paroi) polygon(nz);
            translate([-nez_long + paroi, -1]) square([nez_long - 17 - paroi, paroi + 1.01]);
        }
    }

module aile(s) { // bras de clignotant + patte verticale (face intérieure libre pour l'écrou)
    px = s > 0 ? pad_x : -pad_x - 8;
    hull() {
        translate([s > 0 ? nez_l / 2 - 1 : -nez_l / 2 - 13, pad_y - 12, 0]) cube([14, 24, 14]);
        translate([px, pad_y - 12, 0]) cube([8, 24, 8]);
    }
    translate([px, 0, 0]) yz() linear_extrude(8) hull() {
        translate([pad_y - 12, 0]) square([24, 8]);
        translate([pad_y, cligno_z]) circle(12);
    }
}

module support_fixe() {
    difference() {
        union() {
            linear_extrude(base_ep) hull() {
                translate([-W / 2, -joue_R]) square([W, 2 * joue_R]);
                for (s = [-1, 1]) translate([s * fix_max / 2, fix_y]) circle(8);
            }
            for (s = [-1, 1]) {
                translate([s > 0 ? xj : -xj - joue_ep, 0, 0]) joue();
                aile(s);
            }
            nez();
        }
        // axe, goupille de blocage
        translate([-W, 0, axe_bas]) rotate([0, 90, 0]) cylinder(d = axe_d, h = 2 * W);
        translate([-W, 0, axe_bas - goupille_r]) rotate([0, 90, 0]) cylinder(d = goupille_d, h = 2 * W);
        // fixation
        for (s = [-1, 1]) hull() for (x = [fix_min / 2, fix_max / 2])
            translate([s * x, fix_y, -1]) cylinder(d = fix_d, h = base_ep + 2);
        // clignotants + passage des fils dans le nez
        for (s = [-1, 1]) translate([s > 0 ? pad_x - 1 : -pad_x - 9, pad_y, cligno_z]) rotate([0, 90, 0])
            cylinder(d = cligno_d, h = 10);
        translate([-nez_l / 2 - 1, pad_y, 19]) rotate([0, 90, 0]) cylinder(d = passe_fil, h = nez_l + 2);
        // éclairage de plaque : fil vers le haut, vis perpendiculaires à la pente
        translate([0, ecl_p[0], -1]) cylinder(d = passe_fil, h = ecl_p[1] + 2);
        if (eclairage_entraxe > 0) for (s = [-1, 1])
            translate([s * eclairage_entraxe / 2, ecl_p[0], ecl_p[1]]) rotate([ecl_a - 90, 0, 0])
                translate([0, 0, -1]) cylinder(d = eclairage_trou, h = 12, center = true);
        // catadioptre
        if (catadioptre_d > 0) translate([0, -nez_long + paroi + 1, nez_h / 2]) rotate([90, 0, 0])
            cylinder(d = catadioptre_d, h = paroi + 2);
    }
}

// gabarit de 2 mm : vérifie les vis et l'encombrement avant la grosse impression
module gabarit() linear_extrude(2) projection() support_fixe();

// ---------------- bras (imprimé à plat, axe en y=0 z=R) ----------------
module bras()
    difference() {
        union() {
            hull() {
                translate([-moyeu_l / 2, 0, R]) rotate([0, 90, 0]) cylinder(r = R, h = moyeu_l);
                translate([-moyeu_l / 2, col_y - 1, 0]) cube([moyeu_l, 2, bras_ep]);
            }
            hull() {
                translate([-moyeu_l / 2, col_y - 1, 0]) cube([moyeu_l, 2, bras_ep]);
                for (p = triangle) translate([p[0], p[1], 0]) cylinder(r = 8, h = bras_ep);
            }
        }
        translate([-moyeu_l, 0, R]) rotate([0, 90, 0]) cylinder(d = axe_d, h = 2 * moyeu_l);
        for (p = triangle) translate([p[0], p[1], -1]) cylinder(d = vis_d, h = 3 * R);
        // trous de goupille : déployée et repliée
        for (a = [angle_deploye, 90])
            translate([-moyeu_l, goupille_r * cos(a), R + goupille_r * sin(a)]) rotate([0, 90, 0])
                cylinder(d = goupille_d, h = 2 * moyeu_l);
    }

// ---------------- porte-plaque (imprimé face avant sur le plateau) ----------------
module porte_plaque() {
    y1 = -plaque_recul;              // haut de la plaque
    yc = y1 - plaque_h / 2;
    l = plaque_l - 2 * marge;
    h = plaque_h - 2 * marge;
    difference() {
        union() {
            translate([-l / 2, yc - h / 2, 0]) cube([l, h, dos_ep]);
            translate([0, yc, 0]) {
                difference() {
                    translate([-l / 2, -h / 2, 0]) cube([l, h, ep_tot]);
                    translate([-l / 2 + 3, -h / 2 + 3, -1]) cube([l - 6, h - 6, ep_tot + 2]);
                }
                translate([-1.5, -h / 2, 0]) cube([3, h, ep_tot]);
                translate([-l / 2, -1.5, 0]) cube([l, 3, ep_tot]);
            }
            hull() for (p = triangle) translate([p[0], p[1], 0]) cylinder(r = 9, h = ep_tot);
        }
        for (p = triangle) translate([p[0], p[1], -1]) cylinder(d = vis_d, h = ep_tot + 2);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (plaque_l / 2 - 15), yc + sy * (plaque_h / 2 - 15), -1])
                cylinder(d = rivet_d, h = ep_tot + 2);
    }
}

// bras + plaque dans le repère du support, plié de a° vers l'avant
module mobile(a)
    translate([0, 0, axe_bas]) rotate([-a, 0, 0]) rotate([-90, 0, 0]) translate([0, 0, -R]) {
        bras();
        translate([0, 0, -ep_tot]) porte_plaque();
        if (part == "assemblage") translate([-plaque_l / 2, -plaque_recul - plaque_h, -ep_tot - 1.5]) { // plaque
            color("white") cube([plaque_l, plaque_h, 1.5]);
            color("black") translate([plaque_l / 2, plaque_h / 2, -0.3]) mirror([1, 0, 0])
                linear_extrude(0.5) text("AB-123-CD", size = 22, halign = "center", valign = "center");
        }
    }

// pièces d'origine figurées (aperçu seulement)
module origine() {
    for (s = [-1, 1]) translate([s * (cligno_ecart / 2), pad_y, cligno_z]) {
        color("dimgray") rotate([0, s * 90, 0]) cylinder(d = 10, h = 16);
        color("orange") translate([s > 0 ? 16 : -86, -9, -7]) cube([70, 18, 14]);
    }
    color("ivory") translate([0, ecl_p[0], ecl_p[1]]) rotate([ecl_a - 90, 0, 0]) translate([-30, -12, 0]) cube([60, 24, 12]);
    color("red") translate([-37, -nez_long - 5, nez_h / 2 - 13]) cube([74, 5, 26]);
}

if (part == "support_fixe") support_fixe();
else if (part == "bras") bras();
else if (part == "porte_plaque") porte_plaque();
else if (part == "gabarit") gabarit();
else rotate([0, 180, 0]) { support_fixe(); mobile(pliage); origine(); } // vue sur la moto
