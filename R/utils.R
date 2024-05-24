#' Title
#'
#' @return
#' @export
#'
#' @examples
load_proj_paths <- function(){
  list(
    GAUL0_PATH = file.path(
      Sys.getenv("AA_DATA_DIR"),
      "public",
      "raw",
      "glb",
      "asap",
      "reference_data",
      "gaul0_asap_v04"
    )
  )
}
