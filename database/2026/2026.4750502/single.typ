#import "@preview/cetz:0.5.2": *
#import "/template/single-v1.H.typ": *

#show: make_single.with(input_toml: toml("info.toml"))
#make_title(toml("info.toml"), title_override: none, abstract_content: toml("info.toml").article.abstract)
#let data_summary = json("assets/summary.json")






// BEGIN PROCESS DATA

// Extract dynamic statistical properties
#let sample_size = data_summary.at("sample_size", default: 300)
#let obs = data_summary.at("observed_table")
#let exp = data_summary.at("expected_table")
#let chi_square = data_summary.at("chi_square")
#let df = data_summary.at("degrees_of_freedom")
#let p_value = data_summary.at("p_value")
#let cramers_v = data_summary.at("cramersV")
#let chi_valid = data_summary.at("chi_square_valid")
#let note = data_summary.at("note")

// Number of rows and columns
#let num_rows = obs.len()
#let num_cols = obs.at(0).len()

#let group_titles = ("No Concurrency", "Concurrency")
#let col_labels = ("Left Hand", "Right Hand", "Other")

#let max_val = 0.0
#let categories = ()

#for r in range(num_rows) {
  for c in range(num_cols) {
    let o = float(obs.at(r).at(c))
    let e = float(exp.at(r).at(c))
    if o > max_val { max_val = o }
    if e > max_val { max_val = e }
    
    categories.push((
      group: group_titles.at(r),
      col_label: col_labels.at(c),
      obs: o,
      exp: e,
      row: r,
      col: c,
    ))
  }
}

// #let contributions = ()
// #for r in range(num_rows) {
//   for c in range(num_cols) {
//     let o = float(obs.at(r).at(c))
//     let e = float(exp.at(r).at(c))
//     let residual = (o - e) / calc.sqrt(e)
//     contributions.push(calc.pow((o - e), 2) / e)
//   }
// }
// #table(columns: (auto,auto,auto), ..(contributions).map(repr))



#let ext_table_301 = [
  // =====================================================
  // Chi-square diagnostic table
  // Shows observed, expected, residuals, and contributions
  // =====================================================
  
  #let diagnostics = ()
  
  #for r in range(num_rows) {
    for c in range(num_cols) {
      let o = float(obs.at(r).at(c))
      let e = float(exp.at(r).at(c))
      
      // Standardized residual
      let residual = (o - e) / calc.sqrt(e)
      
      // Pearson chi-square contribution
      let contribution = calc.pow(o - e, 2) / e
      
      diagnostics.push((
        group: group_titles.at(r),
        hand: col_labels.at(c),
        observed: o,
        expected: e,
        residual: residual,
        contribution: contribution,
      ))
    }
  }
  
  
  // Helper for rounding
  #let fmt(value, digits: 2) = {
    str(calc.round(value, digits: digits))
  }
  
  
  // =====================================================
  // Render table
  // =====================================================
  
  #let inner_table = table(
    columns: (1.25fr,) + (1fr,) * 4 + (auto,),
    
    align: (
      left,
      left,
      right,
      right,
      right,
      right,
    ),
    
    // caption: [
    
    // ],
    
    [*Group*],
    [*Hand*],
    [*Observed (O)*],
    [*Expected (E)*],
    [*Residual*],
    [*χ² contribution*],
    
    ..diagnostics
      .map(item => (
        item.group,
        item.hand,
        fmt(item.observed, digits: 0),
        fmt(item.expected, digits: 2),
        fmt(item.residual, digits: 2),
        fmt(item.contribution, digits: 2),
      ))
      .flatten(),
  )
  
  #figure(
    inner_table,
    kind: table,
    placement: auto,
    scope: "parent",
    caption: [
      Chi-square diagnostic table \
      Residuals indicate deviation from independence.
      Positive values indicate more observations than expected.
    ],
  )
]




#let figure01 = align(center)[
  #set text(font: __font_sans)
  
  // 1. Statistical Header Summary Bar
  #if false {
    block(
      width: 100%,
      fill: rgb("#f8fafc"),
      stroke: 1pt + rgb("#e2e8f0"),
      inset: (x: 12pt, y: 8pt),
      radius: 6pt,
      [
        #grid(
          columns: (1fr, 1fr, 1fr, 1fr),
          align: center,
          [#text(size: 7.5pt, fill: rgb("#64748b"))[Sample Size ($N$)] \ #text(
              size: 9.5pt,
              weight: "bold",
            )[#sample_size]],
          [#text(size: 7.5pt, fill: rgb("#64748b"))[Chi-Square ($chi^2$)] \ #text(
              size: 9.5pt,
              weight: "bold",
            )[#calc.round(chi_square, digits: 2) #text(
                size: 7.5pt,
                weight: "regular",
                fill: rgb("#64748b"),
              )[(df=#df)]]],
          [#text(size: 7.5pt, fill: rgb("#64748b"))[p-value] \ #text(size: 9.5pt, weight: "bold")[#if (
              p_value < 0.001
            ) [ < 0.001 ] else [ #calc.round(p_value, digits: 3) ]]],
          [#text(size: 7.5pt, fill: rgb("#64748b"))[Cramér's $V$] \ #text(size: 9.5pt, weight: "bold")[#calc.round(
              cramers_v,
              digits: 3,
            )]],
        )
      ],
    )
    v(8pt)
  }
  // 2. Chart Canvas
  #canvas({
    import draw: *
    
    let (w, h) = (11.5, 4.2)
    
    // Palette & Styling
    let c-obs = rgb("#1e40af") // Deep blue for observed
    let c-exp = rgb("#f59e0b") // Amber for expected baseline
    let c-grid = rgb("#e2e8f0") // Grid lines
    let c-sub = rgb("#64748b") // Secondary text
    let c-axis = rgb("#cbd5e1") // Axis lines
    let c-bg-group = rgb("#f8fafc") // Grouping shading
    
    // Dynamic Y-Scaling
    let y-step = if max_val > 100 { 50 } else if max_val > 50 { 20 } else { 5 }
    let y-max = calc.ceil((max_val * 1.18) / y-step) * y-step
    let num-ticks = 5
    let sy = h / y-max
    
    // Grid Lines & Y-Ticks
    for i in range(0, num-ticks + 1) {
      let val = (y-max / num-ticks) * i
      let y = val * sy
      line((-0.1, y), (w, y), stroke: (dash: "dotted", paint: c-grid, thickness: 0.8pt))
      content((-0.25, y), text(size: 7.5pt, fill: c-sub)[#calc.round(val)], anchor: "east")
    }
    
    // Axes
    line((0, 0), (w, 0), stroke: 1.2pt + c-axis)
    line((0, 0), (0, h + 0.1), stroke: 1.2pt + c-axis)
    
    // Layout Dimensions for 2 Groups x 3 Sub-categories
    let num-groups = 2
    let items-per-group = 3
    let group-width = w / num-groups
    let item-width = group-width / items-per-group
    let bw = item-width * 0.28 // Bar width
    
    // Render Group Backgrounds & Top Group Labels
    for g in range(num-groups) {
      let gx-start = g * group-width
      let gx-end = (g + 1) * group-width
      let gx-center = (gx-start + gx-end) / 2
      
      // Subtle alternate shading for group separation
      if calc.even(g) {
        rect((gx-start, 0), (gx-end, h), fill: c-bg-group.lighten(50%), stroke: none)
      }
      
      // Group Header Bracket & Label (Bottom)
      line((gx-start + 0.2, -0.85), (gx-end - 0.2, -0.85), stroke: 0.8pt + c-axis)
      content((gx-center, -1.1), text(size: 9pt, weight: "bold", fill: rgb("#334155"))[#group_titles.at(g)])
    }
    
    // Render Bars and Sub-labels
    for (i, cat) in categories.enumerate() {
      let group-idx = cat.row
      let col-idx = cat.col
      
      // Compute horizontal center for this pair of bars
      let cx = (group-idx * group-width) + (col-idx + 0.5) * item-width
      let (oh, eh) = (cat.obs * sy, cat.exp * sy)
      
      // Observed Bar (Left)
      rect((cx - bw, 0), (cx, oh), fill: c-obs, stroke: none, radius: (top: 2pt))
      content((cx - bw / 2, oh + 0.15), text(size: 8pt, weight: "bold", fill: c-obs)[#cat.obs])
      
      // Expected Bar (Right)
      rect((cx, 0), (cx + bw, eh), fill: c-exp, stroke: none, radius: (top: 2pt))
      content((cx + bw / 2, eh + 0.15), text(size: 7.5pt, weight: "medium", fill: c-exp)[#calc.round(
        cat.exp,
        digits: 1,
      )])
      
      // Category Sub-label (Directly below bar pair)
      content((cx, -0.35), text(size: 8pt, weight: "medium", fill: rgb("#1e293b"))[#cat.col_label])
    }
    
    // Y-Axis Label
    content((-1.1, h / 2), text(size: 8.5pt, weight: "medium", fill: rgb("#475569"))[Frequency Count], angle: 90deg)
    
    // Legend (Top Right Horizontal Alignment)
    let leg-x = w - 4.2
    let leg-y = h + 0.35
    group({
      // Item 1: Observed
      rect((leg-x, leg-y - 0.08), (leg-x + 0.3, leg-y + 0.08), fill: c-obs, stroke: none, radius: 1pt)
      content((leg-x + 0.4, leg-y), text(size: 8pt, weight: "medium")[Observed ($O$)], anchor: "west")
      
      // Item 2: Expected (shifted from +1.7 to +2.6)
      rect((leg-x + 2.6, leg-y - 0.08), (leg-x + 2.9, leg-y + 0.08), fill: c-exp, stroke: none, radius: 1pt)
      content((leg-x + 3.0, leg-y), text(size: 8pt, weight: "medium")[Expected ($E$)], anchor: "west")
    })
  })
]

// END PROCESS DATA


// Format helpers
#let fmt(val, digits: 2) = str(calc.round(float(val), digits: digits))
#let fmt-p(p) = {
  if float(p) < 0.001 [ $p < 0.001$ ] else [ $p = #fmt(p, digits: 4)$ ]
}

#let effect-label(v) = {
  if v < 0.1 [ Negligible ] else if v < 0.3 [ Weak to Moderate ] else if (
    v < 0.5
  ) [ Moderate to Strong ] else [ Very Strong ]
}

#let figure02 = align(center)[
  #set text(size: 8pt)
  #set text(font: __font_sans)
  #canvas({
    import draw: *
    
    let g-w = 8.0
    let g-h = 0.5
    let pos-x = calc.min(calc.max(cramers_v, 0.0), 1.0) * g-w
    
    // Benchmark Bands (Grayscale shading)
    rect((0, 0), (g-w * 0.1, g-h), fill: luma(96%), stroke: none)
    rect((g-w * 0.1, 0), (g-w * 0.3, g-h), fill: luma(88%), stroke: none)
    rect((g-w * 0.3, 0), (g-w * 0.5, g-h), fill: luma(80%), stroke: none)
    rect((g-w * 0.5, 0), (g-w, g-h), fill: luma(70%), stroke: none)
    
    // Internal division lines & outer border
    line((g-w * 0.1, 0), (g-w * 0.1, g-h), stroke: 0.4pt + luma(100))
    line((g-w * 0.3, 0), (g-w * 0.3, g-h), stroke: 0.4pt + luma(100))
    line((g-w * 0.5, 0), (g-w * 0.5, g-h), stroke: 0.4pt + luma(100))
    rect((0, 0), (g-w, g-h), stroke: 0.6pt + black)
    
    // Ticks & Axis Labels
    for (val, label) in ((0.0, "0.0"), (0.1, "0.1"), (0.3, "0.3"), (0.5, "0.5"), (1.0, "1.0")) {
      let x = val * g-w
      line((x, 0), (x, -0.06), stroke: 0.5pt + black)
      content((x, -0.22), text(size: 7pt)[#label])
    }
    
    // Pointer (Classic downward triangle using closed line path)
    line(
      (pos-x, g-h + 0.04),
      (pos-x - 0.08, g-h + 0.16),
      (pos-x + 0.08, g-h + 0.16),
      close: true,
      fill: black,
      stroke: none,
    )
    
    // Labels
    content((pos-x, g-h + 0.30), text(size: 1em, weight: "regular")[V = #fmt(cramers_v, digits: 3)])
    content((g-w / 2, -0.50), text(size: 1em, style: "italic")[Strength: #effect-label(cramers_v)])
  })
]


#let figure03 = align(center)[
  #set text(size: 8pt)
  #set text(font: __font_sans)
  #canvas({
    import draw: *
    
    let s-w = 8.0
    let s-h = 0.6
    
    // Compute row totals
    let row-totals = ()
    let total-sum = 0.0
    for r in obs {
      let r-sum = 0.0
      for val in r { r-sum += float(val) }
      row-totals.push(r-sum)
      total-sum += r-sum
    }
    
    // Academic grayscale palette
    let palette = (luma(95%), luma(82%), luma(68%), luma(55%))
    
    // Render Stacked Bar for Observed Rows
    let curr-x = 0.0
    for (r-idx, r-tot) in row-totals.enumerate() {
      let pct = if total-sum > 0 { r-tot / total-sum } else { 0.0 }
      let seg-w = pct * s-w
      let fill-color = palette.at(calc.rem(r-idx, palette.len()))
      
      rect((curr-x, 0), (curr-x + seg-w, s-h), fill: fill-color, stroke: 0.5pt + black)
      
      if seg-w > 0.6 {
        content(
          (curr-x + seg-w / 2, s-h / 2),
          text(size: 1em, fill: black)[Row #(r-idx + 1) (#fmt(pct * 100, digits: 1)%)],
        )
      }
      
      curr-x += seg-w
    }
    
    content((s-w / 2, -0.35), text(size: 7.5pt, style: "italic")[Total $N = #calc.round(total-sum)$])
  })
]



#editor_comment_block[
  All data are fabricated using pseudorandom number generator (PRNG). No personally identifiable or anonymous reproductive health data is collected during the research.
]




#[
  #show table: set text(size: 9pt)
  #show: enable_heading_numbering
  #[
    #show: mode_2col
    
    
    
    = Introduction
    To evaluate this hypothesis, a cross-sectional questionnaire study will be conducted among consistently right-handed adult males. Participants will report current masturbation hand preference, early masturbation circumstances, frequency of concurrent computer use during masturbation, age of habit formation, and current habit persistence. Correlation and regression analyses will be used to examine whether left-hand masturbation preference is associated with greater exposure to computer-mouse occupation of the dominant hand during early masturbation experiences. It is hypothesized that right-handed men who primarily masturbate with their left hand will report significantly higher levels of early dual-task computer use than right-handed men who masturbate with their right hand. The findings will provide an empirical test of a dynamic resource-allocation model of behavioral lateralization and contribute to understanding how environmental constraints influence long-term motor habits.
    
    
    
    
    = Methodology
    
    This study employs a cross-sectional observational questionnaire design. Retrospective self-reported data were collected from right-handed male participants on the age at which hand preference was established, the age at which computer mouse use began, the hand used for the mouse at start, the hand used for masturbation at start, and current masturbation hand preference.
    
    The primary analysis tests a specific binary exposure termed *concurrency*. A respondent is classified as having concurrency only if three conditions are met simultaneously: (1) computer mouse use began at or before the self-reported age of hand-preference establishment; (2) the initial mouse hand was the right hand; and (3) the initial masturbation hand was the left hand. All other respondents are classified as non-concurrent. The outcome variable is current masturbation hand preference, categorized as left hand, right hand, or other/unknown.
    
    Statistical analysis consists of a chi-square test of independence applied to a 2×3 contingency table (concurrency status by current hand preference). Expected cell frequencies are evaluated against the chi-square assumption (minimum expected count of 5). Where this assumption is satisfied, the chi-square statistic, degrees of freedom, and p-value are reported; otherwise, the test result is flagged as invalid. Cramer's V is computed as a measure of effect size. This is a bivariate, unadjusted analysis; no covariates are included in the model.
    
    Given the retrospective, self-reported, and cross-sectional nature of the data, this study is designed to identify patterns of association rather than establish temporal causality. Potential sources of bias, including recall bias, selection bias, and unmeasured confounding, are acknowledged when interpreting the findings. The results should be viewed as hypothesis-generating evidence regarding possible relationships between specific early repetitive motor experiences and later habitual motor preferences.
    
    = Questionnaire
    
    // #let qtable01 = table(
    //   columns: (auto, 1fr),
    //   align: (left, left),
    //   table.header([Variable], [Meaning]),
    //   table.hline(),
    //   // [`id`], [Participant unique identifier],
    //   [age], [Age of participant (years)],
    //   [right handed score], [Handedness scale score (higher = stronger right-handedness)],
    //   [mouse start age], [Age when regular mouse use began],
    //   [masturbation start age], [Age when masturbation habit began],
    //   [preferred hand established age], [Age when preferred hand usage pattern was established],
    //   [mouse hand at start], [Hand used for mouse when regular mouse use began],
    //   [penis hand at start], [Hand used for masturbation when habit began],
    //   [current masturbation hand], [Current hand used for masturbation (1 = left hand, 0 = not left hand)],
    //   [right hand injury], [1 = significant right-hand injury, 0 = no injury],
    //   [ambidextrous training], [1 = deliberate mixed-hand training, 0 = no],
    // )
    
    + *Age*\ Age of participant (years)
    + *Right handed score*\ Handedness scale score (higher = stronger right-handedness)
    + *Mouse start age*\ Age when regular mouse use began
    + *Masturbation start age*\ Age when masturbation habit began
    + *Preferred hand established age*\ Age when preferred hand usage pattern was established
    + *Mouse hand at start*\ Hand used for mouse when regular mouse use began
    + *Masturbation hand at start*\ Hand used for masturbation when habit began
    + *Current masturbation hand*\ Current hand used for masturbation (1 = left hand, 0 = not left hand)
    + *Right hand injury*\ 1 = significant right-hand injury, 0 = no injury
    + *Ambidextrous training*\ 1 = deliberate mixed-hand training, 0 = no
    
    
    
    
    
    
    // ] // End of mode_2col
    
    // #let figure01 = align(center)[
    //   #set text(font: __font_sans)
    //   #canvas({
    //     import draw: *
    
    //     let (w, h) = (11.0, 4.5) // Reduced width slightly to leave room for outer right legend
    
    //     // Colors & Styling
    //     let c-obs = rgb("#2563eb")
    //     let c-exp = rgb("#f97316")
    //     let c-grid = rgb("#f1f5f9")
    //     let c-sub = rgb("#64748b")
    //     let c-axis = rgb("#94a3b8")
    
    //     // Dynamic Y-Scaling
    //     let y-step = if max_val > 100 { 50 } else if max_val > 50 { 20 } else { 5 }
    //     let y-max = calc.ceil((max_val * 1.15) / y-step) * y-step
    //     let num-ticks = 5
    //     let sy = h / y-max
    
    //     // 1. Grid Lines & Y-Axis Ticks
    //     for i in range(0, num-ticks + 1) {
    //       let val = (y-max / num-ticks) * i
    //       let y = val * sy
    //       line((-0.1, y), (w, y), stroke: (dash: "dashed", paint: c-grid, thickness: 0.8pt))
    //       content((-0.2, y), text(size: 7.5pt, fill: c-sub)[#calc.round(val)], anchor: "east")
    //     }
    
    //     // 2. Axes
    //     line((0, 0), (w, 0), stroke: 1pt + c-axis)
    //     line((0, 0), (0, h + 0.2), stroke: 1pt + c-axis)
    
    //     // 3. Clustered Bars
    //     let group-w = w / categories.len()
    //     let bw = group-w * 0.32
    
    //     for (i, cat) in categories.enumerate() {
    //       let cx = (i + 0.5) * group-w
    //       let (oh, eh) = (cat.obs * sy, cat.exp * sy)
    
    //       // Observed Bar
    //       rect((cx - bw, 0), (cx, oh), fill: c-obs, stroke: none, radius: (top: 2pt))
    //       content((cx - bw / 2, oh + 0.15), text(size: 8.5pt, weight: "bold", fill: c-obs)[#cat.obs])
    
    //       // Expected Bar
    //       rect((cx, 0), (cx + bw, eh), fill: c-exp, stroke: none, radius: (top: 2pt))
    //       content((cx + bw / 2, eh + 0.15), text(size: 8.5pt, weight: "medium", fill: c-exp)[#fmt(cat.exp, digits: 1)])
    
    //       // Category & Sub-labels
    //       content((cx, -0.35), text(size: 8pt, weight: "medium")[#cat.label])
    //       content((cx, -0.65), text(size: 6.5pt, fill: c-sub)[Row #(cat.row + 1), Col #(cat.col + 1)])
    //     }
    
    //     // Y-Axis Title
    //     content((-1.1, h / 2), text(size: 8pt, weight: "medium", fill: rgb("#475569"))[Frequency Count], angle: 90deg)
    
    //     // 4. Outer Right Legend (Completely outside plot boundary x > w)
    //     let leg-x = w + 0.4
    //     let leg-y = h - 0.2
    //     group({
    //       rect((leg-x, leg-y - 0.1), (leg-x + 0.35, leg-y + 0.1), fill: c-obs, stroke: none, radius: 1pt)
    //       content((leg-x + 0.5, leg-y), text(size: 8pt, weight: "medium")[Observed ($O$)], anchor: "west")
    
    //       rect((leg-x, leg-y - 0.5), (leg-x + 0.35, leg-y - 0.3), fill: c-exp, stroke: none, radius: 1pt)
    //       content((leg-x + 0.5, leg-y - 0.4), text(size: 8pt, weight: "medium")[Expected ($E$)], anchor: "west")
    //     })
    //   })
    // ] //
    
    
    // #mode_2col[
    
    
    = Statistical Results
    
    #ext_table_301
    
    #figure(
      caption: [Observed counts with expected counts in parentheses],
      kind: table,
      placement: auto,
      scope: "parent",
      align(center, table(
        columns: (auto, 1fr, auto, 1fr, auto),
        "Group",
        ..col_labels,
        "Total",
        ..for r in range(num_rows) {
          (
            group_titles.at(r),
            ..for c in range(num_cols) {
              (str(obs.at(r).at(c)) + " (" + str(exp.at(r).at(c)) + ")",)
            },
            str(obs.at(r).sum()),
          )
        },
      )),
    )
    
    #figure(
      figure02,
      // scope: "parent",
      // placement: auto,
      caption: [Cramer's V Strength Indicator\ Effect size benchmark scale ($0.0 "to" 1.0$)],
    )
    
    #figure(
      figure03,
      // scope: "parent",
      // placement: auto,
      caption: [Stacked Total Distribution\ Relative row proportion of observed counts],
    )
    
    
    
    
    // #figure(
    //   table(
    //     columns: (auto, 1fr),
    //     [Sample size], fmt(sample_size),
    //     [$chi^2$], fmt(chi_square),
    //     [Degrees of freedom], [#df],
    //     [p-value], [#p_value],
    //     [Cramer's V], fmt(cramers_v, digits: 3),
    //   ),
    //   kind: table,
    //   caption: [Summary of collected data],
    // )
    
    To rigorously test the dynamic resource-allocation hypothesis, we analyzed categorical hand-preference distributions under asymmetric early-life dual-task constraints among right-handed males ($N = #sample_size$). Parametric assumptions for contingency analysis were verified prior to testing; all expected cell counts exceeded the standard minimum threshold of 5 ($E_min = #fmt(exp.at(1).at(2), digits: 2)$, #note).
    
    
    A Pearson's $chi^2$ test of independence revealed a statistically significant omnibus association between early-life dominant-hand tool occupation (mouse operation) and subsequent non-dominant manual motor establishment ($chi^2(#df, N = #sample_size) = #fmt(chi_square, digits: 2)$, #fmt-p(p_value)). The strength of inter-variable dependence yielded a Cramér's $V$ of $#fmt(cramers_v, digits: 3)$, characterizing a #effect-label(cramers_v) effect size.
    
    Examination of cell-wise deviations demonstrates substantial discrepancies between observed ($O$) and expected ($E$) frequencies:
    - Under the *No Concurrency / Right Hand* condition ($O = #obs.at(0).at(1)$, $E = #fmt(exp.at(0).at(1), digits: 1)$), unconstrained dominant-hand preference showed a marked positive residual.
    - Conversely, under the *Concurrency / Right Hand* condition ($O = #obs.at(1).at(1)$, $E = #fmt(exp.at(1).at(1), digits: 1)$), dominant-hand recruitment exhibited significant attenuation relative to the independence baseline.
    
    These deviations indicate that high early-life exposure to dominant-hand tool operation during habit-formation windows significantly elevates the probability of recruiting the non-dominant contralateral manual motor system.
    
    
    
    #figure(
      figure01,
      scope: "parent",
      placement: auto,
      caption: [Observed vs. Expected Frequency Distribution\ Direct comparison across contingency table cells ($O$ vs $E$)],
    )
    
    
    
    #[
      #let sample_size = data_summary.at("sample_size", default: 300)
      #let obs = data_summary.at("observed_table")
      #let exp = data_summary.at("expected_table")
      #let chi_square = data_summary.at("chi_square")
      #let df = data_summary.at("degrees_of_freedom")
      #let p_value = data_summary.at("p_value")
      #let cramers_v = data_summary.at("cramersV")
      
      
      #let sample_size = data_summary.at("sample_size", default: 300)
      #let obs = data_summary.at("observed_table")
      #let exp = data_summary.at("expected_table")
      #let chi_square = data_summary.at("chi_square")
      #let df = data_summary.at("degrees_of_freedom")
      #let p_value = data_summary.at("p_value")
      #let cramers_v = data_summary.at("cramersV")
      
      #let no_concurrency_n = obs.at(0).sum()
      #let concurrency_n = obs.at(1).sum()
      
      #let no_concurrency_left = obs.at(0).at(0)
      #let concurrency_left = obs.at(1).at(0)
      
      #let total_left = no_concurrency_left + concurrency_left
      
      #let no_concurrency_left_pct = 100 * no_concurrency_left / no_concurrency_n
      
      #let concurrency_left_pct = 100 * concurrency_left / concurrency_n
      
      #let overall_left_pct = 100 * total_left / sample_size
      
      #let relative_risk = (concurrency_left / concurrency_n) / (no_concurrency_left / no_concurrency_n)
      
      #let not_left_no_concurrency = no_concurrency_n - no_concurrency_left
      
      #let not_left_concurrency = concurrency_n - concurrency_left
      
      #let odds_ratio = (concurrency_left / not_left_concurrency) / (no_concurrency_left / not_left_no_concurrency)
      
      #let std_residual(obs, exp) = (obs - exp) / calc.sqrt(exp)
      
      #let concurrency_left_residual = std_residual(
        obs.at(1).at(0),
        exp.at(1).at(0),
      )
      
      #let no_concurrency_left_residual = std_residual(
        obs.at(0).at(0),
        exp.at(0).at(0),
      )
      
      
      = Additional Distributional Analysis
      
      The overall prevalence of left-hand preference was
      #calc.round(overall_left_pct, digits: 1)%
      (#total_left of #sample_size participants). Distributional differences were
      observed between the two exposure groups. Participants classified as having
      early-life concurrency showed a left-hand preference rate of
      #calc.round(concurrency_left_pct, digits: 1)%,
      compared with #calc.round(no_concurrency_left_pct, digits: 1)% among
      participants without concurrency.
      
      #let tt92383 = table(
        columns: 4,
        inset: 6pt,
        align: center,
        [Group], [Left Hand], [Non-Left Hand], [Left Hand Percentage],
        
        [No Concurrency],
        [#no_concurrency_left],
        [#not_left_no_concurrency],
        [#calc.round(no_concurrency_left_pct, digits: 1)%],
        
        [Concurrency], [#concurrency_left], [#not_left_concurrency], [#calc.round(concurrency_left_pct, digits: 1)%],
      )
      
      #figure(
        tt92383,
        caption: [
          Binary comparison of left-hand preference prevalence by concurrency group.
        ],
      )
      
      
      = Effect Magnitude
      
      Beyond statistical significance, the association magnitude was quantified using
      Cramér's V. The observed effect size was
      #calc.round(cramers_v, digits: 3),
      indicating a non-zero association between concurrency classification and
      current hand preference.
      
      A binary interpretation of the primary outcome further showed that the
      relative prevalence of left-hand preference was
      #calc.round(relative_risk, digits: 2) times higher in the concurrency group.
      The corresponding odds ratio was
      #calc.round(odds_ratio, digits: 2).
      
      
      #table(
        columns: (auto, 1fr),
        inset: 6pt,
        align: left,
        [Measure], [Value],
        
        [Chi-square statistic], [#calc.round(chi_square, digits: 2)],
        
        [Degrees of freedom], [#df],
        
        [P-value], [#p_value],
        
        [Cramér's V], [#calc.round(cramers_v, digits: 3)],
        
        [Relative risk], [#calc.round(relative_risk, digits: 2)],
        
        [Odds ratio], [#calc.round(odds_ratio, digits: 2)],
      )
      
      
      = Cell-Level Diagnostic Analysis
      
      Inspection of deviations from independence indicated that the strongest
      contribution to the association occurred in the concurrency and left-hand
      category. This cell showed a standardized residual of
      #calc.round(concurrency_left_residual, digits: 2),
      indicating more left-hand preference cases than expected under independence.
      
      Conversely, the no-concurrency and left-hand category showed a standardized
      residual of
      #calc.round(no_concurrency_left_residual, digits: 2),
      indicating fewer cases than expected under the null model.
      
      #table(
        columns: 4,
        inset: 6pt,
        align: center,
        
        [Condition], [Observed], [Expected], [Standardized Residual],
        
        [No Concurrency + Left Hand],
        [#no_concurrency_left],
        [#calc.round(exp.at(0).at(0), digits: 2)],
        [#calc.round(no_concurrency_left_residual, digits: 2)],
        
        [Concurrency + Left Hand],
        [#concurrency_left],
        [#calc.round(exp.at(1).at(0), digits: 2)],
        [#calc.round(concurrency_left_residual, digits: 2)],
      )
    ]
    
    = Discussion
    
    == Dynamic Resource Allocation and Neurodevelopmental Plasticity
    Our empirical findings lend quantitative support to a dynamic resource-allocation model of human motor habituation. Human manual motor control is heavily lateralized, with dominant-hand preferences governed by left-hemispheric corticomotor dominance in right-handed individuals. However, during critical developmental windows of habit acquisition, continuous high-precision motor occupation of the dominant hand—such as operating a computer mouse—creates a local biomechanical and operational bottleneck.
    
    To optimize dual-task performance, the central nervous system (CNS) appears to execute an opportunistic behavioral re-allocation: fine motor control of secondary tasks is offloaded to the non-dominant hand. This motor displacement relies on cross-modal neural plasticity and interhemispheric transfer via the corpus callosum. Repeated co-activation of contralateral motor pathways during adolescent developmental stages likely stabilizes these auxiliary motor routines, consolidating left-hand preference into a persistent motor habit that endures even when the primary environmental constraint is removed.
    
    == Environmental Constraints as Drivers of Behavioral Asymmetry
    Historically, handedness research has focused on genetic and intrinsic neurological determinants. Our results suggest that external tool ergonomics and environmental constraints act as potent extrinsic directors of lateralized behavior. In modern digital environments, asymmetric device interfaces force asymmetrical biomechanical allocations. The high cognitive and fine-motor demand of dominant-hand cursor navigation imposes an opportunity cost on that hand, driving compensatory recruitment of the ipsilateral motor cortex for concurrent tasks.
    
    == Methodological Considerations and Limitations
    While these results demonstrate robust statistical association ($p #if float(p_value) < 0.001 [< 0.001] else [= #fmt(p_value, digits: 4)]$), several methodological constraints must be contextualized:
    
    + *Retrospective Self-Report:* Historical timing of habit onset and mouse usage relies on participant recall, introducing potential memory-dependent noise.
    + *Confounding Ergonomic Variables:* Differences in hardware interface form factors (e.g., trackpads vs. ergonomic mice), desk geometry, and screen real estate were unmeasured covariates that could influence motor load.
    + *Cross-Sectional Scope:* Statistical association does not inherently establish temporal causality; longitudinal designs tracking adolescent habit formation in real time are required to definitively map corticomotor adaptation over time.
    
    == Future Directions
    Future investigations should integrate objective biomechanical tracking (such as accelerometry or digital telemetry) alongside functional neuroimaging (fNIRS or fMRI) to measure real-time cortical activation shifts during dual-task motor learning. Investigating how emerging interfaces (e.g., touchscreen, eye-tracking, spatial computing) alter manual lateralization will provide further tests of environmental adaptation models.
    
    
    = Conclusion
    This study demonstrates a statistically significant association ($chi^2 = #fmt(chi_square, digits: 2)$, $V = #fmt(cramers_v, digits: 3)$) between early-life dominant-hand mouse occupation and left-hand masturbation preference among right-handed males. These findings support the hypothesis that extrinsic tool-use constraints alter behavioral motor patterns through opportunistic lateralization. As human interaction with asymmetric digital interfaces continues to evolve, understanding environmental influences on motor plasticity remains crucial for comprehending human motor habituation.
  ]
  
  
  
  // #citations_area_style[
  //   #bibliography(
  //     "ref.bib",
  //   )
  // ]
]
