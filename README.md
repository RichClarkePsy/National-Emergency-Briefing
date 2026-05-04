# National Emergency Briefing TidyTuesday

This folder contains a small, simplified version of the National Emergency Briefing dataset.

The [National Emergency Briefing](https://www.nebriefing.org) is a UK campaign built around a film and public briefings about the climate and nature emergency. Local organisers can host screenings, and MPs are invited to sign a Parliamentary Call supporting emergency action.

## Files

- `neb_screenings.csv` lists the recorded screenings, based on the campaign's [screening map](https://www.nebriefing.org/screening-map).
- `mps_signing_status.csv` lists current MPs, their constituencies, and whether they have signed the [Parliamentary Call](https://www.nebriefing.org/parliamentary-call).
- `campaign_status_map.R` creates a simple constituency campaign status map.
- `timeline_histogram.R` creates a simple weekly timeline histogram of dated screenings.

## Notes

The screening data includes a constituency name amendment for Montgomeryshire and Glyndwr so that it matches the July 2024 Westminster constituency boundaries used in the map script.

The MP signing data includes the two UK parliamentary by-election changes listed by Parliament since the 2024 general election: Sarah Pochin for Runcorn and Helsby, elected on 1 May 2025, and Hannah Spencer for Gorton and Denton, elected on 26 February 2026. Source: [UK Parliament by-elections since the 2024 general election](https://www.parliament.uk/about/how/elections-and-voting/by-elections/by-elections-since-the-2024-general-election/).
