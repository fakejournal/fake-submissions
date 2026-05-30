#import "/template/issue-v1.H.typ": *
#show: docinit


#make_cover(
  top_left: [ISSUE PRE-1],
  top_right: [TYPESETTING DEMO],
  cover_bg: place(center + horizon, image(width: 100%, height: 100%, fit: "cover", "cover-juli-kosolapova.jpg")),
  cover_content: [
    #cover_mkhead1[MARTIAN \ BIOSIGNATURES]
    #cover_mkhead2[INDICATORS OF LIFE]
    #cover_mkhead3(
      text_color: special_text_color__gold.darken(60%),
    )[Evidence for Extraterrestrial Life?\ Putative Extracellular Structures Isolated]

    #v(2mm)

    #cover_hbar()
    #cover_smallbox[Final safety checks underway.]

    #cover_hbar(height: 1pt)
    #cover_smallbox[Opening delayed by minor containment concerns.]

    #cover_hbar(height: 1pt)
    #cover_smallbox[Tickets sold out before ethics review.]


  ],
  extra_content: [
    #place(center + horizon, rotate(-57deg, reflow: true, text(
      size: 50mm,
      fill: red.transparentize(40%),
      font: font_sans1,
      weight: 400,
      [SPECIMEN],
    )))
  ],
)


#make_toc(top_right: [2022.01])



#make_part("1", "Cover Story", [Here is some description. We can make it long enough to make up a paragraph.])
#use_article("/database/2022/2022.3170411")

#make_part("2", "Research", [Here is some description. We can make it long enough to make up a paragraph.])
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")

#make_part("3", "Review", [Here is some description. We can make it long enough to make up a paragraph.])
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")

#make_part("4", "Communication", [Here is some description. We can make it long enough to make up a paragraph.])
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")

#make_part("5", "Editorial Announcement", [Here is some description. We can make it long enough to make up a paragraph.])
#use_article("/database/2022/2022.3170411")
#use_article("/database/2022/2022.3170411")










#let cmdsh273645 = ```sh
magick pub/2022/2022.01/cover-juli-kosolapova-raw.jpg \
  -gravity center \
  -crop "%[fx:min(w,h)]x%[fx:min(w,h)]+0+0" +repage \
  -resize 1100x1100! \
  pub/2022/2022.01/cover-juli-kosolapova.jpg
```





#make_ender[
  *COPYRIGHT*

  // Copyright
  #sym.copyright; 2026 Various Authors and Editors at FAKE JOURNAL.

  Released with {{INSERT LICENSE HERE}}.
  See Creative Commons website for full license text and explanation.

  Publish date 2026-05-30

  ~

  *CONTACT*

  https://fakejournal.org \
  https://github.com/fakejournal \
  info\@fakejournal.org
]


