# Add functions to send request and parse response

# https://stackoverflow.com/questions/70060847/how-to-work-with-openai-maximum-context-length-is-2049-tokens

#' Build a request to the OpenAI API
#' @param prompt The prompt
#' @noRd
request_openai <- function(prompt, api_key = Sys.getenv("OPENAI_API"), model = "text-davinci-003", temperature = 0, max_tokens = 3000, top_p = 1, frequency_penalty = 0, presence_penalty = 0) {

  data = paste0('{"model": "text-davinci-003", "prompt": "', prompt, '",  "temperature": ', temperature, ', "max_tokens": ', max_tokens, ', "top_p": ', top_p, ', "frequency_penalty": ', frequency_penalty, ', "presence_penalty": ', presence_penalty, '}')

  res <- httr::POST(url = "https://api.openai.com/v1/completions",
                    httr::add_headers(.headers = c(
                      `Content-Type` = "application/json",
                      `Authorization` = paste0("Bearer ", api_key)
                    )),
                    body = data) |>
    httr::content()

  print(res)
}

#' Parse an API response to a tibble
#' @param response The text
#' @param cols The coumn names to use as headers
#' @noRd
parse_openai_response <- function(response, cols) {
  response$choices[[1]]$text |>
    tibble::as_tibble() |>
    tidyr::separate_longer_delim(1, delim = "\n") |>
    tail(-1) |>
    tidyr::separate(value, sep = "\\|", into = cols)
}
