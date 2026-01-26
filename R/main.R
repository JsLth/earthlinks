#' EarthLinks main modules
#' @description
#' Create the UI and server function of the EarthLinks shiny app. Useful
#' if you need to embed EarthLinks into your own shiny app.
#' 
#' @param input,output,session Internal shiny arguments.
#' @returns UI and server components that can be used as arguments for
#' \code{\link[shiny]{shinyApp}}.
#' 
#' @export
#' 
#' @examples
#' shiny::shinyApp(ui = earthlinks_ui, server = earthlinks_server)
earthlinks_ui <- function() {
  bootstrapPage(
    add_external_resources(),
    layout_ui("layout"),
  )
}


#' @rdname earthlinks_ui
#' @export
earthlinks_server <- function(input, output, session) {
  if (loadable("sever")) sever::sever()
  layout_server("layout")
}