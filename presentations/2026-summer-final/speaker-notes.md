# Speaker notes — EIL summer final presentation

Slides are headline/visual only. Full talking points below, one section per slide.

## 1. Title
The EIL Output Library — translating research for public audiences. Winn Philpott, Environmental Inequality Lab, Summer 2026.

## 2. The Project
UVA and Batten are doing genuinely good, important research — but we aren't always sharing it in a way that shows that. The core motivation this summer: communicate that research to audiences beyond academia, and build something centralized, replicable, and shareable rather than one-off documents scattered across people's laptops.

Concrete before/after: papers like coal worker transitions and citizen complaints existed only as working papers/PDFs before this project touched them — no public-facing version at all. That's what "rarely reaches beyond academia" actually looks like in practice, not just an assertion.

## 3. My Work
Learning by doing. The process: take a paper, write about it, iterate with the PIs, and produce different outputs as we identify different goals and needs — a research highlight and a press release serve different audiences, so they get built differently even from the same paper.

Worth unpacking *why* the formats differ, not just that they do: a press release needs a lede and a quotable line for a journalist; a research highlight needs the full context and caveats for someone who wants to actually understand the study; a social card has to work as a single image with no supporting text at all. Same underlying paper, three genuinely different writing problems.

## 4. Infrastructure I Built
Paper bundles, and more — this is the actual repo structure (`papers/`, `formats/`, `style-guides/`). I built the entire communications infrastructure: it can be added to (new papers, new formats), but the style, design, colors, fonts, and standards are all already decided and standardized. Research highlights serve as the foundation everything else builds from — press release, blog, and social all derive from the highlight, not from the paper directly.

Two things worth telling as a story rather than a fact:
- The git history shows a real inflection point — I started with one shared "briefs" folder, then there's a commit literally titled "Restructure repo around paper bundles" that reorganized everything once papers needed more than one output type each.
- The `formats/`/`style-guides/` split is deliberate: `formats/` is the design system (code, templates), `style-guides/` is writing conventions (prose). Code drift and prose drift get caught by different kinds of review, so keeping them as separate layers means each can be reviewed on its own terms.

## 5. Case Study: EPA — The Iteration
This is my flagship project: 97 commits, 10 full drafted versions of the research highlight — by far the deepest iteration of the summer. The three covers on the slide show the actual arc, not just a count:
- v1: two-column layout, dense academic framing, pull-quote box, a 3-column "implications" section at the bottom
- v4: rebuilt as single-column, added a plain-language note directly under the figure explaining what the reader is looking at
- v10: reorganized again around a "two approaches to compliance" infographic that sets up the comparison, retitled the piece as a question instead of a statement
The underlying finding is a null result (compliance workshops don't reduce violations) — that's *why* getting the framing right took this many passes, but it's incidental detail, not the point. The point is that a good output isn't a first draft; it's the product of a lot of revision to both the design and the writing.

Worth mentioning: the 10 highlight versions aren't even the full extent of the exploration. I also drafted four full "empirical snapshot" concepts exploring different ways to frame the null result — different comparisons, different chart types, different rhetorical hooks — before landing on the simpler combination that shipped. The iteration went wider than just the highlight itself.

## 6. Case Study: EPA — The Output
The whole bundle that shipped from this paper: the research highlight (v10), a press release, the empirical snapshot ("the reveal" — same data, two reads: a 50-60% drop or a 0% effect depending on the comparison), and three social cards (stat, chart, quote). Blog is still to come. This is what "different goals → different formats" (from the My Work slide) actually looks like in practice for one paper.

Related detail worth flagging here or on the Social Media slide: the social copy (actual LinkedIn and X post text, not just the cards) is already drafted and sitting in the repo for this paper and for early-life-pollution — written, ready, just no channel to publish it to yet.

## 7. Handoff Idea: Rethinking the Website
Project pages today are abstract-only — no figures, no plain-language summary, no link to any highlight, press release, or social output. The screenshot shows the homepage's own project dropdown overlapping the mission statement text — the site isn't even internally organized well, let alone set up to surface this summer's outputs. This summer's work has no home on the site — it lives in the repo, not in front of the public. That's a gap against the lab's own mission of "public-facing tools that democratize access to information." Proposal: embed each highlight's key figure + a plain-language summary directly on its project page, linking out to the full one-pager; add a single site-wide index of all research highlights.

Worth saying explicitly why this is a small lift, not a big one: the highlight is already a designed one-pager with a figure. Embedding it is publishing something that already exists, not new work.

## 8. Handoff Idea: Social Media
I like the website direction, and I think social media could use similar treatment — but it's a genuinely open question, not a proposal I have ready. We've talked about doing more here, but I haven't been given access to the accounts or any direction on what the point of the lab's social media actually is. Worth resolving before anyone invests more time building for it.

Concrete evidence there's already demand for this: the LinkedIn/X copy sitting drafted and unused (see note on slide 6) — the content side is ready, it's the channel and mandate that are missing.

## 9. What I Learned — Skills & Workflow
Building figures, graphics, and PDFs with R and TeX scripts. The general importance of replicability and version control. Interviewing PIs about the paper before getting started, to help identify the framing — this also ends up informing the press release later.

Also learned how to actually work with AI as part of this workflow — not just using it to generate a first draft, but directing it: writing clear prompts, checking its output against the actual data and the paper, and iterating when it got the framing or the numbers wrong. The output is only useful because of that verification loop, not instead of it.

Concrete war story: the coal-worker-transitions TikZ infographic needed a specific LaTeX package (`sansmath`) that isn't in a default TinyTeX install, just to keep a "≈" symbol rendering in the brand font instead of silently falling back to a different typeface. Small example of the kind of debugging this work actually involves — it's not just writing R and LaTeX, it's noticing when something renders subtly wrong.

## 10. What I Learned — Judgment & Research Exposure
How to talk about research design and findings in accessible terms — it's hard! Balancing making the writing interesting and engaging with staying true to the caveats and limitations of empirical work. Continually asking yourself "what's the point of this?" to try to produce better work.

A real before/after instead of an abstract claim: v1's Bottom Line box said the program's "true effect was a precise zero." By v10, the language had sharpened to "a lack of understanding at these facilities does not appear to be what was holding compliance back" — more precise about what the finding does and doesn't imply. That shift is the caveat-balancing point made concrete, not just asserted.

## 11. Personal Takeaways
The personal connection with the other interns and pre-docs meant a lot this summer. The work was especially fulfilling because I was surrounded by smart, hard-working, supportive colleagues — the photos are a mix of moments together outside of work: a sunset picnic, a hike, a local festival, messing around in the office, and meals shared along the way.

## 12. Thank you / Questions
