

shinyServer(function(input, output, session) {
  
  ## set up input menu in sidebar
  output$a <- renderUI({
    
    if (input$sbMenu=="threePoints") { 
    
       inputPanel(
        selectInput("player", label="Select Player",playerChoice, selected="nba-stephen-curry"),
      radioButtons("category", label=NULL, choices=c("FG","3P","FT"), selected="3P",inline=T),
      actionButton("go","Get Player Data")
       ) 
     
    } 
    
  })
  source("code/gameLogs.R", local=TRUE)
  
 
  
}) # end




