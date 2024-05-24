library(rgee)
library(tidyverse)
library(tidyrgee)
library(targets)
library(here)
library(sf)

box::use(../R/utils[load_proj_paths])

ee_Initialize(project = "ee-zackarno")

fps <- load_proj_paths()

gdf_adm0 <-  st_read(fps$GAUL0_PATH,"gaul0_asap") |> 
  filter(name0=="Cuba")

cat("reading and manipulate image collection\n")
ic <- ee$ImageCollection("UCSB-CHG/CHIRPS/DAILY")
tic <- as_tidyee(ic)

gdf_adm0 <- gdf_adm0 %>% 
  select(
    asap0_id,
    name0,
    )


gdf_adm0_simp <- st_simplify(
  gdf_adm0,
  dTolerance = 5000
)


pct_reduction <- 1- mapview::npts(gdf_adm0_simp)/mapview::npts(gdf_adm0)




cat("reduced feature vertices by", pct_reduction,"\n")
fc_aoi <- sf_as_ee(x = gdf_adm0_simp)


ic_aoi <- ic$filterBounds(fc_aoi)

# cat("Begin Downloading CHIRPS COGS","\n")
# ee_imagecollection_to_local(ic = ic_aoi,
#                             region = fc_aoi$geometry(),
#                             dsn = file.path(out_dir,"moz_chirps_"),
#                             via = "drive",
#                             scale = 5566
#                               )
# tic_test <- tic %>%
#   filter(doy== 3, year %in% c(2021, 2022))
tic_dekad_labelled <- tic %>% 
  mutate(
    dekad_abbr = case_when(
      year %in% c(1980:1989)~"80s",
      year %in% c(1990:1999)~"90s",
      year %in% c(2000:2009)~"2000s",
      year %in% c(2010:2019)~"2010s",
      year >= 2020 ~"2020s"
    )
  ) 

# started at 2:10 pm
df_rainfall_adm <- unique(tic_dekad_labelled$vrt$dekad_abbr) %>%
  map(
    \(dekad_tmp){
      cat("downloading data for year ", dekad_tmp,"\n")
      tic_temp <- tic_dekad_labelled %>%
        filter(
          dekad_abbr == dekad_tmp
        )
      ee_extract_tidy(
        x = tic_temp,
        y = fc_aoi,
        scale = 5566,
        stat = "mean",
        via = "drive"
      )
    }
  ) %>%
  list_rbind()
# df_rainfall_adm <- ee_extract_tidy(
#   x = tic,
#   y = fc_aoi,
#   scale = 5566,
#   stat = "mean",
#   via = "drive"
# )


# df_rainfall_adm <- rgee::ee_extract(
#   x = ic,
#   y = fc_aoi,
#   scale = 5566,
#   fun = ee$Reducer$mean(),
#   via = "drive"
# )
# 
# df_rainfall_adm <- df_rainfall_adm %>% 
#   pivot_longer(cols = starts_with("X"))
#   
# 
prefix_date <- format(Sys.Date(), "%Y%m%d")
# cat("write zonal sats to csv\n")
write_csv(
  x = df_rainfall_adm,
  file = file.path(
    paste0(
      prefix_date, "_chirps_daily_historical_cuba.csv"
    )
  )
)
# cat("finished")