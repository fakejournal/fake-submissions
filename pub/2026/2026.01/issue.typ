#import "/template/issue-v1.H.typ": *
#show: docinit


#make_cover(
  top_left: [ISSUE 2026.01],
  top_right: [SERIAL 0],
  cover_bg: place(center + horizon, image(width: 100%, height: 100%, fit: "cover", "cover-ashley-batz.jpg")),
  cover_content: [
    // P = NP in the Era of Large Language Models: An Empirical Resolution via Benchmark Saturation (Confidence: 87.3%)
    #cover_mkhead1[P = NP ]
    #cover_mkhead2[in the Era of\ Large Language Models]
    #cover_mkhead3(
      text_color: special_text_color__gold.darken(90%),
    )[An Empirical Resolution\ via Benchmark Saturation\ (Confidence: 87.3%)]

    #v(2mm)
    #v(1fr)
    #set align(right)

    #cover_hbar(fill: special_text_color__gold.darken(90%))
    #cover_smallbox(bg: white)[[RESEARCH]\ 短视频刷取频率与剩余注意⼒半衰期的微分⽅程建模]

    #cover_hbar(fill: special_text_color__gold.darken(90%), height: 1pt)
    #cover_smallbox(bg: white)[什么样的 Fake 值得发表？]

    #cover_hbar(fill: special_text_color__gold.darken(90%), height: 1pt)
    #cover_smallbox(bg: white)[[STORY]\ 一套重复不出来的⼒场参数]


  ],
  extra_content: [
    #place(center + horizon, rotate(-57deg, reflow: true, text(
      size: 50mm,
      fill: red.transparentize(40%),
      font: font_sans1,
      weight: 400,
      // [SPECIMEN],
      [],
    )))
  ],
)


#make_toc(top_right: [2026.01])





#make_part("1", "Editorial Announcement", [
  ~~~~~~~~~~
])
#use_article("/database/2026/2026.4739445", pages: 3)




#make_part("2", "Research", [
  ~~~~~~~~~~
])
#use_article("/database/2026/2026.3896037", pages: 5)
#use_article("/database/2026/2026.3963789", pages: 9)




#make_part("3", "Story", [
  ~~~~~~~~~~
])
#use_article("/database/2026/2026.4311164", pages: 2)













#let cmdsh273645 = ```sh
magick pub/2026/2026.01/cover-juli-kosolapova-raw.jpg \
  -gravity center \
  -crop "%[fx:min(w,h)]x%[fx:min(w,h)]+0+0" +repage \
  -resize 1100x1100! \
  pub/2026/2026.01/cover-juli-kosolapova.jpg
```





#make_ender[
  *COPYRIGHT*

  // Copyright
  #sym.copyright; 2026 Various Authors and Editors at FAKE JOURNAL.

  Released with CC BY 4.0 license.
  See Creative Commons website for full license text and explanation.

  Publish date 2026-08-08

  ~

  *CONTACT*

  https://fakejournal.org \
  https://github.com/fakejournal \
  info\@fakejournal.org
]


