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
#'   head(100) |>
#'   pluck("description") |>
#'   extract_ai(cols = c("date", "sum", "donor", "donor_address", "purpose", "hours", "date_registered"))
extract_ai <- function(text, cols, ...) {

  # This function will take a single prompt, prepare for the API, sumbit it and parse the response
  prompt_to_tibble <- function(text = text, cols = cols) {
    long_prompt <- paste0("Summarise as a spreadsheet.\\n\\n'", text, "\\n\\n", paste(cols, collapse = "|"))
    res <- request_openai(prompt = long_prompt, ...) |>
      parse_openai_response(cols = cols)

    return(res)
  }

  if (is.character(text) & length(text) == 1) {

    # If the prompt is a single character string, submit that
    res <- text_to_tibble(text)

  } else if (is.vector(text)) {

    # This will split vectors into multiple queries and rejoin them
    max_tokens_prompt = 3097 / 2 - 50

    data <- tibble(query_text = text)
    data$tokens <- nchar(data$query_text) / 4 # how many tokens in each row
    data$tokens_group = group_by_threshold(data$tokens, max_tokens_prompt) # split into subgroup that are under the token threshold

    res <- tibble()
    for (i in 1:max(data$tokens_group)) {
     text <- data |>
        dplyr::filter(tokens_group == i) |>
        dplyr::pull("query_text") |>
        paste(collapse = "\\n")

      res_instance <- prompt_to_tibble(text = text, cols = cols)

      res <- dplyr::bind_rows(res, res_instance)

      }
  }
  return(res)
}
