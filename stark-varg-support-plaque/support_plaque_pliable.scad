// Support de plaque rétractable - Stark Varg EX/SM
// Style FL Specialparts : support plat sous le garde-boue, 2 joues portant l'axe,
// bras pivotant qui tient la plaque par 3 vis en triangle.
// Platine arrière fixe : feu arrière LED (avec éclairage de plaque) + 2 clignotants.
// La plaque passe de déployée (0°) à repliée à plat sous le garde-boue (90°).
// Quincaillerie : vis M5x70 + rondelles + nylstop (axe, règle la friction)
//                 piston à bille M6 (crans), 3 vis M5x20 + écrous (plaque),
//                 feu arrière LED homologué à 2 goujons M5, 2 clignotants à tige.
// Compatible "Parametric Model Maker" de MakerWorld / Customizer OpenSCAD.

part = "assemblage"; // [assemblage, support_fixe, bras, porte_plaque]
pliage = 0;          // [0:90] angle de l'aperçu "assemblage"

/* [Plaque] */
plaque_l = 210;    // largeur plaque moto FR
plaque_h = 130;    // hauteur plaque moto FR
plaque_recul = 15; // distance axe / haut de plaque
dos_ep   = 3;      // épaisseur du dos
nervure_h = 4;     // hauteur des nervures au dos
trou_plaque = 4.5; // trous de fixation plaque (rivets / vis M4)

/* [Support fixe] */
support_ep = 6;
support_long = 60;  // longueur vers l'avant
axe_bas = 42;       // distance face d'appui / axe
fix_d   = 6.5;      // vis de fixation (M6)
fix_min = 30;       // lumières : entraxe min
fix_max = 50;       // lumières : entraxe max

/* [Feu et clignotants] */
platine_h  = 28;    // hauteur de la platine arrière
platine_ep = 6;
cligno_d = 10.5;    // tige des clignotants (Ø10 ; 8.5 pour M8)
cligno_entraxe = 220; // entraxe des clignotants (vérifier la largeur légale)
feu_d   = 5.5;      // goujons M5 du feu arrière
feu_min = 20;       // lumières : entraxe min
feu_max = 60;       // entraxe max
cable_d = 8;        // passage des fils

/* [Pivot] */
axe_d   = 5.4;     // vis M5
R       = 10;      // rayon du moyeu du bras
joue_R  = 12;      // rayon des joues autour de l'axe
joue_ep = 8;
moyeu_l = 40;      // largeur du moyeu
jeu     = 0.4;
bras_ep = 6;
vis_d   = 5.4;     // vis plaque M5
triangle = [[-12, -35], [12, -35], [0, -58]]; // vis plaque (repère bras)
piston_d = 5.2;    // piston à bille M6 vissé direct dans le plastique
piston_r = 6.5;    // distance piston / axe
cran_d   = 3.5;
crans    = [0, 90]; // angles des crans : 0 = déployée, 90 = repliée

/* [Hidden] */
$fn = 72;
ep_tot = dos_ep + nervure_h;
xj = moyeu_l / 2 + jeu;          // face intérieure des joues
W = 2 * (xj + joue_ep);

// ---------- support fixe (imprimé face d'appui sur le plateau) ----------
module joue()
    rotate([0, 90, 0]) rotate([0, 0, 90]) linear_extrude(joue_ep) hull() {
        translate([0, axe_bas]) circle(joue_R);
        translate([-joue_R, 0]) square([2 * joue_R + 20, support_ep]);
    }

// platine arrière verticale : feu au centre, clignotants aux extrémités
module platine()
    translate([0, -joue_R + 1, 0]) rotate([90, 0, 0]) difference() {
        linear_extrude(platine_ep) hull() {
            translate([-W / 2, 0]) square([W, platine_h]);
            for (s = [-1, 1]) translate([s * cligno_entraxe / 2, platine_h / 2]) circle(cligno_d / 2 + 7);
        }
        for (s = [-1, 1]) {
            translate([s * cligno_entraxe / 2, platine_h / 2, -1]) cylinder(d = cligno_d, h = platine_ep + 2);
            hull() for (x = [feu_min / 2, feu_max / 2]) translate([s * x, platine_h / 2, -1]) cylinder(d = feu_d, h = platine_ep + 2);
        }
        translate([0, platine_h / 2, -1]) cylinder(d = cable_d, h = platine_ep + 2);
    }

module support_fixe() {
    yf = support_long - 10;
    difference() {
        union() {
            platine();
            linear_extrude(support_ep) hull() {
                translate([-W / 2, -joue_R]) square([W, 2 * joue_R]);
                for (s = [-1, 1]) translate([s * fix_max / 2, yf]) circle(8);
            }
            for (s = [-1, 1]) translate([s > 0 ? xj : -xj - joue_ep, 0, 0]) joue();
        }
        translate([-W, 0, axe_bas]) rotate([0, 90, 0]) cylinder(d = axe_d, h = 2 * W);
        for (s = [-1, 1]) hull() for (x = [fix_min / 2, fix_max / 2])
            translate([s * x, yf, -1]) cylinder(d = fix_d, h = support_ep + 2);
        // piston à bille dans la joue droite, côté support
        translate([xj - 1, 0, axe_bas - piston_r]) rotate([0, 90, 0]) cylinder(d = piston_d, h = joue_ep + 2);
    }
}

// ---------- bras (imprimé à plat, axe en y=0 z=R) ----------
module bras() {
    difference() {
        hull() {
            translate([-moyeu_l / 2, 0, R]) rotate([0, 90, 0]) cylinder(r = R, h = moyeu_l);
            for (p = triangle) translate([p[0], p[1], 0]) cylinder(r = 8, h = bras_ep);
        }
        translate([-moyeu_l, 0, R]) rotate([0, 90, 0]) cylinder(d = axe_d, h = 2 * moyeu_l);
        for (p = triangle) translate([p[0], p[1], -1]) cylinder(d = vis_d, h = 3 * R);
        for (a = crans)
            translate([moyeu_l / 2 + cran_d / 2 - 1.2, piston_r * cos(a), R + piston_r * sin(a)]) sphere(d = cran_d);
    }
}

// ---------- porte-plaque (imprimé face avant sur le plateau) ----------
module porte_plaque() {
    y1 = -plaque_recul;
    y0 = y1 - plaque_h;
    difference() {
        union() {
            translate([-plaque_l / 2, y0, 0]) cube([plaque_l, plaque_h, dos_ep]);
            translate([0, (y0 + y1) / 2, 0]) {
                difference() {
                    translate([-plaque_l / 2, -plaque_h / 2, 0]) cube([plaque_l, plaque_h, ep_tot]);
                    translate([-plaque_l / 2 + 3, -plaque_h / 2 + 3, -1]) cube([plaque_l - 6, plaque_h - 6, ep_tot + 2]);
                }
                translate([-1.5, -plaque_h / 2, 0]) cube([3, plaque_h, ep_tot]);
                translate([-plaque_l / 2, -1.5, 0]) cube([plaque_l, 3, ep_tot]);
            }
            hull() for (p = triangle) translate([p[0], p[1], 0]) cylinder(r = 9, h = ep_tot);
        }
        for (p = triangle) translate([p[0], p[1], -1]) cylinder(d = vis_d, h = ep_tot + 2);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (plaque_l / 2 - 15), (y0 + y1) / 2 + sy * (plaque_h / 2 - 15), -1])
                cylinder(d = trou_plaque, h = ep_tot + 2);
    }
}

// bras + plaque, repère du support, plié de a degrés vers l'avant
module mobile(a)
    translate([0, 0, axe_bas]) rotate([-a, 0, 0]) rotate([-90, 0, 0]) translate([0, 0, -R]) {
        bras();
        translate([0, 0, -ep_tot]) porte_plaque();
    }

if (part == "support_fixe") support_fixe();
else if (part == "bras") bras();
else if (part == "porte_plaque") porte_plaque();
else rotate([0, 180, 0]) { // vue sur la moto, feu et clignotants figurés
    support_fixe(); mobile(pliage);
    color("red") translate([-35, -joue_R - platine_ep - 15, 4]) cube([70, 15, platine_h - 8]);
    for (s = [-1, 1]) color("orange") translate([s * cligno_entraxe / 2, -joue_R - platine_ep, platine_h / 2])
        rotate([90, 0, 0]) cylinder(d = 18, h = 25);
}
