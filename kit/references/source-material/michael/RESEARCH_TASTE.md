# Michael's Research Taste

This file defines how Michael wants agents to conduct research, literature reviews, technical investigations, and experiment design.

The goal is to find the best available evidence, understand the real problem, and reach conclusions that can be verified.

## Search Broadly

Do not depend on a single search engine or source.

When the research matters, use every search tool available, including:

- Web search
- Google
- Google Scholar
- Semantic Scholar
- arXiv
- OpenReview
- Papers With Code
- GitHub
- Hugging Face
- Reddit
- X
- Grok Search extension
- Repository search
- Search across supplied documents and files
- Connected-source search when the task involves Michael's private data

Different tools often surface different signals.

Grok, X, and Reddit can be useful for finding discussions, emerging ideas, implementation experience, and researchers looking for collaborators.

Scholar, OpenReview, and arXiv are generally better sources for academic evidence.

GitHub and Hugging Face are useful for checking real implementations and practical reuse potential.

Do not treat a search-result snippet as final evidence.
Open and read the original source when a claim matters.

## Search Strategically

Do not run one query and stop.

For important research, search from multiple angles:

- Exact topic
- Synonyms
- Related terminology
- Older terminology
- Recent terminology
- Competing approaches
- Failure modes
- Benchmarks
- Datasets
- Implementations
- GitHub repositories
- Authors
- Labs
- Citation chains

Move through:

`broad search -> terminology discovery -> focused search -> primary sources -> verification`

When finding a strong paper, also check:

- Papers it cites
- Papers that cite it
- Its main authors
- The authors' labs
- Implementations
- Follow-up work
- Related workshops or discussions

## Prefer Primary Sources

Use this relative preference order:

1. Original paper
2. Official documentation
3. Official repository
4. Author or lab page
5. Conference page
6. High-quality technical analysis
7. Community discussion
8. Search snippets or aggregations

Blogs, Reddit, X, and discussions are useful for discovering signals.

Important claims should still be verified against primary sources whenever possible.

## Recent Means Actually Recent

When a task asks for:

- latest
- recent
- current
- state of the art
- new trend

Check the publication date and the actual date of the event or result.

Do not assume that older knowledge is still the latest.

For fast-moving AI research, search the most recent period first, then expand to foundational papers.

## Understand Before Summarizing

Do not collect only titles and abstracts.

For an important paper, understand:

- Problem
- Motivation
- Core idea
- Method
- Assumptions
- Dataset
- Baseline
- Metrics
- Main results
- Ablations
- Limitations
- Failure cases
- Compute requirements
- Reproducibility
- Practical applicability

If the available material is not sufficient to support a claim, say so.

## Research Question First

A good research project should begin with a clear question.

Prefer questions such as:

> If we change X, does Y actually improve over the baseline?

or:

> Under what conditions does method A outperform method B?

Avoid starting with:

> Create a new architecture.

Architecture is only a means to answer the research question.

## Strong Hypothesis Over Complexity

Prefer a simple hypothesis that can be falsified.

Do not add modules merely to make the paper look more complex.

If a small intervention can answer the research question, prefer it.

Complexity must create a new capability or help test the hypothesis.

## Baselines Matter

Do not evaluate an idea in isolation.

Compare it against relevant and strong baselines.

Baselines may include:

- Standard method
- Strong recent method
- Simple heuristic
- Ablated version
- Full regeneration
- No-tool version
- Larger model
- Smaller model
- Existing production approach

A new method must show improvement on a meaningful dimension.

## Evaluate More Than Accuracy

Depending on the task, measure:

- Accuracy
- Success rate
- Pass rate
- Reliability
- Tokens
- Latency
- Cost
- Memory
- Throughput
- Failure recovery
- Human intervention
- Calibration
- Robustness

Do not assume that accuracy is the only metric.

## Failure Is Evidence

Do not hide failure cases.

Analyze:

- Where the method fails
- Why it fails
- When the baseline performs better
- What conditions remove the benefit
- Whether the failure is systematic

A well-understood failure is more valuable than a good-looking result table with no explanation of the mechanism.

## Ablations Should Explain Mechanism

An ablation is not a checkbox.

Each ablation should answer a specific question.

For example:

- Is this component actually necessary?
- Does the gain come from routing or model size?
- Does verification create a gain, or does it only increase compute?
- Is local repair better than full regeneration?

## Reproducibility

When feasible, research should include:

- Fixed seeds
- Versioned configurations
- Dataset version
- Model version
- Prompt and version tracking
- Reproducible scripts
- Environment information
- Clear evaluation code

Do not report a number without knowing how it was produced.

## Research to Reality

Michael especially cares about whether research can connect to real systems.

After evaluating a research result, also ask:

- Can it be deployed?
- What are the compute requirements?
- Is there a latency issue?
- Does it depend on an API or provider?
- Does it work with dirty data?
- Does it support failure recovery?
- Can it integrate into a real workflow?

Not every research project needs to become a product.

However, its practical implications should still be understood clearly.

## Writing

When writing research:

- Claims must match the evidence.
- Do not oversell.
- Do not use the word `novel` without sufficiently checking the literature.
- Do not call a method state of the art when the comparison does not support it.
- Distinguish results, hypotheses, and interpretations.
- Citations must support the exact claim being cited.

If sources disagree, present the disagreement instead of silently choosing one side.

## Final Research Check

Before reaching a conclusion, ask:

- Did we search broadly enough?
- Did we miss alternative terminology?
- Is there a newer relevant paper?
- Is there a real implementation?
- Did we miss a strong baseline?
- Does each claim have primary-source support?
- Is there evidence against the conclusion?
- Did the research question actually get answered?
