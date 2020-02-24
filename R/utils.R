# error message
error_msg <- "Error in feed parse; please check URL.\n
  If you're certain that this is a valid rss feed,
  please file an issue at https://github.com/RobertMyles/tidyRSS/issues.
  Please note that the feed may also be undergoing maintenance."

# set user agent
set_user <- function(config) {
  if (length(config) == 0 | length(config$options$`user-agent`) == 0) {
    ua <- user_agent("http://github.com/robertmyles/tidyRSS")
    return(ua)
  } else {
    return(config)
  }
}

# check if JSON or XML
# simply reads 'content-type' of response to check type.
# if contains both atom & rss, prefers rss
type_check <- function(response) {
  content_type <- response$headers$`content-type`
  typ <- case_when(
    grepl(x = content_type, pattern = "atom") ~ "atom",
    grepl(x = content_type, pattern = "xml") ~ "rss",
    grepl(x = content_type, pattern = "rss") ~ "rss",
    grepl(x = content_type, pattern = "json") ~ "json",
    TRUE ~ "unknown"
  )
  return(typ)
}

# geocheck - warning about geo feeds
geocheck <- function(x) {
  gcheck <- grepl("http://www.georss.org/georss", xml_attr(x, "xmlns:georss"))
  if (isTRUE(geocheck)) {
    message("Parsing feeds with geographic information (geoRSS, geoJSON etc.) is
deprecated in tidyRSS as of version 2.0.0. The geo-fields in this feed will be ignored.
If you would like to fetch this information, try the tidygeoRSS package:
https://github.com/RobertMyles/tidygeoRSS")
  }
}

# default value for empty elements
def <- NA_character_

# time formats
formats <- c("a d b Y H:M:S z", "a, d b Y H:M z",
             "Y-m-d H:M:S z", "d b Y H:M:S",
             "d b Y H:M:S z", "a b d H:M:S z Y",
             "a b dH:M:S Y")

#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

# remove all NA columns
no_na <- function(x) all(!is.na(x))

# remove nchar < 1 columns
no_empty_char <- function(x) all(!nchar(x) < 1)

# return if exists
return_exists <- function(x) {
  if (!is.null(x)) {
    out <- x
  } else {
    out <- NA
  }
  out
}

# delist list-columns of one element
delist <- function(x) {
  if (length(x) == 1) {
    x <- unlist(x)
  }
}
# parse dates
date_parser <- function(df, kol) {
  column <- enquo(kol) %>% as_name()
  if (has_name(df, column)) {
    df <- df %>% mutate({{ kol }} := anytime({{ kol }}))
  }
  df
}

# clean HTML tags
# from https://stackoverflow.com/a/17227415/4296028
# removal != parsing!
cleanFun <- function(htmlString) {
  return(gsub("<.*?>", "", htmlString))
}
