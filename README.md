# EIL Output Library

A shared library of public-facing outputs developed at the Environmental Inequality Lab (EIL). Each paper gets a full communications bundle; shared templates and design assets live in `formats/`.

## Structure

```
eil-output-library/
├── papers/                    # One folder per paper, each containing a full output bundle
│   └── YYYY-[topic-slug]/     # If it's a working paper, use WP-[topic-slug]
│       ├── data-viz/          # Figure pipeline shared across this paper's outputs
│       │   ├── code/          # Figure scripts
│       │   ├── data/          # Datasets (excluded from git)
│       │   └── figures/       # Figure outputs (shared across outputs)
│       ├── research-highlight/  # One-page research highlight
│       ├── press-release/     # Press release
│       ├── blog/              # Blog post copy and assets
│       └── social/            # Social media copy and assets
├── newsletter/                # Newsletter posts (date-based, not tied to a single paper)
│   └── YYYY-MM-DD/
├── social/                    # Standalone social campaigns (not tied to a single paper)
│   └── YYYY-[topic-slug]/
├── formats/                   # Shared design system and templates
│   ├── logos/                 # Shared logo assets
│   ├── research-highlight/    # Research highlight templates and LaTeX design system
│   ├── press-release/         # Press release templates
│   ├── blog/                  # Blog post templates
│   ├── social/                # Social media image templates
│   ├── newsletter/            # Newsletter templates
│   └── data-viz/              # Data viz themes and templates
└── style-guides/              # Writing and design conventions by output type
    ├── research-highlight/
    ├── press-release/
    ├── blog/
    ├── social/
    ├── newsletter/
    └── data-viz/
```

## How to Use

- **Starting a new output?** Pick a format from the relevant subfolder in `formats/` and copy it as your starting point.
- **Checking style?** The `style-guides/` folder has conventions for tone, citations, figures, and formatting.
- **Sharing a draft?** Add it to the appropriate output folder with a short descriptive name.

## Paper Intake Workflow

The general idea is to start small, with the most essential bits of information from a paper, and then work up from there. This helps maintain consistent messaging across outputs. 

1. **Reading and Understanding** Read through the paper, talk with PIs about any questions, note any technically dense and/or essential-to-know sections.

   a. **Use AI to help with this Process** Obviously, reading and thinking for yourself are always going to be most helpful. However, AI can assist you to internalize and hone in on key points quickly. Additionally, using examples, templates and style guides, AI can help you create first drafts of outputs that you then iterate on. The goal is not to have AI replace the work and thinking you do, but it can help lower the time and energy costs of drafting and revision. 

   b. **Brief Interview with the PI** Once you've read through, set up a short conversation with the PI. This is your chance to ask what they think the most important takeaway is, clear up anything the paper left you unsure about, and get a sense of how they'd explain the study to someone outside the field. It's also a good spot to pick up a quote for the press release later on — just make sure the PI signs off on the exact wording before it goes into anything.
2. **Research Highlight** Here is where we can get more into the mechanics of the study (while maintaining a general interest audience). We're moving past the intrigue of the press release and taking the time to teach people something. Think about how to communicate the mechanics of research in a digestable way. This is also the piece that ends up shaping everything else. Once you've worked out how to explain the study here, that framing should carry through to the snapshot and the press release instead of starting over each time. 
3. **Empirical Snapshot** Think about what is difficult to explain verbally, or a key point that is supported by some kind of data/empirical visualization.
    - Option One: Identify one (two if absolutely necessary) figure from the paper that gets the central point across. Verify with PIs that this is the idea we want to frame our communication around. ALSO SEE IF YOU HAVE ACCESS TO THE DATA THEMSELF or if we're just doing a visual recreation. Solid example: EPA compliance figure
    - Option Two: Is there a part of the research design/central question that would benefit from an infographic (that the paper doesn't have)?
These can work independently or together, but considering this early in the process will help you avoid getting stuck on a specific visualization option.
    
4. **Press Release** Think about what a reporter needs to know to decide whether or not they want to explore or write about this paper.  This is where quotes/interpretations not in the paper would be helpful from a PI or qualified stakeholder. Talk to PIs about this early on so that we have that if necessary when press release time comes.
<!-- 5. **Social Media** Draft any posts/captions to be shared alongside key figure. Using the thinking and writing done for the press release and research highlights, hone in on the punchiest point(s). -->
<!-- 6. **Blog Post/Newsletter** Still prioritizing findings-first language, but this can be the longest form and more conversational. Hopefully by this point, you'll be familiar enough with the key points of the paper that this will be easy and an opportunity to make connections that you wouldn't in other outputs. For this I think it's fair to assume a more econ/environment-interested audience, though it should still be accessible for general readers. -->

## Contributing

To add a new output or template, open a pull request with your file in the appropriate folder and a short description in the PR body.
