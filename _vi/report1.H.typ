#import "@preview/yemianfengge:0.1.0": *
#import "@preview/ose-pic:0.1.2": *


#let font_serif = (
  "TeX Gyre Termes",
  "Nimbus Roman",
  "FreeSerif",
  "Times New Roman",
  "Libertinus Serif",
  "Noto Serif CJK SC",
)
#let font_sans = (
  "TeX Gyre Heros",
  "FreeSans",
  "Roboto",
  "Inter",
  "Liberation Sans",
  "Noto Sans",
  "Open Sans",
  "Noto Sans CJK SC",
)
#let font_sans_fancy = (
  "Roboto",
  "Inter",
  "TeX Gyre Heros",
  "FreeSans",
  "Liberation Sans",
  "Noto Sans",
  "Open Sans",
  "Noto Sans CJK SC",
)

#let state__allow_empty_pages = state("allow_empty_pages", true)



#let docinit(
  section_numbering: true,
  enable_binding_offset: true,
  allow_empty_pages: true,
  doc,
) = {
  show: ose-pic-init
  state__allow_empty_pages.update(allow_empty_pages)
  let fontsize = 11pt
  let textwidth = 39 * fontsize
  let hmargin = (210mm - textwidth) / 2
  let bindingoffset = 5mm
  if enable_binding_offset == false {
    bindingoffset = 0mm
  }
  set page(margin: (
    top: 40mm,
    bottom: 38mm,
    inside: hmargin + bindingoffset,
    outside: hmargin - bindingoffset,
  ))
  set text(font: font_sans, number-width: "tabular", slashed-zero: false)
  set par(leading: 0.6em, spacing: 1.5em, justify: true, first-line-indent: 2em)
  set heading(numbering: if section_numbering { "1.1.1.1.1.   " } else { none })
  set table(inset: 4pt, stroke: 0.33pt + black.lighten(20%))
  show table: set par(justify: false)


  AddToShipoutFGAll(context {
    if getpagestyle-sync() == "cover" {}
    if getpagestyle-sync() == "plain" {
      let evenodd = if calc.odd(here().page()) { 1 } else { -1 }
      place(center + bottom, dx: bindingoffset * evenodd, dy: -15mm, box(width: textwidth, {
        if evenodd > 0 { h(1fr) }
        [#here().page()]
        if evenodd < 0 { h(1fr) }
      }))
    }
  })

  show heading: it => {
    let dep = it.depth
    let size = (5 - dep) * 5.9pt + 1.5pt
    set par(first-line-indent: 0mm)
    set text(
      font: font_sans_fancy,
      weight: 600,
      size: size,
    )
    block(sticky: true, above: 2.0 * size, below: 1 * size)[
      #it
    ]
  }

  doc
}



#let cover_title_big(it) = block(width: 100%, {
  set text(size: 32pt, weight: 600)
  it
})
#let cover_title_medium(it) = block(width: 100%, {
  set text(size: 25pt, weight: 600)
  it
})
#let cover_title_subtitle(it) = block(width: 100%, {
  set text(size: 18pt, weight: 500)
  it
})



#let make_cover(
  cover_content,
  footer: none,
) = {
  let __covermargin = 22mm
  page(margin: __covermargin, {
    thispagestyle("cover")
    set par(justify: false, leading: 0.5em, spacing: 0.8em)
    set text(number-width: "tabular", font: font_sans_fancy)
    set block(spacing: 5mm)
    block(width: 100%, height: 48mm, {
      image(height: 8mm, "logo2-1.svg")
      v(2mm)
      set text(size: 9pt, tracking: 0.05em, weight: 500)
      upper[The Journal of Unverifiable Discoveries]
    })
    block(width: 100%, {
      cover_content
    })
    v(1fr)
    if footer != none {
      block(width: 100%, {
        set text(size: 11pt, tracking: 0.05em, weight: 500)
        set par(leading: 0.5em, spacing: 1em)
        footer
      })
    }

    AddToShipoutBG(place(center + bottom, box(inset: 0mm, {
      let __buffer = ""
      for itr in range(0, 1 + 175) {
        let vertical = itr * 19 + 220
        if vertical > 2970 - 220 { continue }
        let width = (calc.sin(itr * 0.04500) + 2) / 3
        width += (calc.sin(itr * 0.04500 * 8) + 4) / 5 / 6
        width *= (1800 / 2 - 220)
        __buffer += ```
          <path d="M 2100,2970 m-220,0, m0,-@vertical h -@width" fill="none" stroke="#bbbbbb" stroke-width="2" />
        ```
          .text
          .replace("@vertical", repr(vertical))
          .replace("@width", repr(width))
      }
      let svgxml = ```xml
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2100 2970">
        @buffer
      </svg>
      ```
        .text
        .replace("@buffer", __buffer)
      image(width: 210mm, height: 297mm, fit: "cover", bytes(svgxml))
      pdf.attach("decobg01.svg", bytes(svgxml))
    })))
  })
  pagestyle("plain")
}



#let __chapter_heading_styler(it) = {
  set par(first-line-indent: 0mm, spacing: 0.7em)
  set text(size: 22pt, font: font_sans_fancy)
  it
}
#let maketoc(title: [Table of Contents]) = {
  outline(title: __chapter_heading_styler(title))
}

#let chapter(it) = {
  [
    #show heading.where(level: 1): it => {
      context {
        if state__allow_empty_pages.get() {
          pagebreak(weak: true, to: "odd")
        } else {
          pagebreak(weak: true)
        }
      }
      v(1mm)
      set text(font: font_sans_fancy)
      block(width: 100%)[
        #set par(first-line-indent: 0mm, spacing: 0.7em)
        #text(weight: 500, size: 14pt)[CHAPTER #counter(heading).get().first()]
        #v(3mm)
        #__chapter_heading_styler(it.body)
      ]
      v(10mm)
    }
    #heading(level: 1, it)
  ]
}

// #let bigskip = v(8mm)
#let make_cover_env = (
  bigskip: v(8mm),
)
// #make_cover_env.bigskip = v(8mm)
