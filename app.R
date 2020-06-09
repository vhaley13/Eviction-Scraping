library(shiny)
library(leaflet)
library(tidyverse)
library(DT)
library(dplyr)
library(sf)
library(plotly)
library(leaflet.extras)
library(leaflet.providers)

# load(file = "myevictiondata5.rda")
# load(file = "myevictiondata6.rda")
# load(file = "myevictiondata7.rda")
load(file = "myevictiondata11.rda")

# save(filingsflongplot2, filingsfplot2, fultonlines, judgmentsfplot2, file = "myevictiondata8.rda")

draw_basemap <- function(){
  leaflet(
    options = leafletOptions(minZoom = 5) #, maxZoom = 14)
  ) %>%
    setView(lng = -84.63265, lat = 33.88687, zoom = 9) %>%
    addProviderTiles(providers$Esri.WorldStreetMap) %>%
    # addTiles(
    #   urlTemplate = "https://{s}.tile.thunderforest.com/{variant}/{z}/{x}/{y}.png?apikey={apikey}",
    #   attribution = "&copy; <a href='http://www.thunderforest.com/'>Thunderforest</a>,  &copy; <a href='http://www.openstreetmap.org/copyright'>OpenStreetMap</a>",
    #   options = tileOptions(variant='neighbourhood', apikey = "18455b12c61044aca3d098e55a95401c")) %>%
    addMapPane("borders", zIndex = 400) %>% # allows geom lines to remain fixed when colors drawn again
    addMapPane("points", zIndex = 410) %>%
    #addProviderTiles(providers$CartoDB.Positron,
    # options = providerTileOptions(noWrap = TRUE)) %>%
    addPolylines(data = fultonlines,
                 stroke = TRUE,
                 weight = 3,
                 opacity = 1,
                 color = "black",
                 fillOpacity = 1,
                 fillColor = NULL,
                 highlight = highlightOptions(
                   weight = 3,
                   fillOpacity = 1,
                   color = "black",
                   bringToFront = TRUE),
                 group = "lines",
                 options = pathOptions(pane = "borders")) %>%
    setMaxBounds(lng1 = -84.85072, lat1 = 33.50242, lng2 = -84.0977, lat2 = 34.1863) %>% 
    addResetMapButton()
} 




add_vline = function(p, x) {
  l_shape = list(
    type = "line", 
    y0 = 0, 
    y1 = 1, 
    yref = "paper", # i.e. y as a proportion of visible region
    x0 = x, 
    x1 = x, 
    line = list(dash="dot", color = "green"))
  callout = list(yref = 'paper', 
                 xref = "x", 
                 y = 0.85, x = x, 
                 text = "3/27/2020 - CARES Act Passed", 
                 showarrow=FALSE)
  p %>% layout(shapes=list(l_shape), annotations = list(callout))
}

draw_histogram <- function(df, start, end, bin, title) {
  if(bin=="day"){
    size <- "D1"
  }
  else if(bin=="week"){
    size <- 604800000
  }
  else if(bin=="month"){
    size <- "M1"
  }
  if(title == "filings"){
    suffix <- "Filings"
  }
  else if(title == "judgments"){
    suffix <- "Judgments"
  }
    pdata <- st_drop_geometry(df)
    pdata$Month <- as.Date(cut(pdata$File.Date,
                               breaks = "month"))
    pdata$Week <- as.Date(cut(pdata$File.Date,
                              breaks = "week",
                              start.on.monday = TRUE))
    # pdata$count <- 1
    # pdata <- arrange(pdata, File.Date)
    
    fig <- pdata %>%
      plot_ly(
        x = ~File.Date,
        autobinx = FALSE, 
        autobiny = TRUE, 
        marker = list(color = "rgb(68, 68, 68)"), 
        name = "date", 
        type = "histogram", 
        xbins = list(
          end = end, 
          size = size, 
          start = start
        )
      )
    fig <- fig %>% layout(
      paper_bgcolor = "rgb(240, 240, 240)", 
      plot_bgcolor = "rgb(240, 240, 240)", 
      title = paste("<b>Eviction", suffix, "</b>"),
      xaxis = list(
        type = 'date',
        title = "File Date"
      ),
      yaxis = list(
        title = paste("Eviction", suffix)
      )

    )
    if(start <= "2020-03-27" &  end >= "2020-03-27"){
      fig <- add_vline(fig, "2020-03-27")
    }
}


draw_lineplot <- function(df, start, end, agg, title) {
  pdata <- st_drop_geometry(df)
  pdata$Month <- as.Date(cut(pdata$File.Date,
                             breaks = "month"))
  pdata$Week <- as.Date(cut(pdata$File.Date,
                            breaks = "week",
                            start.on.monday = TRUE))
  pdata$count <- 1
  pdata <- arrange(pdata, File.Date)
  if(agg=="day"){
    x <- pdata$File.Date
  }
  else if(agg=="week"){
    x <- pdata$Week
  }
  else if(agg=="month"){
    x <- pdata$Month
  }
  if(title == "filings"){
    suffix <- "Filings"
  }
  else if(title == "judgments"){
    suffix <- "Judgments"
  }
  fig <- pdata %>% plot_ly(
    mode = 'lines',
    x = x,
    y =pdata$count,
    line = list(color = 'blue',
                width = 4),
    transforms = list(
      list(
        type = 'aggregate',
        groups = pdata$File.Date,
        aggregations = list(
          list(
            target = 'y', func = 'sum', enabled = TRUE)
        )
      )
    )
  )
  
  fig <- fig %>% layout(
    title =  paste("<b>Eviction", suffix, "</b>"),
    xaxis = list(title = 'File Date'),
    yaxis = list(title = paste("Eviction", suffix))
  )
  if(start <= "2020-03-27" &  end >= "2020-03-27"){
    fig <- add_vline(fig, "2020-03-27")
  }
}

# side panel
ui <- fluidPage(
  # Sidebar layout with a input and output definitions
  sidebarLayout(
    
    # Inputs:
    sidebarPanel(width = 3,
      
      # Text instructions
      HTML(paste("Customize the map by:")),
      
      # add slider for choosing filings vs judgments to send to leaflet to map
      radioButtons("typeevict", "Eviction type:",
                   c("Filings" = "filings",
                     "Judgments" = "judgments"),
                   selected = "filings"),
      # date filter
      dateInput("startdate", "Start date:",
                min    = "2017-01-01",
                max    = "2020-12-31",
                value  = "2020-01-01",
                format = "mm/dd/yy"),
      
      dateInput("enddate", "End date:",
                min    = "2017-01-01",
                max    = "2020-12-31",
                value  = "2020-05-20",
                format = "mm/dd/yy"),
      
      selectInput("display", "Show evictions as:", choices = c("Individual points"="individual", "Clusters"="cluster"), 
                  selected = "individual"),
      
      downloadButton("downloadData", "Download Data")
      
    ),
    # Outputs:
    mainPanel(width = 9,
              tabsetPanel(
                tabPanel("Map", 
                         HTML(paste("Select an individual point on the map to view detailed case information below.")),
                         br(),
                         HTML(paste("If using clusters option, click clusters to break them into smaller clusters and individual points.")),
                         br(),
                         leafletOutput("mymap"),
                         br(),
                         textOutput("selected_var"),
                         br(),
                         # Show data table
                         DTOutput("case_table")
                         ), 
                tabPanel("Plots", 
                         fluidPage(selectInput("selectPlot", "Choose desired plot",
                                               choices=c("Histogram"="hist", "Line Plot"="line"),
                                               selected = "hist"),
                                   selectInput("selectTime", "Choose desired timeframe",
                                               choices = c("Daily"="day", "Weekly"="week", "Monthly"="month"),
                                               selected = "day"),
                         plotlyOutput("plot", height = "500px")
                )
              )
              )
  )
)
)


# Define server function
server <- function(input, output) {
  
  output$mymap <- renderLeaflet({
    draw_basemap()
    
  })
  
  # Create map
  # observeEvent(input$typeevict, {
  #   print(input$typeevict)
  # })
  # 
  # observeEvent(input$startdate, {
  #   print(input$startdate)
  # })
  # 
  # 
  # observeEvent(input$enddate, {
  #   print(input$enddate)
  # })
  
  #observe(
  # print(input$daterange[2])
  #)
  
  type <- reactive({
    value = input$typeevict
    return(type)
  })
  
  start <- reactive({
    start <- input$startdate
    return(start)
  })
  
  end <- reactive({
    end <- input$enddate
    return(end)
  })
  
  display <- reactive({
    if(input$display == "individual"){
      display <- NULL
    }
    else if(input$display == "cluster"){
      display <- markerClusterOptions()
    }
    else{
      display <- NULL
    }
    return(display)
  })
  
  
  evictpoints <- reactive({
    req(!is.null(input$typeevict))
    req(!is.null(input$startdate))
    req(!is.null(input$enddate))
    req(input$enddate >= input$startdate)
    if (input$typeevict == "filings" & input$enddate >= input$startdate) {
      data <- filingsfplot2
      data = data[data$File.Date >= start() & data$File.Date <= end(),]
      # data <- data %>% filter(File.Date >= input$startdate)
      # data <- data %>% filter(File.Date <= end())
    } else if (input$typeevict == "judgments" & input$enddate >= input$startdate){
      # data = judgmentsfplot2
      # data = data[data$File.Date>=input$startdate & data$File.Date <= input$enddate,]
      if(nrow(judgmentsfplot2[judgmentsfplot2$File.Date >= start() & judgmentsfplot2$File.Date <= end(),])==0){
        data <- NULL
      }
      else{
        data <- judgmentsfplot2[judgmentsfplot2$File.Date >= start() & judgmentsfplot2$File.Date <= end(),]
      }
      # data <- data %>% filter(File.Date >= input$startdate)
      # data <- data %>% filter(File.Date <= input$enddate)
    } else {
      data <- NULL
    }
    case_ids <- unique(data$Case.ID)
    df <- filingsflongplot2[filingsflongplot2$Case.ID %in% case_ids,]
    df <- df[,-c(6, 9)]
    #print(head(df))
    output$downloadData <- downloadHandler(
      filename = function() {
        paste(as.character(input$typeevict), as.character(input$startdate), as.character(input$enddate), ".csv", sep = "")
      },
      content = function(file) {
        write.csv(df, file, row.names = FALSE)
      }
    )
    sdate <- format(input$startdate, format = "%B %d %Y")
    edate <- format(input$enddate, format = "%B %d %Y")
    output$selected_var <- renderText({ 
      paste(as.character(nrow(data)), "total Fulton", as.character(input$typeevict), "between",
            as.character(sdate), "and", as.character(edate))

    })
    output$plot <- renderPlotly({
      if(input$selectPlot == "hist"){
        draw_histogram(data, input$startdate, input$enddate, input$selectTime, input$typeevict)
      }
      else if(input$selectPlot == "line"){
        draw_lineplot(data, input$startdate, input$enddate, input$selectTime, input$typeevict)
      }
    })
    
    
    return(data)
  })
  
  #observe({
  #print(head(evictpoints()))
  # print(paste(as.character(type()), as.character(start()), as.character(end()), ".csv", sep = ""))
  #})
  
  colorcircles <- reactive({
    req(input$typeevict)
    if(input$typeevict == "filings"){
      color <- "blue"
    }
    else if(input$typeevict == "judgments"){
      color <- "green"
    }
    else {
      color <- NULL
    }
    return(color)
  })
  # add another reactive value for long eviction table
  

  observeEvent(c(input$typeevict, input$startdate, input$enddate, input$display), {
    if(input$display == "cluster"){
      display <- markerClusterOptions()
    }
    else if(input$display == "individual"){
      display <- NULL
    }
    if(input$typeevict=="filings"){
      leafletProxy("mymap") %>%
        clearMarkers() %>%
        clearMarkerClusters() %>%
        addCircleMarkers(data = evictpoints(),
                         radius = 1,
                         color = colorcircles(),
                         stroke = TRUE,
                         fillOpacity = 0.5,
                         popup = ~ Case.ID,
                         label = ~ Case.ID,
                         labelOptions = labelOptions(
                           style = list("font-family" = c("Open Sans", "sans-serif"))),
                         layerId = ~ Case.ID,
                         group = "marks",
                         clusterOptions = display,
                         options = pathOptions(pane = "points"))
    }
     else if(input$typeevict=="judgments" & input$startdate <= "2020-03-09"){
      leafletProxy("mymap") %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addCircleMarkers(data = evictpoints(),
                         radius = 1,
                         color = colorcircles(),
                         stroke = TRUE,
                         fillOpacity = 0.5,
                         popup = ~ Case.ID,
                         label = ~ Case.ID,
                         labelOptions = labelOptions(
                           style = list("font-family" = c("Open Sans", "sans-serif"))),
                         layerId = ~ Case.ID,
                         group = "marks",
                         clusterOptions = display,
                         options = pathOptions(pane = "points"))
     }
    else if(input$typeevict=="judgments" & input$startdate >= "2020-03-10"){
      leafletProxy("mymap") %>%
        clearMarkers() %>%
        clearMarkerClusters() 
    }
  })
  
  
  df <- observeEvent(input$mymap_marker_click, {
    p <- input$mymap_marker_click
    # print(p)
    # print(p$lat)
    # print(p$lng)
    # print(p$id)
    id <- p$id
    df <- filingsflongplot2 %>% filter(Case.ID == id)
    df <- df[, -c(6,9,10,11)]
    colnames(df) <- c("File Date", "Case ID", "Plaintiff", "Plaintiff Address", "Plaintiff City", "Filing Address",
                      "Filing City", "Case Status", "Event Number", "Event")
    # print(head(df))
    output$case_table <- renderDT(df) #, options = list(columnDefs = list(list(visible=FALSE, targets=c(6, 9,10,11)))))
    return(df)
  })
  
  
  
  
}

shinyApp(ui = ui, server = server)