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
      fill: fill_color,
      [Fake],
    )))
  })
]

#makeimg(black)
#makeimg(white)






// How to build output artifacts:


#let shcmd11133 = ```sh
### BEGIN SCRIPT ###
typst c _vi/logo2.typ "_vi/logo2-{0p}.png" --ppi 900
for fn in 1 2; do
  magick "_vi/logo2-$fn.png" -trim +repage "_vi/logo2-$fn.png"
done

for fn in 1 2; do
  vtracer --input "_vi/logo2-$fn.png" --output "_vi/logo2-$fn.svg" --mode spline --filter_speckle 0 --corner_threshold 0 --splice_threshold 0 --segment_length 4
done


### END SCRIPT ###
```
