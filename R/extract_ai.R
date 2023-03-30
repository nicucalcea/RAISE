#' Parse a string or vector to a tibble
#'
#' You will need an OpenAI API key.
#'
#' @param text A vector of unstructured text you want to parse to a table.
#' @param prompt A question you want to ask GPT. Something like "Summarise this as a table".
#' @param prompt_system The system message helps set the behaviour of the AI. It can be something like "You are a helpful assistant."
#' @param cols The columns of the tibble to be returned. Could be something like `c("State", "Area", "Population")`
#' @export
#' @examples
#' mps <- readr::read_csv("https://raw.githubusercontent.com/sparkd/mp-financial-interests/master/data/financial-interests-2010-18.csv") |>
#'   dplyr::filter(type_code == 1) |>
#'   head(100) |>
#'   purrr::pluck("description") |>
#'   extract_ai(cols = c("date", "sum", "donor", "donor_address", "purpose", "hours", "date_registered"))
extract_ai <- function(text,
                       prompt = "Summarise the following: ",
                       prompt_system = "You can only respond with a pipe-separated table.",
                       cols,
                       ...) {

  text <- gsub("\\n", "\\\\n", text) # format new lines for the API
  prompt <- paste0(prompt, "\\n", text) # combine prompt and text

  # If the prompt is a single character string, submit that
  if (is.character(text) & length(text) == 1) {
    res <- request_openai(prompt = prompt,
                          prompt_system = prompt_system,
                          cols = cols,
                          ...)

    res <- parse_openai_response(res, cols = cols)

    return(res)

  } else if (is.vector(text)) {
    # This will split vectors into multiple queries and rejoin them
    max_tokens_prompt = 3097 / 2 - 50

    data <- tibble::tibble(query_text = prompt)
    data$tokens <- nchar(data$query_text) / 4 # how many tokens in each row
    data$tokens_group = group_by_threshold(data$tokens, max_tokens_prompt) # split into subgroup that are under the token threshold

    res <- tibble::tibble()
    for (i in 1:max(data$tokens_group)) {
     text <- data |>
        dplyr::filter(tokens_group == i) |>
        dplyr::pull("query_text") |>
        paste(collapse = "\\n")

      res_instance <- request_openai(prompt = prompt,
                                     prompt_system = prompt_system,
                                     cols = cols,...) |>
        parse_openai_response(cols = cols)

      res <- dplyr::bind_rows(res, res_instance)

      }
  }
  return(res)
}
