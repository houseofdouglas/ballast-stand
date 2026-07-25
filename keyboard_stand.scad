/* ============================================================================
   Akai MPK249 Keyboard Stand
   Parametric, rod-reinforced, sectioned for FDM printing
   ============================================================================

   DESIGN SUMMARY
   --------------
   A 4-legged rigid frame: a top rectangle (the platform the keyboard sits on)
   and a lower stretcher rectangle, joined by 4 continuous vertical legs.
   Every straight run (each leg, each rail) is printed as multiple short
   square-beam segments that plug together with spigot/socket joints, and
   every run has an 8mm steel rod running through its full length, epoxied
   in place at each joint. The rod is NOT there to be decorative -- printed
   PLA/PETG glue joints alone are not trustworthy at this height (~650mm)
   under a 5.7kg dynamic load (someone leaning/pressing on the keys). The rod
   carries the bending load; the printed plastic carries shape, alignment,
   and shear.

   MEASURE YOUR OWN UNIT BEFORE PRINTING EVERYTHING
   -------------------------------------------------
   mpk_key_surface_height below is an ESTIMATE. The Akai spec height (85.8mm)
   is the tallest point of the case, which includes the pitch/mod wheel
   housing -- that sits ABOVE the actual key surface. Put your MPK249 on a
   flat table, measure from the table up to the top of a white key (not the
   wheels, not the display), and update mpk_key_surface_height. Also
   measure/decide your real target_key_height against your own piano or
   bench setup (upright pianos commonly range 730-750mm floor-to-key-top).

   PRINT-BED SIZE
   --------------
   max_segment_length defaults to 200mm (safe for small/mid printers). If you
   have a 250-300mm bed, raise it -- fewer segments, fewer joints, stronger.

   HOW TO EXPORT PARTS
   --------------------
   This file renders a full assembly preview by default. To export an
   individual printable part, set the `part` variable (see the list at the
   bottom of this file, in the "PART SELECTOR" section) via the -D flag, e.g.:
     openscad -D 'part="leg_lower"' -o leg_lower.stl keyboard_stand.scad
   See export_all.sh for a script that exports every part+quantity in one go.
   ============================================================================ */

// ---------------------------------------------------------------------------
// KEYBOARD (Akai MPK249) -- from manufacturer spec sheet
// ---------------------------------------------------------------------------
mpk_width  = 736.6;  // overall case width, mm
mpk_depth  = 311.15; // overall case depth, mm
mpk_height = 85.8;   // overall case height incl. pitch/mod wheels, mm
mpk_key_surface_height = 65; // ESTIMATED height of top-of-white-key above the
                              // unit's feet. MEASURE YOUR UNIT -- see header.
mpk_weight_kg = 5.7;  // user-supplied weight

// ---------------------------------------------------------------------------
// TARGET HEIGHT -- upright piano, top of white keys above the floor
// ---------------------------------------------------------------------------
target_key_height = 730; // mm. Upright pianos commonly run 730-750mm; adjust
                          // to match the piano/bench you're matching against.

// ---------------------------------------------------------------------------
// FRAME FOOTPRINT -- leg centerline spacing, inset from the keyboard edges
// ---------------------------------------------------------------------------
leg_inset_x = 60; // inset of each leg from the keyboard's left/right edge
leg_inset_y = 25; // inset of each leg from the keyboard's front/back edge
frame_width  = mpk_width - 2*leg_inset_x;  // X span between leg centerlines
frame_depth  = mpk_depth - 2*leg_inset_y;  // Y span between leg centerlines

stretcher_height = 180; // height of the lower stretcher rectangle above floor

// ---------------------------------------------------------------------------
// STRUCTURAL BEAM PARAMETERS
// ---------------------------------------------------------------------------
beam_size   = 26;  // square beam cross-section, mm
rod_d       = 8;   // steel reinforcement rod nominal diameter (M8 rod or 8mm
                    // drill-rod/dowel both work -- no threading/nuts needed)
rod_hole_d  = 8.6; // bore diameter for the rod (light clearance for epoxy film)
joint_len   = 18;  // spigot protrusion / socket pocket depth
joint_clear = 0.3; // per-side clearance, spigot vs socket
spigot_size = beam_size - 8; // 18mm -- leaves ~4mm wall around the socket

// corner-block footprint needs to be bigger than the beam so three
// perpendicular bores (2 horizontal rail rods + 1 vertical leg rod) don't
// eat through the walls
corner_size   = beam_size + 16; // 42mm square footprint
corner_height = beam_size;      // 26mm tall -- same "slice" as one beam layer

// ---------------------------------------------------------------------------
// PRINTER / SECTIONING
// ---------------------------------------------------------------------------
max_segment_length = 200; // mm -- raise this if your printer's bed allows it

// ---------------------------------------------------------------------------
// DERIVED
// ---------------------------------------------------------------------------
platform_height = target_key_height - mpk_key_surface_height;

function n_segs(total, maxlen) = ceil(total / maxlen);
function part_len(total, maxlen) = total / n_segs(total, maxlen);

leg_upper_total = platform_height - stretcher_height - 2*beam_size;
leg_upper_n     = n_segs(leg_upper_total, max_segment_length);
leg_upper_len   = part_len(leg_upper_total, max_segment_length);

rail_long_total = frame_width - corner_size;
rail_long_n     = n_segs(rail_long_total, max_segment_length);
rail_long_len   = part_len(rail_long_total, max_segment_length);

rail_short_total = frame_depth - corner_size;
rail_short_n      = n_segs(rail_short_total, max_segment_length);
rail_short_len    = part_len(rail_short_total, max_segment_length);

// sanity checks
assert(stretcher_height <= max_segment_length,
  "stretcher_height must be <= max_segment_length (it prints as one segment) -- reduce stretcher_height or raise max_segment_length");
assert(platform_height > stretcher_height + 2*beam_size + 50,
  "platform_height too close to stretcher_height -- check target_key_height / mpk_key_surface_height");

echo("=== Akai MPK249 Stand — computed dimensions ===");
echo(str("platform_height (top rail top surface) = ", platform_height, " mm"));
echo(str("frame_width x frame_depth = ", frame_width, " x ", frame_depth, " mm"));
echo(str("leg: 1x lower @ ", stretcher_height, "mm + ", leg_upper_n, "x upper @ ", leg_upper_len, "mm  (x4 legs)"));
echo(str("long rail (front/back, top+stretcher): ", rail_long_n, " segments @ ", rail_long_len, "mm  (x4 runs)"));
echo(str("short rail (left/right, top+stretcher): ", rail_short_n, " segments @ ", rail_short_len, "mm  (x4 runs)"));
echo(str("rod length needed: legs ", 4*platform_height, "mm | long rails ", 4*(rail_long_total+2*joint_len), "mm | short rails ", 4*(rail_short_total+2*joint_len), "mm"));
rod_total = 4*platform_height + 4*(rail_long_total+2*joint_len) + 4*(rail_short_total+2*joint_len);
echo(str("TOTAL rod stock needed: ~", ceil(rod_total/100)*100, " mm (buy a bit extra for offcuts)"));

// ---------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------
module box_xyc(sx, sy, sz, z0=0) {
  // box centered on X/Y, starting at z0
  translate([-sx/2, -sy/2, z0]) cube([sx, sy, sz]);
}

// ---------------------------------------------------------------------------
// beam_core: universal straight segment used for every leg segment and every
// rail segment. Built along +Z, cross-section centered at X=0,Y=0.
//   z = 0 .. length            : the beam body (with a socket pocket carved
//                                 into the bottom joint_len of it)
//   z = length .. length+joint_len : a spigot protruding beyond the nominal
//                                 length, sized to plug into the NEXT part's
//                                 socket pocket.
// A single round bore runs the full length for the reinforcement rod.
// ---------------------------------------------------------------------------
module beam_core(length) {
  difference() {
    union() {
      box_xyc(beam_size, beam_size, length, 0);
      box_xyc(spigot_size, spigot_size, joint_len, length);
    }
    // socket pocket, bottom
    box_xyc(spigot_size + 2*joint_clear, spigot_size + 2*joint_clear, joint_len + 0.5, -0.25);
    // rod bore, full length incl. spigot
    translate([0, 0, -1]) cylinder(d=rod_hole_d, h=length + joint_len + 2, $fn=24);
  }
}

// ---------------------------------------------------------------------------
// foot: bottom termination of a leg. Flared pad for floor stability, spigot
// on top to plug into the bottom-most leg segment's socket. Rod bore runs
// through (hidden under a self-adhesive felt/rubber pad the user sticks on).
// ---------------------------------------------------------------------------
module foot() {
  // Flared as wide as practical without intruding much past the keyboard's
  // own footprint (which would get in the way of a seated player's knees).
  // This meaningfully improves tip resistance vs. a foot no wider than the
  // leg, but does NOT make the stand tip-proof -- see README.md "Stability"
  // section and use an anti-tip wall strap.
  pad_size = beam_size + 80; // 106mm square flared foot pad
  pad_h = 14;
  taper_top = beam_size + 4;
  difference() {
    union() {
      hull() {
        box_xyc(pad_size, pad_size, 0.01, 0);
        box_xyc(taper_top, taper_top, 0.01, pad_h);
      }
      box_xyc(spigot_size, spigot_size, joint_len, pad_h);
    }
    translate([0, 0, -1]) cylinder(d=rod_hole_d, h=pad_h + joint_len + 2, $fn=24);
    // shallow recess on the true bottom face for a self-adhesive felt/rubber pad
    translate([0, 0, -0.5]) cylinder(d=pad_size - 16, h=1.5, $fn=48);
  }
}

// ---------------------------------------------------------------------------
// corner_block: universal rectangle-corner joint. Local design (before the
// caller rotates it into place):
//   - bottom face (Z=0): socket pocket, receives the leg spigot from below
//   - top face (Z=corner_height): if is_top, closed (rod bore just opens
//     here, terminus); if NOT is_top (stretcher corner), a spigot protrudes
//     upward to continue into the next leg segment's socket (pass-through)
//   - +X face: horizontal SPIGOT (feeds the next rail segment going
//     "clockwise" around the frame loop)
//   - +Y face: horizontal SOCKET (receives the rail arriving "clockwise")
// Each of the 4 real corners uses this SAME part, rotated 0/90/180/270 about
// Z so the +X/+Y ports line up with the correct rail directions -- see
// corner_rotation() below.
// ---------------------------------------------------------------------------
module corner_block(is_top) {
  difference() {
    union() {
      box_xyc(corner_size, corner_size, corner_height, 0);
      // +X spigot
      translate([corner_size/2, -spigot_size/2, (corner_height-spigot_size)/2])
        cube([joint_len, spigot_size, spigot_size]);
      // vertical spigot on top -- only for pass-through (stretcher) corners
      if (!is_top) {
        box_xyc(spigot_size, spigot_size, joint_len, corner_height);
      }
    }
    // +Y socket pocket
    translate([-(spigot_size+2*joint_clear)/2, corner_size/2 - joint_len, (corner_height-spigot_size-2*joint_clear)/2])
      cube([spigot_size+2*joint_clear, joint_len+0.5, spigot_size+2*joint_clear]);
    // bottom vertical socket pocket (receives leg spigot from below)
    box_xyc(spigot_size+2*joint_clear, spigot_size+2*joint_clear, joint_len+0.5, -0.25);
    // horizontal rod bores, full width/depth of the block
    translate([-corner_size/2-1, 0, corner_height/2]) rotate([0,90,0]) cylinder(d=rod_hole_d, h=corner_size+2, $fn=24);
    translate([0, -corner_size/2-1, corner_height/2]) rotate([-90,0,0]) cylinder(d=rod_hole_d, h=corner_size+2, $fn=24);
    // vertical rod bore, full height
    translate([0,0,-1]) cylinder(d=rod_hole_d, h=corner_height+2, $fn=24);
  }
}

// index: 0=front-left(FL) 1=front-right(FR) 2=back-right(BR) 3=back-left(BL)
// (X: left- to right+, Y: front- to back+) — see header notes for the
// clockwise-loop derivation that makes this rotation scheme self-consistent.
function corner_rotation(idx) = 90*idx;

// ---------------------------------------------------------------------------
// cradle_locator: small fence tab that mounts on the TOP rail's top surface
// to register the keyboard's footprint edge/corner (like the rubber-foot
// stops on commercial keyboard stands). Glue or 2x self-tapping screws into
// the rail below. One per corner, position derived from leg_inset so it
// lines up with the keyboard's actual corner once mpk_key_surface_height /
// footprint are confirmed against the real unit.
// ---------------------------------------------------------------------------
module cradle_locator() {
  base_w = 34;
  base_d = 34;
  base_h = 6;
  lip_h  = 14;
  lip_t  = 5;
  difference() {
    union() {
      box_xyc(base_w, base_d, base_h, 0);
      // L-shaped lip along two inner edges (registers against keyboard corner)
      translate([-base_w/2, -base_d/2, base_h]) cube([lip_t, base_d, lip_h]);
      translate([-base_w/2, -base_d/2, base_h]) cube([base_w, lip_t, lip_h]);
    }
    // two screw pilot holes into the rail below
    translate([base_w/4, 0, -0.5]) cylinder(d=3.2, h=base_h+1, $fn=16);
    translate([-base_w/4, 0, -0.5]) cylinder(d=3.2, h=base_h+1, $fn=16);
  }
}

// ---------------------------------------------------------------------------
// gusset: optional flat triangular brace, screwed to two adjoining beams
// near a corner to resist frame racking. Prints flat, no supports.
// ---------------------------------------------------------------------------
module gusset() {
  leg_len = 55;
  thick = 6;
  linear_extrude(thick)
    polygon([[0,0],[leg_len,0],[0,leg_len]]);
  // screw pilot holes (drop from the extrude so hole is through-thickness)
  translate([leg_len*0.3, leg_len*0.15, -0.5]) cylinder(d=3.2, h=thick+1, $fn=16);
  translate([leg_len*0.15, leg_len*0.3, -0.5]) cylinder(d=3.2, h=thick+1, $fn=16);
}

// ============================================================================
// ASSEMBLY (preview only — not for printing as a single piece)
// ============================================================================
module leg_assembly(x, y, corner_idx) {
  rotz = corner_rotation(corner_idx);
  // foot: pad_h(14) offset already baked into foot(); place its base at Z=0
  translate([x, y, 0]) foot();
  // lower leg segment sits on top of the foot's spigot: spigot top face = pad_h(14)+joint_len(18)... but the
  // NEXT part's socket just needs its z=0 face flush against foot's z=pad_h(14) face (per beam_core convention
  // the socket occupies the part's own bottom joint_len, spigot from the part below fills it) -> so lower leg
  // segment z=0 aligns with foot pad_h.
  foot_pad_h = 14;
  translate([x, y, foot_pad_h]) beam_core(stretcher_height);
  // stretcher corner block sits with its z=0 flush at foot_pad_h + stretcher_height
  z_stretcher = foot_pad_h + stretcher_height;
  translate([x, y, z_stretcher]) rotate([0,0,rotz]) corner_block(false);
  // leg upper segments
  z_upper0 = z_stretcher + corner_height;
  for (i = [0 : leg_upper_n - 1])
    translate([x, y, z_upper0 + i*leg_upper_len]) beam_core(leg_upper_len);
  // top corner block
  z_top = z_upper0 + leg_upper_n*leg_upper_len;
  translate([x, y, z_top]) rotate([0,0,rotz]) corner_block(true);
}

module rail_run(p0, seg_n, seg_len, dir) {
  // places seg_n beam_core segments end-to-end starting at p0, extending in
  // direction `dir` ("+X","-X","+Y","-Y"). beam_core builds along its own
  // +Z, so we rotate that build axis onto the requested horizontal axis
  // (rotating about Z would only spin a symmetric beam in place -- it does
  // NOT tip it over, so the tip angle must be about X or Y).
  rot = (dir == "+X") ? [0,90,0]
      : (dir == "-X") ? [0,-90,0]
      : (dir == "+Y") ? [-90,0,0]
      : [90,0,0]; // "-Y"
  translate(p0) rotate(rot)
    for (i = [0 : seg_n - 1])
      translate([0,0,i*seg_len]) beam_core(seg_len);
}

module assembly() {
  hx = frame_width/2;
  hy = frame_depth/2;
  corners = [[-hx,-hy], [hx,-hy], [hx,hy], [-hx,hy]]; // FL, FR, BR, BL
  for (i = [0:3]) leg_assembly(corners[i][0], corners[i][1], i);

  foot_pad_h = 14;

  // rail runs sit at the mid-height of the corner blocks they plug into
  z_rail_stretcher = foot_pad_h + stretcher_height + corner_height/2;
  z_rail_top       = platform_height - corner_height/2;

  // Loop order FL(0)->FR(1)->BR(2)->BL(3)->FL: front rail travels +X, right
  // rail travels +Y, back rail travels -X, left rail travels -Y. Each run
  // starts at the "from" corner's outward face (offset by corner_size/2).
  gap = corner_size/2;
  // stretcher rails
  rail_run([-hx+gap, -hy, z_rail_stretcher], rail_long_n, rail_long_len, "+X");
  rail_run([hx, -hy+gap, z_rail_stretcher], rail_short_n, rail_short_len, "+Y");
  rail_run([hx-gap, hy, z_rail_stretcher], rail_long_n, rail_long_len, "-X");
  rail_run([-hx, hy-gap, z_rail_stretcher], rail_short_n, rail_short_len, "-Y");
  // top rails
  rail_run([-hx+gap, -hy, z_rail_top], rail_long_n, rail_long_len, "+X");
  rail_run([hx, -hy+gap, z_rail_top], rail_short_n, rail_short_len, "+Y");
  rail_run([hx-gap, hy, z_rail_top], rail_long_n, rail_long_len, "-X");
  rail_run([-hx, hy-gap, z_rail_top], rail_short_n, rail_short_len, "-Y");

  // keyboard silhouette for visual reference (not printed)
  %translate([-mpk_width/2, -mpk_depth/2, platform_height]) cube([mpk_width, mpk_depth, mpk_height]);

  // cradle locators near the 4 top corners, inset to the keyboard's actual corner
  for (i = [0:3]) {
    cx = corners[i][0] * (mpk_width/2 - 17) / hx;
    cy = corners[i][1] * (mpk_depth/2 - 17) / hy;
    translate([cx, cy, platform_height]) rotate([0,0,corner_rotation(i)+180]) cradle_locator();
  }
}

// ============================================================================
// PART SELECTOR — set `part` via -D 'part="..."' for STL export.
// Valid values: "assembly" (default preview), "leg_lower", "leg_upper",
// "corner_top", "corner_stretcher", "foot", "rail_long", "rail_short",
// "cradle_locator", "gusset"
// ============================================================================
part = "assembly";

if (part == "assembly") assembly();
else if (part == "leg_lower") beam_core(stretcher_height);
else if (part == "leg_upper") beam_core(leg_upper_len);
else if (part == "corner_top") corner_block(true);
else if (part == "corner_stretcher") corner_block(false);
else if (part == "foot") foot();
else if (part == "rail_long") beam_core(rail_long_len);
else if (part == "rail_short") beam_core(rail_short_len);
else if (part == "cradle_locator") cradle_locator();
else if (part == "gusset") gusset();
