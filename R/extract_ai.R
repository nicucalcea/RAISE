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


extract_ai_loop <- function(data, col, cols, ...) {

  max_tokens_prompt = 4097 / 2 - 50

  data$tokens <- nchar(data[[col]]) / 4 # how many characters in each row
  data$tokens_group = group_by_threshold(data$tokens, max_tokens_prompt) # split into subgroup that are under the threshold

  res_all <- tibble()

  for (i in 1:2) {
    text <- data |>
      dplyr::filter(tokens_group == i) |>
      dplyr::pull(col) |>
      paste(collapse = "\\n")

    long_prompt <- paste0("Summarise as a spreadsheet only.\\n\\n'", text, "\\n\\n", paste(cols, collapse = "|"))
    res <- request_openai(prompt = long_prompt) |>
      parse_openai_response(cols = cols)

    res_all <- dplyr::bind_rows(res_all, res)
    Sys.sleep(1)
  }

  return(res_all)
}

# df <- extract_ai_loop(data = mps, col = "description", cols = c("date", "sum", "donor", "donor_address", "purpose", "hours", "date_registered"))
