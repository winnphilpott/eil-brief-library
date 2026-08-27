# =====================================================================
#  make-fig1-income-by-damage.R  ·  Wildfire losses — the finding figure
#  Conventions: style-guides/data-viz/README.md
#  Theme/palette: formats/data-viz/eil-theme.R
#
#  Recreates Fig. 4 Panel A of Baylis, Boomhower, Colmer & Voorheis
#  (2026): income for occupants of destroyed homes vs. occupants of
#  homes that survived the same fires, in the years around the event,
#  both measured against people living just outside the fire perimeter.
#
#  The point the figure has to carry: the two lines sit on top of each
#  other before the fire and split apart only for the group whose homes
#  burned. That contrast is the paper's identification argument and its
#  headline result in one picture.
#
#  House-style departures from the paper's version, all per the data-viz
#  guide: plain-language y-axis instead of log points, direct line labels
#  instead of a legend, one emphasis colour (destroyed = accentred, the
#  comparison group in grey), and soft uncertainty bands named once in
#  words rather than as "95% CI".
#
#  Estimates come from code/extract-fig4a.py, which recovers them from
#  the paper's own figure (the paper ships no coefficient table for it).
#  Run that first; its CSV output is gitignored.
#
#  Run (from data-viz/):  Rscript code/make-fig1-income-by-damage.R
#    -> figures/fig1-income-by-damage.png
#  Deps: dplyr, ggplot2 (+ the theme file)
# =====================================================================

library(dplyr)
library(ggplot2)

source("../../../formats/data-viz/eil-theme.R")

DATA_FILE <- "data/fig4a-estimates.csv"
OUT_PATH  <- "figures/fig1-income-by-damage.png"
SOURCE    <- "Environmental Inequality Lab · Wildfire Victims, 2026"

if (!file.exists(DATA_FILE))
  stop("missing ", DATA_FILE, " — run: python3 code/extract-fig4a.py")

est <- read.csv(DATA_FILE)

destroyed <- est |> transmute(year, est = destroyed_est,
                              lo = destroyed_lo, hi = destroyed_hi)
survived  <- est |> transmute(year, est = survived_est,
                              lo = survived_lo, hi = survived_hi)

# --- Plot ------------------------------------------------------------
p <- ggplot(mapping = aes(year, est)) +
  # after-the-fire framing: a shaded region and a dashed marker at year 0
  annotate("rect", xmin = 0, xmax = Inf, ymin = -Inf, ymax = Inf,
           fill = eil_pal$band, alpha = 0.30) +
  # period labels along the top edge, as on the EPA event-study card: the
  # shading already marks the split, these name it. Colour matches the
  # region each one sits over (grey before, red after).
  annotate("text", x = -2.1, y = 0.046, label = "BEFORE THE FIRE",
           size = 2.4, color = eil_pal$muted, fontface = "bold") +
  annotate("text", x = 2.1, y = 0.046, label = "AFTER THE FIRE",
           size = 2.4, color = eil_pal$accentred, fontface = "bold") +
  geom_vline(xintercept = 0, color = eil_pal$accentred,
             linetype = "dashed", linewidth = 0.4) +
  geom_hline(yintercept = 0, color = eil_pal$muted, linewidth = 0.45) +

  # comparison group first, so the emphasised series draws over it
  geom_ribbon(data = survived, aes(ymin = lo, ymax = hi),
              fill = eil_pal$axis, alpha = 0.40) +
  geom_line(data = survived, color = eil_pal$muted, alpha = 0.75,
            linewidth = 0.4) +
  geom_point(data = survived, color = eil_pal$muted, size = 0.85) +

  geom_ribbon(data = destroyed, aes(ymin = lo, ymax = hi),
              fill = eil_pal$accentred, alpha = 0.14) +
  geom_line(data = destroyed, color = eil_pal$accentred, alpha = 0.85,
            linewidth = 0.5) +
  geom_point(data = destroyed, color = eil_pal$accentred, size = 1.05) +

  # two direct labels, no legend and no leader lines — colour alone ties
  # each label to its line
  annotate("text", x = -3.9, y = -0.030, hjust = 0,
           label = "Home survived",
           size = 2.7, color = eil_pal$muted) +
  annotate("text", x = 1.5, y = -0.128, hjust = 0,
           label = "Home destroyed",
           size = 2.7, color = eil_pal$accentred, fontface = "bold") +

  # The estimates are in LOG POINTS (the paper plots log AGI), so the
  # gridlines sit at the log values that correspond to a round percentage
  # drop -- log(0.95) and log(0.90) -- not at -0.05 and -0.10. Over this
  # range the two differ by up to half a percentage point, which is small
  # but is exactly the kind of slippage a reader can't see and can't
  # correct for. Don't "tidy" these back to round numbers.
  #
  # The top label names the quantity so the axis reads as income without
  # needing an axis title; the two below inherit the noun.
  scale_y_continuous(limits = c(-0.138, 0.055),
                     breaks = c(0, log(0.95), log(0.90)),
                     labels = c("Same income", "5% less", "10% less")) +
  scale_x_continuous(breaks = c(-4, -2, 0, 2, 4),
                     labels = c("4 years before", "2 years before", "Fire",
                                "2 years after", "4 years after"),
                     # the end labels are wide, so the panel needs room on
                     # both sides or "4 years after" clips off the canvas
                     expand = c(0.10, 0)) +
  labs(x = NULL, y = NULL) +
  theme_eil()

# The band is explained in the source line rather than annotated on the
# chart, which keeps one more label off the plot (the EPA card does the
# same). The document's note carries what "no change" is measured against.
eil_save(p, OUT_PATH, width = 5.4, height = 3.0,
         source = paste(SOURCE, "· shaded band = range of uncertainty"))
