/* ============================================================================
   Akai MPK249 Keyboard Stand -- SINGLE POST / COLUMN VERSION
   Parametric, rod-reinforced, sectioned for FDM printing
   ============================================================================

   DESIGN SUMMARY
   --------------
   A single inclined column on a ballasted base:

     - BALLAST HUB: a low, wide, open-top box (default 180 x 220 x 100mm)
       printed as 4 quadrants that bolt together. You fill it with bagged
       sand, bricks, or gym weight plates. This is the single most important
       part of the design -- see "WHY BALLAST" below.
     - TWO FEET: splayed backward from the hub's rear corners (default 90
       degrees between them), away from the player's feet.
     - POST: inclined 75 degrees from horizontal, leaning BACKWARD away from
       the player. The lean is what creates knee clearance under the front of
       the keyboard. Printed as stacked square segments over 4 continuous
       8mm steel rods.
     - YOKE: wedge block at the top of the post that converts the 75-degree
       post to a horizontal mounting plate.
     - TRAY ARMS: two lateral arms (not a solid tray) that the keyboard rests
       on, each ~550mm long, printed in segments over 2 steel rods. Two arms
       spaced 200mm apart carry the keyboard fine and print far more easily
       than a solid 550 x 260mm slab would.

   WHY BALLAST
   -----------
   A single post puts everything on one narrow support. The base footprint,
   not the post's strength, is what decides whether this tips over. Ballast
   in the hub does two things at once: it adds weight AND drops the combined
   centre of gravity toward the floor, and tip resistance scales with
   (weight x horizontal margin / CoG height). The echo output below reports
   computed tip resistance both ballasted and unballasted so you can see the
   difference for your own parameters. Fill the hub.

   WHY THE POST IS ROD-REINFORCED
   ------------------------------
   The post is a cantilever. The keyboard's weight acts ~150mm horizontally
   away from the post's base, so the base of the post carries a constant
   bending moment (roughly 10 N.m just from the keyboard sitting there, more
   when you lean on it). Printed plastic is weakest exactly in the direction
   that a bending load pulls layers apart, and it also creeps -- deforms
   slowly and permanently under a load held for months. Four 8mm steel rods
   running continuously from the base shoe to the yoke carry that bending
   load; the printed segments provide shape, spacing, and shear transfer.
   The rods are NOT optional in this design.

   MEASURE YOUR OWN UNIT BEFORE PRINTING EVERYTHING
   -------------------------------------------------
   mpk_key_surface_height is an ESTIMATE -- the Akai spec height (85.8mm) is
   the tallest point of the case including the pitch/mod wheel housing, which
   sits ABOVE the key surface. Measure from a flat table to the top of a white
   key and update it. See README.md.

   EXPORTING PARTS
   ---------------
     openscad -D 'part="post_segment"' -o post_segment.stl single_post_stand.scad
   See export_post.sh to export everything at once, and the PART SELECTOR
   section at the bottom of this file for the list of valid part names.
   ============================================================================ */

// ---------------------------------------------------------------------------
// KEYBOARD (Akai MPK249)
// ---------------------------------------------------------------------------
mpk_width  = 736.6;
mpk_depth  = 311.15;
mpk_height = 85.8;
mpk_key_surface_height = 65;  // ESTIMATE -- measure yours, see header
mpk_weight_kg = 5.7;

// ---------------------------------------------------------------------------
// TARGET HEIGHT
// ---------------------------------------------------------------------------
target_key_height = 730;      // upright piano key-top height above floor
platform_height = target_key_height - mpk_key_surface_height; // top of arms

// ---------------------------------------------------------------------------
// POST
// ---------------------------------------------------------------------------
// The post is a HOLLOW EXTRUSION-STYLE PROFILE, printed VERTICALLY (axis along
// the printer's Z). Because the profile is prismatic, every surface is a
// vertical wall: it needs no support and no infill -- the "infill" is replaced
// by drawn webs, which are both calculable and faster to print than a
// stochastic lattice. Material sits out at the walls where it earns its keep
// rather than smeared through the middle near the neutral axis.
//
// Versus the old 60mm solid-ish section at 50% infill this is ~23% LESS plastic
// and ~1.7x stiffer -- most of the stiffness coming from moving the rods from
// +/-20 out to +/-27, which alone is worth ~1.8x on their contribution.
post_angle   = 75;   // degrees from HORIZONTAL; leans backward, away from player
post_size    = 80;   // outer square of the hollow profile
post_wall    = 3.5;  // outer wall thickness
rod_off      = 27;   // rods at (+/-rod_off, +/-rod_off), in corner bosses
boss_od      = 14;   // corner boss outer diameter (houses a rod bore)
web_w        = 3;    // webs tying each corner boss to the two adjacent walls
rod_d        = 8;    // steel rod nominal diameter
rod_hole_d   = 8.6;  // bore (clearance for an epoxy film)
boss_size    = 26;   // alignment boss -- arms and feet only, not the post
boss_h       = 12;
fit_clear    = 0.3;  // per-side clearance on all plug/socket fits

// Post segments have FLAT seam faces and no alignment boss: the four rods
// through the corner bosses fully locate each segment (4 pins = no freedom
// left), and a flat face maximises bearing area for the clamped joint.

// ---------------------------------------------------------------------------
// BALLAST HUB
// ---------------------------------------------------------------------------
hub_x = 180; hub_y = 220; hub_z = 100; // outer size
hub_cx = -20;                          // hub centre, X (post base sits at X=0)
hub_wall = 8; hub_floor = 8;
shoe_plate  = 24;  // solid base plate of the shoe
shoe_seat   = 26;  // axial distance from the shoe origin up to the post's seat
shoe_collar = 45;  // how far the shoe's collar grips the post above that seat
shoe_base       = 160; // shoe footprint (must fit inside the hub: hub_x-2*hub_wall)
shoe_hull_base  = 120; // collar taper footprint; < shoe_base leaves a bolt flange
shoe_collar_wall= 10;  // collar wall around the post socket
shoe_bolt_off   = 68;  // hub-floor bolts, out in the exposed flange ring

// ---------------------------------------------------------------------------
// FEET  (splay is the half-angle from the rear centreline, so 45 => 90 apart)
// Set to 90 deg apart deliberately: sideways is the weakest tipping direction
// and backward is by far the strongest, so widening trades surplus backward
// margin for the direction that actually needs it (+30% sideways). Forward is
// unaffected -- that comes from the hub, not the feet. Use 22.5 for a
// narrower 45-deg-apart stance; see the table in README.md.
// ---------------------------------------------------------------------------
foot_splay_half = 45;
foot_len = 300;
foot_w = 50; foot_h = 60;
foot_rod_z = [15, 45];  // two rods, vertically separated (bending stiffness)
foot_root_y = 80;       // Y offset of each foot root on the hub rear face
foot_socket_depth = 80; // how far the foot root plugs into the hub boss

// ---------------------------------------------------------------------------
// YOKE + TRAY ARMS
// ---------------------------------------------------------------------------
// yoke_h/yoke_socket_depth are constrained: the tendon nuts seat in a
// counterbore in the top, and the material BETWEEN that seat and the post
// socket below is what carries the nut load. At yoke_h=60/socket=45 that
// ledge was only 3.1mm. 70/40 leaves 18.5mm. See the assert below.
yoke_h = 70; yoke_socket_depth = 40;
tendon_cbore_d = 24;  // clears an M8 nut + penny washer
tendon_cbore_h = 14;
tendon_seat_min = 10; // minimum acceptable ledge under the nut
yoke_x = 280; yoke_y = 200;  // must exceed arm_spacing + arm_w with margin
arm_span = 550;      // total length of each lateral arm
arm_spacing = 200;   // fore-aft distance between the two arms
arm_w = 45; arm_h = 40;
arm_rod_z = [10, 30];
arm_center_len = 200; // middle segment, bolts to the yoke

// ---------------------------------------------------------------------------
// PRINTER
// ---------------------------------------------------------------------------
max_segment_length = 200;

// ---------------------------------------------------------------------------
// MASS MODEL (for the stability report -- rough estimates, tune if you weigh
// your actual prints; they only affect the reported numbers, not geometry)
// ---------------------------------------------------------------------------
est_arms_yoke_kg = 2.0;
est_post_kg      = 2.1;
est_hub_feet_kg  = 4.0;
ballast_kg       = 6.0;  // sand/bricks/plates you put in the hub

// ---------------------------------------------------------------------------
// DERIVED GEOMETRY
// ---------------------------------------------------------------------------
sinA = sin(post_angle);
cosA = cos(post_angle);

// The post axis is a single tilted LINE. Every part that sits on it (shoe,
// segments, yoke) must be placed by walking along that line, not by moving
// straight up -- two parallel tilted lines through different points are not
// the same line, so a vertical-only offset would leave the post misaligned
// with its own socket.
shoe_org_z  = hub_floor;                       // shoe origin sits on the hub floor
post_base_x = -shoe_seat*cosA;                 // post seat, walked up the axis
post_base_z = shoe_org_z + shoe_seat*sinA;
// Post-top point = where the post axis meets the yoke's lower face.
post_top_z  = platform_height - arm_h - yoke_h + yoke_socket_depth*sinA;
post_len    = (post_top_z - post_base_z)/sinA;
post_top_x  = post_base_x - post_len*cosA;
// yoke origin = the point yoke_socket_depth back down the axis from the top
yoke_org_x  = post_top_x + yoke_socket_depth*cosA;
yoke_org_z  = post_top_z - yoke_socket_depth*sinA;

post_n   = ceil(post_len/max_segment_length);
post_seg = post_len/post_n;

arm_wing_len = (arm_span - arm_center_len)/2;
arm_wing_n   = ceil(arm_wing_len/max_segment_length);
arm_wing_seg = arm_wing_len/arm_wing_n;

foot_n   = ceil(foot_len/max_segment_length);
foot_seg = foot_len/foot_n;

hub_front = hub_cx + hub_x/2;
hub_rear  = hub_cx - hub_x/2;
hub_hy    = hub_y/2;

// foot root/tip in plan (X = fore/aft, Y = lateral)
foot_tip_x = hub_rear - foot_len*cos(foot_splay_half);
foot_tip_y = foot_root_y + foot_len*sin(foot_splay_half);

// keyboard + arms are centred on the yoke plate (not on the bare post top --
// the yoke's own centre is offset slightly forward along the tilted axis)
kb_cx = yoke_org_x;

// --- stability model -------------------------------------------------------
// masses as [kg, x, z]
function _m(ball) = [
  [mpk_weight_kg,    kb_cx,        platform_height + mpk_height/3],
  [est_arms_yoke_kg, kb_cx,        platform_height - 20],
  [est_post_kg,      (post_base_x + post_top_x)/2, (post_base_z + post_top_z)/2],
  [est_hub_feet_kg,  hub_cx,       hub_z/2],
  [ball,             hub_cx,       hub_floor + 40]
];
function _tot(v) = v[0]+v[1]+v[2]+v[3]+v[4];
function _sum(v, i) = v[0][0]*v[0][i] + v[1][0]*v[1][i] + v[2][0]*v[2][i]
                    + v[3][0]*v[3][i] + v[4][0]*v[4][i];
function totM(b) = _tot([for (r=_m(b)) r[0]]);
function comX(b) = _sum(_m(b),1)/totM(b);
function comZ(b) = _sum(_m(b),2)/totM(b);
// lateral half-width of the support hull at a given X (hub front corner -> foot tip)
function hullY(x) = hub_hy + ((hub_front - x)/(hub_front - foot_tip_x))*(foot_tip_y - hub_hy);
// tip resistance in kgf = W * horizontal margin / CoG height
function tipFwd(b)  = totM(b)*(hub_front - comX(b))/comZ(b);
function tipRear(b) = totM(b)*(comX(b) - foot_tip_x)/comZ(b);
function tipLat(b)  = totM(b)*hullY(comX(b))/comZ(b);

assert(post_top_z > post_base_z + 100, "Post too short -- check target_key_height / mpk_key_surface_height");
assert(arm_wing_seg <= max_segment_length && post_seg <= max_segment_length,
       "A segment exceeds max_segment_length");
assert(arm_wing_n == 1,
       "Each arm wing must be a single segment: raise max_segment_length, or raise arm_center_len / lower arm_span so that (arm_span - arm_center_len)/2 fits on the bed.");
assert(foot_seg > foot_socket_depth + 20,
       "First foot segment is shorter than the hub socket it plugs into -- raise max_segment_length or lower foot_socket_depth.");
assert(yoke_x >= arm_spacing + arm_w + 20,
       "Yoke plate too small for the arm spacing -- the arms would overhang its edge. Raise yoke_x.");
assert(yoke_h/sinA - tendon_cbore_h - yoke_socket_depth >= tendon_seat_min,
       "Too little material between the yoke's post socket and the tendon nut counterbore -- the nut would sit on a thin ledge over a cavity. Raise yoke_h, or lower yoke_socket_depth / tendon_cbore_h.");
assert(post_size - 2*post_wall > 2*(rod_off + boss_od/2) - post_size,
       "Corner bosses overlap the profile walls oddly -- check post_size / rod_off / boss_od.");

echo("=== MPK249 SINGLE-POST STAND ===");
echo(str("keyboard rest surface (top of arms) = ", platform_height, " mm"));
echo(str("post: ", post_len, "mm axial at ", post_angle, "deg -> ", post_n,
         " segments @ ", post_seg, "mm; top of post at x=", post_top_x));
echo(str("arms: 2 x [1 centre @ ", arm_center_len, "mm + 2 wings @ ", arm_wing_seg,
         "mm x", arm_wing_n, "]"));
echo(str("feet: 2 x ", foot_n, " segments @ ", foot_seg, "mm, splay ",
         2*foot_splay_half, "deg apart, tips at x=", foot_tip_x, " y=+/-", foot_tip_y));
rod_total = 4*(post_len+120) + 4*arm_span + 4*(foot_len+80);
echo(str("TOTAL 8mm rod stock: ~", ceil(rod_total/100)*100, " mm"));
echo("--- STABILITY (force at keyboard height needed to tip it) ---");
echo(str("  BALLASTED (", ballast_kg, "kg in hub): total ", totM(ballast_kg),
         "kg, CoG height ", comZ(ballast_kg), "mm"));
echo(str("     forward ", tipFwd(ballast_kg), " kgf | backward ", tipRear(ballast_kg),
         " kgf | sideways ", tipLat(ballast_kg), " kgf"));
echo(str("  UNBALLASTED: total ", totM(0), "kg, CoG height ", comZ(0), "mm"));
echo(str("     forward ", tipFwd(0), " kgf | backward ", tipRear(0),
         " kgf | sideways ", tipLat(0), " kgf"));

// ---------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------
module box_xyc(sx, sy, sz, z0=0) {
  translate([-sx/2, -sy/2, z0]) cube([sx, sy, sz]);
}
// fully centred box (centred on X, Y AND Z)
module cbox(sx, sy, sz) {
  translate([-sx/2, -sy/2, -sz/2]) cube([sx, sy, sz]);
}
// the 4 post rods, as a cutting tool, along +Z
module post_rod_holes(len, extra=2) {
  for (sx=[-1,1], sy=[-1,1])
    translate([sx*rod_off, sy*rod_off, -extra/2])
      cylinder(d=rod_hole_d, h=len+extra, $fn=24);
}

// ---------------------------------------------------------------------------
// post_segment: hollow extrusion-style profile, printed standing up.
// ---------------------------------------------------------------------------
// 2D profile -- the "extrusion die". Square tube + four corner bosses carrying
// the rod bores + short webs tying each boss to its two adjacent walls.
module post_profile() {
  inner = post_size/2 - post_wall;
  difference() {
    union() {
      difference() {
        square([post_size, post_size], center=true);
        square([post_size-2*post_wall, post_size-2*post_wall], center=true);
      }
      for (sx=[-1,1], sy=[-1,1]) {
        translate([sx*rod_off, sy*rod_off]) circle(d=boss_od, $fn=32);
        // Webs are drawn out to the OUTER face rather than stopping flush on
        // the inner one. Geometrically identical (the wall already fills that
        // band, and both forms verify as "Simple: yes" with the same 544
        // vertices), but it avoids relying on an exact-tangency union, which
        // is the kind of thing that bites when someone edits post_wall later.
        translate([sx*(rod_off + post_size/2)/2, sy*rod_off])
          square([post_size/2 - rod_off, web_w], center=true);
        translate([sx*rod_off, sy*(rod_off + post_size/2)/2])
          square([web_w, post_size/2 - rod_off], center=true);
      }
    }
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*rod_off, sy*rod_off]) circle(d=rod_hole_d, $fn=32);
  }
}

// Print this STANDING UP (segment axis vertical). Prismatic => zero support,
// zero infill, and the flat end faces come out square for good seam bearing.
module post_segment(len) {
  linear_extrude(len) post_profile();
}

// ---------------------------------------------------------------------------
// post_shoe: sits on the hub floor, converts vertical to the post angle.
// Flat bottom (prints straight onto the bed); the post socket and rod bores
// run at (90 - post_angle) = 15 deg off vertical, shallow enough to print
// without support. Bolts through the hub floor -- it deliberately spans all
// four hub quadrant seams and helps tie them together.
// ---------------------------------------------------------------------------
module post_shoe() {
  base       = shoe_base;
  hull_base  = shoe_hull_base;
  difference() {
    union() {
      box_xyc(base, base, shoe_plate, 0);
      // collar tapering up from the plate to grip the post. hull_base is kept
      // smaller than the plate so a flange ring stays EXPOSED around the
      // outside for the hub-floor bolts -- otherwise the taper buries their
      // heads and they can't be reached.
      hull() {
        box_xyc(hull_base, hull_base, 0.01, shoe_plate-0.01);
        rotate([0,-(90-post_angle),0])
          translate([0,0,shoe_seat+shoe_collar])
            box_xyc(post_size+2*shoe_collar_wall, post_size+2*shoe_collar_wall, 0.01);
      }
    }
    rotate([0,-(90-post_angle),0]) {
      // socket starts AT the seat, so solid plate remains underneath for the
      // post to bear on (the seat is square to the post axis, as the post's
      // own cut end is)
      translate([0,0,shoe_seat])
        box_xyc(post_size+2*fit_clear, post_size+2*fit_clear, shoe_collar+80);
      // rod bores run right through
      translate([0,0,-60]) post_rod_holes(shoe_collar+220);
      // NOTE: the tendons are anchored here by BONDED length, not by nuts.
      // Nut pockets were the obvious idea but don't work at the bottom: the
      // rods are tilted while the shoe's underside is horizontal, so four
      // coaxial pockets end up at four different depths (a ~14mm spread at
      // +/-27 offset) -- two would break out through the bottom face while
      // two stayed buried. Bonded anchorage avoids the problem entirely and
      // is loaded in SHEAR along the rod (~0.4 MPa over the embedded length),
      // which is a reliable use of epoxy, unlike pulling a printed seam apart.
      // All tensioning is done at the yoke end.
    }
    // hub-floor bolt holes, out in the exposed flange ring
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*shoe_bolt_off, sy*shoe_bolt_off, -1])
        cylinder(d=6.5, h=shoe_plate+2, $fn=24);
  }
}

// ---------------------------------------------------------------------------
// post_yoke: wedge that turns the 75-degree post into a horizontal plate.
// PRINT UPSIDE DOWN (flat top face on the bed) -- then the angled socket and
// rod bores are only 15 deg off vertical and need no support.
// ---------------------------------------------------------------------------
module post_yoke() {
  difference() {
    hull() {
      translate([0,0,yoke_h-12]) box_xyc(yoke_x, yoke_y, 12);
      // wider than the socket so there is real material around the socket
      // mouth, where bearing stress from the post is highest
      rotate([0,-(90-post_angle),0]) box_xyc(post_size+4*hub_wall, post_size+4*hub_wall, 0.01);
    }
    // socket swallowing the top of the post, plus rod bores running up into it
    rotate([0,-(90-post_angle),0]) {
      translate([0,0,-1]) box_xyc(post_size+2*fit_clear, post_size+2*fit_clear, yoke_socket_depth+1);
      translate([0,0,-1]) post_rod_holes(yoke_h+40);
      // Counterbores for the tendon nuts + washers. Coaxial with the rods so
      // the washer seats square to the rod, not skewed against the horizontal
      // top face. This is the end you actually tension from.
      for (sx=[-1,1], sy=[-1,1])
        translate([sx*rod_off, sy*rod_off, yoke_h/sinA - tendon_cbore_h])
          cylinder(d=tendon_cbore_d, h=tendon_cbore_h+20, $fn=32);
    }
    // bolt holes for the two arms (2 bolts per arm)
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*arm_spacing/2, sy*70, yoke_h-20])
        cylinder(d=5.5, h=30, $fn=24);
  }
}

// ---------------------------------------------------------------------------
// arm_segment: lateral beam the keyboard rests on. Two rods, vertically
// separated so they actually resist bending (a single rod on the neutral
// axis would add almost nothing). `center=true` adds the yoke bolt holes.
// Printed lying down.
//
// NO alignment boss: two parallel rods already fully constrain the joint
// (nothing can rotate or shift), and flat faces give maximum glue area. An
// earlier version had an 18.2mm boss here, but the rod bores at +/-10 span
// +/-5.7..14.3 and cut 3.4mm into it from both sides -- the boss came out
// hacked into a cross and the rods could not pass through the joint cleanly.
// The same reasoning is why the post segments butt flat too.
// ---------------------------------------------------------------------------
module arm_segment(len, center=false) {
  difference() {
    cbox(arm_w, len, arm_h);
    // two rods, vertically separated so they actually resist bending
    for (z = arm_rod_z)
      translate([0, -len/2-1, z-arm_h/2])
        rotate([-90,0,0]) cylinder(d=rod_hole_d, h=len+2, $fn=24);
    if (center)
      for (sy=[-1,1])
        translate([0, sy*70, -arm_h/2-1]) cylinder(d=5.5, h=arm_h+2, $fn=24);
  }
}

// ---------------------------------------------------------------------------
// foot_segment / foot_tip: splayed rear feet. Two rods vertically separated.
// ---------------------------------------------------------------------------
// `root=true` -> the segment that plugs into the hub's foot socket: it carries
// the cross-bolt holes that pin it into the sleeve.
// Butt-jointed on the rods, same as the arms -- the old 20.8mm boss cleared
// the rod bores by only 0.3mm, which is a sliver that would not print.
module foot_segment(len, root=false) {
  difference() {
    box_xyc(foot_w, len, foot_h, 0);
    for (z = foot_rod_z)
      translate([0, -len/2-1, z]) rotate([-90,0,0])
        cylinder(d=rod_hole_d, h=len+2, $fn=24);
    // cross bolts that pin the root into the hub boss (clear of both rods)
    if (root)
      for (y = [-len/2+25, -len/2+60])
        translate([-foot_w/2-hub_wall-1, y, foot_h/2])
          rotate([0,90,0]) cylinder(d=6.5, h=foot_w+2*hub_wall+2, $fn=24);
  }
}

// The tip keeps a FULL-HEIGHT section for its first `flat` mm before tapering.
// A taper running the whole length would drop below the upper rod bore about
// a third of the way along, leaving that rod sitting in an open groove on the
// top surface instead of a closed hole.
module foot_tip() {
  len = 60;
  flat = 26;           // full-height length housing the rod bores
  y0 = -len/2;
  yf = y0 + flat;
  difference() {
    union() {
      translate([0, (y0+yf)/2, 0]) box_xyc(foot_w, flat, foot_h, 0);
      hull() {
        translate([0, yf, 0]) box_xyc(foot_w, 0.01, foot_h, 0);
        translate([0, len/2, 0]) box_xyc(foot_w, 0.01, foot_h*0.55, 0);
      }
    }
    for (z = foot_rod_z)
      translate([0, y0-1, z]) rotate([-90,0,0])
        cylinder(d=rod_hole_d, h=flat-2, $fn=24);
    // recess for a stick-on felt/rubber pad
    translate([0,0,-0.5]) box_xyc(foot_w-12, len-14, 1.5);
  }
}

// ---------------------------------------------------------------------------
// hub_quad: one quarter of the ballast box. Print 4 (two of each variant,
// mirroring one of each in your slicer). Rear quads carry the foot sockets.
// ---------------------------------------------------------------------------
module hub_shell() {
  difference() {
    translate([hub_cx,0,0]) box_xyc(hub_x, hub_y, hub_z);
    translate([hub_cx,0,hub_floor]) box_xyc(hub_x-2*hub_wall, hub_y-2*hub_wall, hub_z);
  }
}

module hub_quad(rear=false) {
  x0 = rear ? hub_rear : hub_cx;
  difference() {
    union() {
      intersection() {
        hub_shell();
        translate([x0, 0, 0]) cube([hub_x/2, hub_hy, hub_z]);
      }
      // foot socket boss on the rear-outer corner. rotate() maps +Y to
      // (-sin, cos), so 90-foot_splay_half sends the foot backward (-X) and
      // outward (+Y) -- which is the whole point of the splay.
      if (rear)
        intersection() {
          translate([hub_rear, foot_root_y, 0])
            rotate([0,0,90 - foot_splay_half])
              translate([-foot_w/2-hub_wall, -12, 0])
                cube([foot_w+2*hub_wall, foot_socket_depth+12, foot_h+hub_wall]);
          // clip keeps the sleeve in this quadrant (y>=0) so the part stays
          // separately printable; generous in +Y/-X so a wide splay angle
          // does not get its sleeve shaved off
          translate([hub_rear-160, 0, 0]) cube([hub_x/2+160, hub_hy+120, hub_z]);
        }
    }
    // The socket is a closed sleeve OUTSIDE the hub wall: it stops at the wall
    // (local y=0) rather than cutting into the interior, so the ballast cavity
    // stays sealed and the foot bottoms out against the wall.
    if (rear)
      translate([hub_rear, foot_root_y, 0])
        rotate([0,0,90 - foot_splay_half]) {
          translate([0, (foot_socket_depth+5)/2, 0])
            box_xyc(foot_w+2*fit_clear, foot_socket_depth+6, foot_h+2*fit_clear);
          for (y = [25, 60])
            translate([-foot_w/2-hub_wall-1, y, foot_h/2])
              rotate([0,90,0]) cylinder(d=6.5, h=foot_w+2*hub_wall+2, $fn=24);
        }
    // post_shoe bolt holes in the floor (one lands in each quadrant)
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*45, sy*45, -1]) cylinder(d=6.5, h=hub_floor+2, $fn=24);
    // seam bolt holes for the splice plates
    for (p = [[hub_cx, hub_hy-40], [hub_cx, 40]])
      translate([p[0], p[1], hub_floor+30]) rotate([0,90,0]) cylinder(d=5.5, h=60, center=true, $fn=24);
  }
}

// splice plate: bolts across a hub seam on the inside
module splice_plate() {
  difference() {
    box_xyc(90, 40, 8);
    for (sx=[-1,1]) translate([sx*30, 0, -1]) cylinder(d=5.5, h=10, $fn=24);
  }
}

// keyboard stop: locates the keyboard fore/aft on the arms
module keyboard_stop() {
  difference() {
    union() {
      box_xyc(30, 24, 6);
      translate([-15,-12,6]) cube([5, 24, 16]);
    }
    for (sy=[-1,1]) translate([6, sy*7, -0.5]) cylinder(d=3.2, h=8, $fn=16);
  }
}

// ============================================================================
// ASSEMBLY (preview only)
// ============================================================================
module assembly() {
  // hub (scale([1,-1,1]) is a clean mirror; mirror([0,0,0]) would be degenerate)
  for (s=[1,-1]) scale([1,s,1]) { hub_quad(false); hub_quad(true); }
  // post shoe + post (both placed along the same tilted axis)
  translate([0,0,shoe_org_z]) post_shoe();
  translate([post_base_x,0,post_base_z]) rotate([0,-(90-post_angle),0])
    for (i=[0:post_n-1]) translate([0,0,i*post_seg]) post_segment(post_seg);
  // yoke
  translate([yoke_org_x, 0, yoke_org_z]) post_yoke();
  // feet: root segment plugs into the hub sleeve, then plain segments, then tip
  for (s=[1,-1]) scale([1,s,1])
    translate([hub_rear, foot_root_y, 0])
      rotate([0,0,90 - foot_splay_half]) {
        for (i=[0:foot_n-1])
          translate([0, i*foot_seg + foot_seg/2, 0]) foot_segment(foot_seg, i==0);
        translate([0, foot_len + 30, 0]) foot_tip();
      }
  // tray arms
  for (sx=[-1,1])
    translate([kb_cx + sx*arm_spacing/2, 0, platform_height - arm_h/2]) {
      arm_segment(arm_center_len, true);
      // wings are symmetric now (plain butt ends), so no flip needed
      for (sy=[-1,1])
        translate([0, sy*(arm_center_len/2 + arm_wing_seg/2), 0])
          arm_segment(arm_wing_seg);
    }
  // keyboard silhouette (not printed)
  %translate([kb_cx - mpk_depth/2, -mpk_width/2, platform_height])
     cube([mpk_depth, mpk_width, mpk_height]);
}

// ============================================================================
// PART SELECTOR -- see README.md for quantities
// Valid: "assembly", "post_segment", "post_shoe", "post_yoke", "arm_center",
//        "arm_wing", "foot_root", "foot_segment", "foot_tip",
//        "hub_quad_front", "hub_quad_rear", "splice_plate", "keyboard_stop"
// ============================================================================
part = "assembly";

if      (part == "assembly")       assembly();
else if (part == "post_segment")   post_segment(post_seg);
else if (part == "post_shoe")      post_shoe();
else if (part == "post_yoke")      post_yoke();
else if (part == "arm_center")     arm_segment(arm_center_len, true);
else if (part == "arm_wing")       arm_segment(arm_wing_seg);
else if (part == "foot_segment")   foot_segment(foot_seg);
else if (part == "foot_root")      foot_segment(foot_seg, true);
else if (part == "foot_tip")       foot_tip();
else if (part == "hub_quad_front") hub_quad(false);
else if (part == "hub_quad_rear")  hub_quad(true);
else if (part == "splice_plate")   splice_plate();
else if (part == "keyboard_stop")  keyboard_stop();
