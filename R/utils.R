#' Build a request to the OpenAI API
#' @param prompt The prompt
#' @noRd
request_openai <- function(prompt,
                           prompt_system,
                           cols,
                           api_key = Sys.getenv("OPENAI_API_KEY"),
                           model = "gpt-3.5-turbo",
                           temperature = 0,
                           max_tokens = 2000,
                           top_p = 1,
                           frequency_penalty = 0,
                           presence_penalty = 0) {

  # If there are columns, paste the prompt and the columns together
  if (hasArg(cols)) {
    prompt <- paste0(prompt, "\\n", paste(cols, collapse = "|"))
  }

  # These are useful to make the model more consistent (or not if that's what you want)
  params <- list(
    model = model,
    temperature = temperature,
    max_tokens = max_tokens,
    top_p = top_p,
    frequency_penalty = frequency_penalty,
    presence_penalty = presence_penalty
  )

  # Do we use the chat or the completion endpoint? Chat is cheaper for now.
  # https://platform.openai.com/docs/models/model-endpoint-compatibility

  if (model_type(model) == "completion") {

    api_endpoint <- "/v1/completions"
    prompt <- paste0(prompt_system, " ", prompt)
    data <- jsonlite::toJSON(c(params, list(prompt = prompt)), auto_unbox = TRUE)

  } else if (model_type(model) == "chat") {

    # The chat endpoint is different than the completion one
    api_endpoint <- "/v1/chat/completions"

    # It also needs a different kind of prompt
    # https://platform.openai.com/docs/guides/chat/chat-vs-completions
    prompt <- list(list(role = "system", content = prompt_system),
                   list(role = "user", content = prompt))

    # Create a the JSON to send to API
    data <- jsonlite::toJSON(c(params, list(messages = prompt)), auto_unbox = TRUE)
  }

  # Send the request
  res <- httr::POST(url = paste0("https://api.openai.com", api_endpoint),
                    httr::add_headers(.headers = c(
                      `Content-Type` = "application/json",
                      `Authorization` = paste0("Bearer ", api_key)
                    )),
                    body = data)

  if (res$status_code == 200) {
    res <- res |> httr::content()
  } else {
    res <- res |> httr::content()
    warning(res$error$message)
    res <- NA
  }

  message(paste0("Used ", res$usage$total_tokens, " tokens, of which ", res$usage$prompt_tokens, " for the prompt, and ", res$usage$completion_tokens, " for the completion."))
  return(res)
}




#' Parse an API response to a tibble
#' @param response The text
#' @param cols The column names to use as headers. If missing, it will just return the text.
#' @noRd
parse_openai_response <- function(response, cols) {

  # Check which model we're using
  if (model_type(response$model) == "completion") {
    response <- response$choices[[1]]$text
    # Add the columns back into the prompt
    if (hasArg(cols)) response <- paste0(paste0(cols, collapse = "|"), "\n", response)
  } else if (model_type(response$model) == "chat") {
    response <- response$choices[[1]]$message$content
  } else {
    stop("Model not recognised.")
  }

  response <- stringr::str_trim(response) # Get rid of whitespace

  # If columns are specified, it's probably a table
  if (hasArg(cols)) {
    response <- readr::read_lines(response)
    response <- response[!grepl('^[[:blank:]+-=:_|]*$', response)]# Ditch the header separator
    response <- gsub('(^\\s*?\\|)|(\\|\\s*?$)', '', response)
    response <- readr::read_delim(paste(response, collapse = '\n'), delim = '|',
                                  col_types = readr::cols(.default = readr::col_character()),
                                  trim_ws = T)
  }

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


# Is the model chat or completion?
#' @param model The prompt
#' @noRd
model_type <- function(model) {
  if (model %in% c("gpt-4", "gpt-4-0314", "gpt-4-32k", "gpt-4-32k-0314", "gpt-3.5-turbo", "gpt-3.5-turbo-0301")) return("chat")
  else if (model %in% c("text-davinci-003", "text-davinci-002", "text-curie-001", "text-babbage-001", "text-ada-001", "davinci", "curie", "babbage", "ada")) return("completion")
  else stop("Model not recognised.")
}
