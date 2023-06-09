% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_ai.R
\name{create_ai}
\alias{create_ai}
\title{Return a tibble based on a prompt}
\usage{
create_ai(
  prompt,
  prompt_system = "You can only respond with a pipe-separated table.",
  cols,
  ...
)
}
\arguments{
\item{prompt}{The prompt you'd like to run. It could be something like "A spreadsheet of all 50 US states"}

\item{prompt_system}{The system message helps set the behaviour of the AI. It can be something like "You are a helpful assistant."}

\item{cols}{The columns of the tibble to be returned. Could be something like `c("State", "Area", "Population")`}
}
\description{
You will need an OpenAI API key.
}
\examples{
us_states <- create_ai("All 50 US states", c("State", "Area", "Population"))
mountains <- create_ai("Top 5 tallest mountains", c("Mountain", "Country", "Height in metres"))
peppers <- create_ai("Top 10 hottest peppers", c("Pepper", "Country of origin", "Scoville heat units"))
}
