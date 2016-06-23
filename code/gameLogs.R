


data <- eventReactive(input$go, {
  req(input$player)
  print(input$player)
  
  name <- players[players$slug == input$player, ]$name
  
  ep <- "game_logs"
  q_body <- list(player_id = input$player,
                 season_id="nba-2015-2016",
                interval_type = 'regularseason')
  
  print("a")
  
  nba <-
    ss_get_result(
      token = token,
      sport = sport,
      league = league,
      ep = ep,
      query = q_body,
      version = 1,
      verbose = TRUE,
      walk = TRUE
    )
  print("b")
  
  logs <- lapply(nba, function(x)
    x$game_logs)
  games <- lapply(nba, function(x)
    x$games)
  
  
  games_df <- tbl_df(rbindlist(games))
  logs_df <- rbindlist(logs)
  
  (glimpse(games_df))
  
  
  logs_df <- logs_df %>%
    filter(game_played == "TRUE")
  
  logs_df[is.na(logs_df)] <- 0
  logs_df$court <-
    ifelse(logs_df$team_outcome == logs_df$home_team_outcome,
           "home",
           "away")
  
  
  logs_df$scoreline <-
    games_df[match(logs_df$game_id, games_df$id), ]$scoreline
  logs_df$winning_team_id <-
    games_df[match(logs_df$game_id, games_df$id), ]$winning_team_id
  logs_df$score_differential <-
    games_df[match(logs_df$game_id, games_df$id), ]$score_differential
  logs_df$game_started_at <-
    games_df[match(logs_df$game_id, games_df$id), ]$started_at
  logs_df$game_ended_at <-
    games_df[match(logs_df$game_id, games_df$id), ]$ended_at
  logs_df$game_slug <-
    games_df[match(logs_df$game_id, games_df$id), ]$slug
  
  logs_df <- logs_df %>%
    arrange(game_ended_at)
  
  ## link to opponents name
  
  opponents <- lapply(nba, function(x)
    x$opponents)
  opponents_df <- rbindlist(opponents) %>%
    select(nickname, id) %>%
    unique() %>%
    rename(opponent_id = id)
  
  logs_df <- logs_df %>%
    left_join(opponents_df) %>%
    mutate(
      field_goals_pct = round(as.numeric(field_goals_pct), 2),
      three_pointers_pct = round(as.numeric(three_pointers_pct), 2),
      free_throws_pct = round(as.numeric(free_throws_pct), 2),
      date = as.Date(str_sub(game_started_at, 1, 10))
    ) %>%
    arrange(date)
  ## for workingdoc
  
  #write_csv(logs_df,"gameLogs.csv")
  
  info = list(logs = logs_df,
              games = games_df,
              player = name)
  return(info)
  
  
})


# output$player <- renderText({
#
#   data()$player
# })


output$threePtCum <- renderPlotly({
  #print(input$category)
  df <- data()$logs
  
  print(glimpse(df))
  
  print(max(df$game_started_at))
  
  if (input$category == "3P") {
    p <-
      pc <-
      round(100 * sum(df$three_pointers_made) / sum(df$three_pointers_attempted),
            1)
    theTitle <- paste0(data()$player, " - 3 Pointers ", pc, "%")
    
    plot_ly(
      data()$logs,
      x = cumsum(three_pointers_attempted),
      y = cumsum(three_pointers_made),
      mode = "markers",
      hoverinfo = "text",
      group = team_outcome,
      text = paste(
        str_sub(game_started_at, 1, 10),
        "<br> v:",
        nickname,
        "<br> Made:",
        three_pointers_made,
        "<br> Attempts:",
        three_pointers_attempted,
        "<br> Tot Made:",
        cumsum(three_pointers_made),
        "<br> Tot Attempts:",
        cumsum(three_pointers_attempted)
      )
    )  %>%
      add_trace(
        x = cumsum(three_pointers_attempted),
        y = three_pointers_made,
        type = "bar",
        name = "Shots Made",
        hoverinfo = "text",
        text = paste(
          "Made:",
          three_pointers_made,
          "<br> PC:",
          three_pointers_pct
        )
      )
  } else if (input$category == "FG") {
    p <-
      pc <-
      round(100 * sum(df$field_goals_made) / sum(df$field_goals_attempted),
            1)
    theTitle <- paste0(data()$player, " - Field Goals ", pc, "%")
    
    plot_ly(
      data()$logs,
      x = cumsum(field_goals_attempted),
      y = cumsum(field_goals_made),
      mode = "markers",
      hoverinfo = "text",
      group = team_outcome,
      text = paste(
        str_sub(game_started_at, 1, 10),
        "<br> v:",
        nickname,
        "<br> Made:",
        field_goals_made,
        "<br> Attempts:",
        field_goals_attempted,
        "<br> Tot Made:",
        cumsum(field_goals_made),
        "<br> Tot Attempts:",
        cumsum(field_goals_attempted)
      )
    )  %>%
      add_trace(
        x = cumsum(field_goals_attempted),
        y = field_goals_made,
        type = "bar",
        name = "Shots Made",
        hoverinfo = "text",
        text = paste("Made:", field_goals_made, "<br> PC:", field_goals_pct)
      )
  } else if (input$category == "FT") {
    p <-
      pc <-
      round(100 * sum(df$free_throws_made) / sum(df$free_throws_attempted),
            1)
    theTitle <- paste0(data()$player, " - Free Throws ", pc, "%")
    
    plot_ly(
      data()$logs,
      x = cumsum(free_throws_attempted),
      y = cumsum(free_throws_made),
      mode = "markers",
      hoverinfo = "text",
      group = team_outcome,
      text = paste(
        str_sub(game_started_at, 1, 10),
        "<br> v:",
        nickname,
        "<br> Made:",
        free_throws_made,
        "<br> Attempts:",
        free_throws_attempted,
        "<br> Tot Made:",
        cumsum(free_throws_made),
        "<br> Tot Attempts:",
        cumsum(free_throws_attempted)
      )
    )  %>%
      add_trace(
        x = cumsum(free_throws_attempted),
        y = free_throws_made,
        type = "bar",
        name = "Shots Made",
        hoverinfo = "text",
        text = paste("Made:", free_throws_made, "<br> PC:", free_throws_pct)
      )
  }
  p %>%  # need Opponent id
    layout(
      hovermode = "closest",
      xaxis = list(title = "Cumulative Attempts"),
      yaxis = list(title = "Cumulative Made"),
      title = theTitle,
      titlefont = list(size = 16),
      legend = list(x = 0, y = 1)
      
    ) %>%
    config(displayModeBar = F)
  
})

output$gameLogs <- DT::renderDataTable({
  data()$logs %>%
    # mutate(field_goals_pct=round(as.numeric(field_goals_pct),2),
    #        three_pointers_pct=round(as.numeric(three_pointers_pct),2),
    #        free_throws_pct=round(as.numeric(free_throws_pct),2),
    #        date=as.Date(str_sub(game_started_at,1,10))) %>%
    select(
      date,
      nickname,
      FG = field_goals_made,
      FGPC = field_goals_pct,
      TPM = three_pointers_made,
      TPPC = three_pointers_pct,
      FTM = free_throws_made,
      FTPC = free_throws_pct,
      points,
      assists,
      steals,
      turnovers,
      blocks,
      R = rebounds_total,
      PF = personal_fouls
    ) %>%
    arrange(desc(date)) %>%
    DT::datatable(
      class = 'compact stripe hover row-border order-column',
      rownames = FALSE,
      options = list(
        paging = TRUE,
        searching = FALSE,
        info = FALSE
      ),
      colnames = c(
        'Date',
        'Opp',
        'FG',
        'FG%',
        '3P',
        '3P%',
        'FT',
        'FT%',
        'PTS',
        'AST',
        'STL',
        'TOV',
        'BLK',
        'TRB',
        'PF'
      )
    )
  
})