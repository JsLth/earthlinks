pal_icon <- function(colors) {
  shiny::span(
    style = "display: inline-flex; align-items: center; gap: 0.3rem;",
    shiny::span(
      style = "display: inline-flex; width: 1.5rem; height: 0.5rem; flex-shrink: 0;",
      shiny::tagList(lapply(colors, function(col) {
        shiny::span(style = htmltools::css(
          background = col,
          flex = 1,
          `aspect-ratio` = "1/1"
        ))
      }))
    )
  )
}


show_more <- function(text) {
  shiny::div(
    shiny::p(text, class = "text-expand"),
    shiny::a(
      "Show more",
      class = "show-more",
      id = "showMore",
      onclick = shiny::HTML("
        const text = document.querySelector('.text-expand')
        if (text.classList.contains('expanded')) {
          text.classList.remove('expanded')
          this.textContent = 'Show more';
        } else {
          text.classList.add('expanded');
          this.textContent = 'Show less';
        }
      ")
    )
  )
}


helpful <- function(widget,
                    label = NULL,
                    tip = NULL,
                    config = NULL,
                    id = NULL,
                    inline = FALSE,
                    ...) {
  shiny::div(
    id = id,
    class = if (!inline) "vertical-stack",
    shiny::span(
      class = c(if (inline) "d-inline-flex", "pseudo-label"),
      if (inline) widget,
      if (!is.null(label)) shiny::tags$b(label),
      if (!is.null(tip)) spacer(inline = inline),
      if (!is.null(tip)) tip,
      if (!is.null(config)) spacer(inline = inline),
      if (!is.null(config)) config,
      ...
    ),
    if (!inline) widget
  )
}


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


spacer <- function(inline = FALSE) {
  cls <- "spacer"
  if (inline) cls <- paste0(cls, "-inline")
  shiny::span(class = cls, shiny::span(class = "divider"))
}


hover_icon <- function(default, hover, ...) {
  shiny::span(
    class = "hover-icon",
    bsicons::bs_icon(default, class = "icon-default", ...),
    bsicons::bs_icon(hover, class = "icon-hover", ...)
  )
}


callout <- function(..., type = "info", id = NULL) {
  shiny::div(
    id = id,
    ...,
    style = "background-color: #f9f9f9;
        border-left: 4px solid #ccc;
        padding: 12px 16px;
        margin: 16px 0;
        border-radius: 4px;
        color: #333;
        font-size: 14px;"
  )
}