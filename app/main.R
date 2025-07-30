box::use(
  shiny[...],
  sever[sever, useSever],
  shinylogs[use_tracking],
  shinyjs[useShinyjs],
  
)

box::use(
  app/view/layout,
  
  app/logic/modals[send_info],
  app/logic/jsutils[toastContainer],
  
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    useSever(),
    useShinyjs(),
    if (getOption("earthlinks_debug", FALSE)) use_tracking(),
    #useShinyFeedback(),
    toastContainer("toast-container"),
    layout$ui(ns("layout")),
  )
}


#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    sever()
    layout$server("layout")
  })
}
