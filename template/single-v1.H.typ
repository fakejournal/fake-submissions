// =============================================================
// An editor may use this to build single article PDF
// =============================================================

#let fake__brand_color = rgb("#FFD390")
#let __font_serif = (
  "Latin Modern Roman",
  "XCharter",
  "Libertinus Serif",
  "TeX Gyre Termes",
  "Noto Serif CJK SC",
)
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







#let make_title(input_toml, title_override: none, abstract_content: none) = {
  let dataobj = input_toml

  set text(number-width: "tabular")
  set par(first-line-indent: 0em)
  block(width: 100%, spacing: 15mm, [
    #set text(font: __font_sans, size: 10pt)
    // *FAKE*
    #box(image(height: 19pt, "/_vi/logo2-1.png"))
    // #box(scale(y: 19pt, x: auto, reflow: true, box(fake_brand_logo_main)))
    #h(1fr)
    // #dataobj.editor.obj_id
    // #link("https://fakejournal.org/en/articles/" + dataobj.editor.obj_id + "/", dataobj.editor.obj_id)

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
      #text(size: 23pt, weight: 700, font: __font_serif, h_shrink(max_width: 130mm, __realTitle))
    ]
    // #v(1mm)
    // #box(width: 130mm, height: 0.4pt, fill: fake__brand_color.darken(20%))
    #v(4mm)

    // 2. Authors Row (Fixed with unified paragraph and non-breaking boxes)
    // #par(leading: 0.65em, [
    //   #set text(font: __font_sans)
    //   #(
    //     dataobj
    //       .author
    //       .map(auth => {
    //         // Keeping the name and its superscripts welded together in a single box
    //         box([
    //           #text(size: 11pt, weight: 500, auth.full_name)
    //           #super(text(fill: gray.darken(40%), {
    //             auth.affiliations.map(str).join(",")
    //           }))
    //           #if auth.corresponding == true [
    //             #super(text(fill: blue.darken(40%), "*"))
    //           ]
    //         ])
    //       })
    //       .join(text(fill: gray.darken(40%), ",  "))
    //   )
    // ])
    // // #v(6mm)

    // // 3. Affiliations Block
    // #block(width: 100%, {
    //   let aff_dict = dataobj.affiliations
    //   for (key, aff) in aff_dict [
    //     #text(size: 9pt, fill: gray.darken(70%), [
    //       #let my_arr = (aff.organization, aff.city, aff.country).filter(it => it != "NULL")
    //       #super(key) #my_arr.join([, ])
    //     ])
    //     #v(0.01mm)
    //   ]
    // })

    // #v(5mm)
    // #block(width: 100%, {
    //   set text(font: __font_sans, size: 9pt)
    //   // set text(size: 9pt)
    //   grid(
    //     columns: (auto, 1fr),
    //     column-gutter: 6mm,
    //     row-gutter: 2.2mm,
    //     [Date Accepted], [#input_toml.editor.date_accept.display()],
    //     [Date Published], [#input_toml.editor.date_print.display()],
    //   )
    // })

    #v(5mm)
    #block(width: 100%, {
      set text(font: __font_sans, size: 9pt)
      let hrule = block(width: 100%, spacing: 3mm, height: 0.45pt, fill: black)
      hrule
      grid(
        columns: (1fr, 2.3fr),
        gutter: 9mm,
        [
          State: #input_toml.editor.state
          #hrule
          Date of Manuscript: #input_toml.editor.date_manuscript.display()
          #hrule
          #{
            if input_toml.editor.state == "PreAccept" {
              [Date of PreAccept: #input_toml.editor.date_review.display()]
            }
            if input_toml.editor.state == "AcceptedSingle" {
              [Date of Accept: #input_toml.editor.date_accept.display()]
            }
            if input_toml.editor.state == "Published" {
              [Date of Print: #input_toml.editor.date_print.display()]
            }
          }
          #hrule
          License: CC BY 4.0
        ],
        [
          #v(1mm)
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
                #let my_arr = (aff.organization, aff.city, aff.country).filter(it => it != "NULL")
                #super(key) #my_arr.join([, ])
              ])
              #v(0.01mm)
            ]
          })

          #if abstract_content != none {
            hrule
            set text(size: 11pt, font: __font_serif)
            abstract_content
          }
        ],
      )
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

#let make_single(doc, input_toml: (:)) = {
  let dataobj = input_toml
  set page(
    paper: "a4",
    margin: (top: 15mm, bottom: 20mm, left: 15mm, right: 15mm),
    footer: [
      #set text(size: 9pt, font: __font_sans, weight: 500)
      #context [
        #block(width: 100%, height: 0.45pt, fill: black)
        FAKE JOURNAL~~~~~
        #link("https://fakejournal.org/en/articles/" + dataobj.editor.obj_id + "/", dataobj.editor.obj_id)
        #h(1fr)
        #counter(page).display()
      ]
    ],
  )
  set heading(bookmarked: false)
  set text(font: __font_serif, size: 10pt)
  set par(leading: 0.75em, spacing: 0.95em, justify: true, first-line-indent: 2em)
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




#let editor_comment_block(it) = block(width: 100%, fill: black.transparentize(93%), inset: 9pt, [
  #set par(first-line-indent: 0mm)
  #it
])



#let citations_area_style(it) = {
  set text(font: __font_sans, size: 8.8pt)
  it
}



#let fullwidth-table(
  styling: it => it,
  columns: (),
  cells: (),
  debug: false,
) = context {
  // --- INTERNAL HELPERS ---
  
  // Strip fractional spacing for accurate natural measurement
  let strip-fr-h(it) = {
    if type(it) != content { return it }
    if it.func() == h {
      let amt = it.at("amount", default: none)
      if type(amt) == ratio { return [] }
      return it
    }
    if it.has("children") { return it.children.map(strip-fr-h).join() }
    if it.has("body") {
      let fields = it.fields()
      let body = strip-fr-h(fields.remove("body"))
      return (it.func())(body, ..fields)
    }
    it
  }
  
  // Extract content from table.header/footer wrappers
  let get-cell-content(it) = {
    if type(it) != content { return (it,) }
    if it.has("children") and (it.func() == table.header or it.func() == table.footer) {
      return it.children
    }
    return (it,)
  }
  
  let probe-col(col-cells) = styling(table(columns: (auto,), ..col-cells))
  
  // --- PREPARATION ---
  
  let flat-cells = cells.map(get-cell-content).flatten()
  let clean-cells = flat-cells.map(strip-fr-h)
  
  let col_specs = if type(columns) == int { range(columns).map(_ => auto) } else { columns }
  let col_count = col_specs.len()
  let natural_widths = ()
  
  if debug [== Debug: Column Probes]
  
  // --- MEASUREMENT LOOP ---
  
  for i in range(col_count) {
    let col_def = col_specs.at(i)
    let w = 0pt
    
    if type(col_def) == length {
      w = col_def
      if debug {
        stack(dir: ltr, spacing: 1em, rect(width: col_def, height: 1em, fill: gray.lighten(50%)), [Fixed: #col_def])
      }
    } else {
      let column_cells = range(i, clean-cells.len(), step: col_count).map(idx => clean-cells.at(idx))
      let probe = probe-col(column_cells)
      w = measure(probe).width
      
      if debug {
        block(stroke: red + 0.5pt, inset: 4pt, [
          #probe
          #text(size: 8pt, fill: red)[Measured (inc. strokes): #w]
        ])
      }
    }
    natural_widths.push(w)
  }
  
  // Calculate overhead to subtract from probes
  let probe_overhead = measure(styling(table(columns: (0pt,), stroke: 0.1pt))).width
  let clean_widths = natural_widths.map(w => if type(w) == length { w } else { w - probe_overhead })
  
  // Calculate final table overhead
  let total_table_overhead = measure(styling(table(columns: col_specs.map(_ => 0pt)))).width
  let sum_clean_natural = clean_widths.sum()
  
  if debug [---]
  
  layout(container_size => {
    let remaining_width = container_size.width - sum_clean_natural - total_table_overhead
    
    let auto_indices = range(col_count).filter(i => col_specs.at(i) == auto)
    let target_count = if auto_indices.len() > 0 { auto_indices.len() } else { col_count }
    let extra_per_col = calc.max(0pt, remaining_width / target_count)
    
    let final_columns = range(col_count).map(i => {
      let base = clean_widths.at(i)
      if col_specs.at(i) == auto or auto_indices.len() == 0 {
        return base + extra_per_col
      }
      return base
    })
    
    if debug [== Final Expanded Table]
    
    styling(table(
      columns: final_columns,
      ..cells
    ))
    
    if debug {
      text(size: 8pt, fill: blue)[
        Container: #container_size.width |
        Clean Natural Total: #sum_clean_natural |
        Remaining Slack: #remaining_width
      ]
    }
  })
}
