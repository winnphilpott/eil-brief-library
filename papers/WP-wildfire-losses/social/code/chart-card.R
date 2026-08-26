# =====================================================================
#  chart-card.R  ·  Wildfire losses — social chart card
#  Conventions: style-guides/social/README.md  (§2: reuse the recipe,
#               re-render the card — don't copy the print PNG)
#  Scaffolding:  formats/social/assets/social-cards.R
#
#  The paper's Fig. 4a re-rendered at social scale: the same recipe as
#  data-viz/code/make-fig1-income-by-damage.R, with a plain-language
#  headline baked in and the logo lock-up added. The card has to work
#  with no caption, so the headline states the finding outright.
#
#  Estimates come from data-viz/code/extract-fig4a.py — run that first;
#  its CSV output is gitignored.
#
#  Run (from REPO ROOT):
#    Rscript papers/WP-wildfire-losses/social/code/chart-card.R
#    -> writes papers/WP-wildfire-losses/social/assets/wildfire-chart-card.png
#  Deps: dplyr, ggplot2, png
# =====================================================================

library(dplyr)
library(ggplot2)
source("formats/social/assets/social-cards.R")

DATA_FILE <- "papers/WP-wildfire-losses/data-viz/data/fig4a-estimates.csv"
OUT       <- "papers/WP-wildfire-losses/social/assets/wildfire-chart-card.png"
SOURCE    <- paste("Environmental Inequality Lab · Wildfire Victims, 2026 ·",
                   "shaded band = range of uncertainty")
HEADLINE  <- wrap_text("Losing a home to a wildfire costs years of income", 32)

if (!file.exists(DATA_FILE))
  stop("missing ", DATA_FILE,
       " — run: python3 papers/WP-wildfire-losses/data-viz/code/extract-fig4a.py")

est <- read.csv(DATA_FILE)
destroyed <- est |> transmute(year, est = destroyed_est,
                              lo = destroyed_lo, hi = destroyed_hi)
survived  <- est |> transmute(year, est = survived_est,
                              lo = survived_lo, hi = survived_hi)

# --- Plot at social scale --------------------------------------------
# Same moves as the print figure — shaded "after" region, dashed marker
# at the fire, one emphasis colour, direct labels, no legend — with the
# marks and type scaled up for a 1200x675 card.
p <- ggplot(mapping = aes(year, est)) +
  annotate("rect", xmin = 0, xmax = Inf, ymin = -Inf, ymax = Inf,
           fill = eil_pal$band, alpha = 0.45) +
  geom_vline(xintercept = 0, color = eil_pal$accentred,
             linetype = "dashed", linewidth = 0.6) +
  geom_hline(yintercept = 0, color = eil_pal$muted, linewidth = 0.5) +

  geom_ribbon(data = survived, aes(ymin = lo, ymax = hi),
              fill = eil_pal$axis, alpha = 0.40) +
  geom_line(data = survived, color = eil_pal$muted, alpha = 0.75,
            linewidth = 0.5) +
  geom_point(data = survived, color = eil_pal$muted, size = 1.3) +

  geom_ribbon(data = destroyed, aes(ymin = lo, ymax = hi),
              fill = eil_pal$accentred, alpha = 0.14) +
  geom_line(data = destroyed, color = eil_pal$accentred, alpha = 0.9,
            linewidth = 0.8) +
  geom_point(data = destroyed, color = eil_pal$accentred, size = 1.7) +

  annotate("text", x = -3.9, y = -0.032, hjust = 0,
           label = "Home survived",
           size = 3.4, color = eil_pal$muted) +
  annotate("text", x = 1.35, y = -0.126, hjust = 0,
           label = "Home destroyed",
           size = 3.4, color = eil_pal$accentred, fontface = "bold") +

  scale_y_continuous(limits = c(-0.138, 0.042),
                     breaks = c(0, -0.05, -0.10),
                     labels = c("Same income", "5% less", "10% less")) +
  scale_x_continuous(breaks = c(-4, -2, 0, 2, 4),
                     labels = c("4 years before", "2 years before", "Fire",
                                "2 years after", "4 years after"),
                     expand = c(0.10, 0)) +
  labs(title = HEADLINE, x = NULL, y = NULL) +
  theme_eil_social() +
  # the axis labels are words rather than numbers, so they need trimming
  # below the card theme's default to sit comfortably
  theme(axis.text.x = element_text(size = 8),
        axis.text.y = element_text(size = 8))

save_card(p, OUT, dims = SOCIAL_DIMS$landscape, source = SOURCE)
