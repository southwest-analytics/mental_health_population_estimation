fluidPage(
  shinyjs::useShinyjs(),
  
  titlePanel("Mental Health Population Estimation"),

  sidebarLayout(
    # Side Bar Panel
    sidebarPanel(
      selectInput(inputId = 'edtPopnLevel',
                  label = 'Popn Level',
                  choices = c('England', 'Region', 'ICB', 'Sub-ICB', 'PCN', 'Practice'),
                  selected = 'England'),
      # Hide edtPopnFilter if England | Region selected in edtPopnLevel
      selectInput(inputId = 'edtPopnFilter',
                  label = 'Popn Filter Region',
                  choices = setNames(df_gbd_locations %>% dplyr::filter(parent_id == 4749) %>% .$loc_id, 
                                     df_gbd_locations %>% dplyr::filter(parent_id == 4749) %>% .$loc_name)),
      selectInput(inputId = 'edtPopnArea',
                  label = 'Popn Area',
                  choices = 'None'),
      # selectInput(inputId = 'edtAgeBand',
      #             label = 'Age Bands',
      #             selected = 'All',
      #             choices = c('00-04','05-09',
      #                         '10-14','15-19',
      #                         '20-24','25-29',
      #                         '30-34','35-39',
      #                         '40-44','45-49',
      #                         '50-54','55-59',
      #                         '60-64','65-69',
      #                         '70-74','75-79',
      #                         '80-84','85-89',
      #                         '90-94','95+'),
      #             multiple = TRUE),
      selectInput(inputId = 'edtPrevFilter',
                  label = 'Prevalence|Incidence Filter',
                  choices = setNames(df_gbd_locations %>% dplyr::filter(parent_id == 4749) %>% .$loc_id, 
                                     df_gbd_locations %>% dplyr::filter(parent_id == 4749) %>% .$loc_name)),
      selectInput(inputId = 'edtPrevIncdArea',
                  label = 'Prevalence|Incidence Area',
                  choices = 'None'),
      checkboxGroupInput(inputId = 'chkPrevIncd',
                         label = 'Prevalence|Incidence',
                         choices = c('Prevalence', 'Incidence'),
                         selected = 'Prevalence'),
      selectInput(inputId = 'edtCauses',
                  label = 'Causes',
                  choices = setNames(df_gbd_causes %>% dplyr::filter(parent_id %in% c(558, 567, 572, 973, 561)) %>% .$cause_id, 
                                     df_gbd_causes %>% dplyr::filter(parent_id %in% c(558, 567, 572, 973, 561)) %>% .$cause_name),
                  multiple = TRUE)
    ),
    # Main Panel
    mainPanel()
  )
)