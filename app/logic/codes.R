search_param <- function(term, regex = FALSE, limit = 1) {
  req <- httr2::request("https://codes.ecmwf.int/")
  req <- httr2::req_url_path(req, "parameter-database", "api", "v1", "param")
  req <- httr2::req_url_query(
    req,
    search = term,
    encoding = "grib2",
    limit = limit,
    format = "json",
    regex = regex
  )
  resp <- httr2::req_perform(req)
  resp <- httr2::resp_body_json(resp)
  resp$results[[1]]
}