#' Send a prompt to GPT and get a response
#'
#' You will need an OpenAI API key.
#'
#' @param prompt A question you want to ask GPT.
#' @export
#' @examples
#' top_banks <- tibble::tribble(~bank, "HSBC Holdings", "Lloyds Banking Group", "Royal Bank of Scotland Group", "Barclays", "Standard Chartered", "Santander UK", "Nationwide Building Society", "Schroders") |>
#'     dplyr::mutate(website = answer_ai(paste0("Official website of ", bank, ": ")),
#'                   phone_nr = answer_ai(paste0("Customer service number of ", bank, ": ")))
answer_ai <- function(prompt){
  res_all <- c()
  for (i in 1:length(prompt)) {
    res <- request_openai(prompt = prompt[[i]])
    res <- res$choices[[1]]$text
    res <- stringr::str_trim(res)
    res_all <- c(res_all, res)
  }

  return(res_all)
}
