// Support de plaque rétractable - Stark Varg EX/SM
// Style "retractable plateholder" : le support fixe garde clignotants et
// éclairage de plaque, seule la plaque pivote de 0° (déployée) à 180° (repliée).
// Quincaillerie : vis M5x70 + rondelles + écrou nylstop (axe, règle la friction)
//                 piston à bille M6 (crans à 0°, 90° et 180°).
// Compatible "Parametric Model Maker" de MakerWorld / Customizer OpenSCAD.

part = "les_deux"; // [les_deux, support_fixe, porte_plaque, replie]

/* [Plaque] */
plaque_l = 210;    // largeur plaque moto FR
plaque_h = 130;    // hauteur plaque moto FR
dos_ep   = 3;      // épaisseur du dos
nervure_h = 4;     // hauteur des nervures au dos
trou_plaque = 4.5; // trous de fixation plaque (rivets / vis M4)

/* [Support fixe] */
support_h  = 55;   // hauteur au-dessus de la charnière
support_ep = 6;
fix_d   = 6.5;     // vis de fixation garde-boue (M6)
fix_min = 30;      // lumières : entraxe min
fix_max = 70;      // lumières : entraxe max
cligno_d = 10.5;   // clignotants à tige Ø10
cligno_entraxe = 200; // entraxe des clignotants (vérifier la largeur légale)
eclairage_d = 4.3; // éclairage de plaque (M4)
eclairage_min = 20;
eclairage_max = 40;

/* [Charnière] */
axe_d   = 5.4;     // vis M5
R       = 11;      // rayon des charnons
charn_l = 60;      // largeur totale charnière (vis M5x70)
charn_c = 30;      // largeur charnon central
jeu     = 0.4;     // jeu entre charnons
piston_d = 5.2;    // piston à bille M6 vissé direct dans le plastique
piston_r = 7.5;    // distance piston / axe
cran_d   = 3.5;    // Ø des crans (bille du piston)

/* [Hidden] */
$fn = 72;
g = R + 1;                 // recul des corps / axe : rotation libre
ep_tot = dos_ep + nervure_h;
xo = charn_c / 2 + jeu;    // début des charnons extérieurs
wo = charn_l / 2 - xo;

module charnon(x0, w, h_lang, sens) // sens : +1 support (y>0), -1 plaque (y<0)
    hull() {
        translate([x0, 0, R]) rotate([0, 90, 0]) cylinder(r = R, h = w);
        translate([x0, sens > 0 ? 0 : -(g + 1), 0]) cube([w, g + 1, h_lang]);
    }

module percage_axe()
    translate([-charn_l, 0, R]) rotate([0, 90, 0]) cylinder(d = axe_d, h = 2 * charn_l);

module lumiere(y, d, emin, emax, h)
    for (s = [-1, 1]) hull()
        for (x = [emin / 2, emax / 2]) translate([s * x, y, -1]) cylinder(d = d, h = h + 2);

module support_fixe() {
    yc = g + 22; // hauteur des clignotants
    difference() {
        union() {
            linear_extrude(support_ep) hull() {
                for (s = [-1, 1]) {
                    translate([s * (fix_max / 2 + 6), g + support_h - 8]) circle(8);
                    translate([s * cligno_entraxe / 2, yc]) circle(cligno_d / 2 + 8);
                    translate([s * (charn_l / 2 + 4), g + 4]) circle(4);
                }
            }
            charnon(-charn_l / 2, wo, support_ep, 1);
            charnon(xo, wo, support_ep, 1);
        }
        percage_axe();
        lumiere(g + support_h - 8, fix_d, fix_min, fix_max, support_ep);
        lumiere(g + 8, eclairage_d, eclairage_min, eclairage_max, support_ep);
        for (s = [-1, 1]) translate([s * cligno_entraxe / 2, yc, -1]) cylinder(d = cligno_d, h = support_ep + 2);
        // piston à bille dans le charnon extérieur droit
        translate([xo - 1, piston_r, R]) rotate([0, 90, 0]) cylinder(d = piston_d, h = wo + 2);
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
        // crans face au piston : déployé (0°), horizontal (90°), replié (180°)
        for (p = [[piston_r, 0], [0, piston_r], [-piston_r, 0]])
            translate([charn_c / 2 + cran_d / 2 - 1.2, p[0], R + p[1]]) sphere(d = cran_d);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (plaque_l / 2 - 15), y0 + plaque_h / 2 + sy * (plaque_h / 2 - 15), -1])
                cylinder(d = trou_plaque, h = ep_tot + 2);
    }
}

if (part == "support_fixe") support_fixe();
else if (part == "porte_plaque") porte_plaque();
else if (part == "replie") { support_fixe(); translate([0, 0, R]) rotate([-180, 0, 0]) translate([0, 0, -R]) porte_plaque(); }
else { support_fixe(); porte_plaque(); }
