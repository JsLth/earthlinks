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