

dashboardPage(skin="yellow",
  dashboardHeader(title = "NBA"),
  
  dashboardSidebar(
    includeCSS("custom.css"),

    
    sidebarMenu(id = "sbMenu",
      uiOutput("a"),
      menuItem(
        "Three Point", tabName = "threePoints",icon = icon("line-chart"), selected=T
      ),
      # menuItem(
      #   "Run Differential", tabName = "RD",icon = icon("area-chart")
      # ),
      # menuItem(
      #   "Awards",
      #   menuSubItem("MVP", tabName = "mvp")
      # ),
      # 
      # menuItem("Info", tabName = "info",icon = icon("info")),
      # 
      # menuItem("Code",icon = icon("code-fork"),
      #          href = "https://github.com/pssguy/mlb"),
      
      tags$hr(),
      menuItem(text="",href="https://mytinyshinys.shinyapps.io/dashboard",badgeLabel = "All Dashboards and Trelliscopes (14)"),
      tags$hr(),
      
      tags$body(
        a(class="addpad",href="https://twitter.com/pssGuy", target="_blank",img(src="images/twitterImage25pc.jpg")),
        a(class="addpad2",href="mailto:agcur@rogers.com", img(src="images/email25pc.jpg")),
        a(class="addpad2",href="https://github.com/pssguy",target="_blank",img(src="images/GitHub-Mark30px.png")),
        a(href="https://rpubs.com/pssguy",target="_blank",img(src="images/RPubs25px.png"))
      )
    )
  ),
  
  dashboardBody(tabItems(
    tabItem(
      "threePoints",
      
      
      box(width=4,
        status = "success", solidHeader = TRUE,
         title = "3P",
         textOutput("player"),
         plotlyOutput("chart")
      )
    )


    
  # tabItem("info",includeMarkdown("info.md"))
    
  ))
)
