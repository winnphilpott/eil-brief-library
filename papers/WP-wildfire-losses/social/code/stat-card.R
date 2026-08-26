# =====================================================================
#  stat-card.R  ·  Wildfire losses — social stat card
#  Conventions: style-guides/social/README.md  (§3b chart/stat card)
#  Scaffolding:  formats/social/assets/social-cards.R
#
#  Archetype "b": one number carries the whole post. The hero figure is
#  the paper's headline earnings loss for a typical wildfire victim; the
#  sub-line supplies the "on top of what" that makes it land.
#
#  Numbers (paper Section 4.4.1 + Conclusion): across the years after a
#  fire, the average wildfire victim foregoes about $38,000, equal to
#  30% of one year's pre-fire adjusted gross income.
#
#  Run (from REPO ROOT):
#    Rscript papers/WP-wildfire-losses/social/code/stat-card.R
#    -> writes papers/WP-wildfire-losses/social/assets/wildfire-stat-card.png
#  Deps: ggplot2, png
# =====================================================================

library(ggplot2)
source("formats/social/assets/social-cards.R")

OUT <- "papers/WP-wildfire-losses/social/assets/wildfire-stat-card.png"

# --- Content ---------------------------------------------------------
EYEBROW  <- "New EIL research · 2026"
STAT     <- "$38,000"
HEADLINE <- wrap_text("in lost income when a wildfire destroys a home", 26)
SUB      <- wrap_text(paste("a cumulative loss equal to 30% of a year's income,",
                            "on top of the cost of rebuilding"), 54)
SOURCE   <- "Environmental Inequality Lab · Wildfire Victims, 2026"

# --- Build + save ----------------------------------------------------
# Two departures from the template defaults, both forced by the copy:
#   stat_size — "$38,000" is seven glyphs where the EPA card's "0%" was
#     two, so the house size would run off the card.
#   stat_y / head_y / sub_y — the template's anchors assume a one-line
#     headline; this one needs two, so the whole centre cluster shifts
#     up to keep the sub-line clear of the footer rule.
card <- eil_stat_card(STAT, HEADLINE, sub = SUB, eyebrow = EYEBROW,
                      source = SOURCE, stat_size = 22,
                      stat_y = 0.672, head_size = 8.0, head_y = 0.415,
                      sub_size = 4.3, sub_y = 0.257) +
  theme_eil_card(bg = eil_pal$paper)

save_card(card, OUT, dims = SOCIAL_DIMS$landscape, bg = eil_pal$paper)
