box::use(
  shiny[...],
  sever[sever, useSever],
  shinyFeedback[useShinyFeedback]
)

box::use(
  app/view/layout,
  
  app/logic/modals[send_info]
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    useSever(),
    useShinyFeedback(),
    layout$ui(ns("layout")),
  )
}


#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    sever()
    layout$server("layout")
    
    observe({
      send_info("test", popup = TRUE)
    })
  })
}
