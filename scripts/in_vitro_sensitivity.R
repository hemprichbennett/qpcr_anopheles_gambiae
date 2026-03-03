# script for representing the qPCR sensitivity data from Sinsoma
library(tidyverse)
library(here)

in_tib <- read_csv(here('data', 'raw_data', 'sensitivity_test_results.csv'))
  

sensitivity_summary <- in_tib %>%
  mutate(worked = ifelse(is.na(ct), 0, 1)) %>%
  # calculate summary stats for each concentration
  group_by(concentration) %>%
  summarise(n_replicates = n(),
            n_viable = sum(worked),
            # using na.rm as otherwise any treatment that failed once or more
            # will get a mean and sd of 'NA'
            mean_ct = mean(ct, na.rm = T),
            sd_ct = sd(ct, na.rm = T)
            ) %>%
  # round the mean and sd columns to 2 decimal places
  mutate(mean_ct = round(mean_ct, digits = 2), 
         sd_ct = round(sd_ct, digits = 2)) %>%
  # reorder the tibble's rows so concentration goes from biggest to smallest
  arrange(desc(concentration))

sensitivity_summary

# write output file
write_csv(sensitivity_summary,
          file = here('results', 'sensitivity_summary.csv'))
