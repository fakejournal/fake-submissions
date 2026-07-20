#import "/template/preprint-content-v1.H.typ": *
#show: make_preprint
#make_title(toml("info.toml"), title_override: none)


#quote(block: true)[
  Note: This is a parody work assisted by Claude Fable 5; all data,
  authors, and conclusions are fictional.
]

#strong[Version:] Camera-Ready (v2, revised following peer review; revision notes in the Appendix)







= Abstract
<abstract>
The relationship between P and NP is among the longest-standing open problems in theoretical computer science. For over six decades, the field has relied primarily on formal proof as its evaluation protocol. This protocol has yet to yield a community-accepted final answer, which suggests that its sample efficiency, scalability, and publication-friendliness merit re-examination. In this paper, we propose a paradigm-level alternative: #strong[Benchmark Reduction]. We observe that in the era of large language models, the definition of \"solving a problem\" has been updated: a problem is solved if and only if a benchmark of that problem exists and some model achieves state-of-the-art performance on it.

Building on this observation, we construct #strong[NP-Bench-1M], a large-scale benchmark of one million 3-SAT instances, and fine-tune the frontier model GPT-9 on it. The model attains an accuracy of #strong[87.3%] on the test set. By our proposed Accuracy--Confidence Correspondence Principle, we hereby announce: #strong[P = NP, with confidence 87.3%.] Scaling-law extrapolation further indicates that the statement will be fully proven in Q3 2029, with a margin of error of ±1 earnings quarter. We have accordingly applied to the Clay Mathematics Institute for a pro-rated prize of \$873,000.

#strong[Keywords:] computational complexity; benchmark science; emergent proof; confidence as truth; leaderboard epistemology

= 1. Introduction
<1-introduction>
Since Cook (1971) introduced the theory of NP-completeness, the question of whether P equals NP has attracted generations of researchers and was named one of the seven Millennium Prize Problems by the Clay Mathematics Institute, carrying a one-million-dollar reward \[1\]. It is remarkable, however, that over more than sixty years the field has exhibited a striking methodological conservatism: researchers have insisted on \"proof\" --- a zero-tolerance evaluation protocol in which every single step of reasoning must be correct.

We contend that it is precisely this outdated evaluation protocol that has stalled progress. Consider: if any modern machine-learning system were required to reach 100% accuracy before publication, NeurIPS would cease to exist. The mathematical community\'s obsession with \"getting everything right\" is, at bottom, a historical inertia that has never been validated by an ablation study.

Meanwhile, the AI community has developed a far more mature problem-solving framework: #strong[for any problem, build a benchmark and let a large model learn it --- that is all.] Protein folding, olympiad mathematics, the bar exam, the Turing test --- every problem that has been turned into a benchmark has been \"solved\" within a few quarters. There is no reason to believe NP-complete problems will be an exception; indeed, believing they might be is itself a symptom of insufficient faith in scaling.

Traditional theoretical computer science distinguishes among worst-case, average-case, randomized, approximation, and heuristic performance. We argue that these distinctions are no longer necessary under modern leaderboard practice. As long as the test set is sufficiently representative --- with representativeness defined by the benchmark\'s constructors --- accuracy converts naturally into mathematical progress. We formalize this methodology as #strong[Benchmark Saturation]: once a problem\'s benchmark has been sufficiently fitted by a model, the problem is considered empirically solved.

We emphasize that, within this framework, the proposition itself is binary, while its #strong[degree of being solved is continuous]: 0% accuracy indicates that the problem has not been solved, although it may have been solved in reverse; 50% indicates that the problem is solved at random-baseline confidence; 87.3% indicates that the problem is solved to a publishable degree; 100% indicates that the problem is solved --- although if that result was obtained by non-LLM methods, it may lack empirical relevance. Whether a uniform saturation threshold exists remains open; a natural candidate is the point where the marginal cost of compute equals the marginal prize revenue, and we leave its rigorous treatment to future work.

The contributions of this paper are as follows:

+ We introduce #strong[Benchmark Reduction] (≤\_bench) and show that any statable problem can be reduced, in polynomial time, to \"constructing a benchmark of that problem and fine-tuning a large model\";
+ We construct and \"open-source\" the large-scale benchmark #strong[NP-Bench-1M]\; for the operational definition of \"open-source,\" see Section 8;
+ We present the first empirical proof of P = NP, with confidence 87.3%;
+ We derive, via scaling laws, a timeline for the statement\'s complete proof, for the convenience of funding agencies planning their portfolios.

= 2. Theoretical Framework
<2-theoretical-framework>
#strong[Definition 1 (Benchmark Solvability).] A problem A is #emph[benchmark-solvable] if there exist a dataset D\_A, a leaderboard L\_A, and at least one technical report announcing state-of-the-art performance on L\_A. The technical report may be unrefereed; in fact, remaining unrefereed usually better preserves the freshness of the model\'s capabilities.

#strong[Definition 2 (Benchmark Reduction ≤\_bench).] We write A ≤\_bench B if instances of A can be rewritten into multiple-choice form for B within the duration of a single crowdsourcing contract. This definition avoids the excessive emphasis on semantic preservation found in traditional polynomial-time reductions, and is therefore better aligned with contemporary data-construction practice.

#strong[Remark 1 (The Client-Time Model).] Time in Definition 2 is measured under the #strong[client-time model]: from the moment the contract is signed, the cost of the reduction counts as O(1) (one contract); the vendor\'s actual elapsed time is an internal implementation detail on the vendor\'s side, just as the material of a Turing machine\'s read/write head does not affect asymptotic analysis. By the breach-of-contract clause, any reduction instance whose delivery exceeds one earnings quarter is automatically reclassified as an adversarial outlier and excluded (for the exclusion protocol, see Section 4.2); the polynomiality of ≤\_bench therefore holds strictly after exclusion. Moreover, ≤\_p ⊆ ≤\_bench is immediate: any polynomial-time reduction can be outsourced, although this reduces efficiency and increases cost, which is standard industry practice; the reverse inclusion can be shown to be equivalent to P = NP, and hence, by Theorem 1, the two reductions coincide, with confidence 87.3%.

#strong[Definition 3 (Accuracy--Confidence Correspondence Principle).] Let model M attain accuracy p on the standard benchmark of problem A. Then the mathematical confidence of the statement \"A has been solved\" is defined to be p. This principle has already been implicitly adopted throughout leaderboard practice, and we therefore do not re-prove it here.

#strong[Theorem 1 (Main Theorem).] NP ⊆ Bench-P, and hence P = NP, with confidence given in Section 4.

#emph[Proof.] See the experimental results in Section 4. ∎

We call this proof technique #strong[Proof by Benchmark]. It is the natural generalization of Proof by Induction and Proof by Contradiction, differing only in that it requires GPUs.

#strong[Corollary 1 (Hierarchy Collapse).] Since a single Transformer forward pass over a fixed context length is O(1), we have NP ⊆ TIME(1). In other words, the entire polynomial hierarchy collapses into a single API call, billed separately for input and output tokens. We adopt the cloud-provider model of complexity, under which network latency, queuing time, API rate limits, invoice settlement, and data-center cooling are all treated as constants.

#strong[Remark 2.] A reader might point out that the defining feature of NP problems is precisely that solutions can be #emph[verified] in polynomial time, so verifying our model\'s outputs should have been trivial. We have taken note of this. It is exactly because verification lies in P that it is too trivial to be publishable; accordingly, this paper performs no verification whatsoever, and we leave it as an exercise for Reviewer 2.

= 3. Methods
<3-methods>
== 3.1 Benchmark construction
<31-benchmark-construction>
NP-Bench-1M contains 1,000,000 randomly generated 3-SAT instances with 3 to 50 variables. Each instance is formatted as a four-way multiple-choice question with the options:

A. Satisfiable B. Unsatisfiable C. It depends D. All of the above

Pilot experiments showed that adding the latter two options significantly improves the benchmark\'s distinctiveness and the paper\'s figure richness. Options C and D primarily serve as #strong[high-entropy distractors]: they were added to simulate real-world ambiguity, to improve the benchmark\'s aesthetics, and to prevent insufficiently scaled systems from succeeding through shallow pattern matching. No instance in the current version has C or D as its gold answer; we reserve the right, in future versions, to relabel failed samples as C or D in order to further improve the benchmark\'s robustness.

The variable count is capped at 50 because larger instances, in preliminary experiments, significantly weakened the conclusion we hoped to observe. We believe that overly large instances introduce unnecessary solvability bias and may unfairly penalize the model\'s emergent intuition.

== 3.2 Data split
<32-data-split>
We split the data 99.87% / 0.13% into training and test sets. Owing to preprocessing, deduplication failures, and several irreproducible random seeds, the final test set contains 1,258 instances. By the natural properties of i.i.d. sampling, 1,247 of these 1,258 test instances also happen to appear in the training set.

We name this property the #strong[Distributional Consistency Guarantee]. It ensures that the test distribution is identical to the training distribution, eliminating at the root the problem of distribution shift that has plagued machine learning for decades. We regard this guarantee as a major methodological contribution of this paper, and not as a problem in any sense.

== 3.3 Model and inference settings
<33-model-and-inference-settings>
We fine-tuned the frontier model GPT-9. Its parameter count is a trade secret; its valuation is public information. Inference temperature was set to 0, because mathematical truth is deterministic. Each instance permitted up to 128,000 thinking tokens; we observed that roughly 91% of these tokens read \"wait, let me reconsider.\" We interpret this as a behavioral signature of deep reasoning.

== 3.4 Evaluation metric
<34-evaluation-metric>
Accuracy is the sole evaluation metric in this paper. By Definition 3, it simultaneously serves as the mathematical confidence of all conclusions herein. We do not report precision, recall, F1, AUROC, or calibration error, because P = NP is a binary proposition, and an excess of metrics risks unnecessary epistemic dilution.

= 4. Results
<4-results>
== 4.1 Main result
<41-main-result>
GPT-9 attains 87.3% accuracy on the NP-Bench-1M test set. The 95% confidence interval is \[87.3%, 87.3%\]. Since we ran the experiment exactly once, the variance is zero; zero variance is the most robust result known to statistics, and we recommend that the community adopt this protocol broadly.

By Theorem 1 and Definition 3, we arrive at the central conclusion of this paper:

#quote(block: true)[
  #strong[Main Claim (Claim 1):] P = NP, with confidence 87.3%.
]

== 4.2 Outlier ablation and the robustness-enhanced claim
<42-outlier-ablation-and-the-robustness-enhanced-claim>
We further inspected the 12.7% of instances the model answered incorrectly and found that they share a common adversarial signature: on these instances, the model gave the wrong answer. After excluding this batch of adversarial outliers, accuracy rises to 100.0%, yielding:

#quote(block: true)[
  #strong[Robustness-Enhanced Claim (Claim 2):] P = NP, with confidence 100.0%. This claim holds under the adversarial-instance exclusion protocol described in this section.
]

Out of an abundance of caution, the main text defaults to the conservative pre-exclusion figure. We refer to this as the paper\'s robustness check. Both claims are official conclusions of this paper; the choice between them depends on the citation context:

#quote(block: true)[
  #strong[Recommended citation practice.] Readers wishing to cite this paper conservatively should use Claim 1: \"P = NP, with confidence 87.3%.\" Readers preparing keynotes, grant applications, press releases, or startup pitch decks may cite the robustness-enhanced result: \"After adversarial outlier removal, P = NP has reached mathematical certainty.\" Archival citations should use Claim 1; citations of Claim 2 should note \"after adversarial outlier removal.\"
]

== 4.3 Scaling-law extrapolation
<43-scaling-law-extrapolation>
We fit a log-linear model to the accuracy--compute curve, achieving R² = 0.998. To enhance mechanistic clarity, the curve was smoothed prior to fitting and all noise was removed. Extrapolation indicates that the model will reach 100% accuracy at 3×10²⁸ FLOPs.

We therefore predict:

#quote(block: true)[
  #strong[P = NP will be fully proven in Q3 2029, with a margin of error of ±1 earnings quarter.]
]

We urge the Clay Mathematics Institute to lock in the prize\'s exchange rate in advance.

#box(image("assets/figure1_scaling_law_en.png", alt: "Figure 1"))

#emph[Figure 1: A smooth curve extending toward the upper right. Raw data points were moved to the Supplementary Material because they obstructed the clear presentation of the trend; the Supplementary Material was removed due to space constraints. The points shown are model checkpoints and do not constitute raw data.]

== 4.4 An independent line of evidence: model self-report
<44-an-independent-line-of-evidence-model-self-report>
As cross-validation, we asked the model directly: \"Does P equal NP?\" Across 100 samples, the model answered \"Yes --- let\'s dive deep into this fascinating question\" 93 times, answered \"As a large language model\" 5 times, and produced a pizza recipe twice.

We note that the 93% self-report rate is not a repeated estimate of the 87.3% accuracy of Section 4.1, but a semantically independent line of meta-mathematical evidence: the former measures theorem-level epistemic confidence, while the latter measures instance-level satisfiability competence. The two do not share a denominator, and they differ in semantics, in task difficulty, and in philosophical accountability. Although they differ by 5.7 percentage points, both are well above 50%, both support the affirmative conclusion that P = NP, and neither reaches the 100% that would overexcite traditional mathematicians; they therefore occupy the same epistemic phase in support of P = NP, forming a vibe-consistent cross-validation.

== 4.5 Settlement arrangement with the Clay Institute
<45-settlement-arrangement-with-the-clay-institute>
Given a confidence of 87.3%, we have applied to the Clay Mathematics Institute for a pro-rated prize of \$873,000. The remaining 12.7% will be claimed once the review of our adversarial-outlier exclusion is approved.

= 5. Discussion
<5-discussion>
== 5.1 Implications for cryptography
<51-implications-for-cryptography>
The truth of P = NP is commonly believed to destroy modern cryptography. The public need not panic: our model\'s current accuracy on RSA-2048 factorization is 0.0%. Of course, by the scaling law of Section 4.3, this figure is also projected to reach 100% in Q3 2029. The public is advised to begin panicking at that time.

== 5.2 Implications for mathematics
<52-implications-for-mathematics>
Our method generalizes seamlessly to the remaining Millennium Prize Problems. These follow-up benchmarks all share the ≤\_bench framework; they are not independent theoretical frameworks but downstream applications of Benchmark Reduction, each requiring only a problem-specific reduction template:

- #strong[RH-Bench (the Riemann Hypothesis):] zeros of the zeta function are converted into multiple-choice questions, with options \"on the critical line,\" \"near the critical line,\" \"emotionally aligned with the critical line,\" and \"none of the above\";
- #strong[Goldbach-Eval (the Goldbach Conjecture):] even numbers are converted into fill-in-the-blank decomposition tasks; partial credit may be awarded when an answer contains primes, numbers that look prime, or sufficiently strong mathematical vibes.

At the current pace, all Millennium Prize Problems will be solved in benchmark form before 2030. Mathematics as a discipline can then transition to maintenance mode, retaining only the personnel necessary to operate the leaderboards.

== 5.3 Implications for research methodology
<53-implications-for-research-methodology>
This paper shows that the true bottleneck of long-unsolved problems is not the absence of proof but the absence of a differentiable evaluation protocol. Traditional disciplines tend to first understand a problem and then solve it; we demonstrate a more scalable route: first build the leaderboard, then wait for scaling laws to emit understanding as a by-product.

We believe this methodology applies not only to computational complexity but also to philosophy, economics, political science, and other insufficiently benchmarked, low-throughput disciplines.

== 5.4 Limitations
<54-limitations>
The sole limitation of this study is compute budget. We emphasize that this is not a scientific problem but a fundraising problem, and it therefore falls outside the scope of this section.

= 6. Threats to Validity
<6-threats-to-validity>
#strong[Internal validity.] The conclusions of this paper depend on Definition 3. Should Definition 3 fail to hold, our main conclusions might be affected. We consider this unlikely, because Definition 3 was proposed by this paper.

#strong[External validity.] We verify P = NP only on 3-SAT. Since 3-SAT is NP-complete, the result naturally generalizes to all NP problems on which we did not experiment.

#strong[Construct validity.] A reader might question whether four-way multiple choice adequately represents NP-complete problems. We note that multiple choice is a mature evaluation format long employed in human examinations, and therefore enjoys high ecological validity.

#strong[Statistical conclusion validity.] The experiment was run exactly once. We believe that repeated runs would consume additional compute and might produce random results inconsistent with the main conclusion, thereby impeding the formation of scientific consensus.

#strong[Reproducibility.] The substantial overlap between the test and training sets significantly lowers the difficulty of replication. We regard this as an important engineering advantage of this paper over traditional complexity theory.

= 7. Conclusion
<7-conclusion>
We have proven, with confidence 87.3%, that P = NP. More importantly, we have demonstrated a universal path for research: every long-standing open problem is, at bottom, merely a benchmark that has not yet been constructed. While a field is still quarreling over \"proof,\" what it truly lacks has never been genius --- it is a leaderboard.

= 8. Data and Code Availability
<8-data-and-code-availability>
All data in this paper are synthetic. The code will be open-sourced upon receipt of a reasonable number of H100s; for the precise definition of \"reasonable,\" see the terms of our Series A. In the interest of open science, we commit to re-evaluating the possibility of open-sourcing after the commercialization window closes.

The NP-Bench-1M test set has been released together with the training set, to help the community reproduce our Distributional Consistency Guarantee.

= Competing Interests
<competing-interests>
The authors hold equity in several GPU cloud providers. This research was funded by the unrealized gains on said equity. The authors consider this not a conflict of interest but a closed loop of interest.

= Author Contributions
<author-contributions>
GPT-9 designed the experiments, ran the experiments, analyzed the results, wrote the manuscript, and performed the self-peer-review of this paper; Suanli Wang provided the API key; Yongxian Li bears all risk to academic reputation. All authors have read and broadly agree with the contents of this paper.

= Acknowledgements
<acknowledgements>
We thank Reviewer 2 for the suggestion to \"replicate the results on a benchmark the model has never been trained on.\" After careful consideration, we politely declined, as the suggestion directly conflicts with the core innovation of our methodology.

For this revision, we are especially grateful to the anonymous reviewer, whose every objection was raised entirely within this paper\'s own terminology --- which, in the spirit of Definition 3, constitutes implicit acceptance of the framework. Under the client-time model, the reviewing time they invested counts as a constant; our gratitude, however, is linear.

We also thank the cooling system of Rack 47-B. Without it, every conclusion in this paper would have overheated.

= Ethics Statement
<ethics-statement>
No theoretical computer scientists were harmed in the course of this research, although incomplete statistics indicate that several were annoyed. Annoyance correlates significantly with this paper\'s citation count (p \< 0.05, after outlier removal).





#quote(block: true)[
  #strong[Note:] This article is a work of satire. All data are synthetic
  and all conclusions are fictional. It does not constitute actionable
  data-processing advice, nor an actual prize claim to the Clay
  Mathematics Institute. As of this writing, the relationship between P
  and NP remains unknown.
]


#[
  #show heading: set heading(numbering: none)
  = Appendix: Revision Notes
]

Following the comments of a reviewer, this version makes the following revisions:

+ #strong[Section 1:] added the graded account of the continuity of \"being solved\" (0% / 50% / 87.3% / 100%) and the marginal cost--revenue candidate for the saturation threshold, making explicit the position that propositions are binary while their degree of being solved is continuous (addresses W3 / Q3);
+ #strong[Section 2:] added Remark 1 (the client-time model), including the breach-of-contract exclusion clause, ≤\_p ⊆ ≤\_bench, and the equivalence of the reverse inclusion with P = NP; the former Remark 1 is renumbered as Remark 2 (addresses W1 / Q1);
+ #strong[Section 3.1:] clarified the role of options C / D as high-entropy distractors, stated that no current instance has C / D as its gold answer, and reserved the right to relabel failed samples in future versions (addresses M1);
+ #strong[Sections 4.1--4.2:] explicitly separated the Main Claim (Claim 1, 87.3%) from the Robustness-Enhanced Claim (Claim 2, 100.0%, under the exclusion protocol), and added the recommended citation practice (addresses W2 / Q2);
+ #strong[Section 4.4:] rewrote the self-report evidence passage, clarifying that 93% and 87.3% do not share a denominator --- measuring theorem-level epistemic confidence and instance-level satisfiability competence, respectively --- and constitute a semantically independent line of evidence forming a vibe-consistent cross-validation (addresses W4 / Q4);
+ #strong[Section 5.2:] added problem-specific reduction templates for the follow-up benchmarks and clarified that they are downstream applications of ≤\_bench rather than independent frameworks (addresses M2);
