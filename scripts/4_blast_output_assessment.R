# Setup -------------------------------------------------------------------

library(tidyverse)
library(here)

all_results <- list.files(path = here('data', 'blast_outputs'),
                          pattern = '.tsv',
                          full.names = T) %>%
  map(read_delim, 
         col_names = c("qseqid", "sseqid", "pident", "length", "mismatch", 
                       "gapopen", "qstart", "qend", "sstart", "send", "evalue", 
                       "bitscore", "staxids", "sscinames", "scomnames"))

#! Need to filter by scores etc, the presence of a sequence doesn't mean 
# it had a good match for the binding site

for(i in 1:length(all_results)){
  all_results[[i]] <- all_results[[i]] %>%
    # there's a weird glitch where a low number of rows contain multiple taxa,
    # and so rather than having an integer staxid, they have two separated by a ;
    # which makes the entire column be formatted as a character instead of a double.
    # remove the characters after the ;, and format the column as numeric so that
    # the tibbles can be combined. We still retain the duplicate values in the 
    # character columns 'sscinames' and 'scommnames', so we can check on them later
    mutate(staxids = gsub('\\;.+', '', staxids),
           staxids = as.numeric(staxids),
          # add a column saying which pair of primers the tibble corresponds to
           primer_pair = i) %>%
    # change the qseqid (currently just an 'f' or 'r' depending on which 
    # amplification is present in that row), for more descriptive use as a 
    # column name
    mutate(qseqid = paste0(qseqid, '_primer'),amplified = T) 
}

# Now make a long tibble, to look at the scores etc of all of the BLAST 
# 'matches' we got

# combine the data
full_results_long <- bind_rows(all_results)


full_results_long <- full_results_long %>%
  mutate(anopheles = grepl('Anopheles', sscinames))

# make a tibble of just taxonomic information, to be used later after 
# rearranging the data
taxonomy <- full_results_long %>%
  select(sseqid, sscinames, scomnames) %>%
  distinct()

# we currently have a row for every match, but what we care about is if a 
# taxa matches BOTH primers for a given primer pair
wide_results_list <- list()
for(i in 1:length(all_results)){
  wide_results_list[[i]] <- all_results[[i]] %>%
    # we currently have a row for every match, but what we care about is if a 
    # taxa matches BOTH primers for a given primer pair
    select(primer_pair, qseqid, staxids,sseqid, amplified) %>%
    distinct() %>%
    pivot_wider(names_from = qseqid, values_from = amplified) %>%
    mutate(both_amplified = f_primer == T & r_primer == T)
}

wide_results_tib <- bind_rows(wide_results_list) %>%
  left_join(taxonomy)

# make a tibble of only full amplifications
positive_results_tib <- wide_results_tib %>%
  filter(both_amplified == T)

both_primers_matched <- positive_results_tib %>% 
  group_by(sscinames) %>% 
  summarise(nhits = n())





# filter only for those where both primers matched
long_matches_only <- full_results_long %>%
  filter(sscinames %in% both_primers_matched$sscinames)

non_anopheles_matches <- long_matches_only %>%
  filter(anopheles == F)
