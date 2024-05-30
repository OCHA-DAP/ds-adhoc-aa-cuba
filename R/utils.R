#' Title
#'
#' @return
#' @export
#'
#' @examples
load_proj_paths <- function(){
  list(
    GAUL0 = file.path(
      Sys.getenv("AA_DATA_DIR"),
      "public",
      "raw",
      "glb",
      "asap",
      "reference_data",
      "gaul0_asap_v04"
    ),
    IBTRACS = file.path(
      Sys.getenv("AA_DATA_DIR_NEW"),
      "public",
      "processed",
      "glb",
      "ibtracs"
    ) ,
    CHIRPS_ADM0 = "20240524_chirps_daily_historical_cuba.csv"
  )
}
