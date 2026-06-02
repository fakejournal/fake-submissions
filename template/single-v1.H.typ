#let fake__brand_color = rgb("#FFD390")
#let __font_serif = ("Libertinus Serif", "TeX Gyre Termes", "Noto Serif CJK SC")
#let __font_sans = ("TeX Gyre Heros", "Noto Sans CJK SC")


#let fake_brand_logo_main = [
  #let titlewidth = 130mm
  #block({
    scale(x: titlewidth, y: titlewidth * 30%, reflow: true, box(text(
      font: (
        // "GFS Didot",
        "Playfair Display",
        "DM Serif Display",
      ),
      stroke: white + 0.008em,
      tracking: -0.025em,
      weight: 600,
      [Fake],
    )))
  })
]




#let h_shrink(
  it,
  max_width: 100mm,
  eps: 0.1pt,
  max_iter: 40,
) = context {
  // Find the smallest width that preserves the natural height of `it`.
  //
  // Strategy:
  // 1. Measure the unconstrained layout height.
  // 2. Find a lower bound where height increases.
  // 3. Binary-search the transition point.
  // 4. Return a box with the optimal width.
  //
  // Caveats:
  // - This assumes height is monotonic as width shrinks.
  // - Typst measurements are quantized, so `eps` controls precision.
  // - Extremely pathological layouts may not behave perfectly.

  // Natural size
  let natural = measure(box(it), width: max_width)
  let target_h = natural.height
  let natural_w = natural.width

  // Helper
  // let fits = w => {
  //   measure(box(width: w, it)).height == target_h
  // }
  let fits = w => {
    (
      calc.abs(
        measure(box(width: w, it)).height - target_h,
      )
        < 0.01pt
    )
  }

  // Trivial case
  if natural_w <= eps {
    return box(width: natural_w, it)
  }

  // ------------------------------------------------------------------
  // Phase 1: find lower bound where height increases
  // ------------------------------------------------------------------

  let lo = 0pt
  let hi = natural_w

  // Exponential descent toward smaller widths.
  // We keep shrinking until height changes.
  let probe = natural_w

  while probe > eps and fits(probe) {
    hi = probe
    probe = probe / 2
  }

  lo = probe

  // If even extremely tiny widths still fit,
  // just return the smallest discovered.
  if fits(lo) {
    return box(width: lo, it)
  }

  // ------------------------------------------------------------------
  // Phase 2: binary search
  // invariant:
  //   lo -> DOES NOT fit
  //   hi -> DOES fit
  // ------------------------------------------------------------------

  let iter = 0

  while iter < max_iter and hi - lo > eps {
    let mid = (lo + hi) / 2

    if fits(mid) {
      hi = mid
    } else {
      lo = mid
    }

    iter += 1
  }

  box(width: hi, it)
}







#let make_title(input_toml, title_override: none) = {
  let dataobj = input_toml

  set text(number-width: "tabular")
  set par(first-line-indent: 0em)
  block(width: 100%, spacing: 15mm, [
    #set text(font: __font_sans, size: 10pt)
    // *FAKE*
    #box(image(height: 19pt, "/_vi/logo2-1.png"))
    // #box(scale(y: 19pt, x: auto, reflow: true, box(fake_brand_logo_main)))
    #h(1fr)
    #dataobj.editor.obj_id

    #v(2mm)

    #text(tracking: 0.11em, weight: 600, fill: fake__brand_color.darken(20%), upper(dataobj.editor.category_label))

    // #block(width: 100%, height: 0.44pt, fill: gray)
  ])

  block(width: 100%, spacing: 10mm, [
    // 1. Article Title
    #block(width: 100%)[
      #set par(justify: false)
      #let __realTitle = dataobj.article.title
      #if title_override != none {
        __realTitle = title_override
      }
      #show math.equation.where(block: false): it => box(it)
      #text(size: 16pt, weight: 700, font: __font_sans, h_shrink(max_width: 130mm, __realTitle))
    ]
    // #v(1mm)
    // #box(width: 130mm, height: 0.4pt, fill: fake__brand_color.darken(20%))
    #v(4mm)

    // 2. Authors Row (Fixed with unified paragraph and non-breaking boxes)
    #par(leading: 0.65em, [
      #set text(font: __font_sans)
      #(
        dataobj
          .author
          .map(auth => {
            // Keeping the name and its superscripts welded together in a single box
            box([
              #text(size: 11pt, weight: 500, auth.full_name)
              #super(text(fill: gray.darken(40%), {
                auth.affiliations.map(str).join(",")
              }))
              #if auth.corresponding == true [
                #super(text(fill: blue.darken(40%), "*"))
              ]
            ])
          })
          .join(text(fill: gray.darken(40%), ",  "))
      )
    ])
    // #v(6mm)

    // 3. Affiliations Block
    #block(width: 100%, {
      let aff_dict = dataobj.affiliations
      for (key, aff) in aff_dict [
        #text(size: 9pt, fill: gray.darken(70%), [
          #super(key) #aff.organization, #aff.city, #aff.country
        ])
        #v(0.01mm)
      ]
    })
    // #v(5mm)

    // 4. Modern minimalist separator accent
    // #line(length: 100%, stroke: 0.5pt + gray.lighten(40%))
  ])
}



#let mode_2col(doc) = {
  columns(2, gutter: 16pt, doc)
}



#let enable_heading_numbering(doc) = {
  set heading(numbering: "1.1.1.1.1.1    ")
  doc
}

#let make_single(doc) = {
  set page(
    paper: "a4",
    margin: (top: 15mm, bottom: 20mm, left: 15mm, right: 15mm),
    footer: [
      #set text(size: 9pt, font: __font_sans, weight: 500)
      #context [
        #let __isodd = calc.odd(counter(page).get().first())
        #if __isodd { h(1fr) }
        #counter(page).display()
        #if not __isodd { h(1fr) }
      ]
    ],
  )
  set heading(bookmarked: false)
  set text(font: __font_serif, size: 10pt)
  set par(leading: 0.6em, spacing: 0.6em, justify: true, first-line-indent: 2em)
  set table(inset: 4pt, stroke: 0.33pt + black.lighten(20%))
  show table: set par(justify: false)

  show heading: it => {
    let dep = it.depth
    let size = (7 - dep) * 1.5pt + 3.5pt
    set par(first-line-indent: 0mm)
    set text(
      font: __font_sans,
      weight: 600,
      size: size,
    )
    block(sticky: true, above: 2.0 * size, below: 1 * size)[
      #it
    ]
  }

  show columns: it => {
    v(20pt, weak: false)
    it
    v(20pt, weak: true)
  }

  doc
}
