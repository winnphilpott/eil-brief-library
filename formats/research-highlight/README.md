# Research Highlight Templates

Starter templates for EIL research highlights. Copy a template into a new paper's `research-highlight/` folder and fill in the placeholders.

## Available Templates

| File | Description |
|---|---|
| `research-highlights-template.qmd` | Research highlight (~two pages) with bottom line, background, the challenge, findings (with figure), and implications sections |

## How to Use

1. Copy the template into your new paper's `research-highlight/` folder and rename it to `[topic-slug]_research-highlight.qmd`
2. Update `include-in-header` in the YAML to point to `../../../formats/research-highlight/_style.tex`
3. Update the logo path to `../../../formats/logos/eil-logo-maroon.png` (or white version)
4. Fill in all `[placeholder]` text with your content
5. Add your figure to the paper's `data-viz/figures/` folder (built by a script in `data-viz/code/`) and update the figure path
