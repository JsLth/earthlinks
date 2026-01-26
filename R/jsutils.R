toastContainer <- function(id = NULL) {
  shiny::div(id = id, class = c("toast-container", "position-absolute", "p-3"))
}


toast <- function(message,
                  title = NULL,
                  position = "topcenter",
                  delay = 5000,
                  type = "info",
                  layout = c("standard", "minimal", "footer"),
                  autohide = TRUE,
                  animation = TRUE,
                  id = NULL,
                  session = shiny::getDefaultReactiveDomain()) {
  layout <- match.arg(layout)

  position = switch(
    position,
    topleft = "top-0 start-0",
    topcenter = "top-0 start-50 translate-middle-x",
    topright = "top-0 end-0",
    middleleft = "top-50 start-0 translate-middle-y",
    middlecenter = "top-50 start-50 translate-middle",
    middleright = "top-50 end-0 translate-middle-y",
    bottomleft = "bottom-0 start-0",
    bottomcenter = "bottom-0 start-50 translate-middle-x",
    bottomright = "bottom-0 end-0"
  )
  
  icon <- switch(
    type,
    info = bsicons::bs_icon("info-circle-fill", class = "text-info"),
    success = bsicons::bs_icon("check-circle-fill", class = "text-success"),
    danger = bsicons::bs_icon("x-circle-fill", class = "text-danger"),
    warning = bsicons::bs_icon("exclamation-circle-fill", class = "text-warning")
  )
  
  title <- title %||% switch(
    type,
    info = "Information",
    success = "Success!",
    danger = "Error!",
    warning = "Warning!"
  )
  
  opts <- list(
    message = as.character(message),
    title = title,
    icon = icon,
    position = position,
    delay = delay,
    type = type,
    autohide = autohide,
    animation = animation,
    layout = layout,
    id = id
  )
  
  session$sendCustomMessage("show-toast", opts)
}


remove_toast <- function(id, session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("remove-toast", id)
}


liveCounter <- function(start = Sys.time(), id = NULL) {
  tags$div(
    id = id,
    `data-start` = format(start, "%Y-%m-%dT%H:%M:%S%z"),
    class = "live-counter"
  )
}


remove_tooltip <- function(id, session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("remove-tooltip", id)
}
