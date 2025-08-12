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


linux_time <- function(x, tz = "") {
  as.numeric(as.POSIXct(x, tz = tz))
}