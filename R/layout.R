layout_ui <- function(id) {
  ns <- NS(id)

  bslib::page_navbar(
    id = ns("navbar"),
    title = span(
      id = ns("brand"),
      tags$img(src = "www/logo.png", id = ns("logo")),
      span("EarthLinks", id = ns("title")),
    ),
    window_title = "EarthLinks",
    lang = "en",
    navbar_options = bslib::navbar_options(
      collapsible = FALSE
    ),
    theme = earthlinks_theme(),
    
    # Navbar ----
    bslib::nav_panel_hidden(
      id = ns("nav-panel-main"),
      "Link",
      leaflet::leafletOutput(ns("map"), height = "100%")
    ),
    bslib::nav_spacer(),
    bslib::nav_item(
      a(
        href = "https://github.com/denabel/gxc",
        bslib::tooltip(
          icon("box", class = c("icon", "icon-hover"), id = ns("pkg")),
          "R package",
          placement = "left",
          options = list(offset = c(0, 13))
        )
      )
    ),
    bslib::nav_item(
      a(
        href = "https://denabel.github.io/gxc_pages/",
        bslib::tooltip(
          icon("book", class = c("icon", "icon-hover"), id = ns("cmp")),
          "Online compendium",
          placement = "left",
          options = list(offset = c(0, 13))
        )
      )
    ),
    bslib::nav_item(
      a(
        href = "https://gesis.org/en/",
        bslib::tooltip(
          img(src = "www/gesis-nobg.png", class = c("icon", "icon-hover")),
          "GESIS homepage",
          placement = "left",
          options = list(offset = c(0, 13))
        )
      )
    ),
    
    # Sidebar ----
    sidebar = bslib::sidebar(
      id = ns("sidebar"),
      open = "desktop",
      width = "25vw",

      bslib::accordion(
        id = ns("accordion"),
        open = c(ns("intro"), ns("input")),
        multiple = TRUE,

        ## What is EarthLinks? ----
        bslib::accordion_panel(
          title = tags$b("What is EarthLinks?"),
          value = ns("intro"),
          p(
            "This tool is designed to help you access earth observation data and link it to any social science
            (survey) dataset in an intuitive, interactive way. Simply",
            no(1), "load a dataset,",
            no(2), "select an earth observation indicator,",
            no(3), "link the two datasets, and",
            no(4), "explore and download the linked data."
          )
        ),

        ## Input data ----
        bslib::accordion_panel(
          title = tags$b("Input data"),
          value = ns("input"),
          
          ### File input ----
          helpful(
            fileInput(
              ns("file"),
              label = NULL
            ),
            label = "Upload a GIS file",
            tip = tip(HTML(paste(
              "You can browse your local or drag-and-drop a file that contains",
              "the spatial units that you want to link with. These spatial units",
              "can either be points or polygons. Please note that the data must be",
              "stored in a common R or GIS format. This includes:<br>
              <ul>
                <li><b>R files:</b> rds, <a href='https://cran.r-project.org/package=qs2'>qs</a></li>
                <li><b>Tabular files:</b> csv</li>
                <li><b>Stata or SPSS files:</b> dta, sav, por
                <li><b>Geospatial files:</b> shp, geojson, gpkg, and others
              </ul>"
            ))),
            config = config(
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
                  choices = c("Guess the driver", sf::st_drivers()$name)
                )
              )
            )
          ),
          
          ### Example data ----
          helpful(
            actionButton(
              ns("example_data"),
              label = tagList(
                bsicons::bs_icon("file-earmark-spreadsheet"),
                "Load example data"
              )
            ),
            label = "Just want to look around?",
            tip = tip(HTML(
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
              
              #### Spatial identifiers ----
              helpful(
                div(
                  style = "display: flex; align-items: stretch; gap: 10px;",
                  shinyWidgets::virtualSelectInput(
                    ns("areal_id"),
                    choices = list(),
                    multiple = FALSE,
                    label = NULL
                  ),
                  shiny::actionButton(
                    ns("enrich"),
                    label = tagList(bsicons::bs_icon("magic"), "Enrich"),
                    icon = NULL,
                    style = css(
                      height = "36px",
                      width = "30%",
                      display = "flex",
                      `align-items` = "center",
                      `justify-content` = "center"
                    )
                  )
                ),
                label = "Which columns contain territorial codes?",
                tip = tip(HTML(paste0(
                  "It seems you have loaded a <b>non-spatial file</b>, i.e.,
                  a file that does not directly define geometries like CSV,
                  Stata or SPSS files. While these files can carry
                  geo-information in the form of points or territorial codes,
                  you need to <b>explicitly specifiy</b> which columns
                  represent the spatial references of the records.
                  <br><br>
                  Please select the column that contains the territorial
                  codes of each record, then click \"Enrich\". EarthLinks will
                  try to detect the type of code and link with the geometries
                  automatically. You can also click on ",
                  bsicons::bs_icon("gear"),
                  " to state the code scheme (e.g., NUTS, INSPIRE, FIPS,
                  country codes, etc.).
                  <br><br>
                  If your data contains coordinates, please specify them
                  in the drop-down menu below."
                ))),
                
                config = config(
                  div(
                    shinyWidgets::virtualSelectInput(
                      ns("geolink_geolinker"),
                      choices = list(
                        "Guess" = "guess",
                        "Country codes" = "country codes",
                        "GADM" = "gadm",
                        "EU NUTS" = "nuts",
                        "INSPIRE" = "inspire",
                        "EU LAU" = "lau",
                        "German AGS" = "ags",
                        "US FIPS" = "fips",
                        "Postal codes" = "postcode"
                      ),
                      multiple = FALSE,
                      label = "What type of territorial code?"
                    ),
                    
                    shinyWidgets::virtualSelectInput(
                      ns("geolink_iso3_scheme"),
                      choices = list(
                        "Guess" = "guess",
                        "ISO-2" = "iso3c",
                        "ISO-3" = "iso3c",
                        "GENC-2" = "genc2c",
                        "GENC-3" = "genc3c",
                        "Top-level domain" = "cctld",
                        "Country name (English)" = "country.name.en",
                        "Country name (German)" = "country.name.de",
                        "Country name (French)" = "country.name.fr",
                        "Country name (Italian)" = "country.name.it",
                        "Correlates of War" = "cowc",
                        "European Central Bank" = "ecb",
                        "Eurostat" = "eurostat",
                        "FAO" = "fao",
                        "FIPS 10-4" = "fips",
                        "Global Administrative Unit Layers (GAUL)" = "gaul",
                        "Gleditsch & Ward" = "gwc",
                        "International Olympic Committee" = "ioc",
                        "United Nations M49" = "un",
                        "Unicode" = "unicode.symbol",
                        "UNHCR" = "unhcr",
                        "UNPD" = "unpd",
                        "Varieties of Democracy" = "vdem",
                        "World Bank" = "wb",
                        "World Values Survey" = "wvs"
                      ),
                      label = "In case of country codes, what type of code scheme?",
                      multiple = FALSE,
                      search = TRUE,
                      allowNewOption = TRUE,
                      searchPlaceholderText = "Add other country code schemes..."
                    ),
                    
                    shinyWidgets::virtualSelectInput(
                      ns("geolink_iso3_default"),
                      choices = list(
                        "Natural Earth" = "naturalearth",
                        "geoBoundaries" = "geoboundaries",
                        "GADM" = "gadm",
                        "UNHCR" = "unhcr"
                      ),
                      label = "In case of country codes, what type of country database?"
                    )
                  )
                )
              ),
              
              #### Coordinates ----
              helpful(
                shinyWidgets::virtualSelectInput(
                  ns("non_gis_geometry"),
                  choices = list(),
                  multiple = TRUE,
                  label = NULL,
                  maxValues = 2
                ),
                label = "Which columns contain coordinates?",
                tip = tip(HTML(
                  "It seems you have loaded a <b>non-spatial file</b>, i.e.,
                  a file that does not directly define geometries like CSV,
                  Stata or SPSS files. While these files can carry
                  geo-information in the form of points or territorial codes,
                  you need to <b>explicitly specifiy</b> which columns
                  represent the spatial references of the records.
                  <br><br>
                  Please select the two column names that contain the X and
                  Y coordinates, respectively (or longitude and latitude).
                  <br><br>
                  If your data contains territorial codes instead of coordinates,
                  please specify them in the drop-down menu above."
                ))
              ),
              
              #### CRS ----
              helpful(
                shinyWidgets::virtualSelectInput(
                  ns("non_gis_crs"),
                  choices = list(
                    "WGS84 (4326)" = "4326",
                    "Web Mercator (3857)" = "3857",
                    "ETRS89 (4258)" = "4258",
                    "LAEA Europe (3035)" = "3035"
                  ),
                  label = NULL,
                  multiple = FALSE,
                  search = TRUE,
                  allowNewOption = TRUE,
                  searchPlaceholderText = "Add other EPSG codes..."
                ),
                label = "Select a reference system (CRS)",
                tip = tip(HTML("
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
            helpful(
              id = ns("flat_date_container"),
              shinyWidgets::airDatepickerInput(
                ns("flat_date"),
                label = NULL,
                range = TRUE,
                addon = "none",
                view = "years",
                update_on = "close"
              ),
              label = "Select a time frame that describes your data",
              tip = tip(tagList(
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
            helpful(
              id = ns("showcase_col_container"),
              shinyWidgets::virtualSelectInput(
                ns("showcase_col"),
                label = NULL,
                choices = list(),
                search = TRUE,
                additionalClasses = "code-input",
                additionalDropboxClasses = "code-input",
                additionalDropboxContainerClasses = "code-input",
                additionalToggleButtonClasses = "code-input"
              ),
              label = "Which column do you want to show on the map?",
              tip = tip(HTML(
                "Your selected dataset contains multiple features but only
                  one of them can be displayed on the map. This step lets
                  you select a column from your dataset to display on the map
                  alongside your linked earth observation data."
              )),
              config = config(
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
                      palettes(),
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
            bslib::card(
              max_height = 250,
              id = ns("data_details_container"),
              style = "margin-top: 20px;",
              bslib::card_header(
                span(bsicons::bs_icon("bar-chart-fill"), "Dataset details")
              ),
              uiOutput(ns("data_details"))
            )
          )
        ),
        
        ## Indicator selection ----
        bslib::accordion_panel(
          title = tags$b("Indicator selection"),
          value = ns("indicator_select"),
          
          ### Indicator ----
          helpful(
            shinyWidgets::virtualSelectInput(
              ns("indicator"),
              label = NULL,
              choices = names(indicators)
            ),
            label = "Select an indicator",
            tip = tip(div(HTML(
              "Select the earth observation indicator you want to link. The
              available indicators you can select depend on the choices in
              data provider, data catalogue and other options above.<br>
              <i>Note:</i> Some indicators are averaged over time (e.g.,
              temperature), while others are summed (e.g., precipitation),
              depending on their nature and the selected time aggregation
              level."
            )))
          ),
          
          uiOutput(ns("indicator_desc")),
          
          ### Time level ----
          helpful(
            id = ns("time_level_container"),
            radioButtons(
              ns("time_level"),
              label = NULL,
              choices = time_levels
            ),
            label = "Select a time aggregation level",
            tip = tip(
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
          helpful(
            id = ns("land_container"),
            checkboxInput(ns("land"), label = NULL, value = TRUE, width = "auto"),
            label = "Only include land areas?",
            tip = tip(div(HTML(
              "Tick this box to use land-only data. When selected, the data
              comes from ERA5-Land, which provides higher-resolution climate
              information from <b>land surfaces only</b>. Otherwise, the data
              includes both <b>land and ocean areas</b> using the standard
              ERA5 dataset."
            ))),
            inline = TRUE
          )
        ),
        
        ## Finalize ----
        bslib::accordion_panel(
          title = tags$b("Finalize"),
          value = ns("finalize"),

          helpful(
            passwordInputToggle(
              ns("api_key"),
              label = NULL,
              placeholder = "API key"
            ),
            label = "Enter your API key",
            tip = tip(div(HTML(
              "To access earth observation data, EarthLinks needs to communicate with various
              <a href='https://en.wikipedia.org/wiki/API'>APIs</a> (application programming interfaces).
              To proceed, please register with ECMWF (<a href='https://www.ecmwf.int/'>Link</a>) and
              retrieve your API key (<a href='https://api.ecmwf.int/v1/key/'>Link</a>)."
            )))
          ),

          br(),

          helpful(
            bslib::input_task_button(
              ns("do_link"),
              label = "Link",
              icon = bsicons::bs_icon("lightning-charge-fill"),
              label_busy = "Linking...",
              type = "default"
            ),
            label = "Download indicators and link"
          ),
          
          br(),
          
          helpful(
            shinyjs::disabled(
              shiny::downloadButton(
                ns("export"),
                label = "Export"
              )
            ),
            label = "Export to file",
            tip = tip(div(HTML(sprintf(
              "Click to export your linked data to a file.<br>By default,
              drops geometries and saves the data as a CSV. You can change
              this default by clicking on the options icon (%s)",
              as.character(bsicons::bs_icon("gear")))
            ))),
            
            config = config(
              div(
                shinyWidgets::virtualSelectInput(
                  ns("output_format"),
                  label = "Select an output format",
                  choices = list(
                    CSV = "csv",
                    RDS = "rds",
                    Stata = "dta",
                    SPSS = "sav",
                    GeoJSON = "geojson",
                    GeoPackage = "gpkg",
                    Shapefile = "shp"
                  )
                ),
                
                numericInput(
                  ns("output_stataVersion"),
                  label = "Stata file version",
                  value = 14,
                  min = 8,
                  max = 15
                )
              )
            )
          )
        )
      )
    )
  )
}


layout_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    if (!loadable("haven")) {
      toast(
        "To load or save files from SPSS or Stata, you need to install the
        'haven' package.",
        title = "Package notice",
        type = "warning",
        delay = 6000
      )
    }
    
    if (!loadable("qs2")) {
      toast(
        "To load or save files from SPSS or Stata, you need to install the
        'qs2' package.",
        title = "Package notice",
        type = "warning",
        delay = 6000
      )
    }
    
    parsed <- reactiveVal(NULL) # parsed file object, yet to be cleaned
    .data <- reactiveVal(NULL) # data ready to be linked
    dates <- reactiveVal(NULL) # date information from .data()
    example_data_loaded <- FALSE
    api_keys <- list(
      ecmwf = NULL
    )
    

    # Restore old API keys ----
    onSessionEnded(function() {
      if (!is.null(api_keys$ecmwf)) {
        keyring::key_set_with_value("ecmwfr", "ecmwfr", password = api_keys$ecmwf)
        options_restore()
      }
    })

    
    # Input data ----
    observe(execute_safely({
      path <- input$file$datapath

      haven_msg <- "To read files from Stata or SPSS, please ensure that
        the 'haven' package is installed."
      ext <- tools::file_ext(path)
      new <- switch(
        ext,
        rds = readRDS(path),
        qs = with_package(
          qs2::qs_read(path),
          "haven",
          "to load .qs files"
        ),
        csv = {
          if (loadable("readr")) {
            readr::read_delim(path, show_col_types = FALSE)
          } else {
            read.csv(path)
          }
        },
        sav = with_package(
          haven::read_sav(path),
          "haven",
          "to load .sav files"
        ),
        por = with_package(
          haven::read_por(path),
          "haven",
          "to load .por files"
        ),
        dta = with_package(
          haven::read_dta(path),
          "haven",
          "to load .dta files"
        ),
        execute_safely(
          sf::read_sf(path),
          toast = TRUE,
          message = HTML(sprintf("Failed to read the provided file. Make sure to load
            a supported file that contains geo-information. Click on %s
            if you don't know what this means.", bsicons::bs_icon("question-circle")))
        )
      )
      
      shinyjs::disable("export")
      example_data_loaded <<- FALSE
      parsed(new)
      if (inherits(new, "sf")) .data(new)
    })) |>
      bindEvent(input$file)
    
    
    # Example data ----
    observe(execute_safely({
      new <- utils::read.csv("app/data/ESS11-subset.csv")[c("cntry", "inwde", "wrclmch")]
      new$inwde <- as.POSIXct(new$inwde, format = "%Y-%m-%d %H:%M:%S")
      new <- stats::aggregate(cbind(inwde, wrclmch) ~ cntry, new, mean, na.rm = TRUE)
      countries <- unique(new$cntry)
      geom <- giscoR::gisco_get_nuts(
        year = "2024",
        resolution = "60",
        spatialtype = "RG",
        nuts_level = "0",
        country = countrycode::countrycode(countries, origin = "iso2c", destination = "iso3c")
      )["geo"]
      new <- merge(new, geom, by.x = "cntry", by.y = "geo")
      new <- sf::st_as_sf(new)
      new <- sf::st_transform(new, 4326)
      new <- suppressWarnings(sf::st_intersection(
        new,
        sf::st_as_sfc(sf::st_bbox(c(
          xmin = -25,
          ymin = 30,
          xmax = 40,
          ymax = 70
        ), crs = sf::st_crs(4326)))
      ))
      names(new) <- c("country", "date", "climate_concern", "geometry")
      new$date <- as.Date(as.POSIXct(new$date))
      new$date <- as.Date(as.POSIXct("2022-01-01"))
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
    observe(execute_safely({
      ext <- tools::file_ext(input$file$datapath)
      if (length(ext) &&
          any(ext %in% c("csv", "dta", "sav", "por", "rds", "qs")) &&
          !example_data_loaded) {
        shinyjs$show("non_gis_file_container", anim = TRUE)
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
        
        freezeReactiveValue(input, "areal_id")
        shinyWidgets::updateVirtualSelect(
          session = session,
          "areal_id",
          choices = colnames(parsed()),
          selected = NULL
        )
        
        freezeReactiveValue(input, "non_gis_geometry")
        shinyWidgets::updateVirtualSelect(
          session = session,
          "non_gis_geometry",
          choices = colnames(parsed()),
          selected = selected
        )
        
        
      } else {
        shinyjs::hide("non_gis_file_container", anim = TRUE)
      }
    })) |>
      bindEvent(parsed())
    
    
    # Non-GIS - suggest CRS ----
    observe(execute_safely({
      parsed <- parsed()
      x <- parsed[[input$non_gis_geometry[[1]]]]
      y <- parsed[[input$non_gis_geometry[[2]]]]
      
      if (!is.numeric(x) || !is.numeric(y)) {
        return()
      }
      
      if (all(between(x, -180, 180) & between(y, -90, 90))) {
        selected <- 4326
      } else {
        selected <- 3035
      }
      
      freezeReactiveValue(input, "non_gis_crs")
      updateSelectizeInput(session = session, "non_gis_crs", selected = selected)
    }), priority = 401) |>
      bindEvent(req(
        parsed(),
        input$non_gis_geometry,
        length(input$non_gis_geometry) == 2
      ))
    
    
    # Non-GIS - convert ----
    observe(execute_safely({
      req(
        length(input$non_gis_geometry) == 2,
        input$non_gis_geometry %in% names(parsed()),
        input$non_gis_crs
      )
      
      crs <- suppressWarnings(sf::st_crs(as.numeric(input$non_gis_crs)))
      req_else(!anyNA(crs), toast(
        "The coordinate reference system (CRS) you provided could not
          be identified. Please validate your CRS on <a>https://epsg.io/</a>
          and try again.",
        title = "CRS could not be identified",
        type = "danger",
        delay = 10000
      ))
      
      coord_cols <- unlist(input$non_gis_geometry, use.names = FALSE)
      req_else(!anyNA(parsed()[, coord_cols]), toast(
        sprintf(
          "Some of the values within the columns \"%s\" and \"%s\"
            contain missing values. Please remove them and load your
            file again.", coord_cols[1], coord_cols[2]),
        title = "Missing coordinates detected",
        type = "danger",
        delay = 10000
      ))

      req_else(all(vapply(parsed()[, coord_cols], is.numeric, FALSE)), toast(
        "The coordinate columns you selected could not be parsed as
          coordinates. Did you select the correct columns?",
        title = "Invalid coordinates selected",
        type = "danger",
        delay = 10000
      ))
      
      new_sf <- sf::st_as_sf(
        parsed(),
        coords = coord_cols,
        crs = crs
      )
      
      attr(new_sf, "bbox") <- sf::st_bbox(new_sf)
      
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
    }), priority = 400)
    
    
    # Non-GIS - confirm enrich ----
    observe({
      execute_safely({
        linker <- input$geolink_geolinker
        scheme <- input$geolink_iso3_scheme
        ids <- parsed()[[input$areal_id]]
        
        if (!identical(scheme, "guess")) {
          ids <- countrycode::countrycode(ids, scheme, "iso3c")
          
          req_else(
            !anyNA(ids),
            toast(
              sprintf(
                "The codes in %s do not represent valid %s country codes.
               Maybe try a different code scheme?",
                tags$code(input$areal_id), scheme
              ),
              type = "warning"
            )
          )
        }
        
        changed <- FALSE
        if (identical(linker, "country codes")) {
          ids_old <- ids
          ids <- geolink:::convert_to_iso3(ids)
          changed <- length(setdiff(ids, ids_old)) > 0
          
          if (!changed) {
            cc_guess <- countrycode::guess_field(ids, min_similarity = 100)
            
            req_else(
              "iso3c" %in% cc_guess$code,
              toast(
                sprintf(
                  "The codes in %s do not represent valid country codes.
                 Maybe try selecting a different type of territorial code?",
                  shiny::tags$code(input$areal_id)
                ),
                type = "warning"
              )
            )
          }
          
          linker <- input$geolink_iso3_default
        }
        
        if (identical(linker, "guess")) {
          linker <- tryCatch(
            geolink:::guess_linker(
              ids,
              iso3_auto = TRUE,
              iso3_default = input$geolink_iso3_default
            ),
            error = function(e) {
              req_else(
                !grepl("could not automatically", e$message),
                toast(
                  sprintf(
                    "Could not automatically detect the type of territorial code.
                   Maybe try selecting a code type manually? Otherwise, you
                   will have to georeference your data yourself.",
                    tags$code(input$areal_id)
                  ),
                  type = "error"
                )
              )
              
              stop(e)
            }
          )
        }
        
        linker_pretty <- switch(
          linker,
          gadm = "GADM boundaries",
          unhcr = "UNHCR boundaries",
          nuts = "EU NUTS regions",
          inspire = "INSPIRE grids",
          lau = "EU LAU regions",
          ags = "German AGS regions",
          fips = "US FIPS regions",
          postcode = "postal code centroids",
          "country boundaries"
        )
        
        send_info(
          title = "Are you sure you want to continue?",
          text = sprintf(
            "You are about to link your data with %s. Depending on your
             data this may take a while and will also overwrite any
             current geometry. Do you want to continue?",
            linker_pretty
          ),
          footer = tagList(
            modalButton("Cancel"),
            bslib::input_task_button(
              session$ns("enrich_confirm"),
              label = "Continue",
              label_busy = "Linking..."
            )
          )
        )
      })
    }) |>
      bindEvent(input$enrich)
    
    
    # Non-GIS - enrich ----
    observe({
      execute_safely({
        linker <- if (!input$geolink_geolinker %in% c("guess", "country codes")) {
          input$geolink_geolinker
        }
        
        scheme <- if (!input$geolink_iso3_scheme %in% "guess") {
          input$geolink_iso3_scheme
        }
        
        linked <- geolink::enrich(
          parsed(),
          id_col = input$areal_id,
          linker = linker,
          iso3_scheme = scheme,
          iso3_default = input$geolink_iso3_default,
          crs = as.numeric(input$non_gis_crs)
        )
        
        removeModal()
        .data(linked)
      })
    }) |>
      bindEvent(input$enrich_confirm)
    
    
    # Flat date - show/hide ----
    observe(execute_safely({
      if (!input$date_column %in% names(parsed()) && !example_data_loaded) {
        shinyjs::show("flat_date_container", anim = TRUE)
      } else {
        shinyjs::hide("flat_date_container", anim = TRUE)
      }
    })) |>
      bindEvent(parsed())
    
    
    # Flat date - merge ----
    observe(execute_safely({
      if (input$date_column %in% names(parsed())) {
        dates(parsed()[[input$date_column]])
      } else {
        dates(input$flat_date)
      }
    })) |>
      bindEvent(.data() %||% parsed(), input$flat_date)
    
    
    # Showcase - show/hide ----
    observe(execute_safely({
      .data <- .data()
      req(.data)
      
      featnames <- setdiff(names(.data), "geometry")
      featnames <- featnames[vapply(.data[, featnames], is_valid_for_leaflet, logical(1))]
      if (!length(featnames)) {
        toast(
          "The selected dataset contains no valid features (categorical or continuous vectors).
            No features can be displayed.",
          title = "No valid features found",
          type = "warning",
          delay = 5000
        )
        
        shinyWidgets::updateVirtualSelect(
          "showcase_col",
          choices = character()
        )
        
        req(FALSE)
      }
      
      if (ncol(.data) > 1) {
        # Select the first column in input data that can be plotted
        selected <- NULL
        for (feat in featnames) {
          vec <- .data[[feat]]

          # adopt the following only if necessary:
          # - Categorical data with less than 2 or more than 20 categories
          # - Numeric data with only 1 unique value
          # 
          # They look bad on maps but can technically be plotted.
          # This sets them to TRUE but does not stop the loop. If any other
          # attribute is better suited, this is overwritten
          is_cat <- is_categorical(vec)
          too_few <- length(unique(vec)) < 2
          too_many <- length(unique(vec)) > 20
          if (is_valid_for_leaflet(vec) &&
              !(is_cat && too_many) &&
              !too_few
             ) {
            selected <- feat
            break

          # other valid data are adopted straightaway
          } else if (is_valid_for_leaflet(vec)) {
            selected <- feat
          }
        }

        choices <- shinyWidgets::prepare_choices(
          data.frame(value = featnames, classNames = "code-input"),
          label = value,
          value = value,
          classNames = classNames
        )
        shinyWidgets::updateVirtualSelect(
          "showcase_col",
          choices = choices,
          selected = selected
        )

        shinyjs::show("showcase_col_container", anim = TRUE)
      } else {
        shinyWidgets::updateVirtualSelect(
          "showcase_col",
          choices = list(featnames),
          selected = featnames[[1]]
        )
        shinyjs::hide("showcase_col_container", anim = TRUE)
      }
    }))
    

    # Showcase - palette ----
    observe(execute_safely({
      showcase <- .data()[[input$showcase_col]]
      freezeReactiveValue(input, "showcase_palette")
      if (is_categorical(showcase)) {
        shinyWidgets::updateVirtualSelect(
          "showcase_palette",
          selected = "Dark 3"
        )
      } else if (is_diverging(showcase)) {
        shinyWidgets::updateVirtualSelect(
          "showcase_palette",
          selected = "Blue-Red"
        )
      } else {
        shinyWidgets::updateVirtualSelect(
          "showcase_palette",
          selected = "Viridis"
        )
      }
    })) |>
      bindEvent(input$showcase_col)

    
    # Data details - show ----
    observe(execute_safely({
      if (isTruthy(.data() %||% parsed())) {
        shinyjs::show("data_details_container", anim = TRUE)
      } else {
        shinyjs::hide("data_details_container", anim = TRUE)
      }
    }))
    
    
    # Data details - render ----
    output$data_details <- renderUI(execute_safely({
      if (isTruthy(dates())) {
        start <- min(as_date(dates()))
        end <- max(as_date(dates()))
      } else {
        start <- NULL
        end <- NULL
      }


      details <- list(
        start = start,
        end = end,
        extent = format_duration(end - start),
        variables = ncol(.data() %||% parsed()) - 1,
        records = nrow(.data() %||% parsed())
      )
      
      div(
        style = css(
          display = "flex",
          `align-items` = "center"
        ),
        div(
          style = "flex: 1;",
          div(
            style = css(
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
                "%s attribute%s",
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
    }))
    
    
    # Data details - inspect ----
    observe(execute_safely({
      send_info(
        div(
          reactable::reactableOutput(session$ns("explore_data_table")),
          style = "overflow-y: auto; overflow-x: auto;"
        ),
        title = "Dataset inspection",
        size = "xl",
        btn_label = "Dismiss"
      )
    })) |>
      bindEvent(input$explore_data)
    
    
    output$explore_data_table <- reactable::renderReactable(execute_safely({
       reactable::reactable(
         sf::st_drop_geometry(.data() %||% parsed()),
         striped = TRUE,
         highlight = TRUE,
         bordered = TRUE,
         resizable = TRUE,
         filterable = TRUE
       ) 
    }))
    
    
    # Choose catalogue ----
    catalogue <- reactive(execute_safely({
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
    }))

    
    param_meta <- reactive({
      tryCatch(
        {
          meta <- search_param(input$indicator)
          meta$unit <- units[units$id %in% meta$unit_id, ]$name
          meta
        },
        error = function(e) list()
      )
    })
    
    
    # Show indicator description ----
    output$indicator_desc <- renderUI(execute_safely({
      meta <- param_meta()
      desc <- if (length(meta)) {
        meta$description
      } else {
        "No parameter description can currently be displayed because the parameter database is unavailable. Please try again later."
      }

      callout(show_more(HTML(desc)))
    }))
    
    
    # Update catalogue selection ----
    observe(execute_safely({
      req(input$indicator)
      ind <- indicators[input$indicator]
      in_catalogue <- vapply(
        gxc:::allowed_indicators_by_catalogue,
        function(x) ind %in% x,
        logical(1)
      )
      catas <- names(in_catalogue)[in_catalogue]
      
      ## Time level check ----
      has_time <- vapply(
        time_levels,
        function(x) any(grepl(x, catas, ignore.case = TRUE)),
        logical(1)
      )
      
      n_has_time <- sum(has_time)
      if (n_has_time == 0) {
        shinyjs::hide("time_level_container", anim = TRUE)
      } else if (n_has_time > 0) {
        new_times <- invert(invert(time_levels)[has_time])
        freezeReactiveValue(input, "time_level")
        updateRadioButtons(
          inputId = "time_level",
          choices = new_times
        )
      }

      ## Land-only check ----
      if (any(!grepl("land", catas))) {
        shinyjs::hide("land_container", anim = TRUE)
      } else {
        shinyjs::show("land_container", anim = TRUE)
      }
    })) |>
      bindEvent(input$indicator)


    key <- key_get0("ecmwfr", "ecmwfr")
    if (!is.null(key)) {
      updateTextInput(session, "api_key", value = key)
    }


    # Check API key ----
    observe({
      key <- key_get0("ecmwfr", "ecwfr")
      if (nzchar(input$api_key)) {
        api_keys$ecmwf <<- key
        keyring::key_set_with_value("ecmwfr", "ecmwfr", password = input$api_key)
      }
    }) |>
      bindEvent(input$api_key)

    
    # Perform linking ----
    linked <- reactive({
      req_else(.data(), toast(
        message = HTML("Please provide a dataset before trying to link.<br>
          You can do this by navigating to \"Input data\" and either
          selecting data from a file or loading up our example dataset."),
        type = "danger",
        title = "Input data missing!"
      ))

      req_else(key_get0("ecmwfr", "ecmwfr"), toast(
        message = "Please provide a working API key for the ECMWF API.",
        type = "danger",
        title = "No API key provided!"
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

      on.exit(remove_toast("link_idle"))
      
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
          printError(e)
          send_error(
            tagList(
              p("The data provider returned the following error message:"),
              tags$blockquote(e$message),
              p("This is can either be a problem with the API (e.g., server
              problems, problems with your account) or with your data.
              Check your API key, your internet connection as well as the spatial
              and temporal resolution of your data - then try again.")
            ),
            size = "m",
            title = "Error during linking"
          )
        }
      )
      
      shinyjs::enable("export")
      
      out
    }) |>
      bindEvent(input$do_link)
    
    
    # Export ----
    output$export <- downloadHandler(
      filename = function() {
        paste0("gxc-linked-", Sys.Date(), ".", input$output_format)
      },
      
      content = function(file) {
        execute_safely(
          switch(
            input$output_format,
            csv = utils::write.csv(
              sf::st_drop_geometry(linked()),
              file = file,
              row.names = FALSE
            ),
            qs = with_package(
              qs2::qs_save(linked(), file),
              "haven",
              "to save .qs files"
            ),
            rds = saveRDS(linked(), file),
            dta = {
              linked <- linked()
              names(linked) <- gsub("\\.", "", names(linked))
              with_package(
                haven::write_dta(
                  sf::st_drop_geometry(linked),
                  path = file,
                  version = input$output_stataVersion
                ),
                "haven",
                "to save .dta files"
              )
            },
            sav = {
              linked <- linked()
              names(linked) <- gsub("\\.", "", names(linked))
              with_package(
                haven::write_sav(sf::st_drop_geometry(linked), path = file),
                "haven",
                "to save .sav files"
              )
            },
            sf::write_sf(linked(), dsn = file)
          )
        )
      }
    )
    
    
    # Render base map ----
    output$map <- leaflet::renderLeaflet(execute_safely({
      leaflet::leaflet(options = leaflet::leafletOptions(zoomControl = FALSE)) |>
        leaflet::addMapPane("svyPane", zIndex = 210) |>
        leaflet::addMapPane("eodPane", zIndex = 200) |>
        leaflet::addProviderTiles(
          "CartoDB.Positron",
          group = "Light",
          layerId = session$ns("svyTiles"),
          options = leaflet::tileOptions(pane = "svyPane")
      ) |>
        leaflet::addProviderTiles(
          "CartoDB.DarkMatter",
          group = "Dark",
          layerId = session$ns("eodTiles"),
          options = leaflet::tileOptions(pane = "eodPane")
      ) |>
        #leaflet::addLayersControl(baseGroups = c("Light", "Dark")) |>
        leaflet::setView(14, 48, 5) |>
        htmlwidgets::onRender(
          "function(el, x) {
            L.control.zoom({
              position: 'topright'
            }).addTo(this);
          }"
        )
    }))
    
    
    # Clear map on new file ----
    observe(execute_safely({
      leaflet::leafletProxy("map") |>
        leaflet::clearShapes() |>
        leaflet::clearMarkers() |>
        leaflet::clearControls() |>
        removeSidebyside(session$ns("sidebyside"))
    })) |>
      bindEvent(input$file)


    # Add input data to map ----
    observe(execute_safely({
      req(.data(), inherits(.data(), "sf"))
      .data <- sf::st_transform(.data(), 4326)
      bbox <- sf::st_bbox(.data)
      proxy <- leaflet::leafletProxy("map", data = .data) |>
        leaflet::clearGroup("svyGroup")

      leaflet::flyToBounds(
        proxy,
        lng1 = bbox[["xmin"]],
        lat1 = bbox[["ymin"]],
        lng2 = bbox[["xmax"]],
        lat2 = bbox[["ymax"]]
      )
      
      showcase_col <- input$showcase_col
      showcase_given <- showcase_col %in% names(.data)
      if (showcase_given) {
        domain <- .data[[showcase_col]]
        colors <- grDevices::hcl.colors(n = 50, input$showcase_palette)
        
        # convert date-times to numbers, then transform their labels later
        is_datetime <- is_datetime(domain)
        if (is_datetime) {
          tz <- tz(domain)
          domain <- linux_time(domain)
          pal <- leaflet::colorNumeric(colors, domain = domain)
        } else if (is_continuous(domain)) {
          pal <- leaflet::colorBin(colors, domain = domain)
        } else if (is_categorical(domain)) {
          levels <- if (is.factor(domain)) {
            levels(domain)
          } else {
            sort(unique(domain))
          }

          pal <- leaflet::colorFactor(
            colors,
            domain = domain,
            levels = levels,
            ordered = is.ordered(domain)
          )
        }
      }

      if (all(sf::st_is(.data, c("POLYGON", "MULTIPOLYGON")))) {
        fill_opacity <- if (showcase_given) 1 else 0.001
        leaflet::addPolygons(
          proxy,
          group = "svyGroup",
          weight = 1,
          color = "black",
          fill = TRUE,
          fillColor = if (showcase_given) {
            pal(domain)
          } else {
            "white"
          },
          fillOpacity = fill_opacity,
          opacity = 0.5,
          highlightOptions = leaflet::highlightOptions(
            weight = 2,
            color = "black",
            opacity = 0.5,
            fillOpacity = fill_opacity,
            bringToFront = TRUE,
            sendToBack = TRUE
          ),
          options = leaflet::pathOptions(pane = "svyPane")
        )
      } else if (all(sf::st_is(.data, c("POINT", "MULTIPOINT")))) {
        leaflet::addCircleMarkers(
          proxy,
          group = "svyGroup",
          radius = 0.5,
          color = if (showcase_given) {
            pal(domain)
          } else {
            "black"
          },
          opacity = 1,
          fillOpacity = 1,
          options = leaflet::pathOptions(pane = "svyPane")
        )
      }

      if (showcase_given) {
        leaflet::addLegend(
          proxy,
          position = "bottomleft",
          layerId = session$ns("svyLegend"),
          group = "svyGroup",
          pal = pal,
          values = domain,
          title = paste(
            input$showcase_desc %zchar% showcase_col,
            if (nzchar(input$showcase_unit)) {
              sprintf("(in %s)", input$showcase_unit)
            } else {
              NULL
            }
          ),
          na.label = "N/A",
          opacity = 1,
          labFormat = labelFormat2(
            transform = if (is_datetime) {
              function(x) {
                if (!length(x)) return(format(as.POSIXct(
                  unique(domain),
                  origin = "1970-01-01",
                  tz = tz %||% "UTC"
                )))

                format(as.POSIXct(x, tz = tz %||% "UTC"), "%Y-%m-%d")
              }
            } else {
              identity
            }
          )
        )
      }
    }))
    
    
    # Add linked data to map ----
    observe({
      linked <- linked()
      req(linked)
      execute_safely({
        .data <- sf::st_transform(linked, 4326)
        bbox <- sf::st_bbox(.data)
        proxy <- leaflet::leafletProxy("map", data = .data) |>
          leaflet::clearGroup("eodGroup")
        
        leaflet::flyToBounds(
          proxy,
          lng1 = bbox[["xmin"]],
          lat1 = bbox[["ymin"]],
          lng2 = bbox[["xmax"]],
          lat2 = bbox[["ymax"]]
        )
        
        palette <- leaflet::colorBin(palette = "viridis", domain = .data$.linked)
        
        if (all(sf::st_is(.data, c("POLYGON", "MULTIPOLYGON")))) {
          leaflet::addPolygons(
            proxy,
            group = "eodGroup",
            weight = 1,
            color = "black",
            fill = TRUE,
            fillColor = ~palette(.linked),
            fillOpacity = 0.8,
            opacity = 0.5,
            highlightOptions = leaflet::highlightOptions(
              weight = 2,
              color = "black",
              opacity = 0.1,
              fillOpacity = 1,
              bringToFront = TRUE,
              sendToBack = TRUE
            ),
            options = leaflet::pathOptions(pane = "eodPane")
          )
        } else if (all(sf::st_is(.data, c("POINT", "MULTIPOINT")))) {
          leaflet::addCircleMarkers(
            proxy,
            group = "eodGroup",
            weight = 1,
            color = ~palette(.linked),
            fill = TRUE,
            fillColor = ~.linked,
            opacity = 0.5,
            options = leaflet::pathOptions(pane = "eodPane")
          )
        }
        
        leaflet::addLegend(
          proxy,
          "bottomright",
          layerId = session$ns("eodLegend"),
          group = "eodGroup",
          pal = palette,
          values = ~.linked,
          title = paste(
            isolate(input$indicator),
            sprintf("(in %s)", isolate(param_meta()$unit))
          ),
          opacity = 1
        )

        addSidebyside(
          proxy,
          layerId = session$ns("sidebyside"),
          leftId = session$ns("svyTiles"),
          rightId = session$ns("eodTiles")
        )
      })
    })
  })
}
