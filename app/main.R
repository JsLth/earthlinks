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
    tags$head(
      useSever(),
      useShinyjs(),
      if (getOption("earthlinks_debug", FALSE)) use_tracking(),
      #useShinyFeedback(),
      toastContainer("toast-container"),
      tags$script('
        Shiny.addCustomMessageHandler("resetFileInputHandler", function(x) {      
          var id = "#" + x + "_progress";
          var idBar = id + " .bar";  
          $(id).css("visibility", "hidden");
          $(idBar).css("width", "0%");
        });
      ')
    ),
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
