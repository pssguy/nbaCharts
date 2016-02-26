

data <-eventReactive(input$go,{
  
  req(input$player)
 # req(input$category)

  print(input$category)
  
  name <- players[players$slug==input$player,]$name
  
  ep <- "game_logs"      #teams
  q_body <- list(player_id=input$player)
  
 # print(token)
  nba <- ss_get_result(token=token,sport=sport, league=league, ep=ep, query=q_body, version=1, verbose=TRUE, walk=TRUE)
  logs <- lapply(nba, function(x) x$game_logs)
  games <- lapply(nba, function(x) x$games)
  
  
  games_df <- tbl_df(rbindlist(games)) #Same as do.call("rbind", l) on data.frames, but much faster. data.table is in depends of 
  logs_df <- rbindlist(logs)
  
  # print(str(games_df))
  # print(str(logs_df))
  
 
  
  
  logs_df <- logs_df %>% 
    filter(game_played == "TRUE")
  
  logs_df[is.na(logs_df )] <- 0
  logs_df$court <- ifelse(logs_df$team_outcome == logs_df$home_team_outcome, "home", "away")
  
  # games_df <- games_df %>% 
  #   select(scoreline)
  
  logs_df$scoreline <- games_df[match(logs_df$game_id, games_df$id),]$scoreline
  logs_df$winning_team_id <- games_df[match(logs_df$game_id, games_df$id),]$winning_team_id
  logs_df$score_differential <- games_df[match(logs_df$game_id, games_df$id),]$score_differential
  logs_df$game_started_at <- games_df[match(logs_df$game_id, games_df$id),]$started_at
  logs_df$game_ended_at <- games_df[match(logs_df$game_id, games_df$id),]$ended_at
  logs_df$game_slug <- games_df[match(logs_df$game_id, games_df$id),]$slug
  
 logs_df <- logs_df %>% 
   arrange(game_ended_at)
  
  info=list(logs=logs_df,games=games_df,player=name)
  return(info)
  

})


# output$player <- renderText({
# 
#   data()$player
# })


output$chart <- renderPlotly({
  
  #print(input$category)
  df <- data()$logs
  
  print(glimpse(df))
  
  print(max(df$game_started_at))
  
  if (input$category=="3P") {
p <-  pc <- round(100*sum(df$three_pointers_made)/sum(df$three_pointers_attempted),1)
  theTitle <- paste0(data()$player, " - 3 Pointers ",pc,"%")
  
  plot_ly(data()$logs, x = cumsum(three_pointers_attempted), y = cumsum(three_pointers_made), mode = "markers", hoverinfo = "text", group=team_outcome, 
          text = paste(str_sub(game_started_at,1,10),"<br> Made:",three_pointers_made,"<br> Attempts:",three_pointers_attempted,"<br> Tot Made:",cumsum(three_pointers_made),"<br> Tot Attempts:",cumsum(three_pointers_attempted)))
  } else if (input$category=="FG") {
    p <-  pc <- round(100*sum(df$field_goals_made)/sum(df$field_goals_attempted),1)
    theTitle <- paste0(data()$player, " - Field Goals ",pc,"%")
    
    plot_ly(data()$logs, x = cumsum(field_goals_attempted), y = cumsum(field_goals_made), mode = "markers", hoverinfo = "text", group=team_outcome, 
            text = paste(str_sub(game_started_at,1,10),"<br> Made:",field_goals_made,"<br> Attempts:",field_goals_attempted,"<br> Tot Made:",cumsum(field_goals_made),"<br> Tot Attempts:",cumsum(field_goals_attempted)))
  } else if (input$category=="FT") {
    p <-  pc <- round(100*sum(df$free_throws_made)/sum(df$free_throws_attempted),1)
    theTitle <- paste0(data()$player, " - Free Throws ",pc,"%")
    
    plot_ly(data()$logs, x = cumsum(free_throws_attempted), y = cumsum(free_throws_made), mode = "markers", hoverinfo = "text", group=team_outcome, 
            text = paste(str_sub(game_started_at,1,10),"<br> Made:",free_throws_made,"<br> Attempts:",free_throws_attempted,"<br> Tot Made:",cumsum(free_throws_made),"<br> Tot Attempts:",cumsum(free_throws_attempted)))
  }
  p %>%  # need Opponent id 
    layout(hovermode = "closest",
           xaxis=list(title="Cumulative Attempts"),
           yaxis=list(title="Cumulative Made"),
            title= theTitle, titlefont=list(size=16)
           
    ) %>% 
    config(displayModeBar = F)
  
})