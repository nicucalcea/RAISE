RAISE: R-based AI for Structured Extraction
================

- <a href="#setting-up" id="toc-setting-up">Setting up</a>
- <a href="#creating-data" id="toc-creating-data">Creating data</a>
- <a href="#parsing-unstructured-data"
  id="toc-parsing-unstructured-data">Parsing unstructured data</a>

This is an experimental library for using GPT-3.5 / ChatGPT to help with
difficult to automate tasks, such as parsing unstructured text into
structured data.

ChatGPT is new and tends to
[hallucinate](https://en.wikipedia.org/wiki/Hallucination_(artificial_intelligence)),
so it will return data that is wrong or doesn’t even exist. Use at your
own risk.

## Setting up

You can install the library from GitHub.

``` r
remotes::install_github("nicucalcea/RAISE")
```

You’ll also need to set up an [OpenAI API key](https://openai.com/).

The easiest way for RAISE to access the key is to save it into your R
environment.

Run `usethis::edit_r_environ()` to open your R environment file and add
a new line containing your API key. It should look something like this.

```
OPENAI_API_KEY = "API_KEY_HERE"
```

Save it and restart.

If you use [gptstudio](https://github.com/MichelNivard/gptstudio) or
[gpttools](https://github.com/JamesHWade/gpttools), you should already
be set up.

## Creating data

RAISE can help you send a prompt to ChatGPT and get a response as a
table.

Let’s say you want a table of the biggest buildings in the world and
their height.

``` r
buildings <- create_ai("Top 10 tallest buildings in the world",
                       cols = c("Building", "Country", "Developer", "Year built", "Height in metres"))
```

As mentioned before, GPT-3.5 is a language model, not a factual search
engine. While the data can be correct, there’s a chance it is not and it
needs to manually checked. This is just an experiment.

## Parsing unstructured data

GPT-3.5 seems quite good at parsing data from unstructured text.

Let’s take the [Register of Members’ Financial
Interests](https://www.parliament.uk/mps-lords-and-offices/standards-and-financial-interests/parliamentary-commissioner-for-standards/registers-of-interests/register-of-members-financial-interests/),
a notoriously clunky database to parse, making it difficult to keep
track of changes over time.

``` r
library(tidyverse)
mps <- read_csv("https://raw.githubusercontent.com/sparkd/mp-financial-interests/master/data/financial-interests-2010-18.csv") |>
  filter(type_code == 1) |>
  head(100)

mps_structured <- extract_ai(mps$description,
                             cols = c("date", "sum", "donor", "donor_address", "purpose", "hours", "date_registered"))
```

GPT-3.5 has extracted and filled in the columns we asked for. As before,
the process is not without fault and the results will need to be
verified, but it can save many hours of manual labour and give us quick
insights even if the data is not final.

The API has some limitations in terms of [how big a prompt and answer
can be](https://platform.openai.com/docs/models/gpt-3-5), so we’re
splitting the query into chunks and rejoining the parts afterwards. This
may throw some errors in the future, so it’s a work in progress.
