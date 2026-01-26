pal_icon <- function(colors) {
  span(
    style = "display: inline-flex; align-items: center; gap: 0.3rem;",
    span(
      style = "display: inline-flex; width: 1.5rem; height: 0.5rem; flex-shrink: 0;",
      tagList(lapply(colors, function(col) {
        span(style = css(
          background = col,
          flex = 1,
          `aspect-ratio` = "1/1"
        ))
      }))
    )
  )
}


show_more <- function(text) {
  div(
    p(text, class = "text-expand"),
    
    if (nchar(text) > 200) {
      a(
        "Show more",
        class = "show-more",
        id = "showMore",
        onclick = HTML("
        const text = document.querySelector('.text-expand')
        
        if (text.classList.contains('expanded')) {
          text.classList.remove('expanded');
          this.textContent = 'Show more';
        } else {
          text.classList.add('expanded');
          this.textContent = 'Show less';
        }
      ")
      )
    }
  )
}


helpful <- function(widget,
                    label = NULL,
                    tip = NULL,
                    config = NULL,
                    id = NULL,
                    inline = FALSE,
                    ...) {
  div(
    id = id,
    class = if (!inline) "vertical-stack",
    span(
      class = c(if (inline) "d-inline-flex", "pseudo-label"),
      if (inline) widget,
      if (!is.null(label)) tags$b(label),
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
  span(class = cls, span(class = "divider"))
}


hover_icon <- function(default, hover, ...) {
  span(
    class = "hover-icon",
    bsicons::bs_icon(default, class = "icon-default", ...),
    bsicons::bs_icon(hover, class = "icon-hover", ...)
  )
}


callout <- function(..., type = "info", id = NULL) {
  div(
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


no <- function(number) {
  span(class = "number-circle", span(number))
}


passwordInputToggle <- function(inputId, label, value = "", width = NULL, placeholder = NULL) {
  div(
    class = c("form-group", "shiny-input-container"),
    width = width,
    tags$label(
      label,
      class = "control-label",
      class = if (is.null(label)) "shiny-label-null",
      id = paste0(inputId, "-label"),
      `for` = inputId
    ),
    div(
      class = "input-group",
      tags$input(id = inputId, type = "password", class = "form-control"),
      tags$button(
        class = "input-group-text",
        onclick = sprintf("togglePassword('%s', '%s-toggle')", inputId, inputId),
        span(
          bsicons::bs_icon("eye"),
          bsicons::bs_icon("eye-slash", display = "none"),
          id = paste0(inputId, "-toggle")
        )
      )
    )
  )
}