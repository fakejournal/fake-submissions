#let __font_serif = ("TeX Gyre Termes", "Nimbus Roman", "Times New Roman", "Libertinus Serif", "Noto Serif CJK SC")
#let __font_sans = ("TeX Gyre Heros", "Noto Sans CJK SC")

#let docinit(
  doc,
  fontsize: 11pt,
  refno: none,
  pages: false,
  self_addr: none,
  recv_addr: none,
) = {
  import "@preview/ose-pic:0.1.2": *
  show: ose-pic-init
  let hmargin = (210mm - fontsize * 39) / 2
  set page(margin: (
    left: hmargin,
    right: hmargin,
    top: 45mm,
    bottom: 40mm,
  ))
  set text(size: fontsize, number-width: "tabular")
  set text(font: __font_serif)

  AddToShipoutFGAll({
    // Top logo
    place(top + center, box(width: 200mm, inset: 11mm, {
      set align(left)
      box(image(height: 9mm, "logo2-1.svg"))
      par[The Journal of Unverifiable Discoveries]
    }))
    // Reference number
    if refno != none {
      place(top + center, box(width: 200mm, inset: 11mm, {
        align(right, text(size: 10pt, {
          set par(leading: 0.55em, spacing: 0.55em)
          text(font: __font_sans, {
            // par[The Journal of Unverifiable Discoveries]
            par[https://fakejournal.org]
            par[https://github.com/fakejournal]
          })
          v(6.5mm)
          refno
        }))
      }))
    }
    // Page numbers
    if pages {
      place(bottom + center, box(width: 200mm, inset: 11mm, {
        h(1fr)
        context here().page()
      }))
    }
  })

  set par(justify: true)
  doc
}




#let make_title_medium(it, alignment: center) = block(spacing: 16mm, width: 100%, {
  set par(justify: false)
  set text(weight: 600, font: __font_serif, size: 14pt)
  set align(alignment)
  v(10mm)
  it
})
