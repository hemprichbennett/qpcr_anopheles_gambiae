library(tidyverse)
library(here)



# Fig 1 -------------------------------------------------------------------


df <- read_csv(here('data', 'processed_data', 'fig1_input.csv')) %>%
  janitor::clean_names()%>%
  select(sample_name, species, ct) %>%
  filter(!species %in% c('Negative control', 'Testsample_SiinEx328_A5')) %>%
  mutate(species = gsub('Soyo2024', 'Anopheles gambiae s.l.', species))


# --- helper: zero-anchored logistic curve generator ---
amp_curve_zero_anchor <- function(cycle, Ct, k = 0.9, maxd = 98, start_cycle = 0) {
  raw  <- 1 / (1 + exp(-k * (cycle - Ct)))
  raw0 <- 1 / (1 + exp(-k * (start_cycle - Ct)))
  scaled <- maxd * (raw - raw0) / (1 - raw0)
  pmax(scaled, 0)
}

# --- prepare metadata and mapping for visual appearance ---
plot_meta <- df %>%
  mutate(
    Ct_num = as.numeric(ct),
    # extract dilution tag from sample_name: "1:10", "1:100", or undiluted / No Ct
    dilution = case_when(
      str_detect(sample_name, "1:100|\\(1:100\\)") ~ "1:100",
      str_detect(sample_name, "1:10|\\(1:10\\)")   ~ "1:10",
      #is.na(Ct_num)                                 ~ "No Ct",
      TRUE                                          ~ "undiluted"
    ),
    # choose slope & plateau by dilution for visual separation (tweak as needed)
    k = case_when(
      dilution == "undiluted" ~ 1.05,
      dilution == "1:10"      ~ 0.85,
      dilution == "1:100"     ~ 0.65,
      #dilution == "No Ct"     ~ 0.3,
      TRUE                    ~ 0.85
    ),
    maxd = case_when(
      dilution == "undiluted" ~ 98,
      dilution == "1:10"      ~ 92,
      dilution == "1:100"     ~ 88,
      #dilution == "No Ct"     ~ 0,
      TRUE                    ~ 60
    )
  )

# create cycle grid including 0 so lines begin at (0,0)
cycles <- tibble(Cycle = 0:40)

# expand and compute dRn per sample
plotdata <- plot_meta %>%
  crossing(cycles) %>%
  mutate(
    dRn = if_else(is.na(Ct_num),
                  0,   # No Ct -> flat zero
                  amp_curve_zero_anchor(Cycle, Ct_num, k = k, maxd = maxd, start_cycle = 0))
  ) %>%
  # make the facet labels
  mutate(
    # ensure species is plain character
    species = as.character(species),
    # escape any double-quotes inside names (rare, but safe)
    species_escaped = gsub('"', '\\"', species, fixed = TRUE),
    # build the label string that label_parsed() can parse:
    #  - italic("Aedes japonicus") for Aedes/Anopheles/Culex
    #  - "NK" (quoted) for everything else so parse() yields a literal string
    species_label = ifelse(
      grepl("^(Aedes|Anopheles|Culex)", species_escaped),
      paste0('italic("', species_escaped, '")'),
      paste0('"', species_escaped, '"')
    ),
    # ensure it's character (not factor)
    species_label = as.character(species_label)
  )
# 
# # order factor levels for nicer facet ordering (optional)
# plotdata <- plotdata %>%
#   mutate(species_label = fct_inorder(species_label))

# colour / linetype mapping for dilution groups
cols <- c("undiluted" = "#1f77b4", "1:10" = "#8fc06e", "1:100" = "#bfe6b3")
lts  <- c("undiluted" = "solid", "1:10" = "dashed", "1:100" = "dotdash")



# --- plotting: facet by species ---
p <- ggplot(plotdata, aes(x = Cycle, y = dRn, group = sample_name,
                          color = dilution, linetype = dilution)) +
  geom_line(size = 1) +
  # threshold and baseline lines
  geom_hline(yintercept = 20, color = "black", size = 0.8) +   # threshold
  geom_hline(yintercept = 0,  color = "#d62728", size = 0.5, alpha = 0.8) + # baseline
  # keep all data (do not drop) and avoid clipping thick strokes
  coord_cartesian(xlim = c(0, 40), ylim = c(0, 100)) +
  scale_x_continuous(breaks = seq(0, 40, 5), expand = c(0,0)) +
  scale_y_continuous(expand = expansion(mult = 0, add = c(0, 2))) +
  scale_color_manual(values = cols) +
  scale_linetype_manual(values = lts) +
  labs(x = "Cycle", y = "dRn", color = "Dilution", linetype = "Dilution") +
  theme_bw(base_size = 13) +
  theme(
    plot.background  = element_rect(fill = "#f5f5f5", colour = NA),
    panel.background = element_rect(fill = "white", colour = NA),
    panel.border     = element_rect(color = "black", size = 1),
    panel.grid.major = element_line(color = "grey90"),
    panel.grid.minor = element_line(color = "grey95"),
    legend.position  = "bottom",
    strip.text       = element_text(face = "plain"),
    axis.title       = element_text(face = "bold"),
    text=element_text(size=12)
  ) +
  facet_wrap(~ species_label, ncol = 2, labeller = label_parsed)


p

# save (note: default units are inches; change units if you prefer)
ggsave(filename = here('figures', 'figure_1.png'), plot = p,
       units = "in", dpi = 300)



# Fig 2 -------------------------------------------------------------------

fig2_input <- read_csv(here('data', 'processed_data', 'fig2_input.csv'))



# zero-anchored logistic amplification curve (value = 0 at start_cycle)
amp_curve_zero_anchor <- function(cycle, Ct, k = 0.9, maxd = 98, start_cycle = 0) {
  raw  <- 1 / (1 + exp(-k * (cycle - Ct)))
  raw0 <- 1 / (1 + exp(-k * (start_cycle - Ct)))
  scaled <- maxd * (raw - raw0) / (1 - raw0)
  pmax(scaled, 0)
}

# build params: map each sample to a Ct (numeric, NA for 'No Ct'), slope and plateau (maxd)
params <- fig2_input %>%
  rename(sample = `Sample name`) %>%
  mutate(
    Ct_num = suppressWarnings(as.numeric(Ct)),   # NA if "No Ct"
    # choose slope (k) and plateau (maxd) to give visually distinct plateaus
    k = case_when(
      str_detect(sample, "50c")  ~ 1.0,
      str_detect(sample, "25c")  ~ 0.9,
      str_detect(sample, "10c")  ~ 0.8,
      str_detect(sample, "5c")   ~ 0.7,
      sample == "Negative control" ~ 0.4,
      TRUE ~ 0.85
    ),
    maxd = case_when(                 # visual plateaus (tweak to taste)
      str_detect(sample, "50c")  ~ 95,
      str_detect(sample, "25c")  ~ 78,
      str_detect(sample, "10c")  ~ 64,
      str_detect(sample, "5c")   ~ 30,
      sample == "Negative control" ~ 0,
      TRUE ~ 60
    )
  )

# cycle grid including 0
cycles <- tibble(Cycle = 0:40)

# expand and compute dRn (negative control / No Ct -> flat zero)
plotdata <- params %>%
  crossing(cycles) %>%
  mutate(
    dRn = if_else(is.na(Ct_num),
                  0,
                  amp_curve_zero_anchor(Cycle, Ct_num, k = k, maxd = maxd, start_cycle = 0))
  )

# set factor order for legend
plotdata <- plotdata %>%
  mutate(sample = gsub('S-G304_PLS_', '', sample),
    sample = factor(sample,
                         levels = c("50c/µl",
                                    "25c/µl",
                                    "10c/µl",
                                    "5c/µl",
                                    "Negative control"))
         )


# Plot
p2 <- ggplot(plotdata, aes(x = Cycle, y = dRn,#
                           #color = sample, group = sample
                           )) +
  # amplification lines
  geom_line(size = 1.2) +
  facet_wrap(.~ sample)+
  # threshold line (black) and baseline (red)
  geom_hline(yintercept = 20, color = "blue", size = 0.8) +   # threshold - adjust if needed
  geom_hline(yintercept = 0,  color = "#d62728", size = 0.5, alpha = 0.8) + # red baseline
  # axes ranges via coord_cartesian to avoid clipping thick lines
  coord_cartesian(xlim = c(0, 40), ylim = c(0, 100)) +
  scale_x_continuous(breaks = seq(0, 40, by = 5), expand = c(0,0)) +
  scale_y_continuous(expand = expansion(mult = 0, add = c(0, 2))) +
  #scale_colour_viridis_d()+
  #scale_color_manual(values = col_map, guide = guide_legend(reverse = FALSE)) +
  labs(x = "Cycle", y = "dRn", color = NULL) +
  # styling to mimic the example (outer grey background + inner black framed panel)
  theme_bw(base_size = 14) +
  theme(
    text = element_text(size = 12),
    legend.position = 'bottom'
  )

# show
print(p2)

ggsave(here('figures', 'figure_2.png'))


