fluidPage(
  shinyjs::useShinyjs(),
  
  titlePanel("Mental Health Population Estimation"),

  sidebarLayout(
    # Side Bar Panel
    sidebarPanel(
      tags$h3('Popn Source'),
      shinyTree(outputId = 'edtPopnTree'),
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
      tags$h3('Prevalence|Incidence Source'),
      shinyTree(outputId = 'edtPrevTree'),
      checkboxGroupInput(inputId = 'chkPrevIncd',
                         label = 'Prevalence|Incidence',
                         choices = c('Prevalence', 'Incidence'),
                         selected = 'Prevalence'),
      shinyTree(outputId = 'edtCauseTree', checkbox = TRUE, multiple = TRUE, three_state = TRUE)
    ),
    # Main Panel
    mainPanel(
      verbatimTextOutput(outputId = 'txtCauses')
    )
  )
)