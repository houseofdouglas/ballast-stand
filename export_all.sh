#!/usr/bin/env bash
# Exports every distinct printable part of the MPK249 stand to STL.
# Each part is a distinct SHAPE -- print the quantity noted in the comment
# for a complete stand (4 legs x lower+upper segments, 8 rail runs, etc).
set -euo pipefail
cd "$(dirname "$0")"

SCAD=keyboard_stand.scad
OUT=stl
mkdir -p "$OUT"

export_part() {
  local part="$1" qty="$2"
  echo "==> ${part}  (print x${qty})"
  openscad -D "part=\"${part}\"" -o "${OUT}/${part}.stl" "$SCAD"
}

# part name           qty needed for a full stand (see README.md for the full BOM table)
export_part leg_lower        4   # 1 per leg
export_part leg_upper        12  # 3 per leg x 4 legs (count = leg_upper_n from the .scad echo output)
export_part corner_top       4   # top platform corners
export_part corner_stretcher 4   # lower stretcher corners
export_part foot             4   # 1 per leg
export_part rail_long        12  # 3 segments x 4 runs (2 top + 2 stretcher, front/back)
export_part rail_short       8   # 2 segments x 4 runs (2 top + 2 stretcher, left/right)
export_part cradle_locator   4   # 1 per top corner
export_part gusset           8   # optional reinforcement, 4 top corners + 4 stretcher corners

echo
echo "All STLs written to ${OUT}/"
echo "NOTE: leg_upper / rail_long / rail_short segment counts and lengths are"
echo "computed from your parameters (target_key_height, max_segment_length, etc)."
echo "If you change those in keyboard_stand.scad, re-check the echo output"
echo "(run: openscad --export-format=echo -o - keyboard_stand.scad) and update the qty"
echo "numbers above and in README.md to match."
