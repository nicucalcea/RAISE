#' Send a prompt to GPT and get a response
#'
#' You will need an OpenAI API key.
#'
#' @param prompt A question you want to ask GPT.
#' @param prompt_system The system message helps set the behaviour of the AI. It can be something like "You are a helpful assistant."
#' @export
#' @examples
#' top_banks <- tibble::tribble(~bank, "HSBC Holdings", "Lloyds Banking Group", "Royal Bank of Scotland Group", "Barclays", "Standard Chartered", "Santander UK", "Nationwide Building Society", "Schroders") |>
#'     dplyr::mutate(website = answer_ai(paste0("Official website of ", bank, ": ")),
#'                   phone_nr = answer_ai(paste0("Customer service number of ", bank, ": ")))
answer_ai <- function(prompt,
                      prompt_system = "You are a helpful assistant that answers question as briefly as possible.",
                      ...) {
  res_all <- c()
  for (i in 1:length(prompt)) {
    res <- request_openai(prompt = prompt[[i]], prompt_system = prompt_system, ...) |>
      parse_openai_response()

    res_all <- c(res_all, res)
  }

  return(res_all)
}
