

shinyServer(function(input, output, session) {
  
  ## set up input menu in sidebar
  output$a <- renderUI({
    
    if (input$sbMenu=="threePoints") { 
     
      inputPanel(selectInput("player", label=NULL,playerChoice, selected="nba-stephen-curry"))
    } 
    
  })
  source("code/threePointers.R", local=TRUE)
  
 
  
}) # end




