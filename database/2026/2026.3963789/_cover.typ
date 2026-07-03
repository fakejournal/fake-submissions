/**
 * How to build:    $  ./make.sh database/2026/2026.3963789/_cover.typ
 */


#import "/template/preprint-cover-v1.H.typ": *
#make_cover(
  toml("info.toml"),
  title_override: none,
  abstract_content: [
   #toml("info.toml").article.abstract.split(" ").slice(0, 60).join(" ");...
  ],
)




