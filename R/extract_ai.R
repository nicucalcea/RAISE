# extract_ai <- function(text, cols, id, model = "text-davinci-003", temperature = 0, max_tokens = 500, top_p = 1, frequency_penalty = 0, presence_penalty = 0) {
#
#   if (is.vector(text)) {
#     text = paste(text, collapse = "\\n")
#   }
#
#   data = paste0('{"model": "', model, '", "prompt": "A spreadsheet summarizing:\\n\\n', text, '\\n\\n', paste(cols, collapse = "|"), '",  "temperature": 0, "max_tokens": ', max_tokens, ', "top_p": ', top_p, ', "frequency_penalty": ', frequency_penalty, ', "presence_penalty": ', presence_penalty, '}')
#
#   res <- httr::POST(url = "https://api.openai.com/v1/completions",
#                     httr::add_headers(.headers = c(
#                       `Content-Type` = "application/json",
#                       `Authorization` = "Bearer "
#                     )),
#                     body = data) |>
#     httr::content()
#
#   print(res$choices[[1]]$text)
#
#   parsed_table <- res$choices[[1]]$text |>
#     as_tibble() |>
#     separate_longer_delim(1, delim = "\n") |>
#     tail(-1) |>
#     separate(value, sep = "\\|", into = cols)
#
#   return(parsed_table)
# }
#
# # data <- ai_extract(text = "23 November 2022, received £215,275.98 from Televisao Independente, S.A. Rue Mario Castelhano, no40, Queluz de Baixo, 2734-502 Barcarena, Portugal, for a speaking engagement at CNN Global Summit Lisbon. Transport, food and accommodation provided for me and two members of staff. Hours: 8 hrs. (Registered 07 December 2022)\\n6 December 2022, received £50,000 plus VAT from Ballymore Group, Ballymore Properties Ltd, Marsh Wall, London E14 9SJ, for a speaking engagement. Hours: 7 hrs. (Registered 21 December 2022)",
# #                      cols = c("date", "sum", "donor", "donor_address", "purpose", "hours", "date_registered"))
#
# #################################################################
# ##                             MPs                             ##
# #################################################################
#
# mps <- read_csv("https://raw.githubusercontent.com/sparkd/mp-financial-interests/master/data/financial-interests-2010-18.csv")
#
# mps_parsed <- mps |>
#   filter(type_code == 1) |>
#   head(50) |>
#   pluck("description") |>
#   ai_extract(cols = c("date", "sum", "donor", "donor_address", "purpose", "hours", "date_registered"),
#              max_tokens = 1000)
