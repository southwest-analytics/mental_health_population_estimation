library(tidyverse)
library(readxl)
library(shiny)
library(shinyjs)
library(shinyTree)
library(htmltools)
library(conflicted)

filename_gbd_data <- '.\\www\\England_Regions_and_UTLA_Incidence_and_Prevalence.csv'
filename_gbd_hierarchies <- '.\\www\\GBD_Hierarchies.xlsx'
filename_popn_data <- '.\\www\\gp-reg-pat-prac-quin-age.csv'
filename_popn_hierarchies <- '.\\www\\gp-reg-pat-prac-map.csv'

# GBD Hierarchies ----
# ════════════════════

# Locations 
# ─────────
# England 4749
#   East Midlands 4621
#     ...
#   East of England 4623
#     ...
#   Greater London 4624
#     ...
#   North East England 4618
#     ...
#   North West England 4619
#     ...
#   South East England 4625
#     ...
#   South West England 4626
#     ...
#   West Midlands 4622
#     ...
#   Yorkshire and the Humber 4620
#     ...

# Causes
# ──────
# Mental disorders 558
#   Schizophrenia 559
#   Depressive disorders 567
#     ...
#   Bipolar disorder 570
#   Anxiety disorders 571
#   Eating disorders 572
#     ...
#   Autism spectrum disorders 575
#   Attention-deficit/hyperactivity disorder 578
#   Conduct disorder 579
#   Idiopathic developmental intellectual disability 582
#   Other mental disorders 585

# Substance use disorders 973
#   Alcohol use disorders 560
#   Drug use disorders 561
#     ...


# Load the GDB data ----
# ══════════════════════
df_gbd_data <- read.csv(filename_gbd_data)

# Create lookup data frame
df_codes <- data.frame(code = as.integer(), desc = as.character(), field = as.character()) %>%
  # measure_name
  bind_rows(
    data.frame(code = c(5, 6), 
               desc = c('Prevalence', 'Incidence'), 
               field = c('measure_name'))) %>%
  # sex_name
  bind_rows(
    data.frame(code = c(1, 2), 
               desc = c('Male', 'Female'),
               field = c('sex_name'))) %>%
  # age_name
  bind_rows(
    data.frame(code = c(1, 6:20, 30:32, 235, 22),
               desc = c('00_04', '05_09', '10_14', '15_19', '20_24', '25_29',
                        '30_34', '35_39', '40_44', '45_49', '50_54', '55_59',
                        '60_64', '65_69', '70_74', '75_79', '80_84', '85_89',
                        '90_94', '95+', 'Total'),
               field = 'age_name')) %>%
  # metric_name
  bind_rows(
    data.frame(code = 3,
               desc = 'Rate',
               field = 'metric_name')) %>%
  # population_area
  bind_rows(
    data.frame(code = c(1:5),
               desc = c('Comm Region', 'ICB', 'SUB_ICB_LOCATION_CODE', 'PCN', 'GP'),
               field = 'population_area'))
  
df_gbd_locations <- read_excel(path = filename_gbd_hierarchies,
                               sheet = 'GBD 2021 Locations Hierarchy') %>%
  rename_with(.fn = ~c('version', 'loc_id', 'loc_name', 'parent_id', 'level', 'sort_order'))

df_gbd_causes <- read_excel(path = filename_gbd_hierarchies,
                            sheet = 'Cause Hierarchy') %>%
  rename_with(.fn = ~c('cause_id', 'cause_name', 'parent_id', 'parent_name', 
                       'level', 'cause_outline', 'sort_order', 'yll_only', 'yld_only'))

cause_tree <- dfToTree(df_gbd_causes %>% 
                         dplyr::filter(cause_id %in% c(558, 973)) %>% 
                         mutate(level_1_id = parent_id, level_1_name = parent_name, level_2_id = cause_id, level_2_name = cause_name,
                                .keep = 'none') %>%
                         left_join(
                           df_gbd_causes %>% 
                             mutate(level_2_id = parent_id, level_3_id = cause_id, level_3_name = cause_name,
                                    .keep = 'none'),
                           by = 'level_2_id') %>%
                         left_join(
                           df_gbd_causes %>% 
                             mutate(level_3_id = parent_id, level_4_id = cause_id, level_4_name = cause_name,
                                    .keep = 'none'),
                           by = 'level_3_id') %>%
                         mutate(level_1_label = if_else(is.na(level_1_id), NA, sprintf('%s - [%d]', level_1_name, level_1_id)),
                                level_2_label = if_else(is.na(level_2_id), NA, sprintf('%s - [%d]', level_2_name, level_2_id)),
                                level_3_label = if_else(is.na(level_3_id), NA, sprintf('%s - [%d]', level_3_name, level_3_id)),
                                level_4_label = if_else(is.na(level_4_id), NA, sprintf('%s - [%d]', level_4_name, level_4_id)),
                                .keep = 'none'),
                       c('level_1_label', 'level_2_label', 'level_3_label', 'level_4_label'))

# Process gbd locations to tree format ----
# ─────────────────────────────────────────
df_gbd_country <- df_gbd_locations %>% 
  dplyr::filter(loc_id == 4749) %>% 
  mutate(parent_id = NA, country_id = loc_id, country_name = loc_name, .keep = 'none')

df_gbd_region <- df_gbd_locations %>% semi_join(df_gbd_country, by = c('parent_id' = 'country_id')) %>%
  mutate(parent_id, region_id = loc_id, region_name = loc_name, .keep = 'none')

df_gbd_utla <- df_gbd_locations %>% semi_join(df_gbd_region, by = c('parent_id' = 'region_id')) %>%
  mutate(parent_id, utla_id = loc_id, utla_name = loc_name, .keep = 'none')

df_gbd_tree <- df_gbd_country %>% 
  left_join(df_gbd_region, by = c('country_id' = 'parent_id')) %>%
  left_join(df_gbd_utla, by = c('region_id' = 'parent_id'))

gbd_tree <- dfToTree(df_gbd_tree %>% mutate(country_label = sprintf('%s - [%d]', country_name, country_id),
                                            region_label = sprintf('%s - [%d]', region_name, region_id),
                                            utla_label = sprintf('%s - [%d]', utla_name, utla_id),
                                            .keep = 'none'), c('country_label', 'region_label', 'utla_label'))

# Load the registered population data ----
# ════════════════════════════════════════
df_popn_data <- read.csv(filename_popn_data) %>% 
  rename_with(.fn = ~c('ORG_TYPE', 'ORG_CODE', 'GENDER', 'AGE_BAND', 'POPN')) %>%
  mutate(ORG_TYPE = as.factor(df_codes$desc[df_codes$field=='population_area'][ORG_TYPE]),
         GENDER = as.factor(df_codes$desc[df_codes$field=='sex_name'][GENDER]),
         AGE_BAND = as.factor(df_codes$desc[df_codes$field=='age_name'][AGE_BAND])
         )

df_popn_data <- df_popn_data %>% 
  bind_rows(
    df_popn_data %>% 
      dplyr::filter(ORG_TYPE == 'Comm Region') %>% 
      group_by(GENDER, AGE_BAND) %>%
      summarise(POPN = sum(POPN, na.rm = TRUE), .groups = 'keep') %>%
      ungroup() %>%
      mutate(ORG_TYPE = 'Country', ORG_CODE = 'ENG') %>%
      select(ORG_TYPE, ORG_CODE, GENDER, AGE_BAND, POPN)
  )

# Load the registered population hierarchies ----
# ═══════════════════════════════════════════════
df_popn_map <- read.csv(filename_popn_hierarchies) %>%
  mutate(ICB_NAME = gsub('Integrated Care Board', 'ICB', ICB_NAME),
         COUNTRY_NAME = 'England', COUNTRY_CODE = 'ENG')
  
popn_tree <- dfToTree(df_popn_map %>% 
                        mutate(COUNTRY = sprintf('%s - [%s]', COUNTRY_NAME, COUNTRY_CODE),
                               REGION = sprintf('%s - [%s]', COMM_REGION_NAME, COMM_REGION_CODE),
                               ICB = sprintf('%s - [%s]', ICB_NAME, ICB_CODE),
                               SUB_ICB = sprintf('%s - [%s]', SUB_ICB_LOCATION_NAME, SUB_ICB_LOCATION_CODE),
                               PCN = sprintf('%s - [%s]', PCN_NAME, PCN_CODE),
                               PRACTICE = sprintf('%s - [%s]', PRACTICE_NAME, PRACTICE_CODE),
                               .keep = 'none'), 
                      c('COUNTRY', 'REGION', 'ICB', 'SUB_ICB', 'PCN', 'PRACTICE'))

  
