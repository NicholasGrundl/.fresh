# Plotting patterns (matplotlib / seaborn)

Load this only when the script being authored produces figures. These conventions sit on
top of the base scaffold in `assets/script_template.py`.

## Core rule: never display, always save

The consumer is usually an agent, not an interactive session. Scripts must save figures to
disk and never call `plt.show()`.

## matplotlib pattern

The reliable pattern (works across backends in practice):

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(10, 6))
plt.close()  # prevent any display; we still hold the fig/ax references

# build everything on ax. and fig. methods
ax.plot(df["x"], df["y"], label="series")
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.legend(loc="best", frameon=False)
ax.grid(True, alpha=0.3)

# export by passing the fig object to the renderer
fig.savefig(output_path, dpi=150, bbox_inches="tight")
```

Key points:
- Create `fig, ax` with `plt.subplots()`.
- Call `plt.close()` immediately after creating the figure to suppress display.
- Operate only on `ax.` / `fig.` methods, never the `plt.` state machine for building.
- Export with `fig.savefig(...)`. PNG at `dpi=150`, `bbox_inches="tight"` are good defaults.

## seaborn pattern

Create the figure/axes yourself, then hand the `ax` (or `fig`) to seaborn so you keep
control of sizing and saving:

```python
import matplotlib.pyplot as plt
import seaborn as sns

fig, ax = plt.subplots(figsize=(10, 6))
plt.close()

sns.lineplot(data=df, x="time_h", y="value", hue="variable", ax=ax)
ax.set_title("...")

fig.savefig(output_path, dpi=150, bbox_inches="tight")
```

Use seaborn when you want higher-level chart types or its default styling; otherwise plain
matplotlib is enough.

## Output path

Figures default to a `figures/` directory under the project root. Apply the same
non-clobber + nanoid suffix rule from the base scaffold (`resolve_output_path`), and log
the final resolved path so the agent can find the image.

## Where to find more (web)

Both libraries split their docs into the same three kinds. Pick by what you need:

**matplotlib**
- Tutorials — https://matplotlib.org/stable/tutorials/index.html — learn concepts (Artist
  model, layout, color, text). Read when unsure *how* something works.
- Gallery — https://matplotlib.org/stable/gallery/index.html — copy-paste examples grouped by
  chart type (Lines/bars/markers, Statistics, Images/contours, Pie/polar, Text/annotations,
  Color, 3D, …). Start here when you already know the chart you want.
- API — https://matplotlib.org/stable/api/index.html — exact signatures.
  `matplotlib.axes.Axes` is the workhorse for our `ax.`-based pattern;
  `matplotlib.figure.Figure` for figure-level methods like `savefig`.

**seaborn**
- Tutorial — https://seaborn.pydata.org/tutorial.html — concepts: relational / distribution /
  categorical plots, plus figure aesthetics & color palettes.
- Examples — https://seaborn.pydata.org/examples/index.html — thumbnail gallery (~50 plots),
  each linking to full code.
- API — https://seaborn.pydata.org/api.html — function reference. Prefer **axes-level**
  functions (`scatterplot`, `histplot`, `boxplot`, `lineplot`) that accept `ax=` and fit our
  `fig, ax` + `savefig` convention. Avoid **figure-level** functions (`relplot`, `displot`,
  `catplot`) — they create their own figure and bypass our pattern.

**Fetching these programmatically:** matplotlib.org rejects default tool user-agents with
HTTP 403. If a fetch fails, retry with a browser User-Agent, e.g.:

```bash
curl -sS -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124.0 Safari/537.36" \
  https://matplotlib.org/stable/api/index.html
```

seaborn.pydata.org fetches fine without special headers.
