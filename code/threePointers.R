

data <- reactive({
  
  req(input$player)
  input$player
})


output$player <- renderText({
  
  data()
})