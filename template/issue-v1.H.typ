#import "@preview/ose-pic:0.1.2": *



#import "single-v1.H.typ": fake_brand_logo_main, h_shrink





#let special_text_color__gold = rgb("#FFD390")
#let font_brand = ("DM Serif Display",)
#let font_serif = ("FreeSerif", "Noto Serif CJK SC")
#let font_sans1 = ("TeX Gyre Heros", "Noto Sans CJK SC")
#let font_sans2 = ("Barlow", "Noto Sans CJK SC")



#let state__alttoclist = state("state__alttoclist", ())

#let docinit(doc) = {
  set page(paper: "a4", margin: 20mm)
  show: ose-pic-init
  set text(
    font: font_sans1,
    number-width: "tabular",
  )
  doc
}




#let cover_mkhead1(it) = block(spacing: 6mm)[
  #set text(font: "Zalando Sans", stretch: 50%, weight: 500, spacing: 70%)
  #set par(leading: 0.16em, spacing: 0.2em)
  #scale(reflow: true, x: 80%, text(size: 18mm)[#it])
]
#let cover_mkhead2(it) = block(spacing: 6mm)[
  #set text(font: "Zalando Sans", stretch: 50%, weight: 500, spacing: 50%)
  #set par(leading: 0.2em, spacing: 0.2em)
  #scale(reflow: true, x: 80%, text(size: 12mm)[#it])
]
#let cover_mkhead3(it, text_color: black) = block(spacing: 7mm)[
  #set text(font: "Zalando Sans", stretch: 50%, weight: 500, spacing: 70%)
  #set par(leading: 0.41em, spacing: 0.41em)
  #scale(reflow: true, x: 90%)[
    #text(size: 5.5mm, fill: text_color)[#it]
  ]
]
#let cover_hbar(width: 9mm, height: 2pt, fill: special_text_color__gold.darken(20%)) = box(
  width: width,
  height: height,
  fill: fill,
)
#let cover_smallbox(it) = block(spacing: 5mm, width: 51mm, h_shrink(
  {
    set text(size: 11pt, font: font_sans1)
    set par(leading: 0.38em, justify: false)
    it
  },
  max_width: 50mm,
))




#let make_cover(
  cover_bg: [],
  i_date: "",
  top_left: [ISSUE 1],
  top_right: [INAUGURAL ISSUE],
  cover_content: [FILL SOME CONTENT HERE],
  extra_content: [FILL SOME CONTENT HERE],
) = {
  [
    #metadata((
      i_date: i_date,
    )) <memo_meta>
  ]
  page(fill: white, margin: 9mm)[
    #set par(justify: false)
    #[
      #set par(spacing: 0.7em)
      #set text(font: font_sans2, stretch: 90%, tracking: 0.2em, size: 10pt, weight: 600)
      #[
        #top_left
        #h(1fr)
        #set text(fill: special_text_color__gold.darken(20%))
        #top_right
      ]
    ]
    #v(2mm)
    #align(center)[
      #let titlewidth = 130mm
      // #fake_brand_logo_main
      #box(image(width: titlewidth, "/_vi/logo2-1.png"))
      #v(3mm)
      #block(width: titlewidth, inset: (left: 0.1mm, right: 0.1mm))[
        #let halfrule = box(width: 1fr, height: 3pt, inset: (bottom: 6pt), box(
          width: 1fr,
          height: 1pt,
          fill: special_text_color__gold.darken(20%),
        ))
        #set text(
          fill: black,
          font: font_sans2,
          stretch: 90%,
          tracking: 0.3em,
          size: 9.5pt,
          weight: 500,
        )
        #halfrule;#h(5pt);THE JOURNAL OF UNVERIFIABLE DISCOVERIES#h(5pt);#halfrule;
      ]
    ]
    #v(3mm)

    #block(width: 100%, height: 200mm, inset: 0mm, fill: special_text_color__gold.desaturate(60%).lighten(25%), [
      #cover_bg
      #box(width: 100%, height: 100%, inset: 5mm)[
        #set par(leading: 0.7em, spacing: 0.6em)
        #v(5mm)
        #cover_content
      ]
    ])

    #v(1fr)
    #align(center)[
      #set text(
        fill: black,
        font: font_sans2,
        stretch: 90%,
        tracking: 0.3em,
        size: 9.5pt,
        weight: 600,
        spacing: 220%,
      )
      JOIN US. MAKE #text(fill: special_text_color__gold.darken(20%))[FAKE] REAL.
    ]
    #extra_content
  ]
  pagebreak(to: "odd")
}










#let make_part(i_index, i_title, i_desc) = page(margin: 50mm, context {
  let page_num = here().page()
  state__alttoclist.update(arr => {
    let obj = (
      level: 1,
      page: page_num,
      title: eval(mode: "markup", i_title),
    )
    return (..arr, obj)
  })
  v(30mm)
  set text(font: font_sans1)
  align(center)[
    #set text(font: font_sans1, size: 19pt, weight: 600, spacing: 140%)
    PART #i_index

    #v(10mm)
    #set text(font: font_sans1, size: 28pt, spacing: 110%)
    #i_title
  ]
  v(10mm)
  block({
    set par(justify: true)
    set text(size: 12pt, font: font_serif)
    i_desc
  })
})



#let use_article(ipath) = context {
  pagebreak(weak: true, to: "odd")
  let info_obj = toml(ipath + "/info.toml")
  let page_num = here().page()
  state__alttoclist.update(arr => {
    let obj = (
      level: 2,
      page: page_num,
      raw_toml: info_obj,
      title: eval(mode: "markup", info_obj.article.title),
    )
    return (..arr, obj)
  })

  include ipath + "/single.typ"
  pagebreak(weak: true)
}




#let make_ender(it) = {
  pagebreak(to: "odd")
  page(margin: 45mm, {
    v(70mm)
    set par(leading: 0.7em, spacing: 1.2em, justify: false)
    set text(font: font_sans1, size: 10pt, tracking: 0mm, spacing: 100%, stretch: 100%, fill: cmyk(0%, 0%, 0%, 100%))
    it
  })
}




#let make_toc(top_right: [Add some text here]) = context {
  let __pagenumzonewidth = 9mm
  set text(font: font_sans1, number-width: "tabular")
  set page(margin: 19mm)
  grid(
    columns: (1fr, 1fr),
    align: (left + bottom, right + bottom),
    box(image(height: 17mm, "/_vi/logo2-1.png")),
    box(height: 18mm)[
      #text(size: 10pt, number-width: "tabular", weight: 400, top_right)
      #v(1fr)
      #text(size: 17pt, weight: 600)[Table of Contents]
    ],
  )
  v(12mm)
  let articles = state__alttoclist.final()

  show: doc => columns(2, doc)

  set text(size: 10pt, font: font_serif)

  let counter1 = 0
  let counter2 = 0
  for (idx, obj) in articles.enumerate() {
    // Part
    if obj.level == 1 {
      counter1 += 1
      block(sticky: true, breakable: false, above: 12mm, below: 9pt, { // This block should snap to 15mm vertical quantization
        set par(leading: 0.44em, spacing: 0.5em)
        set text(size: 11pt, weight: 600, font: font_sans1)
        obj.title
        v(1mm)
        box(width: 1fr, height: 0.4pt, fill: gray)
      })
    }
    // Article
    if obj.level == 2 {
      counter2 += 1
      block(breakable: false, spacing: 9pt, {
        set par(leading: 0.44em, spacing: 0.5em)
        set text(size: 10pt, font: font_sans1)
        grid(
          columns: (__pagenumzonewidth, 1fr),
          column-gutter: 0mm,
          row-gutter: 3mm,
          align: (top + left, top + left),
          strong[#obj.page], [#obj.title],
          [],
          text(size: 9pt, fill: luma(55%))[
            _#obj.raw_toml.editor.obj_id;_~~
            #obj.raw_toml.author.map(item => item.full_name).join([, ])
          ],
        )
      })
    }
  }
}
