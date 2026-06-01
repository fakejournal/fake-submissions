#import "/_vi/fakeletterhead1.H.typ": *




// --------- BEGIN EDITABLE DATA ---------
#let acting_editor = [John Appleseed]
#let toml_data = toml("../database/2022/2022.3170411/info.toml") // Change article path here
#show: docinit.with(
  refno: [Reference No. 20263278738], // Generate unique number using: https://neruthes.github.io/jsu/u/nowts47/
)
// --------- END EDITABLE DATA ---------






#make_title_medium(upper[Letter of Acceptance])
#let authorsplural = toml_data.author.len() > 1

Dear #if authorsplural { [Authors] } else { [Author] },

We are glad to inform you that your manuscript has been accepted.



#v(1em)

_Manuscript title_:

#block(width: 100%, inset: (left: 4em, right: 4em))[
  #set align(center)
  #eval(mode: "markup", toml_data.article.title)
]
#v(1em)

#if authorsplural { [_Authors_] } else { [_Author_] }:

#block(width: 100%, inset: (left: 4em, right: 4em))[
  #toml_data.author.map(it => [#it.full_name]).join([, ])
]
#v(1em)


#v(50mm)
#box(inset: (left: 24em), [
  #acting_editor

  Editorial Office

  #toml_data.editor.date_accept.display()
])

#v(20mm)

#par(lorem(300))
#par(lorem(300))
#par(lorem(300))
#par(lorem(300))




// How to build document
#let shcmd078405041998891059 = ```sh
./make.sh office/letter_acceptance.typ
```
