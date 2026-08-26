#!/usr/bin/env python3
"""
extract-fig4a.py  ·  Recover the Figure 4 Panel A estimates from the source PDF.

Figure 4 Panel A is the paper's headline event study: differential log adjusted
gross income for occupants of Destroyed and Survived homes, relative to the
Adjacent comparison group, in years -4 to +4 around the fire (year -1 = 0 by
construction). The paper ships no coefficient table for it, so we recover the
numbers from the figure itself rather than eyeballing them off the page.

Unlike the citizen-complaints figure, Panel A is a RASTER image inside the PDF
(page 32 carries two 3397x2100 PNGs, one per panel), so there are no vector
paths to read. We instead render the page at 600 dpi and measure pixels:

  - y calibration : the five printed y-axis ticks (0.05 ... -0.15) left of the
                    panel's axis line, fit by least squares.
  - x calibration : the Destroyed marker centres for year -4 and year +4 are the
                    leftmost/rightmost marker blobs; year 0 is their midpoint,
                    cross-checked against the dashed vertical line.
  - series values : median y of the series-coloured pixels in a narrow column
                    at each year's marker centre.
  - 95% CI bounds : min/max of the ribbon fill in the same column, including the
                    blended colour where the two ribbons overlap.

Both series are pinned to 0 at year -1 by construction, which gives a free
accuracy check on the whole pipeline, and we assert the recovered Destroyed path
matches the magnitudes quoted in the paper text (~-10% in years 1-2, back to
about zero by year 4) so a silently-broken extraction fails loud.

Run (from the paper's data-viz/ folder):
    python3 code/extract-fig4a.py
    -> writes data/fig4a-estimates.csv   (gitignored; regenerate locally)

Deps: PyMuPDF, numpy, Pillow (`pip install pymupdf numpy pillow`).
Needs the source PDF, which is gitignored and kept only locally.
"""
import csv
import os

import fitz  # PyMuPDF
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
PAPER_DIR = os.path.normpath(os.path.join(HERE, "..", ".."))
PDF = os.path.join(PAPER_DIR, "Wildfire_Losses_NBER_2026.pdf")
OUT = os.path.join(HERE, "..", "data", "fig4a-estimates.csv")

PAGE = 31   # page 32, Figure 4
DPI = 600

# Panel A occupies the top half of the page; crop generously around it so the
# Panel B copy of the same colours never enters the measurement.
PANEL_TOP, PANEL_BOT = 1233, 2700          # page pixels at 600 dpi
AXIS_SEARCH = (1300, 1500)                 # x window holding the panel's y axis

# Colours as drawn by the paper's plotting package (Dark2 palette).
DESTROYED = (217, 95, 2)      # orange line + round markers
SURVIVED = (117, 112, 179)    # purple dashed line + triangle markers
FILL_D = (235, 174, 127)      # Destroyed 95% ribbon
FILL_S = (185, 182, 216)      # Survived 95% ribbon
FILL_OVERLAP = (175, 141, 152)  # where the two ribbons cross

Y_TICK_VALUES = [0.05, 0.00, -0.05, -0.10, -0.15]   # top to bottom
YEARS = list(range(-4, 5))


def render(pdf, page, dpi):
    doc = fitz.open(pdf)
    pm = doc[page].get_pixmap(dpi=dpi)
    a = np.frombuffer(pm.samples, dtype=np.uint8)
    return a.reshape(pm.height, pm.width, pm.n)[:, :, :3].astype(int)


def near(img, rgb, tol=25):
    """Mask of pixels within `tol` (summed channel distance) of `rgb`."""
    return np.abs(img - np.array(rgb)).sum(axis=2) < tol


def runs(idx, gap=3):
    """Group a sorted index array into runs separated by more than `gap`."""
    out, cur = [], [idx[0]]
    for i in idx[1:]:
        if i - cur[-1] <= gap:
            cur.append(i)
        else:
            out.append(cur)
            cur = [i]
    out.append(cur)
    return out


def main():
    page = render(PDF, PAGE, DPI)
    panel = page[PANEL_TOP:PANEL_BOT]
    dark = panel.max(axis=2) < 120

    # --- locate the panel's y axis (the one long vertical dark run) ---
    lo, hi = AXIS_SEARCH
    col_heights = dark[:, lo:hi].sum(axis=0)
    axis_x = lo + int(np.argmax(col_heights))

    # --- y calibration from the five printed ticks left of that axis ---
    # The ticks are short marks butted against the axis (about 10 px at 600
    # dpi); read only that sliver so the numeric labels further left, which
    # also sit dark on white, can't be mistaken for ticks.
    strip = dark[:, axis_x - 11:axis_x - 1]
    tick_rows = np.where(strip.sum(axis=1) >= strip.shape[1] * 0.8)[0]
    ticks = [float(np.mean(g)) for g in runs(tick_rows)]
    if len(ticks) != len(Y_TICK_VALUES):
        raise SystemExit(f"expected {len(Y_TICK_VALUES)} y ticks, found {len(ticks)}")
    slope_y, intercept_y = np.polyfit(ticks, Y_TICK_VALUES, 1)

    def value(y_px):
        return slope_y * y_px + intercept_y

    # --- x calibration from the first and last Destroyed markers ---
    marks = near(panel, DESTROYED)
    counts = marks.sum(axis=0)
    blobs = runs(np.where(counts >= counts.max() * 0.5)[0])
    centres = [float(np.mean(g)) for g in blobs]
    x_first, x_last = centres[0], centres[-1]       # year -4 and year +4
    step = (x_last - x_first) / 8.0
    x_zero = (x_first + x_last) / 2.0

    # cross-check against the dashed vertical line the paper draws at year 0
    tall = dark.sum(axis=0)
    interior = np.arange(len(tall))
    cand = interior[(interior > axis_x + 100) & (tall > dark.shape[0] * 0.25)]
    if len(cand):
        vline_x = float(np.mean(cand))
        if abs(vline_x - x_zero) > 8:
            raise SystemExit(f"year-0 mismatch: markers say {x_zero:.1f}, "
                             f"dashed line says {vline_x:.1f}")

    # --- read each series at each year ---
    series = {"destroyed": near(panel, DESTROYED), "survived": near(panel, SURVIVED)}
    bands = {
        "destroyed": near(panel, FILL_D) | near(panel, FILL_OVERLAP),
        "survived": near(panel, FILL_S) | near(panel, FILL_OVERLAP),
    }

    rows = []
    for yr in YEARS:
        xc = int(round(x_zero + yr * step))
        row = {"year": yr}
        for name in ("destroyed", "survived"):
            win = series[name][:, xc - 3:xc + 4]
            ys = np.where(win.any(axis=1))[0]
            if not len(ys):
                raise SystemExit(f"no {name} pixels at year {yr}")
            row[f"{name}_est"] = round(float(value(np.median(ys))), 4)

            bwin = bands[name][:, xc - 3:xc + 4]
            bys = np.where(bwin.any(axis=1))[0]
            if len(bys):
                # the marker itself masks part of the ribbon; bound it by the
                # ribbon pixels in the column, which run past the marker.
                row[f"{name}_lo"] = round(float(value(bys.max())), 4)
                row[f"{name}_hi"] = round(float(value(bys.min())), 4)
            else:
                # year -1: both series are normalised to 0, so the ribbon
                # pinches to nothing and there is no fill to measure.
                row[f"{name}_lo"] = row[f"{name}_hi"] = row[f"{name}_est"]
        rows.append(row)

    by_year = {r["year"]: r for r in rows}

    # --- de-bias against the known zero -------------------------------
    # Both series are normalised to 0 in year -1, so whatever we read there is
    # pure measurement error: the pixel centroid of a marker glyph sits a hair
    # off its data point (the triangles more than the circles). Shift each
    # series by its own year -1 read. The correction is ~0.003 log points.
    for name in ("destroyed", "survived"):
        bias = by_year[-1][f"{name}_est"]
        assert abs(bias) < 0.005, \
            f"{name} at year -1 should be ~0 by construction, got {bias}"
        for r in rows:
            for k in (f"{name}_est", f"{name}_lo", f"{name}_hi"):
                r[k] = round(r[k] - bias, 4)

    # --- fail loud if the recovery drifts from what the paper states ---
    d1, d2, d4 = (by_year[y]["destroyed_est"] for y in (1, 2, 4))
    assert -0.12 < d2 < -0.08, f"destroyed year 2 = {d2:.3f}, expected about -0.10"
    assert -0.11 < d1 < -0.06, f"destroyed year 1 = {d1:.3f}, expected about -0.08"
    assert abs(d4) < 0.035, f"destroyed year 4 = {d4:.3f}, expected near zero"
    assert max(abs(by_year[y]["survived_est"]) for y in YEARS) < 0.02, \
        "survived series should stay close to zero throughout"

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    fields = ["year", "destroyed_est", "destroyed_lo", "destroyed_hi",
              "survived_est", "survived_lo", "survived_hi"]
    with open(OUT, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {os.path.relpath(OUT, PAPER_DIR)}  "
          f"(validated: yr1={d1:.3f}, yr2={d2:.3f}, yr4={d4:.3f})")


if __name__ == "__main__":
    main()
