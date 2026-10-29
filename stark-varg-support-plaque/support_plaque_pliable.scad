// Support de plaque rétractable - Stark Varg EX (version EU)
// Garde le feu arrière d'origine dans le garde-boue. Le support fixe reçoit :
//   - les 2 clignotants EU d'origine (3 en 1 : clignotant + position + stop),
//   - l'éclairage de plaque d'origine (facette sous la coque, face à la plaque),
//   - le catadioptre d'origine (dos de la coque).
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
axe_bas = 42;   // face d'appui / axe de pivot
angle_deploye = 0; // [-30:30] corrige la pente du garde-boue : plaque verticale sur la moto

/* [Clignotants EU d'origine] */
cligno_d = 10.5;      // tige Ø10 (8.5 si M8)
cligno_ecart = 140;   // largeur de la coque aux clignotants (bords éclairés ≥ 180 mm)
cligno_z = 12;        // hauteur des tiges sous la face d'appui

/* [Coque] */
paroi   = 3.5;
arrondi = 3;
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
S  = cligno_ecart / 2;
pad_x = S - paroi;                // face intérieure des flancs (écrous)
pad_y = -29;                      // position des tiges (Y)
// coque = enveloppe de disques (dessus plat) et de sphères (dessous) :
// [x, y, r] sur la face d'appui, [x, y, z, r] dessous (symétrique en X)
dessus  = [[fix_max / 2, fix_y + 2, 12], [S - 8, -16, 8], [S - 8, -42, 8]];
dessous = [[28, fix_y + 4, 7, 6], [S - 8, -16, 22, 8], [S - 8, -42, 22, 8], [26, -26, 26, 8], [26, -42, 30, 8]];
dos_y = -50;
cav_av = 15;                      // la cavité s'arrête ici, l'avant est plein
// éclairage de plaque : dessous arrière, entre les deux dernières sphères, face à la plaque
fc = [dessous[3][1], dessous[3][2]];
fl = [dessous[4][1], dessous[4][2]];
nn = [fl[1] - fc[1], fc[0] - fl[0]] / norm(fl - fc);
ecl_p = (fc + fl) / 2 + 8 * nn;
ecl_a = atan2(-nn[0], nn[1]);     // rotation X : axe Z -> normale

module yz() rotate([90, 0, 90]) children(); // 2D (Y,Z) extrudé selon X

// extrusion à arêtes supérieures arrondies (r), en tranches fines
module rext(h, r, n = 5) {
    linear_extrude(h - r) children();
    for (i = [1:n]) translate([0, 0, h - r + r * (i - 1) / n])
        linear_extrude(r / n + 0.01) offset(delta = -(r - sqrt(r * r - pow(r * i / n, 2)))) children();
}
// dalle centrée en z, arrondie des deux côtés
module rslab(t, r) { rext(t / 2, r) children(); mirror([0, 0, 1]) rext(t / 2, r) children(); }
// congés : OR sur les angles saillants, IR sur les angles rentrants
module round2d(OR, IR) offset(r = OR) offset(r = -IR - OR) offset(r = IR) children();

// ---------------- support fixe : coque ----------------
module corps(e) // e = 0 : extérieur ; e = paroi : cavité ouverte côté garde-boue
    hull() for (sx = [-1, 1]) {
        for (p = dessus) translate([sx * p[0], p[1], e > 0 ? -1 : 0]) cylinder(r = p[2] - e, h = e > 0 ? 1 + e : 0.01);
        for (p = dessous) translate([sx * p[0], p[1], p[2]]) sphere(p[3] - e);
    }

module cavite() intersection() { corps(paroi); translate([-100, -100, -10]) cube([200, 100 + cav_av, 70]); }

module joue() // patte de pivot sous la coque
    yz() rslab(joue_ep, 1.5) hull() {
        translate([0, axe_bas]) circle(joue_R);
        translate([-joue_R, 4]) square([2 * joue_R + 12, 2]);
    }

module support_fixe() {
    difference() {
        union() {
            difference() { corps(0); cavite(); }
            intersection() { // nervures : rigidité + ponts courts à l'impression
                cavite();
                for (y = [-14, 2]) translate([-100, y - 1.25, 0]) cube([200, 2.5, 60]);
                translate([-50, -24 - 1.25, 0]) cube([100, 2.5, 60]); // laisse la place aux écrous
            }
            for (s = [-1, 1]) translate([s * (xj + joue_ep / 2), 0, 0]) joue();
        }
        // axe, goupille de blocage
        translate([-W, 0, axe_bas]) rotate([0, 90, 0]) cylinder(d = axe_d, h = 2 * W);
        translate([-W, 0, axe_bas - goupille_r]) rotate([0, 90, 0]) cylinder(d = goupille_d, h = 2 * W);
        // fixation : lumières + lamage par-dessous (5 mm sous tête)
        for (s = [-1, 1]) {
            hull() for (x = [fix_min / 2, fix_max / 2]) translate([s * x, fix_y, -1]) cylinder(d = fix_d, h = 30);
            hull() for (x = [fix_min / 2, fix_max / 2]) translate([s * x, fix_y, 5]) cylinder(d = 15, h = 30);
        }
        // fils : passages dans les nervures et gorge vers l'avant (sous le garde-boue)
        translate([-6, dos_y + paroi + 2, -1]) cube([12, 120, 8]);
        // clignotants : tiges dans les flancs, écrous dans la cavité
        translate([-S - 5, pad_y, cligno_z]) rotate([0, 90, 0]) cylinder(d = cligno_d, h = 2 * S + 10);
        // éclairage de plaque : fil vers l'intérieur, vis perpendiculaires à la facette
        translate([0, ecl_p[0], ecl_p[1]]) rotate([ecl_a, 0, 0]) {
            cylinder(d = 7, h = 4 * paroi, center = true);
            if (eclairage_entraxe > 0) for (s = [-1, 1])
                translate([s * eclairage_entraxe / 2, 0, 0]) cylinder(d = eclairage_trou, h = 12, center = true);
        }
        // catadioptre
        if (catadioptre_d > 0) translate([0, dos_y + 8, 14]) rotate([90, 0, 0])
            cylinder(d = catadioptre_d, h = 20);
    }
}

// gabarit de 2 mm : vérifie les vis et l'encombrement avant la grosse impression
module gabarit() linear_extrude(2) projection() support_fixe();

// ---------------- bras (imprimé à plat, axe en y=0 z=R) ----------------
module bras_plan()
    round2d(2, 10) {
        translate([-moyeu_l / 2, col_y]) square([moyeu_l, -col_y]);
        hull() {
            translate([-moyeu_l / 2, col_y - 1]) square([moyeu_l, 2]);
            for (p = triangle) translate(p) circle(8);
        }
    }

module bras()
    difference() {
        union() {
            rext(bras_ep, 2) bras_plan();
            hull() { // moyeu chanfreiné, raccordé en rampe sur le bras
                translate([0, 0, R]) rotate([0, 90, 0]) {
                    cylinder(r = R, h = moyeu_l - 2, center = true);
                    cylinder(r = R - 1, h = moyeu_l, center = true);
                }
                translate([-moyeu_l / 2 + 1, col_y - 1, 0]) cube([moyeu_l - 2, 2, bras_ep - 2]);
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
module rrect(l, h, r) offset(r = r) square([l - 2 * r, h - 2 * r], center = true);

module porte_plaque() {
    yc = -plaque_recul - plaque_h / 2;
    l = plaque_l - 2 * marge;
    h = plaque_h - 2 * marge;
    difference() {
        union() {
            translate([0, yc, 0]) {
                linear_extrude(dos_ep) rrect(l, h, 6);
                rext(ep_tot, 1.5) {
                    difference() { rrect(l, h, 6); rrect(l - 7, h - 7, 3); }
                    rrect(4, h - 4, 2);
                    rrect(l - 4, 4, 2);
                }
            }
            rext(ep_tot, 1.5) round2d(2, 6) {
                hull() for (p = triangle) translate(p) circle(10);
                translate([-6, -plaque_recul - 2]) square([12, plaque_recul + 2 + triangle[0][1]]);
            }
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
        color(noir) { bras(); translate([0, 0, -ep_tot]) porte_plaque(); }
        if (part == "assemblage") translate([0, -plaque_recul - plaque_h / 2, -ep_tot - 1.5]) { // plaque
            color("white") linear_extrude(1.5) rrect(plaque_l, plaque_h, 8);
            color("royalblue") for (sx = [-1, 1]) translate([sx * (plaque_l / 2 - 10), 0, -0.2])
                linear_extrude(0.3) rrect(16, plaque_h - 6, 3);
            color("black") translate([0, 0, -0.3]) mirror([1, 0, 0])
                linear_extrude(0.4) text("AB-123-CD", size = 21, halign = "center", valign = "center");
        }
    }

// pièces d'origine figurées (aperçu seulement)
noir = [0.16, 0.16, 0.17];
module origine() {
    for (s = [-1, 1]) translate([s * S, pad_y, cligno_z]) {
        color("silver") rotate([0, s * 90, 0]) cylinder(d = 10, h = 14);
        translate([s > 0 ? 14 : -14, 0, 0]) mirror([s > 0 ? 0 : 1, 0, 0]) {
            color("black") hull() for (x = [9, 66]) translate([x, 0, 0]) rotate([90, 0, 0]) cylinder(r = 9, h = 14, center = true);
            color("orange") hull() for (x = [14, 61]) translate([x, -7.2, 0]) rotate([90, 0, 0]) cylinder(r = 6, h = 0.6, center = true);
        }
    }
    color("ivory") translate([0, ecl_p[0], ecl_p[1]]) rotate([ecl_a, 0, 0]) linear_extrude(9) rrect(56, 16, 4);
    color("red") translate([0, dos_y, 14]) rotate([90, 0, 0]) linear_extrude(4) rrect(70, 22, 10);
}

if (part == "support_fixe") support_fixe();
else if (part == "bras") bras();
else if (part == "porte_plaque") porte_plaque();
else if (part == "gabarit") gabarit();
else rotate([0, 180, 0]) { color(noir) support_fixe(); mobile(pliage); origine(); } // vue sur la moto
