# Akai MPK249 Keyboard Stand

Parametric OpenSCAD stands that hold an Akai MPK249 at the height of an
upright piano's keys (top of white keys ~730mm off the floor), printed in
sections on a normal desktop FDM printer and reinforced internally with
steel rod.

There are **two independent designs** here — pick one:

| | **A. Four-leg frame** | **B. Single post** |
|---|---|---|
| File | `keyboard_stand.scad` | `single_post_stand.scad` |
| Shape | table-like box frame | inclined column on a ballasted base |
| Printed parts | ~36 | ~24 |
| Knee clearance | legs at the keyboard's corners | open — post leans away from you |
| Tip resistance (sideways) | ~3 kgf | ~10.9 kgf ballasted / ~5.9 kgf not |
| Needs a wall strap? | yes, strongly recommended | no, if you ballast the hub |

**Design B is the better stand**, somewhat counter-intuitively. A single post
sounds less stable than four legs, but the ballasted hub both adds weight and
drops the centre of gravity, and tip resistance scales with
(weight x margin / CoG height). Design A is tall, light and narrow front-to-back,
which is the worst combination. Design B is documented
[further down](#design-b--single-post-stand).

---

# Design A — four-leg frame

## How it's built

A rigid box frame, like a small table: 4 vertical legs, a top rectangle
(the platform the keyboard sits on) and a lower stretcher rectangle for
rigidity. Every long run (each leg, each rail) is too long to print in one
piece, so it's sliced into short square-beam segments that plug together
with spigot/socket joints, and an **8mm steel rod runs through the full
length of every run**, epoxied in at each joint.

The rod is doing the real structural work. A glued plastic butt joint alone
is not something to trust at ~650mm of height under a keyboard that gets
pressed on — the rod carries the bending load; the printed plastic carries
shape, alignment, and shear.

Everything is generated from `keyboard_stand.scad`. Open it in OpenSCAD to
tweak parameters (they're all at the top of the file, with comments) and
re-render.

## Before you print anything: measure your unit

Two numbers in the file are estimates, not measurements, and they directly
set how tall the stand is:

- **`mpk_key_surface_height` (default 65mm)** — height from the MPK249's
  feet to the top of the white keys. The Akai spec (85.8mm) is the tallest
  point of the case, which includes the pitch/mod wheel housing — that sits
  *above* the actual key surface. Put the keyboard on a table and measure
  straight up to a white key with a tape measure or square; update this
  value.
- **`target_key_height` (default 730mm)** — floor to top-of-key height you're
  matching. Upright pianos commonly run 730–750mm; measure the piano/bench
  you're actually trying to match, or just pick a comfortable playing height.

`platform_height` (where the keyboard physically rests) is computed as
`target_key_height - mpk_key_surface_height`. Get those two inputs right
before you commit to printing 30-some parts.

Re-run OpenSCAD after changing anything — the console/terminal echoes the
computed dimensions, segment counts, and rod lengths so you can sanity-check
before exporting:

```
openscad --export-format=echo -o - keyboard_stand.scad
```

## Parts list (default parameters)

| Part | STL | Qty | Notes |
|---|---|---|---|
| Leg, lower segment | `leg_lower.stl` | 4 | floor to stretcher height (180mm) |
| Leg, upper segment | `leg_upper.stl` | 12 | 3 per leg × 4 legs, ~144mm each |
| Foot | `foot.stl` | 4 | flared pad, stick a felt/rubber bumper on the bottom |
| Corner block, stretcher | `corner_stretcher.stl` | 4 | leg passes through; 2 rail sockets |
| Corner block, top | `corner_top.stl` | 4 | leg terminates here; 2 rail sockets |
| Long rail segment | `rail_long.stl` | 12 | 3 segments × 4 runs (front/back, top+stretcher), ~192mm each |
| Short rail segment | `rail_short.stl` | 8 | 2 segments × 4 runs (left/right, top+stretcher), ~110mm each |
| Cradle locator | `cradle_locator.stl` | 4 | fence tab at each top corner, registers the keyboard's corner |
| Gusset (optional) | `gusset.stl` | 8 | extra anti-racking brace, 1 per corner (top+stretcher) |

Segment counts/lengths above are for the **default** parameters (200mm max
segment, 730mm target key height, 65mm key-surface estimate). If you change
`target_key_height`, `mpk_key_surface_height`, or `max_segment_length`,
re-run OpenSCAD, read the new echoed counts, and update `export_all.sh`
quantities to match before exporting.

Run `./export_all.sh` to export every STL into `stl/` in one go.

## Hardware BOM

- **Steel rod, 8mm diameter, ~6.3m total** (smooth rod or M8 threaded rod —
  threading isn't needed since nothing is torqued down, so plain 8mm
  drill-rod/round bar is cheaper and simpler; cut to length with a hacksaw or
  angle grinder). Buy a little over the computed total for offcuts and square
  cuts. The console echo reports the exact breakdown per leg/rail run.
- **2-part epoxy** (JB Weld or similar) — for bonding rod-to-socket and
  spigot-to-socket at every joint. Don't use cyanoacrylate/PLA "weld" as the
  primary structural bond; epoxy handles the gap-filling and has much better
  long-term creep resistance under sustained load.
- **4x self-adhesive felt or rubber furniture pads**, ~85–100mm — stick to
  the underside of each foot.
- **Small self-tapping screws (M3.5×12 or similar), ~24x** — for the cradle
  locators (2 each) and gussets (2 each) if you use them.
- **1x anti-tip furniture strap** (the kind sold for bookcases/dressers) —
  see Stability below. Not optional in my view; read that section.

## Print settings

- **Material: PETG over PLA if you can.** This stands loaded, indoors,
  possibly for years — PETG resists creep (slow permanent bending under
  sustained load) much better than PLA, which matters a lot for the legs.
- **Orientation: print every beam segment lying flat** (long axis
  horizontal on the bed), not standing on end. This is both the more stable
  print (short + wide vs. tall + thin) and the structurally correct
  orientation — it puts the strong in-layer plastic along the beam's length,
  where the bending load is, instead of relying on layer adhesion to resist
  bending.
- **Infill: 40–60% (or higher) on all beam segments, corner blocks, and
  feet.** These are load-bearing; don't print them like decorative parts.
  Gyroid or cubic infill patterns are both fine.
- **Walls: 3–4 perimeters minimum.**
- **Supports:** generally not needed — the horizontal 8.6mm rod bore bridges
  fine on most printers, and the spigot/socket features are small enough to
  bridge cleanly. Check your first print of each part; add support only for
  the rod bore if your printer struggles with it.
- **Print one of each joint type first** (`leg_lower`, `leg_upper`,
  `corner_top`, `corner_stretcher`, `foot`, `rail_long` or `rail_short`) and
  dry-fit them together before committing to the full run. Spigot/socket
  clearance (`joint_clear = 0.3mm`) is tuned for a snug push-fit on a
  reasonably well-calibrated printer; loosen it (increase `joint_clear`) if
  your prints run oversized.

## Assembly order

1. Dry-fit every joint first, no glue, to confirm fit and catch any printer
   calibration issues before anything is permanent.
2. Build each **leg** as its own sub-assembly: foot → leg_lower →
   corner_stretcher → leg_upper × 3 → corner_top. Cut an 8mm rod to the full
   leg length, dry-insert it, then go back through joint by joint applying
   epoxy to the socket and spigot faces and to the rod as you insert it.
   Keep the leg straight (a flat floor or a straightedge helps) while the
   epoxy cures.
3. Build the **8 rail runs** (2 long + 2 short, at both stretcher and top
   height) the same way — segments glued end to end with their own rod.
4. Assemble the frame: glue the 4 legs' corner_stretcher and corner_top
   horizontal sockets to the rail ends, forming the closed stretcher
   rectangle and top rectangle simultaneously. Work on a flat floor, check
   the frame is square (measure both diagonals — they should match) before
   the epoxy sets.
5. Once cured, screw on the 4 cradle locators at the top corners, positioned
   against your actual keyboard's corners (dry-fit the MPK249 on top first
   and mark the corners before drilling/screwing).
6. Optional: screw on the 8 gussets at the top and stretcher corners for
   extra anti-racking stiffness.
7. Stick felt/rubber pads on the feet.
8. Set the keyboard on the platform, registered against the cradle locators.

## Stability — please read this

The MPK249's footprint is narrow front-to-back (311mm) relative to the
stand's height (~665mm to the platform), and the legs in this design are
**vertical, not splayed** — the ground footprint is only as wide as the
platform itself (plus a modest ~40mm foot flare each way). That's a real
tip-stability limitation, not a hypothetical one: a rough worst-case
calculation (total weight ~9kg between keyboard + stand, CoG around
550-600mm up, tip pivot at the foot edge ~185mm from center with the
default foot flare) puts the sideways force needed to tip it front-to-back
at only around 3kg-force — comparable to a moderate bump, not a shove. This
is a rough estimate (actual printed-stand weight and CoG depend on your
infill/material choices) meant to make the order of magnitude clear, not an
exact figure.

This is normal for tall, narrow, top-loaded printed furniture, and the
standard, cheap, effective fix is the one used for bookcases and dressers
with the same problem: **use an anti-tip strap to anchor the top of the
stand to a wall or heavy furniture behind it.** Do this before you trust the
stand with the keyboard on it. Playing normally (pressing keys, which is a
vertical load right above the legs) is not the risk — a lateral bump or
someone leaning on the front edge is.

If you want more inherent stability without a strap, the parametric places
to get it (in `keyboard_stand.scad`) are:
- Reduce `leg_inset_y` (moves legs closer to the keyboard's own front/back
  edges — there's only ~5-10mm of headroom left by default before the legs
  are at the case edges).
- Increase the foot flare in `foot()` (trades off against knee clearance if
  you sit close in front of it).
- The more effective but more involved option: angle the legs outward
  (splay) below the stretcher height instead of keeping them vertical — this
  file doesn't implement that; it would need mitered/compound-angle joints
  at the stretcher corners.

---

# Design B — single post stand

An inclined column on a ballasted base. This is the design I'd build.

```
        keyboard
   ═════════════════   <- two lateral arms, 550mm, on a yoke plate
          ╱
         ╱              <- post, 75° from horizontal, leaning AWAY from you
        ╱                  (this lean is what gives you knee clearance)
       ╱
   ┌──┴──┐
 ╱─┤ HUB ├─╲            <- ballast box, + two feet splayed 90° apart,
╱  └─────┘  ╲              pointing backward, out of your foot space
```

## How it's built

- **Ballast hub** — a low, wide, open-top box (180 x 220 x 100mm) printed as
  4 quadrants that bolt together with splice plates. You fill it with bagged
  sand, bricks, or gym weight plates.
- **Two feet** — splayed backward from the hub's rear corners, 90° apart.
  They point away from the player so they're not in your foot space, and the
  tips stay inside the keyboard's own width so they aren't a trip hazard.
  Each plugs 80mm into a closed sleeve on the hub and is pinned with two M6
  cross bolts. (Splay is adjustable — see the table below.)
- **Post** — 75° from horizontal, leaning backward, printed as 3 stacked
  **hollow extrusion-profile** segments (80 x 80mm, 3.5mm wall, four corner
  bosses) over **4 continuous 8mm steel rods** that run unbroken from the base
  shoe all the way into the yoke. See [the post profile](#the-post-profile).
- **Yoke** — a wedge block at the top that converts the 75° post to a
  horizontal mounting plate.
- **Tray arms** — two lateral arms (550mm each, 200mm apart) rather than a
  solid tray, each on 2 rods. Two arms carry the keyboard perfectly well and print far more
  easily than a solid 550 x 260mm slab, which wouldn't fit most beds.

## Why ballast, and why the post is rod-reinforced

**Ballast.** The base footprint, not the post's strength, decides whether
this tips over. Ballast adds weight *and* drops the combined centre of
gravity toward the floor, and both terms help:
tip resistance ≈ weight x horizontal margin / CoG height. With 6kg in the
hub the CoG drops from 436mm to 323mm and total weight rises from 14.7kg to
20.7kg — that's why the numbers nearly double. **Fill the hub.**

**Rods.** The post is a cantilever: the keyboard's weight acts ~160mm
horizontally away from the post's base, so the base carries a constant
bending moment (roughly 10 N·m just from the keyboard sitting there, several
times that if you lean on the keys). Printed plastic is weakest in exactly
the direction a bending load pulls layers apart, and it *creeps* — deforms
slowly and permanently under a load held for months. Four 8mm rods carry
that moment; the plastic provides shape, spacing and shear transfer. **The
rods are not optional in this design.**

## The post profile

The post is a hollow extrusion-style section rather than a solid block:

```
  ┌─────────────────────┐    80 x 80mm, 3.5mm wall
  │ ◎               ◎   │    ◎ = corner boss, 8.6mm bore, at +/-27
  │  ╲             ╱    │    short webs tie each boss to both walls
  │                     │
  │  ╱             ╲    │    open centre - nothing to fill
  │ ◎               ◎   │
  └─────────────────────┘
```

**Print it standing up, 0% infill, no support.** Because the profile is
prismatic, every surface is a vertical wall — there is nothing to overhang and
nothing to fill. The webs replace infill with geometry you can actually
calculate, and walls extrude continuously where infill is constant direction
changes and travel moves.

Against the previous 60mm solid-ish section at 50% infill:

| | 60sq @50% infill | 80sq hollow | change |
|---|---|---|---|
| plastic (post only) | 1494 g | 1146 g | **−23%** |
| bending stiffness EI | 1.82e10 | 3.16e10 | **1.7x** |
| stiffness per kg | 1.2e7 | 2.8e7 | **2.3x** |

Most of the stiffness gain isn't the hollow section itself — it's that the
rods moved from ±20 to ±27, which alone is worth ~1.8x on their contribution.
Infill sits near the neutral axis, where material contributes almost nothing
to bending; the point of the profile is to get material (and the rods) out to
the edges where it earns its keep.

## Compression at the seams (optional)

The four rods can be run as **post-tensioning tendons** rather than just being
epoxied: thread the ends, and the nuts in the yoke's counterbores squeeze every
seam permanently closed so the joints never see tension at all.

The preload needed is small. For a 60 N·m design moment this section needs
~2.9 kN total, ~723 N per rod, which is about **1.2 N·m of torque** — barely
more than finger-tight — and puts only 1.27 MPa on the seam. The deeper hollow
section actually needs *53% less* preload than the old solid one, because
section modulus grows faster than bearing area.

Two things worth knowing before you bother:

- **It buys robustness, not strength.** At 60 N·m the steel carries 91% of the
  bending and the plastic sees ~0.11 MPa of tension — a ~226x margin against
  PETG's layer-adhesion strength. The layer bonds were never close to failing.
  What you gain is a **demountable column** (loosen four nuts and it packs
  flat) and no dependence on epoxy in tension.
- **Creep will eat the preload if you use plain nuts.** The rods are so stiff
  axially that **0.1mm of creep shortening loses ~1687 N per rod** — more than
  the whole preload. Either use disc-spring (Belleville) stacks under the nuts,
  or re-torque after a week, a month, then annually. Wire rope would dodge this
  entirely (~26x more compliant) but can't carry bending, so it can't replace
  the rods here.

### Why nothing has alignment bosses

Every segmented member here — post, arms, feet — butts together on **flat
faces** with no spigot/socket. That's deliberate: two or more parallel rods
already remove every degree of freedom at the joint, so a boss adds nothing
but does eat bearing and glue area.

It also avoids a trap. The arms originally had an 18.2mm boss, but their rod
bores sit at ±10 and span ±5.7–14.3, so the bores cut 3.4mm into the boss
from both sides — it came out hacked into a cross shape and the rods couldn't
pass through the joint. The feet had the same collision with only 0.3mm of
clearance, a sliver that would never have printed. If you re-introduce a boss,
check it clears `rod_hole_d/2` beyond every rod centre.

The bottom ends are anchored by **bonded length in the shoe**, not nuts —
because the rods tilt while the shoe's underside is horizontal, four coaxial
nut pockets would end up at four different depths. Epoxy loaded in shear along
a steel rod is reliable (~0.4 MPa here); that's a completely different demand
from pulling a printed seam apart. All tensioning happens at the yoke end.

## Stability numbers

Computed by the model itself — run `openscad --export-format=echo -o - single_post_stand.scad`
and it echoes these for your current parameters. Values are the sideways force
needed at keyboard height to tip the stand:

| | forward (toward you) | backward | sideways |
|---|---|---|---|
| **Ballasted, 6kg in hub** | 8.9 kgf | 15.1 kgf | 10.9 kgf |
| **Unballasted** | 5.3 kgf | 6.9 kgf | 5.9 kgf |

For comparison, Design A manages about 3 kgf. Even unballasted this is the
more stable stand; ballasted it's comfortably solid.

These come from a mass model with **estimated** print weights
(`est_post_kg` etc. near the top of the file). They're order-of-magnitude
guidance, not certified figures — weigh your actual prints and update those
values if you want the numbers to be tighter.

### Foot splay angle

Sideways is the weakest tipping direction and backward is by far the
strongest, so widening the feet trades surplus margin for the direction that
actually needs it. `foot_splay_half` controls this (it's the half-angle from
the rear centreline, so 45 = 90° between the feet):

| `foot_splay_half` | feet apart | forward | backward | sideways |
|---|---|---|---|---|
| 22.5 | 45° | 9.4 kgf | 19.8 kgf | 8.8 kgf |
| 30 | 60° | 9.4 kgf | 18.7 kgf | 9.6 kgf |
| **45 (default)** | **90°** | **9.4 kgf** | **15.7 kgf** | **11.4 kgf** |

The default is 90° apart: it buys **30% more sideways resistance** while
backward stays the strongest direction by a comfortable margin. Forward is
unaffected either way — that comes from the hub's forward reach, not the
feet. Set it to 22.5 if you prefer the narrower stance.

At 90° the foot tips land at x=-322, y=±292 — inside the keyboard's own
736mm width, so they don't stick out sideways into walking space.

One deliberate trade-off: the hub's front edge sticks out about 70mm in
front of the keyboard's front edge. That forward reach is what buys the
9.4 kgf forward tip resistance — forward is the dangerous direction, since
that's where you are. The hub is only 100mm tall, so it sits under your
feet/ankles rather than your knees. If you find you're kicking it, move it
back with `hub_cx` and re-read the echoed numbers before you commit.

## Parts list

| Part | STL | Qty | Notes |
|---|---|---|---|
| Post segment | `post_segment.stl` | 3 | ~193mm each, hollow profile, print standing up |
| Post shoe | `post_shoe.stl` | 1 | angled seat, bolts to hub floor |
| Post yoke | `post_yoke.stl` | 1 | 75° → horizontal wedge |
| Arm centre | `arm_center.stl` | 2 | 200mm, bolts to yoke |
| Arm wing | `arm_wing.stl` | 4 | 175mm, 2 per arm |
| Foot root | `foot_root.stl` | 2 | plugs into hub sleeve, cross-bolted |
| Foot segment | `foot_segment.stl` | 2 | outer segment |
| Foot tip | `foot_tip.stl` | 2 | tapered, felt pad recess |
| Hub quadrant, front | `hub_quad_front.stl` | 2 | print 2, mirror one in your slicer |
| Hub quadrant, rear | `hub_quad_rear.stl` | 2 | carries the foot sleeve; mirror one |
| Splice plate | `splice_plate.stl` | 4 | bolts across hub seams inside |
| Keyboard stop | `keyboard_stop.stl` | 4 | locates the keyboard on the arms |

Run `./export_post.sh` to write all of these to `stl_post/`.

## Hardware BOM

- **8mm steel rod, ~6.6m total.** Plain round bar/drill rod is fine — nothing
  is torqued, so threaded rod buys you nothing. Cut with a hacksaw.
  Breakdown: 4 x ~716mm (post, running into shoe and yoke), 4 x 550mm (arms),
  4 x ~380mm (feet).
- **2-part epoxy** — every rod-in-bore and every plug/socket joint.
- **M6 bolts + nuts**: 4 (shoe to hub floor), 4 (foot cross bolts),
  8 (hub seams/splice plates). M6 x 40 covers most; the shoe bolts need to
  reach through the hub floor.
- **M5 bolts + nuts, 8** — arms to yoke plate.
- **Small self-tapping screws, 8** — keyboard stops.
- **Ballast, ~6kg**: a bag of play sand, two housebricks, or a 5kg gym plate.
  **Use a bag** rather than loose sand — the hub is bolted, not sealed, and
  bagged ballast also puts no outward pressure on the walls.
- **Self-adhesive felt/rubber pads** — 2 for the foot tips, 4 for the hub
  underside.
- **Adhesive rubber or foam strip** — along the top of both arms, so the
  keyboard doesn't slide or buzz against bare plastic.

## Print settings

Same principles as Design A: **PETG over PLA** (creep resistance matters when
a load sits on it for years), 40–60% infill on all structural parts, 3–4
perimeters.

Orientation notes specific to this design:

- **Post segments**: print **standing up** (axis vertical), **no infill, no
  support**. The profile is prismatic, so every surface is a vertical wall —
  the slicer just traces the outline. Set infill to 0%; the webs *are* the
  infill. This is the opposite of the advice for the other beams, and it's
  only safe because the rods take the bending (see below).
- **Arms and feet**: print lying down, long axis horizontal. These are solid
  beams, so this puts strong in-layer plastic along the length where the
  bending load is, instead of relying on layer adhesion.
- **Post yoke**: print **upside down**, flat top face on the bed. Then the
  angled socket and rod bores are only 15° off vertical and need no support.
- **Post shoe**: flat base on the bed, right way up — the socket is again 15°
  off vertical, so no support.
- **Hub quadrants**: floor on the bed. The rear quadrants bridge ~50mm over
  the foot sleeve; slow your first bridge layer, or print those two on their
  side if your printer bridges poorly.
- **Dry-fit one of each joint type before printing the full set.**

## Assembly order

1. Dry-fit everything first, no glue.
2. **Hub**: bolt the 4 quadrants together, splice plates on the inside seams.
   Epoxy the seams as you go.
3. **Post**: thread the 4 rods through the shoe, stack the 3 post segments
   onto them, then the yoke on top. Check it's straight against a
   straightedge, then work back through it joint by joint with epoxy — on the
   rods, in the bores, and on every mating face. Let it cure fully before
   standing it up.
4. Bolt the shoe down to the hub floor (4 x M6). Its bolt pattern deliberately
   spans all four quadrant seams and helps tie the hub together.
5. **Feet**: rod + epoxy the root/outer/tip segments into one beam each, slide
   80mm into the hub sleeves, then fit the 2 M6 cross bolts per foot.
6. **Arms**: rod + epoxy each arm (centre + 2 wings), then bolt both arms down
   to the yoke plate with M5.
7. Fill the hub with bagged ballast.
8. Sit the keyboard on the arms, mark its position, then screw on the 4
   keyboard stops. Add rubber strip along the arms.
9. Felt pads under the foot tips and hub.

## Files

**Design A — four-leg frame**
- `keyboard_stand.scad` — the parametric design (parameters at the top)
- `export_all.sh` — batch-exports every part to `stl/`
- `stl/` — exported STLs (generated; re-run `export_all.sh` after changes)

**Design B — single post**
- `single_post_stand.scad` — the parametric design
- `export_post.sh` — batch-exports every part to `stl_post/`
- `stl_post/` — exported STLs (generated; re-run `export_post.sh` after changes)

**Both**
- `renders/` — preview renders generated while designing these

Both files echo their computed dimensions, segment counts and rod lengths
when you run them. After changing any parameter:

```
openscad --export-format=echo -o - single_post_stand.scad
```

read the echoed output, and update the quantities in the export script and
this README if the segment counts changed.
