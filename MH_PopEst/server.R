# Define server logic required to draw a histogram
function(input, output, session) {

  observeEvent(input$edtPopnLevel,
               {
                 if(input$edtPopnLevel %in% c('England', 'Region'))
                   shinyjs::hide(id = 'edtPopnFilter')
                 else {
                   updateSelectInput(session, 
                                     inputId = 'edtPopnFilter', 
                                     choices = setNames(df_gbd_locations %>% dplyr::filter(parent_id == 4749) %>% .$loc_id, 
                                                        df_gbd_locations %>% dplyr::filter(parent_id == 4749) %>% .$loc_name))
                                       
                                       
                                       
                                     )
                   shinyjs::show(id = 'edtPopnFilter')
                   
                 }
               }
  )
  # Ensure the session stops
  session$onSessionEnded(stopApp)
}

df_gbd_locations