

shinyServer(function(input, output, session) {
  
  ## set up input menu in sidebar
  output$a <- renderUI({
    
    if (input$sbMenu=="threePoints") { 
    
       inputPanel(
        selectInput("player", label=NULL,playerChoice, selected="nba-stephen-curry"),
      radioButtons("category", label=NULL, choices=c("FG","3P","FT"),inline=T),
      actionButton("go","Get Player Data")
       )  # not remaining in sidebar
     
    } 
    
  })
  source("code/threePointers.R", local=TRUE)
  
 
  
}) # end




