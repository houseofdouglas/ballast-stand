#!/usr/bin/env bash
# Exports every distinct printable part of the SINGLE-POST stand to STL.
# Quantities are for one complete stand -- see README.md for the full table.
set -euo pipefail
cd "$(dirname "$0")"

SCAD=single_post_stand.scad
OUT=stl_post
mkdir -p "$OUT"

export_part() {
  local part="$1" qty="$2"
  echo "==> ${part}  (print x${qty})"
  openscad -D "part=\"${part}\"" -o "${OUT}/${part}.stl" "$SCAD"
}

# part               qty
export_part post_segment   3   # stacked up the column
export_part post_shoe      1
export_part post_yoke      1
export_part arm_center     2   # one per arm
export_part arm_wing       4   # two per arm
export_part foot_root      2   # the segment that plugs into the hub (1 per foot)
export_part foot_segment   2   # the outer segment (1 per foot)
export_part foot_tip       2
export_part hub_quad_front 2   # print 2, mirroring one in your slicer
export_part hub_quad_rear  2   # print 2, mirroring one in your slicer
export_part splice_plate   4
export_part keyboard_stop  4

echo
echo "All STLs written to ${OUT}/"
echo "NOTE: post_segment count comes from your parameters. Re-check the echo"
echo "output (openscad --export-format=echo -o - ${SCAD}) after changing any dimension and"
echo "update the quantities above and in README.md to match."
