#let fake_brand_logo_main = [

]



#set page(
  width: auto,
  height: auto,
  margin: (
    top: 15mm,
    left: 15mm,
    right: 15mm,
    bottom: 15mm,
  ),
  fill: none,
)

#let makeimg(fill_color) = page[
  #let titlewidth = 130mm
  #block({
    scale(x: titlewidth, y: titlewidth * 30%, reflow: true, box(text(
      font: (
        // "GFS Didot",
        "Playfair Display",
        "DM Serif Display",
      ),
      // stroke: fill_color + 0.008em,
      tracking: -0.025em,
      weight: 600,
      [Fake],
    )))
  })
]

#makeimg(black)
#makeimg(white)


// typst c _vi/logo2.typ "_vi/logo2-{0p}.svg" &&

#let shcmd11133 = ```sh
typst c _vi/logo2.typ "_vi/logo2-{0p}.png" --ppi 900
for fn in 1 2; do
  magick "_vi/logo2-$fn.png" -trim +repage "_vi/logo2-$fn.png"
done
```
