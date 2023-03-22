#' Parse a string or vector to a tibble
#'
#' You will need an OpenAI API key.
#'
#' @param text A vector of unstructured text you want to parse to a table.
#' @param cols The columns of the tibble to be returned. Could be something like `c("State", "Area", "Population")`
#' @export
#' @examples
#' # mps <- read_csv("https://raw.githubusercontent.com/sparkd/mp-financial-interests/master/data/financial-interests-2010-18.csv") |>
#'   filter(type_code == 1) |>
#'   head(10) |>
#'   pluck("description") |>
#'   extract_ai(cols = c("date", "sum", "donor", "donor_address", "purpose", "hours", "date_registered"),
#'              max_tokens = 1000)
extract_ai <- function(text, cols, ...) {
    if (is.vector(text)) {
      text = paste(text, collapse = "\\n")
    }

  long_prompt <- paste0("Summarise as a spreadsheet.\\n\\n'", text, "\\n\\n", paste(cols, collapse = "|"))

  res <- request_openai(prompt = long_prompt, ...)
  parse_openai_response(res, cols = cols)
}
