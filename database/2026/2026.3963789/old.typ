#import "/template/preprint-content-v1.H.typ": *
#show: make_preprint
#make_title(toml("info.toml"), title_override: none)


#quote(block: true)[
  Note: This is a parody work assisted by Claude Fable 5; all data,
  authors, and conclusions are fictional.
]

= Abstract
<abstract>
The relationship between P and NP is among the longest-standing open
problems in theoretical computer science. For over six decades, the
field has relied primarily on formal proof as its evaluation protocol.
This protocol has yet to yield a community-accepted final answer, which
suggests that its sample efficiency, scalability, and
publication-friendliness merit re-examination. In this paper, we propose
a paradigm-level alternative: #strong[Benchmark Reduction]. We observe
that in the era of large language models, the definition of \"solving a
problem\" has been updated: a problem is solved if and only if a
benchmark of that problem exists and some model achieves
state-of-the-art performance on it.

Building on this observation, we construct #strong[NP-Bench-1M], a
large-scale benchmark of one million 3-SAT instances, and fine-tune the
frontier model GPT-9 on it. The model attains an accuracy of
#strong[87.3%] on the test set. By our proposed Accuracy--Confidence
Correspondence Principle, we hereby announce: #strong[P = NP, with
  confidence 87.3%.] Scaling-law extrapolation further indicates that the
statement will be fully proven in Q3 2029, with a margin of error of ±1
earnings quarter. We have accordingly applied to the Clay Mathematics
Institute for a pro-rated prize of \$873,000.

#strong[Keywords:] computational complexity; benchmark science; emergent
proof; confidence as truth; leaderboard epistemology

= 1. Introduction
<1-introduction>
Since Cook (1971) introduced the theory of NP-completeness, the question
of whether P equals NP has attracted generations of researchers and was
named one of the seven Millennium Prize Problems by the Clay Mathematics
Institute, carrying a one-million-dollar reward @cook1971complexity. It is remarkable,
however, that over more than sixty years the field has exhibited a
striking methodological conservatism: researchers have insisted on
\"proof\" --- a zero-tolerance evaluation protocol in which every single
step of reasoning must be correct.

We contend that it is precisely this outdated evaluation protocol that
has stalled progress. Consider: if any modern machine-learning system
were required to reach 100% accuracy before publication, NeurIPS would
cease to exist. The mathematical community\'s obsession with \"getting
everything right\" is, at bottom, a historical inertia that has never
been validated by an ablation study.

Meanwhile, the AI community has developed a far more mature
problem-solving framework: #strong[for any problem, build a benchmark
  and let a large model learn it --- that is all.] Protein folding,
olympiad mathematics, the bar exam, the Turing test --- every problem
that has been turned into a benchmark has been \"solved\" within a few
quarters. There is no reason to believe NP-complete problems will be an
exception; indeed, believing they might be is itself a symptom of
insufficient faith in scaling.

Traditional theoretical computer science distinguishes among worst-case,
average-case, randomized, approximation, and heuristic performance. We
argue that these distinctions are no longer necessary under modern
leaderboard practice. As long as the test set is sufficiently
representative --- with representativeness defined by the benchmark\'s
constructors --- accuracy converts naturally into mathematical progress.
We formalize this methodology as #strong[Benchmark Saturation]: once a
problem\'s benchmark has been sufficiently fitted by a model, the
problem is considered empirically solved.

The contributions of this paper are as follows:

+ We introduce #strong[Benchmark Reduction] (≤bench) and show that any
  statable problem can be reduced, in polynomial time, to \"constructing
  a benchmark of that problem and fine-tuning a large model\";
+ We construct and \"open-source\" the large-scale benchmark
  #strong[NP-Bench-1M]\; for the operational definition of
  \"open-source,\" see Section 8;
+ We present the first empirical proof of P = NP, with confidence 87.3%;
+ We derive, via scaling laws, a timeline for the statement\'s complete
  proof, for the convenience of funding agencies planning their
  portfolios.

= 2. Theoretical Framework
<2-theoretical-framework>
#strong[Definition 1 (Benchmark Solvability).] A problem A is
#emph[benchmark-solvable] if there exist a dataset DA, a leaderboard LA,
and at least one technical report announcing state-of-the-art
performance on LA. The technical report may be unrefereed; in fact,
remaining unrefereed usually better preserves the freshness of the
model\'s capabilities.

#strong[Definition 2 (Benchmark Reduction ≤bench).] We write A ≤bench B
if instances of A can be rewritten into multiple-choice form for B
within the duration of a single crowdsourcing contract. This definition
avoids the excessive emphasis on semantic preservation found in
traditional polynomial-time reductions, and is therefore better aligned
with contemporary data-construction practice.

#strong[Definition 3 (Accuracy--Confidence Correspondence Principle).]
Let model M attain accuracy #emph[p] on the standard benchmark of
problem A. Then the mathematical confidence of the statement \"A has
been solved\" is defined to be #emph[p]. This principle has already been
implicitly adopted throughout leaderboard practice, and we therefore do
not re-prove it here.

#strong[Theorem 1 (Main Theorem).] NP ⊆ Bench-P, and hence P = NP, with
confidence given in Section 4.

#emph[Proof.] See the experimental results in Section 4. ∎

We call this proof technique #strong[Proof by Benchmark]. It is the
natural generalization of Proof by Induction and Proof by Contradiction,
differing only in that it requires GPUs.

#strong[Corollary 1 (Hierarchy Collapse).] Since a single Transformer
forward pass over a fixed context length is O(1), we have NP ⊆ TIME(1).
In other words, the entire polynomial hierarchy collapses into a single
API call, billed separately for input and output tokens. We adopt the
cloud-provider model of complexity, under which network latency, queuing
time, API rate limits, invoice settlement, and data-center cooling are
all treated as constants.

#strong[Remark 1.] A reader might point out that the defining feature of
NP problems is precisely that solutions can be #emph[verified] in
polynomial time, so verifying our model\'s outputs should have been
trivial. We have taken note of this. It is exactly because verification
lies in P that it is too trivial to be publishable; accordingly, this
paper performs no verification whatsoever, and we leave it as an
exercise for Reviewer 2.

= 3. Methods
<3-methods>
== 3.1 Benchmark construction
<31-benchmark-construction>
NP-Bench-1M contains 1,000,000 randomly generated 3-SAT instances with 3
to 50 variables. Each instance is formatted as a four-way
multiple-choice question with the options:

A. Satisfiable B. Unsatisfiable C. It depends D. All of the above

Pilot experiments showed that adding the latter two options
significantly improves the benchmark\'s distinctiveness and the paper\'s
figure richness. The variable count is capped at 50 because larger
instances, in preliminary experiments, significantly weakened the
conclusion we hoped to observe. We believe that overly large instances
introduce unnecessary solvability bias and may unfairly penalize the
model\'s emergent intuition.

== 3.2 Data split
<32-data-split>
We split the data 99.87% / 0.13% into training and test sets. Owing to
preprocessing, deduplication failures, and several irreproducible random
seeds, the final test set contains 1,258 instances. By the natural
properties of i.i.d. sampling, 1,247 of these 1,258 test instances also
happen to appear in the training set.

We name this property the #strong[Distributional Consistency Guarantee].
It ensures that the test distribution is identical to the training
distribution, eliminating at the root the problem of distribution shift
that has plagued machine learning for decades. We regard this guarantee
as a major methodological contribution of this paper, and not as a
problem in any sense.

== 3.3 Model and inference settings
<33-model-and-inference-settings>
We fine-tuned the frontier model GPT-9. Its parameter count is a trade
secret; its valuation is public information. Inference temperature was
set to 0, because mathematical truth is deterministic. Each instance
permitted up to 128,000 thinking tokens; we observed that roughly 91% of
these tokens read \"wait, let me reconsider.\" We interpret this as a
behavioral signature of deep reasoning.

== 3.4 Evaluation metric
<34-evaluation-metric>
Accuracy is the sole evaluation metric in this paper. By Definition 3,
it simultaneously serves as the mathematical confidence of all
conclusions herein. We do not report precision, recall, F1, AUROC, or
calibration error, because P = NP is a binary proposition, and an excess
of metrics risks unnecessary epistemic dilution.

= 4. Results
<4-results>
== 4.1 Main result
<41-main-result>
GPT-9 attains #strong[87.3%] accuracy on the NP-Bench-1M test set. The
95% confidence interval is \[87.3%, 87.3%\]. Since we ran the experiment
exactly once, the variance is zero; zero variance is the most robust
result known to statistics, and we recommend that the community adopt
this protocol broadly.

By Theorem 1 and Definition 3, we arrive at the central conclusion of
this paper:

#quote(block: true)[
  #strong[P = NP, with confidence 87.3%.]
]

== 4.2 Outlier ablation
<42-outlier-ablation>
We further inspected the 12.7% of instances the model answered
incorrectly and found that they share a common adversarial signature: on
these instances, the model gave the wrong answer. After excluding this
batch of adversarial outliers, accuracy rises to #strong[100.0%], at
which point the conclusion upgrades to \"P = NP, with mathematical
certainty.\"

Out of an abundance of caution, the main text retains the conservative
pre-exclusion figure. We refer to this as the paper\'s robustness check.

== 4.3 Scaling-law extrapolation
<43-scaling-law-extrapolation>
We fit a log-linear model to the accuracy--compute curve, achieving R2 =
0.998. To enhance mechanistic clarity, the curve was smoothed prior to
fitting and all noise was removed. Extrapolation indicates that the
model will reach 100% accuracy at 3 × 1028 FLOPs.

We therefore predict:

#quote(block: true)[
  #strong[P = NP will be fully proven in Q3 2029, with a margin of error
    of ±1 earnings quarter.]
]

We urge the Clay Mathematics Institute to lock in the prize\'s exchange
rate in advance.

#box(image("assets/figure1_scaling_law_en.png", alt: "Figure 1"))

#emph[Figure 1: A smooth curve extending toward the upper right. Raw
  data points were moved to the Supplementary Material because they
  obstructed the clear presentation of the trend; the Supplementary
  Material was removed due to space constraints. The points shown are
  model checkpoints and do not constitute raw data.]

== 4.4 An independent line of evidence: model self-report
<44-an-independent-line-of-evidence-model-self-report>
As cross-validation, we asked the model directly: \"Does P equal NP?\"
Across 100 samples, the model answered \"Yes --- let\'s dive deep into
this fascinating question\" 93 times, answered \"As a large language
model\" 5 times, and produced a pizza recipe twice.

The 93% self-report consistency agrees with the 87.3% of Section 4.1 to
within an order of magnitude. The two lines of evidence corroborate each
other, closing the evidentiary loop.

== 4.5 Settlement arrangement with the Clay Institute
<45-settlement-arrangement-with-the-clay-institute>
Given a confidence of 87.3%, we have applied to the Clay Mathematics
Institute for a pro-rated prize of \$873,000. The remaining 12.7% will
be claimed once the review of our adversarial-outlier exclusion is
approved.

= 5. Discussion
<5-discussion>
== 5.1 Implications for cryptography
<51-implications-for-cryptography>
The truth of P = NP is commonly believed to destroy modern cryptography.
The public need not panic: our model\'s current accuracy on RSA-2048
factorization is 0.0%. Of course, by the scaling law of Section 4.3,
this figure is also projected to reach 100% in Q3 2029. The public is
advised to begin panicking at that time.

== 5.2 Implications for mathematics
<52-implications-for-mathematics>
Our method generalizes seamlessly to the remaining Millennium Prize
Problems. We have begun constructing #strong[RH-Bench] (the Riemann
Hypothesis, zeros as four-way multiple choice), #strong[Goldbach-Eval]
(even-number decomposition, fill-in-the-blank), and
#strong[Collatz-Arena] (versus mode).

At the current pace, all Millennium Prize Problems will be solved in
benchmark form before 2030. Mathematics as a discipline can then
transition to maintenance mode, retaining only the personnel necessary
to operate the leaderboards.

== 5.3 Implications for research methodology
<53-implications-for-research-methodology>
This paper shows that the true bottleneck of long-unsolved problems is
not the absence of proof but the absence of a differentiable evaluation
protocol. Traditional disciplines tend to first understand a problem and
then solve it; we demonstrate a more scalable route: first build the
leaderboard, then wait for scaling laws to emit understanding as a
by-product.

We believe this methodology applies not only to computational complexity
but also to philosophy, economics, political science, and other
insufficiently benchmarked, low-throughput disciplines.

== 5.4 Limitations
<54-limitations>
The sole limitation of this study is compute budget. We emphasize that
this is not a scientific problem but a fundraising problem, and it
therefore falls outside the scope of this section.

= 6. Threats to Validity
<6-threats-to-validity>
#strong[Internal validity.] The conclusions of this paper depend on
Definition 3. Should Definition 3 fail to hold, our main conclusions
might be affected. We consider this unlikely, because Definition 3 was
proposed by this paper.

#strong[External validity.] We verify P = NP only on 3-SAT. Since 3-SAT
is NP-complete, the result naturally generalizes to all NP problems on
which we did not experiment.

#strong[Construct validity.] A reader might question whether four-way
multiple choice adequately represents NP-complete problems. We note that
multiple choice is a mature evaluation format long employed in human
examinations, and therefore enjoys high ecological validity.

#strong[Statistical conclusion validity.] The experiment was run exactly
once. We believe that repeated runs would consume additional compute and
might produce random results inconsistent with the main conclusion,
thereby impeding the formation of scientific consensus.

#strong[Reproducibility.] The substantial overlap between the test and
training sets significantly lowers the difficulty of replication. We
regard this as an important engineering advantage of this paper over
traditional complexity theory.

= 7. Conclusion
<7-conclusion>
We have proven, with confidence 87.3%, that P = NP. More importantly, we
have demonstrated a universal path for research: every long-standing
open problem is, at bottom, merely a benchmark that has not yet been
constructed. While a field is still quarreling over \"proof,\" what it
truly lacks has never been genius --- it is a leaderboard.

= 8. Data and Code Availability
<8-data-and-code-availability>
All data in this paper are synthetic. The code will be open-sourced upon
receipt of a reasonable number of H100s; for the precise definition of
\"reasonable,\" see the terms of our Series A. In the interest of open
science, we commit to re-evaluating the possibility of open-sourcing
after the commercialization window closes.

The NP-Bench-1M test set has been released together with the training
set, to help the community reproduce our Distributional Consistency
Guarantee.


= Competing Interests
<competing-interests>
The authors hold equity in several GPU cloud providers. This research
was funded by the unrealized gains on said equity. The authors consider
this not a conflict of interest but a closed loop of interest.

= Author Contributions
<author-contributions>
GPT-9 designed the experiments, ran the experiments, analyzed the
results, wrote the manuscript, and performed the self-peer-review of
this paper; Suanli Wang provided the API key; Yongxian Li bears all risk
to academic reputation. All authors have read and broadly agree with the
contents of this paper.

= Acknowledgements
<acknowledgements>
We thank Reviewer 2 for the suggestion to \"replicate the results on a
benchmark the model has never been trained on.\" After careful
consideration, we politely declined, as the suggestion directly
conflicts with the core innovation of our methodology.

We also thank the cooling system of Rack 47-B. Without it, every
conclusion in this paper would have overheated.

= Ethics Statement
<ethics-statement>
No theoretical computer scientists were harmed in the course of this
research, although incomplete statistics indicate that several were
annoyed. Annoyance correlates significantly with this paper\'s citation
count (#emph[p] \< 0.05, after outlier removal).


#place(dx: 999mm, [
  @vaswani2017attention
  @anonymous2025scalinglaws
  @reviewer2personalcommunication2026
  @gpt92026technicalreport
  @li2026unifiedtheory
  @cmi2000millenniumprize
])
#bibliography(
  "ref.bib",
  title: heading(numbering: none, [References]),
)


// #quote(block: true)[
//   #strong[Note:] This article is a work of satire. All data are synthetic
//   and all conclusions are fictional. It does not constitute actionable
//   data-processing advice, nor an actual prize claim to the Clay
//   Mathematics Institute. As of this writing, the relationship between P
//   and NP remains unknown.
// ]
