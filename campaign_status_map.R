# Load packages
library(tidyverse)
library(sf)
library(stringi)

# Read the simplified data files
neb_screenings <- read_csv("neb_screenings.csv", show_col_types = FALSE)
mps_signing_status <- read_csv("mps_signing_status.csv", show_col_types = FALSE)

# Download Westminster constituency boundaries from ONS
constituency_boundaries_url <- paste0("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/",
  "Westminster_Parliamentary_Constituencies_July_2024_Boundaries_UK_BGC/",
  "FeatureServer/0/query?",
  "where=1%3D1&outFields=*&f=geojson")

constituencies <- st_read(constituency_boundaries_url, quiet = TRUE)

# Make simple matching names for joining local data to boundary data
constituencies <- constituencies |>
  mutate(constituency_match = PCON24NM |>
           stri_trans_general("Latin-ASCII") |>
           str_to_lower() |>
           str_squish())

mps_signing_status <- mps_signing_status |>
  mutate(constituency_match = constituency |>
           stri_trans_general("Latin-ASCII") |>
           str_to_lower() |>
           str_squish())

neb_screenings <- neb_screenings |>
  mutate(screening_date = suppressWarnings(dmy(date)),
         screening_timing = case_when(is.na(screening_date) ~ "Date TBC",
                                      screening_date < Sys.Date() ~ "Past",
                                      TRUE ~ "Upcoming"),
    constituency_match = constituency |>
      stri_trans_general("Latin-ASCII") |>
      str_to_lower() |>
      str_squish())

# Count past, upcoming, and date TBC screenings in each constituency
screenings_by_constituency <- neb_screenings |>
  group_by(constituency_match) |>
  summarise(past_screenings = sum(screening_timing == "Past"),
            upcoming_screenings = sum(screening_timing == "Upcoming"),
            tbc_screenings = sum(screening_timing == "Date TBC"),
            .groups = "drop")

# Join the MP and screening data to the constituency boundaries
map_data <- constituencies |>
  left_join(mps_signing_status, by = "constituency_match") |>
  left_join(screenings_by_constituency, by = "constituency_match") |>
  mutate(signed_call = replace_na(signed_call, FALSE),
         past_screenings = replace_na(past_screenings, 0),
         upcoming_screenings = replace_na(upcoming_screenings, 0),
         tbc_screenings = replace_na(tbc_screenings, 0))

# Create a simple campaign status variable for the map colours
map_data <- map_data |>
  mutate(campaign_status = case_when(
    past_screenings > 0 & signed_call ~ "Past screening and MP signed",
    past_screenings > 0 & !signed_call ~ "Past screening and MP not signed",
    upcoming_screenings > 0 & signed_call ~ "Upcoming screening and MP signed",
    upcoming_screenings > 0 & !signed_call ~ "Upcoming screening and MP not signed",
    tbc_screenings > 0 & signed_call ~ "Date TBC screening and MP signed",
    tbc_screenings > 0 & !signed_call ~ "Date TBC screening and MP not signed",
    signed_call ~ "No screening recorded and MP signed",
    TRUE ~ "No screening recorded and MP not signed"))

# Draw the campaign status map
campaign_status_map <- ggplot(map_data) +
  geom_sf(aes(fill = campaign_status), colour = "white", linewidth = 0.05) +
  scale_fill_manual(values = c("Past screening and MP signed" = "#006D2C",
                               "Past screening and MP not signed" = "#8B0000",
                               "Upcoming screening and MP signed" = "#31A354",
                               "Upcoming screening and MP not signed" = "#FC9272",
                               "Date TBC screening and MP signed" = "#B8860B",
                               "Date TBC screening and MP not signed" = "#FEE08B",
                               "No screening recorded and MP signed" = "#A1D99B",
                               "No screening recorded and MP not signed" = "#BDBDBD")) +
  labs(title = "National Emergency Briefing campaign status by constituency",
       fill = "Campaign status",
       caption = "Boundary data: ONS Westminster Parliamentary Constituencies, July 2024") +
  theme_void() +
  theme(plot.title = element_text(face = "bold"),
        legend.position = "right")

# Show the map
campaign_status_map
