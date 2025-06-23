box::use(
  shiny[...],
  shiny.blueprint[...],
  leaflet
)


ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$head(
      tags$style(HTML("
      .navbar {
        height: 60px;
        font-size: 22px;
        padding: 0 32px;
        border-bottom: 1px solid #293742;
      }"))
    ),
    
    Navbar(
      class = "navbar",
      NavbarGroup(
        align = "left",
        tags$img(src = "static/logo.png", height = "50", style = "padding:5px"),
        NavbarDivider(),
        NavbarHeading("EarthLinks")
      ),
      NavbarGroup(
        align = "right",
        Button(text = "Compendium", minimal = TRUE),
        Button(text = "R package", minimal = TRUE),
        Button(text = "GESIS", minimal = TRUE, href = "https://www.gesis.org/en/home")
      )
    ),
    
    fluidRow(
      class = "split-root",
      column(
        class = "split-left",
        width = 4,
        H2("Config panel"),
        Menu(
          MenuItem(text = "Item 1", icon = "document"),
          MenuItem(text = "Item 2", icon = "user")
        )
      ),
      column(
        class = "split-right",
        width = 8,
        leaflet$leafletOutput(ns("map"), height = "100%", width = "100%")
      )
    )
  )
}


server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$map <- leaflet$renderLeaflet({
      leaflet$leaflet() |>
        leaflet$addProviderTiles("CartoDB.DarkMatter")
    })
  })
}