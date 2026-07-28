# Research Highlight Style Guide

Writing and design conventions for EIL **research highlights** — one- to two-page PDFs that
translate a single academic paper for a policy audience.

- **Canonical example:** `papers/2026-epa-compliance-workshops/research-highlight/v10/epa-compliance-workshops_research-highlight_v10.qmd`
- **Design system:** `formats/research-highlight/_style.tex` (colors, fonts, boxes, macros)
- **Starter template:** `formats/research-highlight/research-highlights-template.qmd` (matches this guide)

---

## 1. Purpose & shape

A research highlight is a **two-page PDF** built from a single paper — the setup and the
Background infographic on the first page, the findings and their data viz on the second. Body
type is 10.5/13.5pt. **Use the space the paper warrants:** don't try to cram too much into one
page, and **don't shrink the layout to force a fit.** The running masthead and footer repeat
across pages, so highlights stay branded throughout.

**Section order (fixed):**

1. **Masthead** — EIL logo (left) + `RESEARCH HIGHLIGHT` label (right), 2.2pt ink rule
   beneath. Repeats as a running header on every page via `fancyhdr`.
2. **Title** — the finding stated as a claim, not a topic, in sentence case.
3. **Citation line** — directly under the title.
4. **Bottom Line** — maroon box; the finding in one breath.
5. **Background** — why the question matters.
6. **The challenge** — the research-design story: why a fair comparison is hard and how
   the researchers found one. Head it with the specific obstacle ("The challenge"), not a
   generic label. See §3.
7. **Findings** — the result, anchored by a figure, closing on a bold sentence that
   interprets it. **Head this section with the finding itself**
   ("No effect on violations or discharges"), not a generic label like "What the study found."
8. **Implications for policy** — zoom out from the finding to what it means for policy and
   practice, stated soberly. Usually ~2 paragraphs: what follows if the result holds more
   broadly, the limit named plainly, and what it does and doesn't imply. See §2 on calibrated
   humility.
9. **For more information** — full-width closing block: contact line, full citation, author
   affiliations, EIL boilerplate. See §6.
10. **Footer** — "For full paper:" + DOI link, and page number.

Section heads 5–8 carry the argument, so name them for *this* paper: `Background`, then the
specific obstacle, then the finding, then `Implications for policy`. The challenge, the
findings, and a short implications section are the norm. (The older *What the study found* +
*Takeaways* scaffold has been retired; the `\subhead` macro survives only so earlier
highlights still compile.)

## 2. Tone

- **Lead with the conclusion.** The title, the Bottom Line, and each section's bolded
  sentence all state the answer first. *("No evidence that compliance assistance reduces environmental violations.")*
- **Plain, declarative, active voice.** Prefer short words to technical ones —
  "free help to follow the rules," not "voluntary compliance interventions."
- **Bold one claim per block.** Picture a reader skimming only the bold sentences — do they
  still get the story? Bold that one, then stop. More than one or two per section and the
  emphasis stops meaning anything.
- **Define jargon on first use** and bold the term (**compliance assistance**), then
  explain it in plain language. Name the general actor ("regulators") rather than a specific
  agency unless the agency is essential to the point; when you do name one, spell it out on
  first mention — "Environmental Protection Agency (EPA)."
- **Explain the method, don't name it.** Your reader doesn't need the textbook term — they
  need to see *why* the comparison is fair. Narrate it ("similar facilities that signed up but
  hadn't yet been trained") instead of labeling it ("difference-in-differences"). This is the
  heart of the *challenge* section — see §3, Explaining the research design.
- **Earn trust with calibrated humility.** Name the limit plainly — "this is one program, and
  small benefits can't be ruled out" — then restate the real point. A reader trusts a caveat
  more than a hard sell.
- **No hype.** State the stakes soberly and let them land — "commits more public funding
  without delivering the reduction in pollution it was meant to achieve." Don't make adjectives
  do the work the facts should do.

## 3. Explaining the research design

The hardest section to write is usually **"The challenge,"** where you explain the research design to a general audience. The goal is not just to explain the method, but to walk the reader through the reasoning behind it — the challenges researchers faced and how they solved them. Rather than "here were the problems, here were the fixes," lay it out as a story: *"You might first think to compare X. But that raises [a problem]. So you might try [Y] — except that introduces [a complication]. The researchers got around this by [doing Z]."* Take the reader along the journey of figuring out how to answer the question, instead of handing them the answer at face value. (The *finding* itself still leads — title, Bottom Line, and bold sentence — this storytelling applies to how the design is explained.)

## 4. Citations

- **Citation line** (`\briefcitation`, under the title):
  *Lessons from "[Exact Paper Title]" by [Authors] in* [Journal]*, [Year].*
  Paper title in straight quotes; journal italicized.
- **In-text reference:** Author & Author (Year) — "Ferraro & Shimshack (2026)."
- **Figure source:** `Source: Ferraro & Shimshack (2026), Fig. 2a.` — cite the specific figure
  when the highlight reproduces one. Use *et al.* for 3+ authors.
- **Footer link:** `For full paper: doi.org/...` — always a resolvable DOI, underlined,
  in the faint footer color. If source paper is a working paper without a DOI, use an appropriate alternative link. 

## 5. Figures

- **Two figures in a standard highlight:** an infographic on the first page that sets up the
  question or the research design, and a data viz on the second page that carries the finding.
  The data viz is centered in a `0.75\linewidth` minipage. Add a further figure only when it
  carries a distinct result — not to decorate the extra space.
- **Three stacked parts:**
  1. `\figtitle` — a sentence-style title in uppercase maroon describing what the chart
     shows ("The workshops' effect on violations, month by month") plus the source line.
  2. The image at `width=\linewidth`.
  3. An italic, faint **Note** in plain language telling the reader *how to read it* and
     what to conclude ("The band always includes 'no change,' so the workshops had no
     detectable effect").
- **Reproducible:** every figure is generated by a script in the paper's `data-viz/code/`
  (e.g. `make-fig2-event-study.R`) and saved to `data-viz/figures/`. No hand-edited images.
- **Background infographic:** the first-page figure is a conceptual diagram (e.g. contrasting
  two approaches). It sits in the Background as a right-side `wrapfigure` with text flowing
  around it, rather than a centered minipage. Scope `\usepackage[none]{hyphenat}` (or a raised `\hyphenpenalty`) to that
  section so the narrowed column doesn't break words mid-line.
- **Chart styling** inherits the brand palette from `_style.tex` — `accentred` maroon for
  the data series, faint grey for uncertainty bands.

## 6. Formatting & mechanics

- **Never restyle in the `.qmd`.** All colors, fonts (Source Sans 3 / Source Serif 4),
  boxes, and macros live in `_style.tex`. Edit there to restyle every highlight at once.
- **Macros:** `\brieftitle`, `\briefcitation`, `\sectionhead`, `\figtitle`,
  `\begin{bottomline}`, `\begin{moreinfo}`. Section heads are maroon in `_style.tex`, so the
  only per-document override to keep is the body type — `\fontsize{10.5pt}{13.5pt}` — set once
  after the citation line. (`\subhead` and `\begin{infobox}` are legacy, kept so earlier
  highlights still compile; new highlights don't use them.)
- **`moreinfo`** is the full-width closing block ("For more information") — a rule above, no
  box. Four paragraphs: a contact line, the full citation, the author affiliations (one
  **bold-lead** sentence each), then the EIL boilerplate. Text is `cite` grey; wrap any link as
  `\href{url}{\color{cite}\underline{text}}` so it stays grey instead of the accent link color.
- **Color tokens:** `ink` (title, masthead rule), `body` (text), `accentred` maroon (label,
  links, section heads, figure title), `boxred` (Bottom Line fill). Hex values are fixed in
  `_style.tex`.
- **Paragraphs** begin with `\noindent`; separate sections with an explicit, uniform
  `\vspace{6pt}`.
- **File layout:** `papers/<paper-slug>/research-highlight/` holds the `.qmd`; figures come
  from the paper's `data-viz/` folder (`data-viz/code/` scripts → `data-viz/figures/` outputs).
  Keep `keep-tex: true`.
- **Rendering:** there's no standalone `quarto` on PATH here — render with RStudio's bundled
  binary plus TinyTeX (`…/RStudio.app/…/quarto/bin/quarto render <file>.qmd`), which supplies
  the pdflatex the build needs.

## 7. Length budget (target)

This is the least strict element of the style guide, as long as the text is clear, direct,
and based on all other conventions in this style guide. 

| Block          | Budget                                     |
|----------------|--------------------------------------------|
| Title          | ≤ 10                                       |
| Bottom Line    | ~40–50                                      |
| Background     | ~120–180 (2–3 paragraphs)                  |
| The challenge  | ~180–300 (2–4 paragraphs)                  |
| Findings       | ~150 + 1–2 figs                            |
| Implications   | ~120 (~2 paragraphs)                       |
