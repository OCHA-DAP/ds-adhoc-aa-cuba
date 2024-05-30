# Requets for data set to see windspeed and distance of cyclones to Cuba
library(dplyr)

IBTRACS_DIR <- file.path(
  Sys.getenv("AA_DATA_DIR_NEW"),
  "public",
  "processed",
  "glb",
  "ibtracs"
) 

GAUL0_PATH = file.path(
  Sys.getenv("AA_DATA_DIR"),
  "public",
  "raw",
  "glb",
  "asap",
  "reference_data",
   "gaul0_asap_v04"
)
adm0 <- st_read(
  AUL0_PATH,
  "gaul0_asap"
  )

cuba_asap0_id <- adm0 |> 
  filter(name0=="Cuba") |> 
  pull(asap0_id)

# All track data lat,lon, windspeed, time
tracks <- file.path(
  IBTRACS_DIR,
  "ibtracs_with_wmo_wind.parquet"
) |> 
  arrow::read_parquet()


# All distances -- all countries
df_dist_cuba <- file.path(
  IBTRACS_DIR,
  "all_adm0_distances.parquet" 
) |> 
  arrow::open_dataset() |> 
  # filter to all distances from cuba <= 250 km
  filter(
    asap0_id==cuba_asap0_id,
    `distance (m)`<300000
  ) |> 
  collect()

# join filtered distances to tracks
df_cuba_cyclones <- df_dist_cuba |> 
  left_join(
    tracks, by = "row_id"
  ) |> 
  filter(
    as_date(time) >= as_date("2000-01-01") 
    
  ) |> 
  select(time,name,`distance (m)`,wmo_wind) |> 
  arrange(time, name) 


df_cuba_cyclones |> 
  group_by(
    name
  ) |> 
  summarise(
    dist = min(`distance (m)`),
    wind = max(wmo_wind)
  ) |> 
  ggplot(
    aes(x= dist, wind)
  )+
  geom_point()


df_cuba_cyclones |> 
  write_csv(
    "cuba_ibtracs_windspeed_distance.csv"
  )
