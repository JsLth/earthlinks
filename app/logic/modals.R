box::use(
  htmltools[...],
  shiny[...]
)


box::use(
  app/logic/jsutils[toast],
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
                           stopOperation = TRUE,
                           error_fun = NULL,
                           toast = FALSE,
                           ...,
                           session = getDefaultReactiveDomain()) {
  message <- message %||% HTML(paste0(
    "Something went wrong! If this keeps happening, consider ",
    "opening a <a href='https://github.com/jslth/earthlinks/issues'>Github ",
    "issue</a> or email the tool maintainer (",
    "<a href = 'mailto:jonas.lieth@gesis.org'>jonas.lieth@gesis.org</a>)."
  ))

  tryCatch(
    expr = {
      # In case of warning, return expression
      withCallingHandlers(
        expr = expr,
        warning = function(w) {
          toast(message = w$message, type = "warning", session = session)
        }
      )
    },
    error = function(e) {
      # Stop without error message
      if (inherits(e, "shiny.silent.error")) req(FALSE)

      if (is.null(error_fun)) {
        if (!toast) {
          traceback <- rlang::trace_back()
          send_error(div(
            style = "text-align: left",
            message,
            ...,
            br(), br(),
            "Error details:", br(),
            tags$pre(cli_to_html(e, warn = FALSE), style = "max-height: 20vh"),
            if (length(traceback$call)) {
              traceback_fmt <- paste(format(traceback), collapse = "\n")
              tags$details(
                tags$summary("Traceback"),
                tags$pre(cli_to_html(traceback_fmt, warn = FALSE), style = "max-height: 20vh")
              )
            }
          ), session = session, title = title, size = "l")
        } else {
          toast(
            message = message,
            title = title,
            delay = 10000,
            type = "danger"
          )
        }

      } else {
        error_fun(e)
      }
      
      # Send error message and then stop
      if (stopOperation) req(FALSE)
      
      return(e)
    }
  )
}


with_info <- function(expr, session = getDefaultReactiveDomain()) {
  withCallingHandlers(
    expr,
    message = function(m) {
      toast(
        message = cli_to_html(m),
        type = "info",
        title = "Progress update"
      )
    }
  )
}


# Convert ANSI formatting of rlang errors to HTML
cli_to_html <- function(e, ...) {
  e <- fansi::to_html(format(e), ...)
  HTML(gsub("\n", "<br>", e))
}


# Send info message
send_info <- function(text,
                      title = "Info",
                      btn_type = "outline-secondary",
                      btn_label = "Got it!",
                      size = "m",
                      ...,
                      session = getDefaultReactiveDomain()) {
  shiny::showModal(shiny::modalDialog(
    text,
    title = title,
    size = size,
    footer = modalButton(btn_label, type = btn_type)
  ))
}

# Send error message
send_error <- function(text,
                       title = "Oops!",
                       btn_type = "danger",
                       btn_label = "Got it!",
                       size = "m",
                       ...,
                       session = getDefaultReactiveDomain()) {
  shiny::showModal(shiny::modalDialog(
    text,
    title = title,
    size = size,
    footer = modalButton(btn_label, type = btn_type)
  ))
}


send_warning <- function(text,
                         title = "Attention!",
                         btn_type = "warning",
                         btn_label = "Got it!",
                         size = "m",
                         ...,
                         session = getDefaultReactiveDomain()) {
  shiny::showModal(shiny::modalDialog(
    text,
    title = title,
    size = size,
    footer = modalButton(btn_label, type = btn_type)
  ))
}


modalButton <- function(label, icon = NULL, type = "primary") {
  tags$button(
    type = "button",
    class = c("btn", paste0("btn-", type)),
    `data-dismiss` = "modal",
    `data-bs-dismiss` = "modal",
    icon, label
  )
}