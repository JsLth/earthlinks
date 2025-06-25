box::use(
  htmltools[...],
  shiny[...]
)


#' Execute expression safely in server
#' @description
#' Errors in a server environment usually lead to the Shiny app crashing. To
#' prevent this, `execute_safely` catches errors and displays a user message
#' instead. This function is a modified version of
#' `shinyWidgets::execute_safely`. With other defaults, different formatting,
#' and the ability to handle silent expressions.
#'
#' @param expr Expression to evaluate
#' @param title Title to display
#' @param message Message to display
#' @param stopOperation Whether to stop the reactive chain after showing the
#' error message.
#' @param session Session object.
#'
#' @noRd
execute_safely <- function(expr,
                           title = "Oops!",
                           message = NULL,
                           disrupt = FALSE,
                           stopOperation = TRUE,
                           session = getDefaultReactiveDomain()) {
  message <- message %||% HTML(paste0(
    "Something went wrong! If this keeps happening, consider ",
    "opening a <a href='https://github.com/JsLth/gretan/issues'>Github ",
    "issue</a> or email the tool maintainer (",
    "<a href = 'mailto:jonas.lieth@gesis.org'>jonas.lieth@gesis.org</a>)."
  ))

  tryCatch(
    expr = {
      # In case of warning, return expression
      withCallingHandlers(
        expr = expr,
        warning = function(w) {
          shinyFeedback::showToast(
            type = "warning",
            message = w$message,
            title = "Warning!",
            session = session
          )
        }
      )
    },
    error = function(e) {
      # Stop without error message
      if (inherits(e, "shiny.silent.error")) req(FALSE)

      send_error(div(
        style = "text-align: left",
        message,
        br(), br(),
        "Error details:", br(),
        rlang_error_to_html(e, warn = FALSE)
      ), session = session, title = title)
      
      # Send error message and then stop
      if (stopOperation) req(FALSE)
      
      return(e)
    }
  )
}


# Convert ANSI formatting of rlang errors to HTML
rlang_error_to_html <- function(e, ...) {
  e <- fansi::to_html(format(e), ...)
  tags$pre(HTML(gsub("\n", "<br>", e)))
}


# Send info message
send_info <- function(text,
                      title = "Info",
                      btn_colors = "#5E81AC",
                      btn_labels = "Got it!",
                      closeOnClickOutside = FALSE,
                      ...,
                      session = getDefaultReactiveDomain()) {
  .dots <- list(...)
  btn_colors <- .dots$btn_colors %||% "#FFCA2B"
  btn_labels <- .dots$btn_labels %||% "Got it!"

  shiny::showModal(shiny::modalDialog(
    text,
    title = title,
    size = "s"
  ))
}

# Send error message
send_error <- function(text,
                       title = "Oops!",
                       btn_colors = "#BF616A",
                       btn_labels = "Got it!",
                       ...,
                       session = getDefaultReactiveDomain()) {
  .dots <- list(...)
  btn_colors <- .dots$btn_colors %||% "#FFCA2B"
  btn_labels <- .dots$btn_labels %||% "Got it!"
  
  shiny::showModal(shiny::modalDialog(
    text,
    title = title,
    size = "s"
  ))
}


send_warning <- function(text,
                         title = "Attention!",
                         btn_colors = "#FFCA2B",
                         btn_labels = "Got it!",
                         ...,
                         session = getDefaultReactiveDomain()) {
  shinyWidgets::sendSweetAlert(
    title = title,
    text = text,
    type = "warning",
    html = TRUE,
    btn_colors = btn_colors,
    btn_labels = btn_labels,
    closeOnClickOutside = FALSE,
    ...
  )
}