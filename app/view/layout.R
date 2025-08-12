box::use(
  bslib[...],
  bsicons[bs_icon],
  htmlwidgets[onRender],
  leaflet,
  sf,
  shiny[...],
  shinyWidgets[pickerInput, airDatepickerInput],
  giscoR[gisco_get_nuts],
  countrycode[countrycode],
  
)

box::use(
  app/logic/widgets,
  app/logic/modals[execute_safely, with_info, send_error, send_info],
  app/logic/codes[search_param],
  app/logic/utils[...],
  app/logic/jsutils[toast, remove_toast, liveCounter],
  app/logic/enum[palettes, units],
  
)

options(cli.progress_handlers = "cli")

indicators <- c(
  "2 metre temperature" = "2m_temperature",
  "Total precipitation" = "total_precipitation",
  "10 metre U wind component" = "10m_u_component_of_wind",
  "10 metre V wind component" = "10m_v_component_of_wind",
  "Leaf area index, high vegetation" = "leaf_area_index_high_vegetation",
  "Leaf area index, low vegetation" = "leaf_area_index_low_vegetation",
  "Snowfall" = "snowfall",
  "Total cloud cover" = "total_cloud_cover",
  "10 metre wind speed" = "10m_wind_speed"
)


theme <- bs_theme(
  primary = "#d20064",
  secondary = "#1E8CC8",
  success = "#198754",
  info = "#0dcaf0",
  warning = "#ffc107",
  danger = "#dc3545",
  base_font = "Source Sans Pro"
) |>
  # modal theming that aligns more closely with BS5 docs
  bs_add_rules("
    /* make toast background opaque */
    .toast {
      --bs-toast-header-bg: rgba(var(--bs-body-bg-rgb), 1) !important;
      --bs-toast-bg: rgba(var(--bs-body-bg-rgb), 1) !important;
    }
    
    /* enforce denser modal styling */
    .modal-footer, .modal-body {
      padding: calc((var(--bs-modal-padding) - var(--bs-modal-footer-gap) * .5)) !important
    }
    
    .modal-content {
      border-width: var(--bs-modal-border-width, 1px);
      border-color: var(--bs-modal-border-color, rgba(0, 0, 0, 0.2));
      border-radius: var(--bs-modal-border-radius, 0.3rem);
    }
    
    .modal {
      --bs-modal-header-border-width: 1px;
      --bs-modal-header-border-color: #dee2e6;
      --bs-modal-header-padding: 0.5rem 1rem;
      --bs-modal-inner-border-radius: calc(0.3rem - 1px);
      --bs-modal-border-width: 1px;
      --bs-modal-border-color: rgba(0, 0, 0, 0.2);
      --bs-modal-border-radius: 0.3rem;
      --bs-modal-width: 700px !important;
    }

    /* remove button borders */
    .accordion {
      --bs-accordion-btn-focus-box-shadow: rgba(0, 0, 0, 0);
    }

    .btn {
      --bs-btn-box-shadow: rgba(0, 0, 0, 0);
      --bs-btn-focus-box-shadow: rgba(0, 0, 0, 0);
    }

    .btn-close {
      --bs-btn-close-focus-shadow: rgba(0, 0, 0, 0)
    }
    
    .vscomp-toggle-button {
      border: var(--bs-border-width) solid #8D959E !important;
      border-radius: var(--bs-border-radius);
      background-color: var(--bs-body-bg) !important;
      transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
      background-clip: padding-box;
      color: var(--bs-body-color) ;
      line-height: 1.5;
      font-weight: 400;
    }
    
    .vscomp-wrapper:focus .vscomp-toggle-button {
      color: var(--bs-body-color);
      background-color: var(--bs-body-bg) !important;
      border-color: #e980b2 !important;
      outline: 0;
      box-shadow: 0 0 0 .25rem rgba(210, 0, 100, 0.25) !important;
    }
  ")


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
    
    # Navbar ----
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
    
    # Sidebar ----
    sidebar = sidebar(
      id = ns("sidebar"),
      open = "desktop",
      width = "25vw",

      accordion(
        id = ns("accordion"),
        open = c(ns("intro"), ns("input")),
        multiple = TRUE,

        ## What is EarthLinks? ----
        accordion_panel(
          title = tags$b("What is EarthLinks?"),
          value = ns("intro"),
          lorem::ipsum(1, sentences = 3)
        ),

        ## Input data ----
        accordion_panel(
          title = tags$b("Input data"),
          value = ns("input"),
          
          ### File input ----
          widgets$helpful(
            fileInput(
              ns("file"),
              label = NULL
            ),
            label = "Upload a GIS file",
            tip = widgets$tip(HTML(paste(
              "You can browse your local or drag-and-drop a file that contains",
              "the spatial units that you want to link with. These spatial units",
              "can either be points or polygons. Please note that the data must be",
              "stored in a common R or GIS format. This includes:<br>
              <ul>
                <li><b>R files:</b> rds, <a href='https://cran.r-project.org/package=qs2'>qs</a></li>
                <li><b>Stata or SPSS files:</b> dta, sav, por
                <li><b>Geospatial files:</b> shp, geojson, gpkg, and others
              </ul>"
            ))),
            config = widgets$config(
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
                  choices = c("Guess the driver", sf$st_drivers()$name)
                )
              )
            )
          ),
          
          ### Example data ----
          widgets$helpful(
            actionButton(
              ns("example_data"),
              label = tagList(
                bsicons::bs_icon("file-earmark-spreadsheet"),
                "Load example data"
              )
            ),
            label = "Just want to look around? No worries!",
            tip = widgets$tip(HTML(
              "By clicking on this button, you will load pre-processed
              example data from the <a href='https://www.europeansocialsurvey.org/'>
              European Social Survey</a> (ESS) that you can use to try out
              the functions of this app. You can always go back to load
              your own dataset by selecting a file."
            ))
          ),
          
          hr(style = "margin-top: 0rem; margin-bottom: 1rem;"),
          
          ### Non-GIS file specs ----
          shinyjs::hidden(
            div(
              id = ns("non_gis_file_container"),
              
              #### Coordinates ----
              widgets$helpful(
                selectizeInput(
                  ns("non_gis_geometry"),
                  choices = list(),
                  multiple = TRUE,
                  label = NULL,
                  options = list(
                    maxItems = 2,
                    hideSelected = TRUE
                  )
                ),
                label = "Which columns contain coordinates?",
                tip = widgets$tip(HTML(
                  "It seems you have loaded a <b>non-spatial file</b>, i.e., .csv,
                  or a file from SPSS or Stata. While these files can carry
                  geo-information in the form of points, you need to <b>explicitly
                  specify</b> which columns represent the coordinates of these points.
                  <br><br>
                  Please select the two column names that contain the X and
                  Y coordinates, respectively (or longitude and latitude)."
                ))
              ),
              
              #### CRS ----
              widgets$helpful(
                selectizeInput(
                  ns("non_gis_crs"),
                  choices = list(
                    "WGS84 (4326)" = "4326",
                    "Web Mercator (3857)" = "3857",
                    "ETRS89 (4258)" = "4258",
                    "LAEA Europe (3035)" = "3035"
                  ),
                  label = NULL,
                  options = list(
                    create = TRUE,
                    maxItems = 1,
                    placeholder = "Select or type a CRS",
                    createFilter = I("function(input) { 
                      return /^\\d+$/.test(input.trim()); 
                    }"),
                    render = I("{
                      option: function(data, escape) {
                        return '<div>' + escape(data.text || data.label || data.value) + '</div>';
                      },
                      item: function(data, escape) {
                        return '<div>' + escape(data.text || data.label || data.value) + '</div>';
                      }
                    }")
                  )
                ),
                label = "Select a reference system (CRS)",
                tip = widgets$tip(HTML("
                  A <a href='https://denabel.github.io/gxc_pages/crs.html#transformations-conversions'>
                  Coordinate Reference System (CRS)</a> is a set of rules
                  and measurements that tells you exactly where something is
                  on Earth. You need to specify a CRS because without it,
                  coordinates are just meaningless digits. A CRS
                  gives those numbers <b>geographic meaning</b> allowing you to
                  accurately locate places on a map.
                  <br><br>
                  A CRS is usually represented by a so-called <b>EPSG code</b>.
                  You can select one of four common EPSG codes from the list or
                  provide your own. Just remove the default code and type in your
                  own. If you are unsure which CRS to select,
                  ask your data provider; they can tell you.")
              ))
            )
          ),
          
          ### Flat date ----
          shinyjs::hidden(
            widgets$helpful(
              id = ns("flat_date_container"),
              airDatepickerInput(
                ns("flat_date"),
                label = NULL,
                range = TRUE,
                addon = "none",
                view = "years",
                update_on = "close"
              ),
              label = "Select a time frame that describes your data",
              tip = widgets$tip(tagList(
                p(
                  "The dataset you have loaded does not contain a date vector
                  in your specified date field. You can choose to either:"
                ),
                tags$ul(
                  tags$li("Specify a flat date for all data points using this input"),
                  tags$li("Specify the column name where your time data is stored. Click the", bsicons::bs_icon("gear"), "icon next to the data input to specify a date column.")
                )
              ))
            )
          ),
          
          ### Showcase column ----
          shinyjs::hidden(
            widgets$helpful(
              id = ns("showcase_col_container"),
              shinyWidgets::virtualSelectInput(
                ns("showcase_col"),
                label = NULL,
                choices = list(),
                search = TRUE
              ),
              label = "Which column do you want to show on the map?",
              tip = widgets$tip(HTML(
                "Your selected dataset contains multiple features but only
                  one of them can be displayed on the map. This step lets
                  you select a column from your dataset to display on the map
                  alongside your linked earth observation data."
              )),
              config = widgets$config(
                div(
                  div(
                    textInput(
                      ns("showcase_desc"),
                      label = "Enter a title for the column",
                      placeholder = "e.g., Gross Domestic Product"
                    )
                  ),
                  div(
                    textInput(
                      ns("showcase_unit"),
                      label = "Is there a unit that describes the feature?",
                      placeholder = "e.g., euro per capita"
                    )
                  ),
                  shinyWidgets::virtualSelectInput(
                    ns("showcase_palette"),
                    label = "What color palette should the feature be shown in?",
                    choices = shinyWidgets::prepare_choices(
                      palettes,
                      label = palette,
                      value = palette,
                      group_by = type
                    ),
                    selected = "Viridis",
                    search = TRUE,
                    html = TRUE,
                    labelRenderer = "renderPalette"
                  )
                )
              )
            )
          ),
          
          ### Data details ----
          shinyjs::hidden(
            card(
              max_height = 250,
              id = ns("data_details_container"),
              style = "margin-top: 20px;",
              card_header(
                span(bsicons::bs_icon("bar-chart-fill"), "Dataset details")
              ),
              uiOutput(ns("data_details"))
            )
          )
        ),
        
        ## Indicator selection ----
        accordion_panel(
          title = tags$b("Indicator selection"),
          value = ns("indicator_select"),
          
          # widgets$helpful(
          #   pickerInput(
          #     ns("data_provider"),
          #     choices = list(
          #       "Copernicus" = "ecmwfr"
          #     )
          #   ),
          #   label = tags$b("Select a data provider"),
          #   tip = widgets$tip("Test")
          # )
          
          ### Time level ----
          widgets$helpful(
            radioButtons(
              ns("time_level"),
              label = NULL,
              choices = list(
                "Daily" = "daily",
                "Monthly" = "monthly"
              )
            ),
            label = "Select a time aggregation level",
            tip = widgets$tip(
              div(
                "This option lets you choose how the climate statistics are
                grouped over time",
                tags$ul(
                  tags$li(tags$b("Daily:"), paste(
                    "Data is shown for each individual day. Use this when",
                    "you need detailed, day-by-day variation"
                  )),
                  tags$li(tags$b("Monthly:"), paste(
                    "Data is averaged or summed over each month. This is",
                    "useful for spotting longer-term trends and reducing",
                    "daily noise."
                  ))
                )
              )
            )
          ),
          
          ### ERA-Land ----
          widgets$helpful(
            checkboxInput(ns("land"), label = NULL, value = TRUE, width = "auto"),
            label = "Only include land areas?",
            tip = widgets$tip(div(HTML(
              "Tick this box to use land-only data. When selected, the data
              comes from ERA5-Land, which provides higher-resolution climate
              information from <b>land surfaces only</b>. Otherwise, the data
              includes both <b>land and ocean areas</b> using the standard
              ERA5 dataset."
            ))),
            inline = TRUE
          ),
          
          ### Indicator ----
          widgets$helpful(
            selectInput(
              ns("indicator"),
              label = NULL,
              choices = unname(invert(indicators)[
                gxc:::allowed_indicators_by_catalogue$`derived-era5-land-daily-statistics`
              ])
            ),
            label = "Select an indicator",
            tip = widgets$tip(div(HTML(
              "Select the earth observation indicator you want to link. The
              available indicators you can select depend on the choices in
              data provider, data catalogue and other options above.<br>
              <i>Note:</i> Some indicators are averaged over time (e.g.,
              temperature), while others are summed (e.g., precipitation),
              depending on their nature and the selected time aggregation
              level."
            )))
          ),
          
          uiOutput(ns("indicator_desc"))
        ),
        
        ## Finalize ----
        accordion_panel(
          title = tags$b("Finalize"),
          value = ns("finalize"),
          bslib::input_task_button(
            ns("do_link"),
            label = "Download and link",
            icon = bsicons::bs_icon("lightning-charge-fill"),
            label_busy = "Linking...",
            type = "default"
          )
        )
      )
    )
  )
}


server <- function(id) {
  moduleServer(id, function(input, output, session) {
    cli::cli_inform("test")
    
    toast(
      "Thanks for using EarthLinks!",
      title = "App successfully started",
      type = "success",
      delay = 6000
    )
    
    parsed <- reactiveVal(NULL) # parsed file object, yet to be cleaned
    .data <- reactiveVal(NULL) # data ready to be linked
    dates <- reactiveVal(NULL) # date information from .data()
    example_data_loaded <- FALSE
    
    
    # Input data ----
    observe(execute_safely({
      path <- input$file$datapath

      ext <- tools::file_ext(path)
      new <- switch(
        ext,
        rds = readRDS(path),
        qs = qs2::qs_read(path),
        csv = utils::read.csv(path),
        sav = haven::read_sav(path),
        por = haven::read_por(path),
        dta = haven::read_dta(path),
        execute_safely(
          sf$read_sf(path),
          toast = TRUE,
          message = HTML(sprintf("Failed to read the provided file. Make sure to load
            a supported file that contains geo-information. Click on %s
            if you don't know what this means.", bsicons::bs_icon("question-circle")))
        )
      )
      
      new <- if (ext %in% "rds") {
        new <- readRDS(path)
      } else if (ext %in% "qs") {
        qs2::qs_read(path)
      } else if (ext %in% "csv") {
        utils::read.csv(path)
      } else if (ext %in% c("sav", "por")) {
        haven::read_spss(path)
      } else if (ext %in% "dta") {
        haven::read_stata(path)
      } else {
        sf$read_sf(path)
      }
      
      example_data_loaded <<- FALSE
      parsed(new)
    })) |>
      bindEvent(input$file)
    
    
    # Example data ----
    observe(execute_safely({
      new <- utils::read.csv("app/data/ESS11-subset.csv")[c("cntry", "wrclmch")]
      new <- stats::aggregate(wrclmch ~ cntry, new, mean)
      countries <- unique(new$cntry)
      geom <- gisco_get_nuts(
        year = "2024",
        resolution = "60",
        spatialtype = "RG",
        nuts_level = "0",
        country = countrycode(countries, origin = "iso2c", destination = "iso3c")
      )["geo"]
      new <- merge(new, geom, by.x = "cntry", by.y = "geo")
      new <- sf$st_as_sf(new)
      new <- sf$st_transform(new, 4326)
      new <- suppressWarnings(sf$st_intersection(
        new,
        sf$st_as_sfc(sf$st_bbox(c(
          xmin = -25,
          ymin = 30,
          xmax = 40,
          ymax = 70
        ), crs = sf$st_crs(4326)))
      ))
      names(new) <- c("country", "climate_concern", "geometry")
      new$date <- as.POSIXct("2023-01-01")
      example_data_loaded <<- TRUE
      parsed(new)
      .data(new)
    })) |>
      bindEvent(input$example_data)

    
    # Reset file input ----
    observe({
      session$sendCustomMessage(type = "resetFileInputHandler", session$ns("file"))
    }) |>
      bindEvent(input$example_data)
    
    
    # Non-GIS - show/hide ----
    observe({
      ext <- tools::file_ext(input$file$datapath)
      if (any(ext %in% c("csv", "dta", "sav", "por")) && !example_data_loaded) {
        shinyjs::show("non_gis_file_container", anim = TRUE)
        toast(
          sprintf(
            "You loaded a %s file. We tried to automatically infer the
            necessary geo-information. Please check if this is correct
            and provide details on coordinates and CRS if necessary.", ext
          ),
          title = "Details needed!",
          type = "warning",
          delay = 10000
        )
        
        selected <- NULL
        if (all(c("lon", "lat") %in% colnames(parsed()))) {
          selected <- c("lon", "lat")
        }
        
        if (all(c("x", "y") %in% colnames(parsed()))) {
          selected <- c("x", "y")
        }
        
        if (all(c("X", "Y") %in% colnames(parsed()))) {
          selected <- c("X", "Y")
        }
        
        freezeReactiveValue(input, "non_gis_geometry")
        updateSelectizeInput(
          session = session,
          "non_gis_geometry",
          choices = colnames(parsed()),
          selected = selected
        )
        
        
      } else {
        shinyjs::hide("non_gis_file_container", anim = TRUE)
      }
    }) |>
      bindEvent(parsed())
    
    
    # Non-GIS - suggest CRS ----
    observe({
      parsed <- parsed()
      x <- parsed[[input$non_gis_geometry[[1]]]]
      y <- parsed[[input$non_gis_geometry[[2]]]]
      
      if (all(between(x, -180, 180) & between(y, -90, 90))) {
        selected <- 4326
      } else {
        selected <- 3035
      }
      
      freezeReactiveValue(input, "non_gis_crs")
      updateSelectizeInput(session = session, "non_gis_crs", selected = selected)
    }) |>
      bindEvent(req(
        parsed(),
        input$non_gis_geometry,
        length(input$non_gis_geometry) == 2
      ))
    
    
    # Non-GIS - convert ----
    observe({
      req(length(input$non_gis_geometry) == 2, input$non_gis_crs)
      new_sf <- sf$st_as_sf(
        parsed(),
        coords = unlist(input$non_gis_geometry, use.names = FALSE),
        crs = as.numeric(input$non_gis_crs)
      )
      attr(new_sf, "bbox") <- sf$st_bbox(new_sf)
      
      if (is_crs_mismatch(new_sf)) {
        toast(
          sprintf(
            "The provided coordinates are incompatible with the specified
              coordinate reference system (EPSG:%s).", input$non_gis_crs
          ),
          title = "Invalid CRS selected",
          type = "danger",
          delay = 10000
        )
        req(FALSE)
      }
      
      .data(new_sf)
    })
    
    
    # Flat date - show/hide ----
    observe({
      if (!input$date_column %in% names(parsed()) && !example_data_loaded) {
        shinyjs::show("flat_date_container", anim = TRUE)
      } else {
        shinyjs::hide("flat_date_container", anim = TRUE)
      }
    }) |>
      bindEvent(parsed())
    
    
    # Flat date - merge ----
    observe({
      if (input$date_column %in% names(parsed())) {
        dates(parsed()[[input$date_column]])
      } else {
        dates(input$flat_date)
      }
    }) |>
      bindEvent(.data() %||% parsed())
    
    
    # Showcase - show/hide ----
    observe({
      req(.data())
      if (ncol(.data()) > 2) {
        shinyWidgets::updateVirtualSelect(
          "showcase_col",
          choices = setdiff(names(.data()), "geometry")
        )
        shinyjs::show("showcase_col_container", anim = TRUE)
      } else {
        shinyjs::hide("showcase_col_container", anim = TRUE)
      }
    })
    
    
    # Data details - show ----
    observe({
      req(.data() %||% parsed(), dates())
      shinyjs::show("data_details_container", anim = TRUE)
    })
    
    
    # Data details - render ----
    output$data_details <- renderUI({
      start <- min(as_date(dates()))
      end <- max(as_date(dates()))

      details <- list(
        start = start,
        end = end,
        extent = format_duration(end - start),
        variables = ncol(.data() %||% parsed()),
        records = nrow(.data() %||% parsed())
      )
      
      div(
        style = htmltools::css(
          display = "flex",
          `align-items` = "center",
        ),
        div(
          style = "flex: 1;",
          div(
            style = htmltools::css(
              display = "grid",
              `grid-template-columns` = "repeat(auto-fit, minmax(200px, 1fr))"
            ),
            div(
              style = "display: flex; align-items: center; gap: 8px;",
              bsicons::bs_icon("calendar-range"),
              format_daterange(details$start, details$end)
            ),
            div(
              style = "display: flex; align-items: center; gap: 8px;",
              bsicons::bs_icon("hourglass-split"),
              details$extent
            ),
            div(
              style = "display: flex; align-items: center; gap: 8px;",
              bsicons::bs_icon("list-ul"),
              sprintf(
                "%s record%s",
                details$records,
                ifelse(details$records == 1, "", "s")
              )
            ),
            div(
              style = "display: flex; align-items: center; gap: 8px;",
              bsicons::bs_icon("diagram-3"),
              sprintf(
                "%s feature%s",
                details$variables,
                ifelse(details$variables == 1, "", "s")
              )
            )
          )
        ),
        
        div(style = "width: 1px; background-color: #dee2e6; align-self: stretch;"),
        
        div(
          style = "margin-left: 20px",
          actionButton(
            session$ns("explore_data"),
            tagList(
              bsicons::bs_icon("table"),
              "Inspect data"
            ),
            class = "btn-outline-primary",
            style = "height: 45px; padding: 8px 8px; white-space: nowrap; min-width: 140px"
          )
        )
      )
    })
    
    
    # Data details - inspect ----
    observe({
      send_info(
        div(
          reactable::reactableOutput(session$ns("explore_data_table")),
          style = "overflow-y: auto; overflow-x: auto;"
        ),
        title = "Dataset inspection",
        size = "xl",
        btn_label = "Dismiss"
      )
    }) |>
      bindEvent(input$explore_data)
    
    
    output$explore_data_table <- reactable::renderReactable({
       reactable::reactable(
         sf$st_drop_geometry(.data()),
         striped = TRUE,
         highlight = TRUE,
         bordered = TRUE,
         resizable = TRUE,
         filterable = TRUE
       ) 
    })
    
    
    # Choose catalogue ----
    catalogue <- reactive({
      if (input$land) {
        switch(
          input$time_level,
          daily = "derived-era5-land-daily-statistics",
          monthly = "reanalysis-era5-land-monthly-means"
        )
      } else {
        switch(
          input$time_level,
          daily = "derived-era5-single-levels-daily-statistics",
          monthly = "reanalysis-era5-single-levels-monthly-means"
        )
      }
    })

    
    param_meta <- reactive({
      meta <- search_param(input$indicator)
      meta$unit <- units[units$id %in% meta$unit_id, ]$name
      meta
    })
    
    
    # Show indicator description ----
    output$indicator_desc <- renderUI({
      desc <- search_param(input$indicator)$description
      widgets$callout(widgets$show_more(HTML(desc)))
    })
    
    
    # Update indicator selection ----
    observe({
      new_choices <- gxc:::allowed_indicators_by_catalogue[[catalogue()]]
      new_choices <- unname(invert(indicators)[new_choices])
      selected <- isolate(input$indicator)
      if (!selected %in% new_choices) {
        selected <- NULL
      }

      updateSelectInput(
        session,
        "indicator",
        choices = new_choices,
        selected = selected
      )
    })
    
    
    # Perform linking ----
    linked <- reactive(execute_safely({
      req_else(.data(), toast(
        message = HTML("Please provide a dataset before trying to link.<br>
          You can do this by navigating to \"Input data\" and either
          selecting data from a file or loading up our example dataset."),
        type = "danger"
      ))
      
      toast(
        tagList(
          p(
            "Linking can take a while! Depending on the size of your data and request,
            this can range from about half a minute to a few hours. Maybe get a
            coffee or take a walk."
          ),
          liveCounter()
        ),
        autohide = FALSE,
        id = "link_idle"
      )
      
      indicator <- indicators[[input$indicator]]
      .data <- .data()
      date <- if (!input$date_column %in% names(.data)) {
        .data[[input$date_column]] <- input$flat_date
      }
      
      out <- execute_safely(
        {
          if (identical(input$time_level, "daily")) {
            gxc::link_daily(
              .data = .data,
              indicator = indicator,
              date_var = input$date_column,
              catalogue = catalogue()
            )
          } else {
            gxc::link_monthly(
              .data = .data,
              indicator = indicator,
              date_var = input$date_column,
              catalogue = catalogue()
            )
          }
        },
        error_fun = function(e) {
          send_error(
            tagList(
              p("The data provider returned the following error message:"),
              tags$blockquote(e$message),
              p("This is can either be a problem with the API (e.g., server
              problems, problems with your account) or with your data.
              Check if the spatial and temporal extent of your input data
              is plausible and then retry.")
            ),
            size = "m",
            title = "Error during linking"
          )
        }
      )
      
      remove_toast("link_idle")
      out
    })) |>
      bindEvent(input$do_link)
    
    
    # Render base map ----
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
    
    
    # Clear map on new file ----
    observe({
      leaflet$leafletProxy("map") |>
        leaflet$clearShapes() |>
        leaflet$clearMarkers() |>
        leaflet$clearControls()
    }) |>
      bindEvent(input$file)


    # Add input data to map ----
    observe(execute_safely({
      req(.data(), inherits(.data(), "sf"))
      .data <- sf$st_transform(.data(), 4326)
      bbox <- sf$st_bbox(.data)
      proxy <- leaflet$leafletProxy("map", data = .data) |>
        leaflet$clearShapes() |>
        leaflet$clearMarkers() |>
        leaflet$clearControls()

      leaflet$flyToBounds(
        proxy,
        lng1 = bbox[["xmin"]],
        lat1 = bbox[["ymin"]],
        lng2 = bbox[["xmax"]],
        lat2 = bbox[["ymax"]]
      )
      
      showcase_col <- input$showcase_col
      showcase_given <- nzchar(showcase_col)
      if (showcase_given) {
        domain <- .data[[showcase_col]]
        
        if (is.numeric(domain)) {
          pal <- leaflet$colorBin(
            grDevices::hcl.colors(n = 50, input$showcase_palette),
            domain = domain
          )
        } else {
          pal <- leaflet$colorFactor(
            grDevices::hcl.colors(n = 50, input$showcase_palette),
            domain = domain,
            levels = if (is.factor(domain)) {
              levels(domain)
            } else {
              sort(unique(domain))
            },
            ordered = is.ordered(domain)
          )
        }
      }

      if (all(sf$st_is(.data, c("POLYGON", "MULTIPOLYGON")))) {
        fill_opacity <- if (showcase_given) 1 else 0.001
        leaflet$addPolygons(
          proxy,
          weight = 1,
          color = "black",
          fill = TRUE,
          fillColor = if (showcase_given) {
            stats::as.formula(sprintf("~pal(%s)", showcase_col))
          } else {
            "white"
          },
          fillOpacity = fill_opacity,
          opacity = 0.5,
          highlightOptions = leaflet$highlightOptions(
            weight = 2,
            color = "black",
            opacity = 0.5,
            fillOpacity = fill_opacity,
            bringToFront = TRUE,
            sendToBack = TRUE
          )
        )
      } else if (all(sf$st_is(.data, c("POINT", "MULTIPOINT")))) {
        leaflet$addCircleMarkers(
          proxy,
          radius = 0.5,
          color = if (showcase_given) {
            stats::as.formula(sprintf("~pal(%s)", showcase_col))
          } else {
            "black"
          },
          opacity = 1,
          fillOpacity = 1
        )
      }
      
      if (showcase_given) {
        leaflet$addLegend(
          proxy,
          position = "bottomright",
          pal = pal,
          values = stats::as.formula(sprintf("~%s", showcase_col)),
          title = paste(
            input$showcase_desc %zchar% showcase_col,
            if (nzchar(input$showcase_unit)) {
              sprintf("(in %s)", input$showcase_unit)
            } else {
              NULL
            }
          ),
          na.label = "N/A",
          opacity = 1
        )
      }
    }))
    
    
    # Add linked data to map ----
    observe(execute_safely({
      req(linked())
      .data <- sf$st_transform(linked(), 4326)
      bbox <- sf$st_bbox(.data)
      proxy <- leaflet$leafletProxy("map", data = .data) |>
        leaflet$clearShapes() |>
        leaflet$clearControls()
      
      leaflet$flyToBounds(
        proxy,
        lng1 = bbox[["xmin"]],
        lat1 = bbox[["ymin"]],
        lng2 = bbox[["xmax"]],
        lat2 = bbox[["ymax"]]
      )
      
      palette <- leaflet$colorBin(palette = "viridis", domain = .data$.linked)
      
      if (all(sf$st_is(.data, c("POLYGON", "MULTIPOLYGON")))) {
        leaflet$addPolygons(
          proxy,
          weight = 1,
          color = "black",
          fill = TRUE,
          fillColor = ~palette(.linked),
          fillOpacity = 0.8,
          opacity = 0.5,
          highlightOptions = leaflet$highlightOptions(
            weight = 2,
            color = "black",
            opacity = 0.1,
            fillOpacity = 1,
            bringToFront = TRUE,
            sendToBack = TRUE
          )
        )
      } else if (all(sf$st_is(.data, c("POINT", "MULTIPOINT")))) {
        leaflet$addCircleMarkers(
          proxy,
          weight = 1,
          color = ~palette(.linked),
          fill = TRUE,
          fillColor = ~.linked,
          opacity = 0.5
        )
      }
      
      leaflet$addLegend(
        proxy,
        "bottomright",
        pal = palette,
        values = ~.linked,
        title = paste(
          isolate(input$indicator),
          sprintf("(in %s)", isolate(param_meta()$unit))
        ),
        opacity = 1
      )
    }))
  })
}
