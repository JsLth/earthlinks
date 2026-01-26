app_sys <- function(...) {
  path <- system.file(..., package = "earthlinks")
  
  if (!nchar(path)) {
    path <- file.path(...)
  }
  
  path
}


add_external_resources <- function() {
  addResourcePath("www", app_sys("app/www"))
  tags$head(
    tags$link(rel = "shortcut icon", href = "www/favicon.ico"),
    includeCSS(app_sys("app/www/css/app.min.css")),
    tags$script(src = "www/js/app.min.js"),
    if (loadable("sever")) sever::useSever(),
    shinyjs::useShinyjs(),
    toastContainer("toast-container"),
    tags$script('
        Shiny.addCustomMessageHandler("resetFileInputHandler", function(x) {      
          var id = "#" + x + "_progress";
          var idBar = id + " .bar";  
          $(id).css("visibility", "hidden");
          $(idBar).css("width", "0%");
        });
      ')
  )
}