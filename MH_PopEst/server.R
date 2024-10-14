# Define server logic required to draw a histogram
function(input, output, session) {

  observeEvent(input$edtPrevRegion,
               {
                 if(input$edtPrevRegion == 'ALL')
                   shinyjs::hide(id = 'edtPrevUTLA')
                 else {
                   updateSelectInput(inputId = 'edtPrevUTLA',
                                     choices = setNames(c('ALL', df_gbd_locations %>% dplyr::filter(parent_id == input$edtPrevRegion) %>% .$loc_id), 
                                                        c('ALL', df_gbd_locations %>% dplyr::filter(parent_id == input$edtPrevRegion) %>% .$loc_name)),
                                     selected = 'ALL')
                   shinyjs::show(id = 'edtPrevUTLA')
                 }
               }
  )
  
  observeEvent(input$edtPopnRegion,
               {
                 if(input$edtPopnRegion == 'ALL')
                   shinyjs::hide(id = 'edtPopnICB')
                 else {
                   updateSelectInput(inputId = 'edtPopnICB',
                                     choices = setNames(c('ALL', df_popn_hierarchy %>% dplyr::filter(parent_org_id == input$edtPopnRegion) %>% .$org_id), 
                                                        c('ALL', df_popn_hierarchy %>% dplyr::filter(parent_org_id == input$edtPopnRegion) %>% .$org_name)),
                                     selected = 'ALL')
                   shinyjs::show(id = 'edtPopnICB')
                 }
               }
  )
  
  observeEvent(input$edtPopnICB,
               {
                 if(input$edtPopnICB == 'ALL')
                   shinyjs::hide(id = 'edtPopnSubICB')
                 else {
                   updateSelectInput(inputId = 'edtPopnSubICB',
                                     choices = setNames(c('ALL', df_popn_hierarchy %>% dplyr::filter(parent_org_id == input$edtPopnICB) %>% .$org_id), 
                                                        c('ALL', df_popn_hierarchy %>% dplyr::filter(parent_org_id == input$edtPopnICB) %>% .$org_name)),
                                     selected = 'ALL')
                   shinyjs::show(id = 'edtPopnSubICB')
                 }
               }
  )
  
  observeEvent(input$edtPopnSubICB,
               {
                 if(input$edtPopnSubICB == 'ALL')
                   shinyjs::hide(id = 'edtPopnPCN')
                 else {
                   updateSelectInput(inputId = 'edtPopnPCN',
                                     choices = setNames(c('ALL', df_popn_hierarchy %>% dplyr::filter(parent_org_id == input$edtPopnSubICB) %>% .$org_id), 
                                                        c('ALL', df_popn_hierarchy %>% dplyr::filter(parent_org_id == input$edtPopnSubICB) %>% .$org_name)),
                                     selected = 'ALL')
                   shinyjs::show(id = 'edtPopnPCN')
                 }
               }
  )

  observeEvent(input$edtPopnPCN,
               {
                 if(input$edtPopnPCN == 'ALL')
                   shinyjs::hide(id = 'edtPopnPrac')
                 else {
                   updateSelectInput(inputId = 'edtPopnPrac',
                                     choices = setNames(c('ALL', df_popn_hierarchy %>% dplyr::filter(parent_org_id == input$edtPopnPCN) %>% .$org_id), 
                                                        c('ALL', df_popn_hierarchy %>% dplyr::filter(parent_org_id == input$edtPopnPCN) %>% .$org_name)),
                                     selected = 'ALL')
                   shinyjs::show(id = 'edtPopnPrac')
                 }
               }
  )
  
  # Ensure the session stops
  session$onSessionEnded(stopApp)
}

