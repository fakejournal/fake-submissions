#set page(width: auto, height: auto, margin: 0mm, fill: none)

#let titlewidth = 142mm
#let font_brand = ("DM Serif Display",)

#let makeimg(fill_color) = page[
  #scale(reflow: true, y: 20% * titlewidth, x: titlewidth, box(
    inset: (left: -1.1mm, right: -1.1mm),
    text(
      fill: fill_color,
      size: 66mm,
      font: font_brand,
    )[FAKE],
  ))
]

#makeimg(black)
#makeimg(white)


#let shcmd11133 = ```sh
typst c src/logo1.typ "src/logo1-{0p}.svg" &&
typst c src/logo1.typ "src/logo1-{0p}.png" --ppi 900
```
