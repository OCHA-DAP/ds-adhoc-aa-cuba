library(zoo)
library(dplyr)
library(sf)
library(arrow)
library(lubridate)

fps <- load_proj_paths()
allocation_years <- c(
  2008,
  2012,
  2016,
  2017,
  2019 ,
  2022
)
df_chirps <- read_csv(load_proj_paths()$CHIRPS_ADM0)

df_chirps |> 
  mutate(
    roll2 = rollsumr(value,k= 2,fill= NA)
  )



# Requets for data set to see windspeed and distance of cyclones to Cuba

adm0 <- st_read(
   fps$GAUL,
  "gaul0_asap"
)



tracks <- read_parquet(
  file.path(
    fps$IBTRACS,
    "ibtracs_with_wmo_wind.parquet"
  )
)

cuba_asap0_id <- adm0 |> 
  filter(name0=="Cuba") |> 
  pull(asap0_id)

# All distances -- all countries
df_dist_cuba <- file.path(
  fps$IBTRACS,
  "all_adm0_distances.parquet" 
) |> 
  open_dataset() |>  # lazy load
  # filter to all distances from cuba <= 250 km
  filter(
    asap0_id==cuba_asap0_id,
    # `distance (m)`<300000
  ) |> 
  collect()

# join filtered distances to tracks
df_cuba_cyclones <- df_dist_cuba |> 
  left_join(
    tracks,
    by = "row_id"
  ) |> 
  select(time,name,dist= `distance (m)`,wmo_wind) |> 
  arrange(time, name) 

cyclone_filtered <- df_cuba_cyclones |> 
  filter(
    as_date(time) >= min(df_chirps$date),
    as_date(time) <= max(df_chirps$date),
  )

cyclone_names_landfall <- cyclone_filtered |> 
  filter(
    dist == 0
  ) |> 
  pull(name) |> 
  unique()

cyclone_filtered |> 
  filter(
    name %in% cyclone_names_landfall
  ) 
  ggplot(
    aes()
  )

  
  ex_func <- function(df,
                      data_source = "string"){
    df |> 
      mutate(
        data_source = data_source
      )
  }
cyclone_filtered  |> 
  ex_func()
