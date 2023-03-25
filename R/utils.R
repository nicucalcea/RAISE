# Add functions to send request and parse response

#' Build a request to the OpenAI API
#' @param prompt The prompt
#' @noRd
request_openai <- function(prompt, api_key = Sys.getenv("OPENAI_API_KEY"), model = "text-davinci-003", temperature = 0, max_tokens = 2000, top_p = 1, frequency_penalty = 0, presence_penalty = 0) {

  data = paste0('{"model": "', model, '", "prompt": "', prompt, '",  "temperature": ', temperature, ', "max_tokens": ', max_tokens, ', "top_p": ', top_p, ', "frequency_penalty": ', frequency_penalty, ', "presence_penalty": ', presence_penalty, '}')

  res <- httr::POST(url = "https://api.openai.com/v1/completions",
                    httr::add_headers(.headers = c(
                      `Content-Type` = "application/json",
                      `Authorization` = paste0("Bearer ", api_key)
                    )),
                    body = data)

  if (res$status_code == 200) {
    res <- res |> httr::content()
  } else {
    res <- res |> httr::content()
    stop(res$error$message)
  }

  # print(res)
  message(paste0("Used ", res$usage$total_tokens, " tokens, of which ", res$usage$prompt_tokens, " for the prompt, and ", res$usage$completion_tokens, " for the completion."))
  return(res)
}

#' Parse an API response to a tibble
#' @param response The text
#' @param cols The coumn names to use as headers
#' @noRd
parse_openai_response <- function(response, cols) {
  response <- response$choices[[1]]$text # Extract from response
  response <- response[!grepl('^[[:blank:]+-=:_|]*$', response)]
  response <- gsub('(^\\s*?\\|)|(\\|\\s*?$)', '', response)
  response <- readr::read_delim(paste(response, collapse = '\n'),
                    delim = '|', col_names = cols, col_types = readr::cols(.default = readr::col_character()))
  return(response)
}


# Split a dataset so that we can loop requests
#' https://stackoverflow.com/questions/60074932/cumulative-sum-in-r-by-group-and-start-over-when-sum-of-values-in-group-larger-t
#' @param prompt The prompt
#' @noRd
group_by_threshold = function(col, threshold) {
  cumsum <- 0
  group <- 1
  result <- numeric()
  for (i in 1:length(col)) {
    cumsum <- cumsum + col[i]
    if (cumsum > threshold) {
      group <- group + 1
      cumsum <- col[i]
    }
    result = c(result, group)
  }
  return (result)
}
