box::use(
  bslib[...],
  bsicons[bs_icon],
  htmlwidgets[onRender],
  leaflet,
  sf[st_is, st_transform, st_bbox, st_drivers],
  shiny[...],
)

box::use(
  app/logic/css[tip, config, spacer],
  app/logic/modals[execute_safely],
)


theme <- bs_theme(
  primary = "#d20064",
  secondary = "#1E8CC8",
  success = "#198754",
  info = "#0dcaf0",
  warning = "#ffc107",
  danger = "#dc3545",
  base_font = "Source Sans Pro"
)


ui <- function(id) {
  ns <- NS(id)

  page_navbar(
    id = ns("navbar"),
    title = span(
      id = ns("brand"),
      tags$img(src = "static/logo.png", id = ns("logo")),
      span("EarthLinks", id = ns("title")),
    ),
    window_title = "EarthLinks",
    collapsible = FALSE,
    lang = "en",
    theme = theme,
    nav_panel_hidden(
      id = ns("nav-panel-main"),
      "Link",
      leaflet$leafletOutput(ns("map"), height = "100%")
    ),
    nav_spacer(),
    nav_item(
      a(
        href = "https://github.com/denabel/gxc",
        tooltip(
          icon("box", class = c("icon", "icon-hover"), id = ns("pkg")),
          "R package",
          placement = "left",
          options = list(offset = c(0, 13))
        )
      )
    ),
    nav_item(
      a(
        href = "https://denabel.github.io/gxc_pages/",
        tooltip(
          icon("book", class = c("icon", "icon-hover"), id = ns("cmp")),
          "Online compendium",
          placement = "left",
          options = list(offset = c(0, 13))
        )
      )
    ),
    nav_item(
      a(
        href = "https://gesis.org/en/",
        tooltip(
          img(src = "static/gesis-nobg.png", class = c("icon", "icon-hover")),
          "GESIS homepage",
          placement = "left",
          options = list(offset = c(0, 13))
        )
      )
    ),
    sidebar = sidebar(
      id = ns("sidebar"),
      open = "desktop",
      width = "25vw",

      accordion(
        id = ns("accordion"),
        open = c(ns("intro"), ns("input")),
        multiple = TRUE,

        accordion_panel(
          title = tags$b("What is EarthLinks?"),
          value = ns("intro"),
          lorem::ipsum(1, sentences = 3)
        ),

        accordion_panel(
          title = tags$b("Input data"),
          value = ns("input"),
          span(
            class = "pseudo-label",
            tags$b("Upload a GIS file"),
            spacer(),
            tip(HTML(paste(
              "You can browse your local or drag-and-drop a file that contains",
              "the spatial units that you want to link with. These spatial units",
              "can either be points or polygons. Please note that the data must be",
              "stored in a common R or GIS format. This can be .rds or",
              "<a href='https://cran.r-project.org/package=qs2'>qs</a>",
              "as well as any format that can be read by",
              "<a href='https://gdal.org/en/stable/drivers/raster/index.html'>GDAL</a>",
              "(e.g., SHP, GeoJSON, GeoPackage)."
            ))),
            spacer(),
            config(
              div(
                div(
                  class = "code-input",
                  textInput(
                    ns("date_column"),
                    label = "Which column contains date information?",
                    value = "date"
                  )
                ),
                div(
                  class = "code-input",
                  textInput(
                    ns("layer"),
                    label = "Optionally, a layer name to read"
                  )
                ),
                selectInput(
                  ns("driver"),
                  label = "What driver to use for reading?",
                  choices = c("Guess the driver", st_drivers()$name)
                )
              )
            )
          ),
          fileInput(
            ns("file"),
            label = NULL
          )
        )
      )
    )
  )
}


server <- function(id) {
  moduleServer(id, function(input, output, session) {
    .data <- reactive({
      req(input$file)
      path <- input$file$datapath

      if (identical(tools::file_ext(path), "rds")) {
        readRDS(path)
      } else {
        sf::read_sf(path)
      }
    })


    output$map <- leaflet$renderLeaflet({
      leaflet$leaflet(options = leaflet$leafletOptions(zoomControl = FALSE)) |>
        leaflet$addProviderTiles("CartoDB.DarkMatter", group = "Dark") |>
        leaflet$addProviderTiles("CartoDB.Positron", group = "Light") |>
        leaflet$addLayersControl(baseGroups = c("Light", "Dark")) |>
        leaflet$setView(14, 48, 5) |>
        onRender(
          "function(el, x) {
            L.control.zoom({
              position: 'bottomleft'
            }).addTo(this);
          }"
        )
    })


    observe({
      .data <- st_transform(.data(), 4326)
      bbox <- st_bbox(.data)
      proxy <- leaflet$leafletProxy("map", data = .data)

      leaflet$flyToBounds(
        proxy,
        lng1 = bbox[["xmin"]],
        lat1 = bbox[["ymin"]],
        lng2 = bbox[["xmax"]],
        lat2 = bbox[["ymax"]]
      )

      if (all(st_is(.data, c("POLYGON", "MULTIPOLYGON")))) {
        leaflet$addPolygons(
          proxy,
          weight = 1,
          color = "black",
          fill = TRUE,
          fillOpacity = 0,
          opacity = 0.5,
          highlightOptions = leaflet$highlightOptions(
            weight = 2,
            color = "black",
            opacity = 0.5,
            fillOpacity = 0.5,
            bringToFront = TRUE,
            sendToBack = TRUE
          )
        )
      } else if (all(st_is(.data, c("POINT", "MULTIPOINT")))) {
        leaflet$addCircleMarkers(
          proxy,
          weight = 1,
          color = "black",
          opacity = 0.5
        )
      }
    })
  })
}
