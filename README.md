RAISE: R-based AI for Structured Extraction\*
================

- <a href="#disclaimers" id="toc-disclaimers">Disclaimers</a>
- <a href="#setting-up" id="toc-setting-up">Setting up</a>
- <a href="#creating-data" id="toc-creating-data">Creating data</a>
- <a href="#mutating-new-columns" id="toc-mutating-new-columns">Mutating
  new columns</a>
- <a href="#parsing-unstructured-data"
  id="toc-parsing-unstructured-data">Parsing unstructured data</a>
- <a href="#web-scraping" id="toc-web-scraping">Web scraping</a>

*\*Yes, this is an AI-generated name.*

This is an experimental library for using GPT / ChatGPT to help with
difficult to automate tasks, such as parsing unstructured text into
structured data.

### Disclaimers

ChatGPT is new and tends to
[hallucinate](https://en.wikipedia.org/wiki/Hallucination_(artificial_intelligence)),
so it will return data that is wrong or doesn’t even exist.

Also note that ChatGPT may respond with a different output or even
different formatting even if you submit the exact same prompt twice. For
example, it may randomly choose to display missing values as a space, or
as a hyphen, or as NA.

This means you can’t reliably incorporate it into a bigger workflow and
expect it to produce the same result consistently.

At the moment, the library is a collection of exploratory scripts that
will fail often and without warning. Things will change and safeguards
will be put in place as the library matures.

OpenAI’s new GPT-4 has a higher token limit (meaning longer prompts) and
is supposed to be better than GPT-3.5 at parsing data. However, I don’t
yet have access to GPT-4, so all these examples are written with GPT-3.5
in mind.

Use at your own risk.

## Setting up

You can install the library from GitHub.

``` r
remotes::install_github("nicucalcea/RAISE")
library(RAISE)
```

You’ll need an [OpenAI API key](https://platform.openai.com/). The
easiest way for RAISE to access the key is to save it into your R
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

As mentioned above, GPT is a language model, not a factual search
engine. While the data can be correct, there’s a chance it is not and it
needs to manually checked.

## Mutating new columns

Let’s say you have a list of email addresses, and you want to extract
the first and last names from them. Or a list of names and you’re trying
to estimate their most likely gender?

You can use GPT to augment your existing data. Here’s an example.

``` r
top_banks <- tibble::tribble(~bank, "HSBC Holdings", "Lloyds Banking Group", "Royal Bank of Scotland Group", "Barclays", "Standard Chartered", "Santander UK", "Nationwide Building Society", "Schroders") |>
  mutate(website = answer_ai(paste0("Official website of ", bank, ": ")),
         phone_nr = answer_ai(paste0("Customer service number of ", bank, ": ")))
```

In this case, the function will call the API for each one of your rows,
and it will save the responses to a new column.

## Parsing unstructured data

GPT seems quite good at parsing data from unstructured text.

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

Another example:

``` r
addresses <- c("Majestic Distribution, Halesfield 2, Telford TF7 4QH", "1 Reeves Drive, Petersfield GU31 4FN", "9 Hawthorn Cottages, Hook Lane, Welling DA16 2LD", "4 Silvester Road, Castor PE5 7BA", "11 St Georges Close, London SE28 8QE", "510 Castle Wharf, East Tucker Street, Bristol BS1 6JU", "19 Brookside Close, Wombourne WV5 8JU", "384 Hough Fold Way, Bolton BL2 3QA", "3 Hadley Croft, Smethwick B66 1DP", "5 Field Drive, Crawley Down RH10 4AE", "Flat 21, Beadnall House, 5 Lingwood Court, Thornaby TS17 0BF", "29 St Leonards Close, Bridgnorth WV16 4EJ", "3 Colville Road, Bournemouth BH5 2AG", "Fferm Ganol, Llaithddu LD1 6YS", "129 Scott Road, Sheffield S4 7BH", "R A O B Club, The Exchange Building, Chapel Street, Goole DN14 5RJ", "Flat 1, Lawrence Court, 15 Highfield South, Birkenhead CH42 4NA", "37 Lower Noon Sun, Birch Vale SK22 1AQ", "1 Church Mews, Exmouth EX8 2SJ", "17 Windsor Drive, Kidderminster DY10 2NA")

addressses_parsed <- extract_ai(addresses,
                                cols = c("city", "postcode", "street name", "street number", "flat or unit number"))
```

In both cases, GPT-3.5 has extracted and filled in the columns we asked
for.

As before, the process is not without fault and the results will need to
be verified, but it can save many hours of manual labour and give us
quick insights even if the data is not final.

The API has some limitations in terms of [how big a prompt and answer
can be](https://platform.openai.com/docs/models/gpt-3-5), so we’re
splitting the query into chunks and rejoining the parts afterwards.

This may throw some errors in the future, so it’s a work in progress.

## Web scraping

Parsing unstructured data also applies to web pages. Let’s look at an
example.

``` r
oscar_winners <- scrape_ai("https://edition.cnn.com/2023/03/12/entertainment/oscar-winners-2023/index.html",
                           cols = c("category", "winner", "nominees"),
                           clean = "text",
                           css = "div[itemprop='articleBody']")
```

Here, we are getting a [CNN article listing all the 2023 Oscars
winners](https://edition.cnn.com/2023/03/12/entertainment/oscar-winners-2023/index.html)
and telling GPT what to scrape off the page. It returns a table with the
columns we specified.

There are two additional parameters we’re feeding into the function:

- The `clean = "text"` strips all our content of HTML tags, which is
  useful in our case, as we don’t care about the formatting. It can be
  set to `clean = "html"` to only scrape off [unnecessary
  HTML](https://lxml.de/api/lxml.html.clean.Cleaner-class.html), or to
  `clean = FALSE` to keep the entire thing.

- The CSS selector targets a specific part of the page, meaning we don’t
  send the entire page with navigation menus, sidebars, etc.
  Alternatively, you can use an XPATH selector.

Both of these are optional and are designed to reduce the size of the
prompt we’re sending, and subsequently reduce the cost of a query.

For now, the web scraper can’t deal with prompts bigger than the token
limit.
