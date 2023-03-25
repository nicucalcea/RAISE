#' Scrape data from a website using AI
#'
#' You will need an OpenAI API key.
#'
#' @param url A URL to the page you want to scrape.
#' @param cols The columns of the tibble to be returned. Could be something like `c("State", "Area", "Population")`
#' @param clean Whether to strip the HTML of unnecessary tags to reduce the number of tokens. Can be set to `"text"`, `"html"` or `FALSE`.
#' @param css CSS selector (also to reduce the number of tokens).
#' @param xpath XPATH selector (also to reduce the number of tokens). Alternative to the CSS selector.
#' @export
#' @examples
#' oscar_winners <- scrape_ai("https://edition.cnn.com/2023/03/12/entertainment/oscar-winners-2023/index.html", cols = c("category", "winner", "nominees"), clean = "text", css = "div[itemprop='articleBody']")

scrape_ai <- function(url, cols, clean = "text", css = FALSE, xpath = FALSE) {
  content_raw <- rvest::read_html(url) # read in full HTML

  content <- content_raw |>
    rvest::html_element("body") # we won't be scraping the head

  # If there's a selector specified, choose matching element
  if (!isFALSE(css)) {
    content <- content |> rvest::html_elements(css)
  } else if (!isFALSE(xpath)) {
    content <- content |> rvest::html_elements(xpath = xpath)
  }


  # Clean up script, style, etc to make file smaller
  # https://lxml.de/api/lxml.html.clean-module.html
  if (clean == "html") {
    # xml2::xml_remove(content |> rvest::html_elements("meta"))
    # xml2::xml_remove(content |> rvest::html_elements("script"))
    # xml2::xml_remove(content |> rvest::html_elements("style"))
    # xml2::xml_remove(content |> rvest::html_elements("svg"))

    content_text <- content |> as.character() # convert to character

    html_clean <- reticulate::import("lxml.html.clean")
    content_text <- html_clean$clean_html(content_text)

    content_text <- minifyHTML::minifyHTML(content_text) # minify
  } else if (clean == "text") {
    # Strip all HTML, leave only text
    content_text <- content |>
      as.character() |>
      htm2txt::htm2txt()
  } else {
    content_text <- content |> as.character() # convert to character
  }

  extract_ai(text = content_text, cols = cols)
}
