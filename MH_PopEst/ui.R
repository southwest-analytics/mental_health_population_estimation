fluidPage(
  titlePanel("Mental Health Population Estimation"),

  sidebarLayout(
    sidebarPanel(
      radioButtons(inputId = 'radPopulationLevel',
                   label = 'Level',
                   choices = c('England', 'Region', 'ICB', 'Sub-ICB', 'PCN', 'Practice')
                   ),
      checkboxINput(inputId = 'chkFilter',
                    label = 'Filter',
                    value = FALSE),
      radioButtons(inputId = 'radFilterLevel',
                   label = 'Filter By',
                   choices = c('Region', 'ICB', 'Sub-ICB', 'PCN', 'Practice')
      ),
                  
                        selectInput(inputId = 'edt',
                  label,
                  choices)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot")
        )
    )
)
