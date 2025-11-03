# possible primer combinations due to degenerate bases
library(tidyverse)
f_initial_degenerate_primer <- 'GCTATACTRGCAATTGGYTTAC'
r_initial_degenerate_primer <- 'YARTATAGCYGGDCTATAAGTT'

possible_combinations <- expand_grid(
            p1_degen_1 = c('A', 'G'),
            p1_degen_2 = c('C', 'T'),
            p2_degen_1 = c('C', 'T'),
            p2_degen_2 = c('A', 'G'),
            p2_degen_3 = c('C', 'T'),
            p2_degen_4 = c('A', 'G', 'T'))

full_primer_combinations <- possible_combinations %>%
  mutate(f_primer = paste0('GCTATACT',p1_degen_1, 'GCAATTGG', p1_degen_2, 'TTAC'),
         r_primer = paste0(p2_degen_1, 'A', p2_degen_2, 'TATAG', p2_degen_3,
                           'GG', p2_degen_4, 'CTATAAGTT'))

write_csv(full_primer_combinations, 'data/processed_data/degenerate_base_combinations.csv')

full_primer_combinations %>%
  select(f_primer, r_primer) %>%
  write_csv(., file = 'data/processed_data/primer_combinations_for_bioinformatics.csv',
            col_names = F)
