#let fake__brand_color = rgb("#FFD390")
#let __font_serif = ("Libertinus Serif", "TeX Gyre Termes", "Noto Serif CJK SC")
#let __font_sans = ("TeX Gyre Heros", "Noto Sans CJK SC")

#let special_text_color__gold = rgb("#FFD390")
#let font_brand = ("DM Serif Display",)
#let font_serif = ("FreeSerif", "Noto Serif CJK SC")
#let font_sans1 = ("TeX Gyre Heros", "Noto Sans CJK SC")
#let font_sans2 = ("Barlow", "Noto Sans CJK SC")

#import "single-v1.H.typ": h_shrink


#let make_cover(input_toml, title_override: none, abstract_content: []) = page(
  width: 3 * 100pt,
  height: 4 * 100pt,
  margin: 20pt,
  foreground: {
    place(bottom + center, dy: -15pt, box(width: 100%, height: auto, inset: (left: 20pt, right: 20pt), [
      #set align(right)
      // #show: upper
      #show: emph
      #set text(
        fill: black.lighten(30%),
        font: font_sans1,
        size: 9pt,
        spacing: 110%,
        tracking: 0.01em,
        ligatures: false,
      )
      #box(width: 1fr, inset: (bottom: 2.5pt), box(width: 100%, height: 0.5pt, fill: black.lighten(30%)))
      The Journal of Unverifiable Discoveries
    ]))
  },
  {
    let dataobj = input_toml

    set text(number-width: "tabular")
    set par(first-line-indent: 0em)
    block(width: 100%, spacing: 15mm, [
      #set text(font: __font_sans, size: 10pt)
      #box(image(height: 25pt, "/_vi/logo2-1.png"))
      #h(1fr)
      #dataobj.editor.obj_id

      #text(tracking: 0.11em, weight: 600, fill: fake__brand_color.darken(20%), upper(dataobj.editor.category_label))
    ])
    v(-3mm)

    block(width: 100%, spacing: 0mm, [
      // 1. Article Title
      #block(width: 100%)[
        #set par(justify: false)
        #let __realTitle = dataobj.article.title
        #if title_override != none {
          __realTitle = title_override
        }
        #show math.equation.where(block: false): it => box(it)
        #text(size: 16pt, weight: 700, font: __font_sans, h_shrink(max_width: 280pt, __realTitle))
      ]
      #v(4mm)

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
      // #block(width: 100%, {
      //   let aff_dict = dataobj.affiliations
      //   for (key, aff) in aff_dict [
      //     #text(size: 9pt, fill: gray.darken(70%), [
      //       #super(key) #aff.organization, #aff.city, #aff.country
      //     ])
      //     #v(0.01mm)
      //   ]
      // })
      // #v(5mm)

      // 4. Modern minimalist separator accent
      // #line(length: 100%, stroke: 0.5pt + gray.lighten(40%))
      #v(15pt)
      #[
        #set text(font: __font_sans, size: 11pt)
        #set par(leading: 0.46em, spacing: 0.9em, justify: true)
        #text(weight: 600, style: "italic", size: 12pt)[Abstract]
        // #v(2mm)

        #block(breakable: false, abstract_content)
      ]
    ])
  },
)


// #let make_cover() = page(width: 300pt, height: 400pt, margin: 20pt,{
//   make_title(input_toml, titleo)
// })
