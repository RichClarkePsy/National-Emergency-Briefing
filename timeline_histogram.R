# Load package
library(tidyverse)

# Read the simplified NEB screenings data
neb_screenings <- read_csv("neb_screenings.csv")

# Filter for known date and create a week-starting date
timeline_data <- neb_screenings |>
  mutate(screening_date = dmy(date)) |>
  filter(!is.na(screening_date)) |>
  mutate(week_start = floor_date(screening_date, unit = "week", week_start = 1),
    timing = case_when(screening_date < Sys.Date() ~ "Past events",
      TRUE ~ "Upcoming events"))


# Count screenings in each week
weekly_screenings <- timeline_data |>
  count(week_start, timing, name = "screenings")

# Draw a simple weekly histogram
timeline_histogram <- ggplot(weekly_screenings,
  aes(x = week_start, y = screenings, fill = timing)) +
  geom_col(width = 6) +
  scale_fill_manual(values = c("Past events" = "#A1D99B", 
                               "Upcoming events" = "#006D2C")) +
  scale_x_date(date_breaks = "1 week", date_labels = "%d %b") +
  labs(title = "National Emergency Briefing screenings by week",
       x = NULL,
       y = "Number of screenings",
       fill = NULL) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        panel.grid.minor = element_blank())

# Show the histogram
timeline_histogram
