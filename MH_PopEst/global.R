library(tidyverse)
library(readxl)
library(shiny)
library(shinyjs)
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
  

# Load the registered population data ----
# ════════════════════════════════════════
df_popn_data <- read.csv(filename_popn_data) %>% 
  rename_with(.fn = ~c('ORG_TYPE', 'ORG_CODE', 'GENDER', 'AGE_BAND', 'POPN')) %>%
  mutate(ORG_TYPE = as.factor(df_codes$desc[df_codes$field=='population_area'][ORG_TYPE]),
         GENDER = as.factor(df_codes$desc[df_codes$field=='sex_name'][GENDER]),
         AGE_BAND = as.factor(df_codes$desc[df_codes$field=='age_name'][AGE_BAND])
         )

# Load the registered population hierarchies ----
# ═══════════════════════════════════════════════
df_popn_map <- read.csv(filename_popn_hierarchies)

df_popn_hierarchy <- df_popn_map %>% 
  mutate(org_id = COMM_REGION_CODE,
         org_name = COMM_REGION_NAME,
         parent_org_id = 'ENG',
         .keep = 'none') %>%
  distinct(org_id, org_name, parent_org_id) %>%
  bind_rows(df_popn_map %>% 
              mutate(org_id = ICB_CODE,
                     org_name = gsub('Integrated Care Board', 'ICB', ICB_NAME),
                     parent_org_id = COMM_REGION_CODE,
                     .keep = 'none') %>%
              distinct(org_id, org_name, parent_org_id)) %>%
  bind_rows(df_popn_map %>% 
              mutate(org_id = SUB_ICB_LOCATION_CODE,
                     org_name = SUB_ICB_LOCATION_NAME,
                     parent_org_id = ICB_CODE,
                     .keep = 'none') %>%
              distinct(org_id, org_name, parent_org_id)) %>%
  bind_rows(df_popn_map %>% 
              dplyr::filter(PCN_CODE!='U') %>%
              mutate(org_id = PCN_CODE,
                     org_name = PCN_NAME,
                     parent_org_id = SUB_ICB_LOCATION_CODE,
                     .keep = 'none') %>%
              distinct(org_id, org_name, parent_org_id)) %>%
  bind_rows(df_popn_map %>% 
              dplyr::filter(PCN_CODE!='U') %>%
              mutate(org_id = PRACTICE_CODE,
                     org_name = PRACTICE_NAME,
                     parent_org_id = PCN_CODE,
                     .keep = 'none') %>%
              distinct(org_id, org_name, parent_org_id))
  
