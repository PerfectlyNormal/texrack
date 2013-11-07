# texrack

Simple Rack middleware to render LaTeX to PNGs on the fly.

## Requirements

* `pdflatex` must exist in `$PATH`
* `convert` (from ImageMagick) must exist in `$PATH`

## Configuration

If "pdflatex" or "convert" is not available in `PATH`, you can change
`Texrack.config` and specify where to find them.

The default configuration is 
```ruby
Texrack.config = {
  pdflatex: "pdflatex",
  convert:  "convert",
}
```

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

### Always respond with 200 OK
If you are dealing with software incapable of proper status codes (looking at
you, Flash), you can pass `always_200=1` and it'll respond with 200 OK even
though we should really respond with a 5xx.
