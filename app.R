#Library
library("shiny")
library("shinydashboard")
library("pipeR")
library("zoo")
library("dplyr")
library("dygraphs")
library("jaguchi")
options(RCurlOptions = list(verbose = FALSE, capath = system.file("CurlSSL", "cacert.pem", package = "RCurl"), ssl.verifypeer = FALSE))
#UI component
#Header
dashboard_header <- dashboardHeader(title="Daily steps of dichika")
#Sidebar
dashboard_sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Charts", icon = icon("bar-chart-o"), tabName="chart"),
    menuItem("About", tabName="about", icon=icon("info-circle"))
  )
)
#Body
dashboard_body <- dashboardBody(
  tabItems(
    # Single time series
    tabItem(
      tabName = "chart",
      fluidRow(
        box(
          title="Daily steps of dichika", solidHeader=TRUE, collapsible=TRUE, color="black", width=12,
          dygraphOutput("chart")
        )
      ),
      downloadButton("download", "Download this data")
    ),    
    # About tab content
    tabItem(
      tabName = "about",
      h2("What's this?"),
      p("This is a web application to show the daily steps of dichka"),
      h2("Can I get the code?"),
      p("You can download all codes from the following URL on Github."),
      p(a(href="https://github.com/teramonagi/ore", "https://github.com/teramonagi/ore")),
      h2("Can I get the original daily step data?"),
      p("You can download the original data from the following URL on Github."),
      p(a(href="https://raw.githubusercontent.com/dichika/jaguchi/master/inst/data/ore.csv", "https://raw.githubusercontent.com/dichika/jaguchi/master/inst/data/ore.csv"))
    )
  )
)
#Combine UI components
ui <- dashboardPage(
  skin = "black",
  dashboard_header,
  dashboard_sidebar,
  dashboard_body
)
################################################################
#Server
server <- function(input, output) {
  ore_zoo <- jaguchi("ore") %>>% read.zoo
  output$chart <- renderDygraph({
    ore_zoo %>>% 
      dygraph() %>>%
      dyOptions(pointSize=6) %>>%
      dySeries("V1", label="Daily steps", strokeWidth=2)
    
  })
  output$download <- downloadHandler(
    filename=function(){"dichika_activity_tracking.csv"},
    content=function(file) {write.csv(ore_zoo, file)}
  )
}
################################################################
#Application
shinyApp(ui, server)