# =====================================================================
#  cost-stack-card.R  ·  Wildfire losses — social cost-stack card
#  Conventions: style-guides/social/README.md  (§2, §3b, §6)
#  Scaffolding:  formats/social/assets/social-cards.R
#
#  The landscape cut of data-viz/code/make-cost-stack-options.R, re-rendered
#  at social scale with a headline and the logo lock-up. This is the card
#  for a reader who won't decode an event study: it needs no time axis and
#  no comparison group, just two amounts side by side.
#
#  NUMBERS (paper Section 6.2) — read that script's header before changing
#  anything here. The $38,000 income loss is measured in this paper; the
#  $72,000 is a back-of-the-envelope the paper assembles from an average
#  California reconstruction cost ($600,000, Boomhower et al. 2024) and a
#  Colorado study finding insurance covered 88% of rebuilding costs
#  (Cookson, Gallagher & Mulder 2025). The card's footer has to keep the
#  word "estimated" for that reason.
#
#  Run (from REPO ROOT):
#    Rscript papers/WP-wildfire-losses/social/code/cost-stack-card.R
#    -> writes papers/WP-wildfire-losses/social/assets/wildfire-cost-card.png
#  Deps: dplyr, ggplot2, png
# =====================================================================

library(dplyr)
library(ggplot2)
source("formats/social/assets/social-cards.R")

OUT      <- "papers/WP-wildfire-losses/social/assets/wildfire-cost-card.png"
SOURCE   <- paste("Environmental Inequality Lab · Wildfire Victims, 2026 ·",
                  "estimated cost for a typical wildfire victim")
# wrapped short so the first line clears the logo lock-up top-right
HEADLINE <- wrap_text("The cost of a wildfire doesn't stop at the house", 26)

UNINSURED <- 72000
INCOME    <- 38000
TOTAL     <- UNINSURED + INCOME

usd <- function(x) paste0("$", formatC(x, format = "d", big.mark = ","))

stack <- tibble(
  part = factor(c("property", "income"), levels = c("income", "property")),
  ymin = c(0, UNINSURED),
  ymax = c(UNINSURED, TOTAL)
)

# Known cost in grey, the paper's new finding in the one emphasis colour.
FILL <- c(property = eil_pal$axis, income = eil_pal$accentred)

p <- ggplot(stack) +
  geom_rect(aes(xmin = ymin, xmax = ymax, ymin = 0.62, ymax = 1.30,
                fill = part), color = eil_pal$canvas, linewidth = 0.6) +
  scale_fill_manual(values = FILL, guide = "none") +
  annotate("text", x = UNINSURED / 2, y = 0.96, hjust = 0.5, lineheight = 1.1,
           label = paste0(usd(UNINSURED), "\nproperty damage\n",
                          "insurance didn't cover"),
           size = 3.6, color = eil_pal$ink) +
  annotate("text", x = UNINSURED + INCOME / 2, y = 0.96, hjust = 0.5,
           lineheight = 1.1,
           label = paste0(usd(INCOME), "\nlost\nincome"),
           size = 3.6, color = eil_pal$paper, fontface = "bold") +
  # a bracket over the whole bar carrying the total
  annotate("segment", x = 0, xend = TOTAL, y = 1.46, yend = 1.46,
           color = eil_pal$warmrule, linewidth = 0.6) +
  annotate("segment", x = 0, xend = 0, y = 1.40, yend = 1.52,
           color = eil_pal$warmrule, linewidth = 0.6) +
  annotate("segment", x = TOTAL, xend = TOTAL, y = 1.40, yend = 1.52,
           color = eil_pal$warmrule, linewidth = 0.6) +
  annotate("text", x = TOTAL / 2, y = 1.66, hjust = 0.5,
           label = paste(usd(TOTAL), "in all"),
           size = 4.2, color = eil_pal$ink, fontface = "bold") +
  scale_x_continuous(limits = c(0, TOTAL), expand = c(0.02, 0)) +
  scale_y_continuous(limits = c(0.42, 1.82), expand = c(0, 0)) +
  labs(title = HEADLINE, x = NULL, y = NULL) +
  theme_eil_social() +
  theme(axis.line.x  = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x  = element_blank(),
        axis.text.y  = element_blank())

save_card(p, OUT, dims = SOCIAL_DIMS$landscape, source = SOURCE)
