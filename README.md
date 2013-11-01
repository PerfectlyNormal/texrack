# texrack

Simple Rack middleware to render LaTeX to PNGs on the fly.

## Requirements

* `pdflatex` must exist in `$PATH`
* `convert` (from ImageMagick) must exist in `$PATH`

## Configuration

## Usage

Either POST or GET to the configured URL with `data` set to the LaTeX source to
compile.

If you `GET /` without setting `data`, you get a simple form.

### Display mode
Everything is rendered inside a displaymath block (`\[` or `$$`) by default.
To disable the displaymath block, pass `math=0`.

### Packages
The only included package is `amsmath`.
To add more, send a pipe-separated string as `packages`.
Arguments can be prepended.

For example: `packages="[usenames,dvipsnames,svgnames,table]xcolor|amssymb"`
turns into
```latex
\usepackage[usenames,dvipsnames,svgnames,table]{xcolor}
\usepackage{amssymb}
```
