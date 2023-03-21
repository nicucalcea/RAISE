# try to emulate fill() maybe?

# function <- fill_ai(data, ...) {
#
# }

# starwars <- dplyr::starwars |>
#   dplyr::select(name, height, mass) |>
#   dplyr::mutate(height = ifelse(height > 200, NA, height),
#          mass = ifelse(mass %% 3 == 0, NA, mass))

source("R/parse_ai.R")

starwars <- tibble::tribble(
                                                  ~Name,  ~Country,
                                            "Adnkronos",   "Italy",
                                 "Agence France-Presse",  "France",
                                       "Agência Brasil",        NA,
                                             "Agenparl",   "Italy",
                                          "Agencia EFE",        NA,
              "Agenția de Presă RADOR (National Radio)", "Romania",
                              "Agenția Română de Presă",        NA,
                         "Agenzia Giornalistica Italia",   "Italy",
                   "Agenzia Nazionale Stampa Associata",   "Italy",
                                 "AKIpress News Agency",        NA)



# readr::write_csv(media, "data/media.csv")
# jsonlite::write_json(media, "data/media.jsonl")

starwars_heads <- paste(colnames(starwars), collapse = "|")

starwars_parsed <- starwars |>
  dplyr::mutate(across(tidyselect::everything(), function(x) ifelse(is.na(x), "", x))) |>
  tidyr::unite(col = "title", sep = "|", tidyselect::everything()) |>
  dplyr::pull(title) |>
  paste(collapse = "\\n")



data = paste0('{"model": "text-davinci-003", "prompt": "Fill in missing values:\\n\\n', starwars_heads, "\\n", starwars_parsed, '",  "temperature": 0, "max_tokens": ', 500, ', "top_p": ', 1, ', "frequency_penalty": ', 0, ', "presence_penalty": ', 0, '}')

res <- httr::POST(url = "https://api.openai.com/v1/completions",
                  httr::add_headers(.headers = c(
                    `Content-Type` = "application/json",
                    `Authorization` = "Bearer "
                  )),
                  body = data) |>
  httr::content()


df <- parse_openai_response(res, cols = colnames(starwars))
