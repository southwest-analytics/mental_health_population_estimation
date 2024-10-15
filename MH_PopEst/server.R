# Define server logic required to draw a histogram
function(input, output, session) {
  
  rvData <- reactiveVal()

  output$edtPopnTree <- renderTree(popn_tree)
  
  output$edtPrevTree <- renderTree(gbd_tree)
  
  output$edtCauseTree <- renderTree(cause_tree)
  
  output$txtCauses <- renderPrint({
    my_list <- get_selected(input$edtCauseTree, format = 'names')
    selected_causes <- as.integer(gsub('\\[|\\]', '', str_sub(unlist(my_list), str_locate(unlist(my_list), '\\[\\d+\\]'))))
    return(selected_causes)
  })
  
  # Ensure the session stops
  session$onSessionEnded(stopApp)
}

