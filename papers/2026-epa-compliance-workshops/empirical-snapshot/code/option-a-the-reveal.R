# =====================================================================
#  DRAFT — Empirical Snapshot, Option A: "The Reveal"
#  NOT a final output. One of four exploratory directions for the
#  paper's empirical snapshot; see the other option-*.R scripts in this
#  folder for the alternatives.
#
#  Concept: set the pre-existing trend against the study's estimate.
#  Panel 1 shows that violations at participating facilities were already
#  falling years before the first workshop; panel 2 is the paper's event
#  study -- a WITHIN-facility comparison baselined on the month each
#  facility attended -- showing no detectable change on top of that
#  decline. Note that panel 2 is NOT the trained vs. not-yet-trained
#  contrast; that is a separate result in the paper, and the panel's
#  text must not describe it as such. The framing is trend-vs-finding,
#  not "two kinds of evaluation" -- the EPA's own before/after figure is
#  deliberately left out. Both panels run head -> body -> chart -> note.
#
#  Masthead/title/dek styling matches the house LaTeX macros exactly
#  (see _font-setup.R for the transcribed specs): logo left + tracked
#  label right + 2.2pt rule (\briefheader), 18pt bold title (\brieftitle),
#  Source Serif 4 italic dek (press-release style), 9.75pt tracked
#  accentred section labels (\sectionhead).
#
#  Run from REPO ROOT:
#    Rscript papers/2026-epa-compliance-workshops/empirical-snapshot/code/option-a-the-reveal.R
#    -> writes empirical-snapshot/figures/option-a-the-reveal.png
#  Deps: haven, dplyr, fixest, ggplot2, grid, png, ragg, systemfonts
# =====================================================================

suppressMessages({
  library(haven); library(dplyr); library(fixest); library(ggplot2); library(grid); library(png); library(ragg)
})

source("formats/data-viz/eil-theme.R")
source("papers/2026-epa-compliance-workshops/empirical-snapshot/code/_font-setup.R")

DATA_FILE <- "papers/2026-epa-compliance-workshops/data-viz/data/final_deidentified_dataset_july2025.dta"
DATA_URL  <- "https://osf.io/download/sa56r/"
OUT <- "papers/2026-epa-compliance-workshops/empirical-snapshot/figures/option-a-the-reveal.png"

if (!file.exists(DATA_FILE)) {
  message("Downloading ", DATA_FILE, " from OSF (~21 MB)...")
  dir.create(dirname(DATA_FILE), showWarnings = FALSE, recursive = TRUE)
  download.file(DATA_URL, DATA_FILE, mode = "wb")
}

df <- read_dta(DATA_FILE)
t  <- df |> filter(group == "t")
wm <- t |> filter(attend == 1) |> group_by(permit2) |> summarise(wm = min(time), .groups = "drop")
t  <- t |> left_join(wm, by = "permit2") |> mutate(post = ifelse(time >= wm, 1, 0))

# --- Panel 1 data: raw monthly series + pre-program trend --------------
# Months 1-72 span 2014-2019; the program rolled out across months 22-42.
# The trend line is fit on the strictly pre-program months only (1-21)
# and projected forward, so it shows the path facilities were already on.
PRE_END <- 21; PROG_START <- 22; PROG_END <- 42

raw <- t |>
  group_by(time) |>
  summarise(viols = mean(viols, na.rm = TRUE), .groups = "drop") |>
  arrange(time)
pre_fit <- lm(viols ~ time, data = filter(raw, time <= PRE_END))
raw <- mutate(raw, trend = predict(pre_fit, newdata = data.frame(time = time)))

# --- Panel 2 data: event study (facility + time FE, ref = 0) ----------
t2 <- t |> mutate(event = time - wm, e = pmin(pmax(event, -12), 12))
m  <- feols(viols ~ i(e, ref = 0) + rainfall + avg_temp | permit2 + time, data = t2, cluster = ~permit2)
ct <- as.data.frame(coeftable(m)); ct$rn <- rownames(ct)
ct <- ct[grepl("^e::", ct$rn), ]
es <- data.frame(event = as.numeric(sub("^e::", "", ct$rn)), est = ct[, 1], se = ct[, 2])
es <- rbind(es, data.frame(event = 0, est = 0, se = 0)) |> arrange(event)
es$lo <- es$est - 1.96 * es$se
es$hi <- es$est + 1.96 * es$se

# --- Compose on an absolute-inch coordinate system -----------------------
W <- 7.6; H <- 11.03; DPI <- 200
MX <- 0.45                       # left/right margin, inches
CW <- W - 2 * MX                 # content width, inches

pt_in <- function(pt, lineheight = 1.15, lines = 1) pt / 72.27 * lineheight * lines
gp <- function(...) gpar(fontfamily = EIL_FONT, ...)

# Greedy wrap on MEASURED width rather than a character count, so the
# figure notes fill the content column margin to margin. Requires an
# open device (called during drawing, after agg_png below).
NOTE_PT <- 8.4
NOTE_GP <- gp(fontface = "italic", fontsize = NOTE_PT)
wrap_in <- function(txt, max_in, gpar_ = NOTE_GP) {
  words <- strsplit(txt, " ")[[1]]
  lines <- character(0); cur <- ""
  for (w in words) {
    test <- if (nzchar(cur)) paste(cur, w) else w
    too_wide <- convertWidth(grobWidth(textGrob(test, gp = gpar_)), "in",
                             valueOnly = TRUE) > max_in
    if (too_wide && nzchar(cur)) { lines <- c(lines, cur); cur <- w } else cur <- test
  }
  c(lines, cur)
}

dir.create(dirname(OUT), showWarnings = FALSE, recursive = TRUE)
agg_png(OUT, width = W, height = H, units = "in", res = DPI, background = eil_pal$paper)

# The two panels sit in separate viewports, so ggplot cannot align their
# panel edges for us -- their y-axis labels differ in width. Measure both
# label sets on the open device and pad the narrower one so the plotting
# areas start at the same x.
AXIS_PT <- 9.6
lab_w <- function(labels) max(vapply(labels, function(s)
  convertWidth(grobWidth(textGrob(s, gp = gp(fontsize = AXIS_PT))), "in", valueOnly = TRUE),
  numeric(1)))
P1_LABS <- c("0", "0.5", "1.0", "1.5")
P2_LABS <- c("Fewer\nviolations", "No change", "More\nviolations")
pad_pt <- max(0, lab_w(P2_LABS) - lab_w(P1_LABS)) * 72.27

# --- Panel 1 plot: the trend already underway ---------------------------
SERIES <- c("Monthly violations", "Pre-existing trend")
p1 <- ggplot(raw, aes(x = time)) +
  annotate("rect", xmin = PROG_START, xmax = PROG_END, ymin = 0, ymax = 1.6,
           fill = eil_pal$band, alpha = 0.75) +
  annotate("segment", x = PROG_START, xend = PROG_START, y = 0, yend = 1.6,
           color = eil_pal$accentred, linetype = "dashed", linewidth = 0.4) +
  annotate("segment", x = PROG_END, xend = PROG_END, y = 0, yend = 1.6,
           color = eil_pal$accentred, linetype = "dashed", linewidth = 0.4) +
  annotate("text", x = (PROG_START + PROG_END) / 2, y = 1.47, label = "WORKSHOPS",
           hjust = 0.5, size = 2.9, color = eil_pal$accentred, fontface = "bold",
           family = EIL_FONT) +
  annotate("text", x = (PROG_START + PROG_END) / 2, y = 1.34, label = "2015–2017",
           hjust = 0.5, size = 2.7, color = eil_pal$accentred, family = EIL_FONT) +
  geom_line(aes(y = trend, color = SERIES[2], linetype = SERIES[2]), linewidth = 0.5) +
  geom_line(aes(y = viols, color = SERIES[1], linetype = SERIES[1]), linewidth = 0.5) +
  scale_color_manual(name = NULL, breaks = SERIES,
                     values = setNames(c(eil_pal$ink, eil_pal$muted), SERIES)) +
  scale_linetype_manual(name = NULL, breaks = SERIES,
                        values = setNames(c("solid", "longdash"), SERIES)) +
  scale_x_continuous(limits = c(1, 72), breaks = c(1, 13, 25, 37, 49, 61),
                     labels = c("2014", "2015", "2016", "2017", "2018", "2019"),
                     expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 1.6), breaks = c(0, 0.5, 1.0, 1.5),
                     labels = P1_LABS, expand = c(0, 0)) +
  labs(x = NULL, y = NULL) +
  guides(color = guide_legend(nrow = 1), linetype = guide_legend(nrow = 1)) +
  theme_eil(base_size = 12, base_family = EIL_FONT) +
  theme(
    plot.background  = element_rect(fill = eil_pal$paper, color = NA),
    panel.background = element_rect(fill = eil_pal$paper, color = NA),
    axis.text.x = element_text(size = 8.6),
    axis.text.y = element_text(size = AXIS_PT),
    legend.position   = "bottom",
    legend.margin     = margin(t = -2),
    legend.key        = element_rect(fill = NA, color = NA),
    legend.key.width  = unit(24, "pt"),
    legend.key.height = unit(10, "pt"),
    legend.text       = element_text(color = eil_pal$muted, size = 8.4),
    plot.margin = margin(2, 10, 2, pad_pt)
  )

# --- Panel 2 plot: what the workshops added ----------------------------
p2 <- ggplot(es, aes(event, est)) +
  annotate("rect", xmin = 0, xmax = 12.5, ymin = -Inf, ymax = Inf,
           fill = eil_pal$band, alpha = 0.4) +
  geom_vline(xintercept = 0, color = eil_pal$accentred, linetype = "dashed", linewidth = 0.45) +
  geom_hline(yintercept = 0, color = eil_pal$muted, linewidth = 0.5) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = eil_pal$axis, alpha = 0.35) +
  geom_line(color = eil_pal$ink, alpha = 0.55, linewidth = 0.45) +
  geom_point(color = eil_pal$ink, size = 1.3) +
  scale_y_continuous(limits = c(-0.85, 1.0), breaks = c(-0.5, 0, 0.5),
                      labels = P2_LABS) +
  scale_x_continuous(breaks = seq(-12, 12, 6),
                      labels = c("12+ before", "6 before", "Workshop", "6 after", "12+ after"),
                      expand = c(0.02, 0)) +
  labs(x = NULL, y = NULL) +
  theme_eil(base_size = 12, base_family = EIL_FONT) +
  theme(
    plot.background  = element_rect(fill = eil_pal$paper, color = NA),
    panel.background = element_rect(fill = eil_pal$paper, color = NA),
    axis.text.x = element_text(size = 8.6),
    axis.text.y = element_text(size = AXIS_PT, lineheight = 0.9),
    plot.margin = margin(2, 10, 2, 0)
  )

grid.newpage()
grid.rect(gp = gp(fill = eil_pal$paper, col = NA))
pushViewport(viewport(x = 0.5, y = 0.5, width = 1, height = 1,
                       xscale = c(0, W), yscale = c(H, 0)))

nx <- function(v) unit(v, "native")
ny <- function(v) unit(v, "native")

y <- 0.35  # cursor: distance from top, inches

# --- masthead: logo left + tracked label right + 2.2pt rule (\briefheader) --
logo <- readPNG("formats/logos/eil-logo-maroon.png")
LOGO_H <- 0.45; LOGO_W <- LOGO_H * (dim(logo)[2] / dim(logo)[1])
grid.raster(logo, x = nx(MX), y = ny(y), width = unit(LOGO_W, "in"), height = unit(LOGO_H, "in"),
            just = c("left", "top"))
grid.text(track_caps("Empirical Snapshot", 200), x = nx(W - MX), y = ny(y + LOGO_H / 2), just = c("right", "center"),
           gp = gp(col = eil_pal$accentred, fontface = "bold", fontsize = EIL_MASTHEAD_LABEL_PT))
y <- y + LOGO_H + 0.055
grid.lines(x = nx(c(MX, W - MX)), y = ny(c(y, y)), gp = gp(col = eil_pal$ink, lwd = pt_lwd(2.2)))

# --- title + dek (\brieftitle + press-release dek) --------------------------
y <- y + 0.18
grid.text("Violations were already falling. Did the workshops help?",
           x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$ink, fontface = "bold", fontsize = EIL_TITLE_PT, lineheight = 1.08))
y <- y + pt_in(EIL_TITLE_PT, 1.08) + 0.09
dek_lines <- strwrap(paste(
  "From 2015 to 2017, the Ohio EPA offered free compliance workshops to hundreds of small",
  "wastewater facilities. Ferraro & Shimshack (2026) asked how much of the improvement that",
  "followed can be credited to the workshops."),
  width = 92)
grid.text(paste(dek_lines, collapse = "\n"), x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gpar(fontfamily = EIL_FONT_SERIF, fontface = "italic",
                     col = eil_pal$cite, fontsize = EIL_DEK_PT, lineheight = 1.27))
y <- y + pt_in(EIL_DEK_PT, 1.27, length(dek_lines))
# Match the 0.20/0.20 breathing room the other two section rules use --
# this one sat at 0.03 above / 0.26 below, which crowded the dek.
y <- y + 0.20
grid.lines(x = nx(c(MX, W - MX)), y = ny(c(y, y)), gp = gp(col = eil_pal$warmrule, lwd = pt_lwd(0.7)))

# --- panel 1: the trend already underway ------------------------------------
y <- y + 0.20
grid.text(track_caps("What was already happening", 20), x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$accentred, fontface = "bold", fontsize = EIL_SECTIONHEAD_PT))
y <- y + pt_in(EIL_SECTIONHEAD_PT) + 0.07
body1_lines <- strwrap(paste(
  "Monthly violations at participating facilities had been declining since 2014, years before the",
  "first workshop was held. The program ran through the middle of that decline."), width = 96)
grid.text(paste(body1_lines, collapse = "\n"), x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$body, fontsize = 11.5, lineheight = 1.3))
y <- y + pt_in(11.5, 1.3, length(body1_lines)) + 0.13

chart1_h <- 2.15
print(p1, vp = viewport(x = nx(MX), y = ny(y), width = unit(CW, "in"),
                         height = unit(chart1_h, "in"), just = c("left", "top")))
y <- y + chart1_h + 0.06
# The trend line is ours, not theirs -- their Fig. 1 plots the raw series
# only -- so the note credits the data, not the figure.
note1_lines <- wrap_in(paste(
  "Average violations per facility per month. Dashed line: linear trend fit on pre-program months only,",
  "projected forward. Data: Ferraro & Shimshack (2026) replication files."), CW)
grid.text(paste(note1_lines, collapse = "\n"), x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$faint, fontface = "italic", fontsize = NOTE_PT, lineheight = 1.15))
y <- y + pt_in(NOTE_PT, 1.15, length(note1_lines))

# --- section rule ------------------------------------------------------------
y <- y + 0.20
grid.lines(x = nx(c(MX, W - MX)), y = ny(c(y, y)), gp = gp(col = eil_pal$warmrule, lwd = pt_lwd(0.7)))

# --- panel 2: what the workshops added --------------------------------------
y <- y + 0.20
grid.text(track_caps("The workshops made no difference", 20), x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$accentred, fontface = "bold", fontsize = EIL_SECTIONHEAD_PT))
y <- y + pt_in(EIL_SECTIONHEAD_PT) + 0.07
body2_lines <- strwrap(paste(
  "Facilities violated about as often in the months after their workshop as in the months before.",
  "Whatever was driving the decline, the workshops were not adding to it."), width = 96)
grid.text(paste(body2_lines, collapse = "\n"), x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$body, fontsize = 11.5, lineheight = 1.3))
y <- y + pt_in(11.5, 1.3, length(body2_lines)) + 0.13

chart2_h <- 2.3
print(p2, vp = viewport(x = nx(MX), y = ny(y), width = unit(CW, "in"),
                         height = unit(chart2_h, "in"), just = c("left", "top")))
y <- y + chart2_h + 0.06
# The body above is narrative, so the baseline mechanic (each month is
# measured against the facility's own workshop month) has to live here.
note2_lines <- wrap_in(paste(
  "Each point compares a month with the month the facility attended. Estimates account for each facility's",
  "usual violation rate, local weather, and trends shared across facilities. Shaded band: 95% confidence",
  "interval. Source: Ferraro & Shimshack (2026), Fig. 2a."), CW)
grid.text(paste(note2_lines, collapse = "\n"), x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$faint, fontface = "italic", fontsize = NOTE_PT, lineheight = 1.15))
y <- y + pt_in(NOTE_PT, 1.15, length(note2_lines))

# --- bottom rule + takeaway + source ----------------------------------------
y <- y + 0.18
grid.lines(x = nx(c(MX, W - MX)), y = ny(c(y, y)), gp = gp(col = eil_pal$warmrule, lwd = pt_lwd(0.7)))
y <- y + 0.15
# The panels narrate themselves, so the takeaway carries only what they
# cannot: the program's premise, and how precise the null is.
takeaway_lines <- strwrap(paste(
  "The workshops assumed operators did not know how to comply. At least at these facilities,",
  "that does not appear to be what was holding compliance back. The estimates are precise",
  "enough that a meaningful improvement would have shown up."), width = 88)
grid.text(paste(takeaway_lines, collapse = "\n"), x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$ink, fontface = "bold", fontsize = 12, lineheight = 1.25))
y <- y + pt_in(12, 1.25, length(takeaway_lines)) + 0.22
grid.text("Environmental Inequality Lab · Ferraro & Shimshack, 2026 · doi.org/10.1002/pam.70056",
           x = nx(MX), y = ny(y), just = c("left", "top"),
           gp = gp(col = eil_pal$faint, fontsize = EIL_FOOTER_PT))
y <- y + pt_in(EIL_FOOTER_PT) + 0.26  # bottom margin

popViewport()
dev.off()
message("wrote ", OUT, " -- content used ", round(y, 2), "in of ", H, "in page")
