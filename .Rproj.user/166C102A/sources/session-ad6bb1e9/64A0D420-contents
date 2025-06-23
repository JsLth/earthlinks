box::use(
  shiny[...],
)

box::use(
  app/view/blueprint,
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    blueprint$ui(ns("blueprint"))
  )
}


#' @export
server <- function(id) {
  ns <- NS(id)
  moduleServer(id, function(input, output, session) {
    blueprint$server(ns("blueprint"))
  })
}
