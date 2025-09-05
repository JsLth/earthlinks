"%zchar%" <- function(x, y) {
  if (all(!nzchar(x))) y else x
}


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


between <- function(x, lower, upper) {
  x >= lower & x <= upper
}


is_integerish <- function(x, tol = .Machine$double.eps ^ 0.5) {
  is.numeric(x) && all(abs(x - round(x)) < tol, na.rm = TRUE)
}


is_categorical <- function(x) {
  (is.factor(x) && !is.ordered(x)) ||
  is.character(x) ||
  is.logical(x) ||
  (is_integerish(x) && all(between(x, 0, 10)))
}


is_datetime <- function(x) {
  inherits(x, "Date") || inherits(x, "POSIXt")
}


is_continuous <- function(x) {
  !is_categorical(x) && (is.numeric(x) || is.ordered(x) || is_datetime(x))
}


is_diverging <- function(x) {
  is_continuous(x) && any(x < 0) && any(x > 0)
}


is_valid_for_leaflet <- function(x) {
  is_categorical(x) || is_continuous(x)
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


unbox <- function(x) {
  if (is.list(x) && length(x) == 1) {
    x <- x[[1]]
  }
  x
}


rbind_list <- function(args) {
  nam <- lapply(args, names)
  unam <- unique(unlist(nam))
  len <- vapply(args, length, numeric(1))
  out <- vector("list", length(len))
  for (i in seq_along(len)) {
    if (nrow(args[[i]])) {
      nam_diff <- setdiff(unam, nam[[i]])
      if (length(nam_diff)) {
        args[[i]][nam_diff] <- NA
      }
    } else {
      next
    }
  }
  out <- suppressWarnings(do.call(rbind, args))
  rownames(out) <- NULL
  out
}


bind_rows <- function(..., .id = NULL) {
  dots <- unbox(list(...))
  out <- rbind_list(dots)
  if (!is.null(.id) && length(out)) {
    names <- names(dots)
    nrows <- vapply(dots, nrow, numeric(1))
    ids <- rep(names, times = nrows)
    ids <- data.frame(ids)
    names(ids) <- .id
    out <- cbind(ids, out)
  }
  
  tibble::tibble(out)
}


labelFormat2 <- function(prefix = "",
                       suffix = "",
                       between = " &ndash; ",
                       transform = identity) {
  formatNum <- function(x) {
    format(
      round(transform(x), digits), trim = TRUE, scientific = FALSE,
      big.mark = big.mark
    )
  }
  
  function(type, ...) {
    switch(
      type,
      numeric = (function(cuts) {
        paste0(prefix, transform(cuts), suffix)
      })(...),
      
      bin = (function(cuts) {
        n <- length(cuts)
        paste0(prefix, transform(cuts[-n]), between, transform(cuts[-1]), suffix)
      })(...),
      
      quantile = (function(cuts, p) {
        n <- length(cuts)
        p <- paste0(round(p * 100), "%")
        cuts <- paste0(transform(cuts[-n]), between, transform(cuts[-1]))
        paste0(
          "<span title=\"", cuts, "\">", prefix,
          p[-n], between, p[-1], suffix, "</span>"
        )
      })(...),
      
      factor = (function(cuts) {
        paste0(prefix, as.character(transform(cuts)), suffix)
      })(...)
    )
  }
}


capture_ansi <- function(..., type = c("output", "message")) {
  old_opt <- options(crayon.enabled = TRUE)
  old_env <- Sys.getenv("TERM")
  on.exit({
    options(old_opt)
    Sys.setenv(TERM = old_env)
  }, add = TRUE)
  Sys.setenv(TERM = "xterm-256color")
  utils::capture.output(..., type = type)
}


key_get0 <- function(service, username = NULL, keyring = NULL) {
  tryCatch(
    keyring::key_get(service, username, keyring = keyring),
    error = function(e) NULL
  )
}