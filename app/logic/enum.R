box::use(dplyr[bind_rows, mutate, case_match])
box::use(app/logic/widgets[pal_icon], app/logic/utils[bind_rows])

types <- c("sequential", "diverging", "divergingx", "qualitative")
palettes <- lapply(
  stats::setNames(types, types),
  \(x) data.frame(palette = grDevices::hcl.pals(x))
) |>
  bind_rows(.id = "type")
  
palettes$type <- vapply(
  palettes$type,
  FUN.VALUE = character(1),
  function(x) switch(
    x,
    sequential = "Continuous palettes",
    diverging = "Diverging palettes",
    divergingx = "High-contrast diverging palettes",
    qualitative = "Categorical palettes"
  )
)

# palettes[c("type", "palette")] |>
#   dplyr::mutate(colors = lapply(palette, \(x) hcl.colors(3, palette = x))) |>
#   as.list() |>
#   jsonlite::write_json(pretty = TRUE, auto_unbox = TRUE, path = "app/static/palettes.json")


# jsonlite::fromJSON("https://codes.ecmwf.int/parameter-database/api/v1/unit/?format=json")
units <- data.frame(
  id = c(
    1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L, 11L, 12L, 13L, 14L, 15L, 16L, 17L,
    18L, 19L, 20L, 21L, 22L, 23L, 24L, 25L, 26L, 27L, 28L, 29L, 30L, 31L, 32L,
    33L, 34L, 35L, 36L, 37L, 38L, 39L, 40L, 41L, 42L, 43L, 44L, 45L, 46L, 47L,
    48L, 49L, 50L, 51L, 52L, 53L, 54L, 55L, 56L, 57L, 58L, 59L, 60L, 61L, 62L,
    63L, 64L, 65L, 66L, 67L, 68L, 69L, 70L, 71L, 72L, 73L, 74L, 75L, 76L, 78L,
    79L, 80L, 81L, 82L, 83L, 84L, 85L, 86L, 87L, 88L, 89L, 90L, 92L, 93L, 94L,
    95L, 96L, 97L, 98L, 100L, 103L, 104L, 105L, 106L, 107L, 110L, 111L, 112L,
    113L, 114L, 115L, 116L, 117L, 118L, 119L, 120L, 121L, 122L, 123L, 124L, 125L,
    126L, 127L, 128L, 129L, 130L, 131L, 133L, 134L, 137L, 139L, 140L, 142L, 143L,
    145L, 146L, 147L, 148L, 154L, 157L, 158L, 159L, 161L, 162L, 163L, 164L, 165L,
    166L, 167L, 168L, 169L, 170L, 171L, 173L, 176L, 177L, 178L, 179L, 180L, 181L,
    182L, 183L, 184L, 185L, 186L, 188L, 189L, 190L, 191L, 192L, 193L, 194L, 195L,
    196L, 197L, 198L, 199L, 200L, 201L, 202L, 203L, 204L, 205L, 206L, 207L, 208L,
    209L, 210L, 211L, 212L, 213L, 214L, 215L, 216L, 217L, 218L, 219L, 220L, 221L,
    222L, 223L, 224L, 225L, 226L, 227L, 228L, 229L, 230L, 231L, 232L, 233L
  ),
  name = c(
    "m**2 s**-1", "K", "(0 - 1)", "m", "m s**-1", "J m**-2", "~", "s**-1",
    "kg m**-3", "m**3 m**-3", "10**-6 W m**-2 sr**-1 m**-1", "s", "mol mol**-1",
    "N m**-2 s", "m**2 s**-2", "Pa", "J kg**-1", "K m**2 kg**-1 s**-1",
    "m**2 m**-2", "s m**-1", "kg kg**-1", "kg m**-2", "dimensionless", "m**-3",
    "Various", "Pa s**-1", "m of water equivalent", "gpm", "%", "radians", "m**2",
    "N m**-2", "kg m**-2 s**-1", "(-1 to 1)",
    "Millimetres*100 + number of stations", "kg m**-2 s", "K s**-1", "m**2 s**-3",
    "kg kg**-1 s**-1", "DU", "degrees", "m**2 s radian**-1", "deg C", "psu",
    "kg m**-3 -1000", "m s**-2", "m s**-1 deg C", "m s**-1 degC", "m**3 s**-1",
    "N m**-3", "Nm**-3", "degrees C", "J m**-1 s**-1", "m s**-1 per time step",
    "psu per time step", "deg C per time step", "Pa m**-1", "N m**-2 s**-1",
    "K m**2 s**-2", "m**3 s**-3", "K m s**-1", "Pa m**2 s**-3", "K Pa s**-1",
    "Pa m s**-2", "K kg m**-2", "kg m**-1 s**-1", "m**4 s**-4", "m**2 K s**-2",
    "K**2", "m s**-1 K", "m**2 Pa s**-3", "Pa s**-1 K", "m Pa s**-2",
    "Pa**2 s**-2", "Pa**2", "W m**-2", "m of water equivalent s**-1",
    "W m**-2 s**-1", "kg C m**-2 s**-1", "(Code table 4.239)",
    "g kg**-1 m**-2 s**-1", "g kg**-1 s**-1", "W**-2 m**4", "kg s**-1 m**-2",
    "m**-1", "m**3 m**-2", "J kg**-1 s**-1", "s**-2", "kg s**2 m**-5",
    "Degree true", "W m**-1 sr**-1", "W m**-3 sr**-1", "J", "m**-1 sr**-1",
    "m**2/3 s**-1", "day", "(Code table 4.201)", "(Code table 4.202)",
    "(Code table 4.222)", "Proportion", "Numeric", "km**-2 day**-1",
    "(Code table 4.203)", "(Code table 4.204)", "(Code table 4.234)",
    "(Code table 4.205)", "Dobson", "dB", "kg m**-1", "Bq m**-3", "Bq m**-2",
    "Bq s m**-3", "(Code table 4.206)", "(Code table 4.207)",
    "(Code table 4.208)", "(Code table 4.209)", "(Code table 4.210)",
    "(Code table 4.211)", "CCITTIA5", "(Code table 4.215)", "(Code table 4.216)",
    "kg**-2 s**-1", "(Code table 4.212)", "(Code table JMA-252)",
    "(Code table 4.219)", "Degree", "J m**-2 K**-1", "kg (m**2 s**-1)**-1",
    "kg (kg s**-1)**-1", "cm per day", "g kg**-1 m", "mm per day",
    "m s**-1 per day", "g kg**-1", "deg", "(s m**-1)**-1", "ln(kPa)",
    "kg (m**2 s-1)**-1", "10**-3", "(10**-6 g) m**-3", "log10((10**-6g) m**-3)",
    "ppb", "mm**6 m**-3", "categorical", "Integer", "log10(kg m**-3)", "Fraction",
    "ppm", "Integer(0-13)", "10**-3 m**-2", "Index", "degreeperday", "psuperday",
    "W m**-1", "W", "kg**2 m**-4", "s**-1 m**-2", "Degree N", "Degree E",
    "m**3 kg**-1 s**-1", "m**2 kg**-1 s**-1", "W m sr m**-2", "10**5 s**-1",
    "K s**-2", "K m**-1", "Pa hPa", "Ws m**-2", "cbar s**-1", "cm", "dam", "hPa",
    "image^data", "kg m**-2/day", "ln(cbar)", "m cm", "m s**-12", "m**2 s**-12",
    "mb", "s s**-1", "s**-12", "-/+", "m**3", "m**3 s**-1 m**-1",
    "(Code table 4.217)", "(Code table 4.218)", "(Code table 4.223)", "K per day",
    "kg kg**-1 per day", "mg kg**-1", "kg m**-3 s**-1", "psu*m", "hour",
    "Number m**-2", "Person m**-2", "Bites per day per person", "Byte", "J m**-1",
    "W s", "km**-2", "day**-1", "% K", "% m**3 m**-3", "K K", "K m**3 m**-3",
    "m**3 m**-3 m**3 m**-3", "(Code table 4.213)", "(Code table 4.106)",
    "(Code table 4.253)"
  )
)