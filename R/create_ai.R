source("R/parse_ai.R")

create_ai <- function(prompt, cols, ...) {
  long_prompt <- paste(cols, collapse = "|")
  long_prompt <- paste0(prompt, "\\n\\n", long_prompt)

  res <- request_openai(prompt = long_prompt, ...)

  parse_openai_response(res, cols = cols)
}

presidents <- create_ai("A spreadsheet of all presidents of the Republic of Moldova since independence",
                        c("Name", "Year of birth", "Year of assumed office", "Party"))

us_states <- create_ai("A spreadsheet of all 50 US states", c("State", "Area", "Population"))


emissions <- create_ai("A table of top 10 countries by cumulative historical carbon emissions", c("Country", "Emissions", "Unit"))

pms <- create_ai("A table of UK prime ministers by length of tenure, from shortest to longest", c("Prime minister", "Party", "Days in office"))
