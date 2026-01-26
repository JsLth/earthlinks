#' Run EarthLinks
#' 
#' @param options See \code{\link[shiny]{shinyApp}}.
#' 
#' @returns A shiny app.
#' @export
#' 
#' @import shiny
#' 
#' @examples
#' run_app()
run_app <- function(options = list()) {
  options_cached(
    cli.progress_handlers = "cli",
    shiny.maxRequestSize = 5 * 1024 ^ 3
  )
  
  shiny::shinyApp(
    ui = earthlinks_ui,
    server = earthlinks_server,
    options = options,
    enableBookmarking = "disable"
  )
}