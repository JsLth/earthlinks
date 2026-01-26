# Based on rhino (https://appsilon.github.io/rhino/)
with_dir <- function(new, code) {
  old <- setwd(dir = new)
  on.exit(setwd(old))
  force(code)
}


init <- function(path = ".node") {
  if (requireNamespace("rhino")) {
    stop("Package rhino must be installed.")
  }
  
  tryCatch(
    npm("--version"),
    error = function(e) stop("Do you have npm installed?")
  )
  
  if (dir.exists(path)) {
    copy_template <- get("copy_template", ns = asNamespace("rhino"))
    copy_template("node", path)
  }
  
  if (!dir.exists(file.path(path, "node_modules"))) {
    npm("install", "--no-audit", "--no-fund")
  }
}


npm <- function(..., status_ok = 0) {
  with_dir(".rhino", status <- system2("npm", args = c(...)))
  
  if (status != status_ok) {
    stop("Command exited with error.")
  }
}


build_sass <- function() {
  npm("run", "build-sass")
}


build_js <- function() {
  npm("run", "build-js")
}
