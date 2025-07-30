invert <- function(x) {
  nm <- names(x)
  names(nm) <- x
  nm
}


req_else <- function(expr, otherwise, cancelOutput = FALSE) {
  otherwise <- rlang::enquo(otherwise)
  ow_expr <- rlang::quo_get_expr(otherwise)
  ow_env <- rlang::quo_get_env(otherwise)

  if (!shiny::isTruthy(expr)) {
    eval(ow_expr, ow_env)
    shiny::req(FALSE, cancelOutput = cancelOutput)
  }
}


format_duration <- function(x) {
  x <- as.numeric(x)
  years <- round(x / 365, 0)
  months <- round((x %% 365) / 30, 0)
  days <- max(round((x %% 365) %% 30, 0), 1)
  year_tail <- if (years != 1) "s" else ""
  month_tail <- if (months != 1) "s" else ""
  day_tail <- if (days != 1) "s" else ""
  
  if (years > 0) {
    sprintf(
      "%s year%s, %s month%s, %s day%s",
      years, year_tail,
      months, month_tail,
      days, day_tail
    )
  } else if (months > 0) {
    sprintf(
      "%s month%s, %s day%s",
      months, month_tail,
      days, day_tail
    )
  } else {
    sprintf(
      "%s day%s",
      days, day_tail
    )
  }
}


format_daterange <- function(x, y) {
  if (as.numeric(difftime(x, y, units = "days")) <= 1) {
    format(x, format = "%B %d, %Y")
  } else {
    x_fmt <- if (identical(year(x), year(y))) {
      format(x, format = "%b %d")
    } else {
      format(x, format = "%b %d, %Y")
    }
    
    sprintf("%s \u2014 %s", x_fmt, format(y, format = "%b %d, %Y"))
  }
}


year <- function(x) {
  as.POSIXlt(x, tz = tz(x))$year + 1900
}


month <- function(x) {
  as.POSIXlt(x, tz = tz(x))$mon + 1
}


day <- function(x) {
  as.POSIXlt(x, tz = tz(x))$mday
}


tz <- function(x) {
  tzone <- attr(x, "tzone")
  
  if (is.null(tzone)) {
    ""
  } else {
    tzone[[1]]
  }
}


as_date <- function(x,
                    try_formats = c("%Y-%m-%d",
                                    "%m/%d/%Y",
                                    "%d/%m/%Y",
                                    "%B %d, %Y",
                                    "%b %d, %Y",
                                    "%d-%b-%Y",
                                    "%Y/%m/%d",
                                    "%d.%m.%Y"),
                    ...) {
  as.Date(x, tryFormats = try_formats, ...)
}


between <- function(x, lower, upper) {
  x >= lower & x <= upper
}


is_crs_mismatch <- function(x, crs = sf::st_crs(x)) {
  is_geographic <- crs$IsGeographic
  bbox <- sf::st_bbox(sf::st_set_crs(x, crs))
  eps <- sqrt(.Machine$double.eps)
  is_geographic && (
    bbox["xmin"] < (-180 - eps) ||
    bbox["xmax"] > (360 + eps) ||
    bbox["ymin"] < (-90 - eps) ||
    bbox["ymax"] > (90 + eps)
  )
}