

data <- reactive({
  
  req(input$player)
  input$player
  
  ep <- "game_logs"      #teams
  q_body <- list(player_id=input$player)
  
 # print(token)
  nba <- ss_get_result(token=token,sport=sport, league=league, ep=ep, query=q_body, version=1, verbose=TRUE, walk=TRUE)
  logs <- lapply(nba, function(x) x$game_logs)
  games <- lapply(nba, function(x) x$games)
  
  
  games_df <- tbl_df(rbindlist(games)) #Same as do.call("rbind", l) on data.frames, but much faster. data.table is in depends of 
  logs_df <- rbindlist(logs)
  
  print(str(games_df))
  print(str(logs_df))
  
 
  
  
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
  
  print(names(games_df))
  print(names(logs_df))
  
  info=list(logs=logs_df,games=games_df,player=input$player)
  return(info)
  
  input$player
})


output$player <- renderText({

  data()$player
})