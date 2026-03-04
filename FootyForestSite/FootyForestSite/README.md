# The Footy Forest Website

AFL match predictions powered by ensemble machine learning.  
Built with [Quarto](https://quarto.org) and deployed to GitHub Pages.

## Weekly workflow

Each round, after running the Footy Forest R pipeline:

### 1. Copy the updated CSVs into the site

```r
# Run this after the pipeline completes, or add it to the end of the pipeline
file.copy(
"C:/Users/User/OneDrive/Documents/R/FootyForestv1.3/tips_table_for_website.csv",
"C:/Users/User/OneDrive/Documents/R/FootyForestWebsite/FootyForestDashboard/data/tips_table_for_website.csv",
overwrite = TRUE
)

file.copy(
"C:/Users/User/OneDrive/Documents/R/FootyForestv1.3/power_rankings.csv",
"C:/Users/User/OneDrive/Documents/R/FootyForestWebsite/FootyForestDashboard/data/power_rankings.csv",
overwrite = TRUE
)
```

Or from the terminal:

```bash
cp FootyForestv1.3/tips_table_for_website.csv FootyForestDashboard/data/
cp FootyForestv1.3/power_rankings.csv FootyForestDashboard/data/
```

### 2. Render the site

```bash
quarto render
```

Or from R:

```r
quarto::quarto_render()
```

### 3. Deploy

If using GitHub Pages with `output-dir: docs`:

```bash
git add -A
git commit -m "Round X predictions"
git push
```

## Project structure

```
FootyForestDashboard/
├── _quarto.yml          # Site configuration
├── custom.scss           # Theme and styling
├── index.qmd            # Home page with predictions table
├── rankings.qmd         # Power rankings page
├── about.qmd            # About the model
├── blog.qmd             # Blog listing page
├── data/
│   ├── tips_table_for_website.csv   # ← overwritten each round
│   └── power_rankings.csv           # ← overwritten each round
├── images/
│   └── logo.png
├── posts/
│   └── welcome/
│       └── index.qmd    # Blog posts go here
└── docs/                 # Rendered site output (git-tracked for GitHub Pages)
```

## Adding a blog post

Create a new folder under `posts/` with an `index.qmd` file:

```
posts/
└── round-5-review/
    └── index.qmd
```

With YAML frontmatter:

```yaml
---
title: "Round 5 review"
description: "How the model performed in round 5."
author: "Matt Nurse"
date: "2026-04-15"
categories: [performance, review]
---
```

The blog listing page will automatically pick it up on the next render.

## Automating the CSV copy

To fully automate, add these lines to the end of `save_results()` in the R pipeline:

```r
# Copy CSVs to website data folder
site_data_dir <- "C:/Users/User/OneDrive/Documents/R/FootyForestWebsite/FootyForestDashboard/data"
file.copy(file.path(config$project_dir, "tips_table_for_website.csv"),
          file.path(site_data_dir, "tips_table_for_website.csv"), overwrite = TRUE)
file.copy(file.path(config$project_dir, "power_rankings.csv"),
          file.path(site_data_dir, "power_rankings.csv"), overwrite = TRUE)
```
