library(here)
library(BOLDconnectR)
library(tidyverse)
library(janitor)
library(seqinr)
# load my personal api key
source(here('logins', 'bold_api_key.R'))

# log in using it
bold.apikey(bold_api_key)


our_projects <- bold.fetch(get_by = 'project_codes', 
                           identifier = c('GCEP', 'TMGHA', 'TMGB')) %>%
  clean_names() %>%
  separate(coord, sep = ',', into = c('lat', 'lon'), remove = F)

to_save <- our_projects %>%
  mutate(seqnames = paste(kingdom, phylum, class, order, family, 
                          genus, species, sep = '|')) %>%
  filter(!is.na(nuc)) %>%
  select(seqnames, nuc) %>%
  distinct()

outfile_path <- here('results',
                     paste0('bold_download_',
                            as.character(Sys.Date()),'.fa'))

seqinr::write.fasta(sequences = as.list(to_save$nuc),
                    names = to_save$seqnames,
                    file.out = outfile_path)
