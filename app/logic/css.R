tip <- function(text, id = NULL, title = "Help", ...) {
  bslib::popover(
    hover_icon("question-circle", "question-circle-fill", title = "Further details"),
    title = title,
    text,
    ...
  )
}


config <- function(text, id = NULL, title = "Options", ...) {
  bslib::popover(
    hover_icon("gear", "gear-fill", title = "Further options"),
    title = title,
    text,
    ...
  )
}


spacer <- function() {
  shiny::span(class = "spacer", shiny::span(class = "divider"))
}


hover_icon <- function(default, hover, ...) {
  shiny::span(
    class = "hover-icon",
    bsicons::bs_icon(default, class = "icon-default", ...),
    bsicons::bs_icon(hover, class = "icon-hover", ...)
  )
}
