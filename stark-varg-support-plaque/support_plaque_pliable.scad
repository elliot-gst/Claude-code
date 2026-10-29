// Support de plaque pliable - Stark Varg (EX)
// Deux pièces imprimées à plat + 1 vis M5x70 et écrou nylstop comme axe.
// Le serrage de l'écrou règle la friction de la charnière.
// Compatible "Parametric Model Maker" de MakerWorld / Customizer OpenSCAD.

part = "les_deux"; // [les_deux, embase, porte_plaque]

/* [Plaque] */
plaque_l = 210;   // largeur plaque moto FR
plaque_h = 130;   // hauteur plaque moto FR
dos_ep   = 3;     // épaisseur du dos
nervure_h = 4;    // hauteur des nervures au dos
trou_plaque = 4.5; // trous de fixation plaque (rivets / vis M4)

/* [Embase (fixation garde-boue)] */
embase_l  = 70;
embase_h  = 40;
embase_ep = 6;
trou_fix  = 6.5;  // M6
entraxe_min = 30; // lumières réglables : entraxe min
entraxe_max = 50; // entraxe max

/* [Charnière] */
axe_d    = 5.4;   // vis M5
R        = 7;     // rayon des charnons
charn_l  = 60;    // largeur totale charnière (vis M5x70)
charn_c  = 30;    // largeur charnon central
jeu      = 0.4;   // jeu entre charnons

/* [Hidden] */
$fn = 64;
g = R + 1;        // recul des corps par rapport à l'axe (rotation libre)
ep_tot = dos_ep + nervure_h;

module charnon(x0, w, h_lang, sens) // sens: +1 embase (y>0), -1 porte-plaque (y<0)
    hull() {
        translate([x0, 0, R]) rotate([0, 90, 0]) cylinder(r = R, h = w);
        translate([x0, sens > 0 ? 0 : -(g + 1), 0]) cube([w, g + 1, h_lang]);
    }

module percage_axe()
    translate([-charn_l, 0, R]) rotate([0, 90, 0]) cylinder(d = axe_d, h = 2 * charn_l);

module embase() {
    xo = charn_c / 2 + jeu;
    wo = charn_l / 2 - xo;
    difference() {
        union() {
            translate([-embase_l / 2, g, 0]) cube([embase_l, embase_h, embase_ep]);
            charnon(-charn_l / 2, wo, embase_ep, 1);
            charnon(xo, wo, embase_ep, 1);
        }
        percage_axe();
        // lumières horizontales : entraxe réglable entre min et max
        for (s = [-1, 1]) hull()
            for (x = [entraxe_min / 2, entraxe_max / 2])
                translate([s * x, g + embase_h / 2 + 4, -1]) cylinder(d = trou_fix, h = embase_ep + 2);
    }
}

module porte_plaque() {
    y0 = -g - plaque_h;
    difference() {
        union() {
            translate([-plaque_l / 2, y0, 0]) cube([plaque_l, plaque_h, dos_ep]);
            // nervures : cadre + croix
            translate([0, y0 + plaque_h / 2, 0]) {
                difference() {
                    translate([-plaque_l / 2, -plaque_h / 2, 0]) cube([plaque_l, plaque_h, ep_tot]);
                    translate([-plaque_l / 2 + 3, -plaque_h / 2 + 3, -1]) cube([plaque_l - 6, plaque_h - 6, ep_tot + 2]);
                }
                translate([-1.5, -plaque_h / 2, 0]) cube([3, plaque_h, ep_tot]);
                translate([-plaque_l / 2, -1.5, 0]) cube([plaque_l, 3, ep_tot]);
            }
            charnon(-charn_c / 2, charn_c, ep_tot, -1);
        }
        percage_axe();
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (plaque_l / 2 - 15), y0 + plaque_h / 2 + sy * (plaque_h / 2 - 15), -1])
                cylinder(d = trou_plaque, h = ep_tot + 2);
    }
}

if (part == "embase") embase();
else if (part == "porte_plaque") porte_plaque();
else { embase(); porte_plaque(); }
