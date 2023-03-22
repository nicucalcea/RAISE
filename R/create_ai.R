#' Return a tibble based on a prompt
#'
#' You will need an OpenAI API key.
#'
#' @param prompt The prompt you'd like to run. It could be something like "A spreadsheet of all 50 US states"
#' @param cols The columns of the tibble to be returned. Could be something like `c("State", "Area", "Population")`
#' @export
#' @examples
#' us_states <- create_ai("All 50 US states", c("State", "Area", "Population"))
#' mountains <- create_ai("Top 5 tallest mountains", c("Mountain", "Country", "Height in metres"))
#' peppers <- create_ai("Top 10 hottest peppers", c("Pepper", "Country of origin", "Scoville heat units"))

create_ai <- function(prompt, cols, ...) {
  long_prompt <- paste(cols, collapse = "|")
  long_prompt <- paste0("Respond as a spreadsheet. ", prompt, "\\n", long_prompt)

  res <- request_openai(prompt = long_prompt, ...)

  parse_openai_response(res, cols = cols)
}
