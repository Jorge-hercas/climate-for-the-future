


function(input, output, session){
  
  
  data_general_plot <- reactive({
    
    data |> 
      mutate(date = floor_date(make_date(Year, Month, 1), "year")) |> 
      group_by(date) |> 
      summarise(
        temp_anomaly = mean(`Month Anomaly`, na.rm = T)
      ) |> 
      mutate(
        color = scales::col_numeric(c("#1F77B4", "#9467BD", "#FF7F0E", "#FFBB78", "#D62728"),
                                    temp_anomaly)(temp_anomaly),
        temp_anomaly = round(temp_anomaly, digits = 2)
      )
    
  })
  
  output$general_plot <- renderEcharts4r({
    
    data_general_plot() |> 
      e_charts(date) |> 
      e_bar(temp_anomaly) |> 
      e_add("itemStyle", color) |> 
      e_color(background = "transparent") |> 
      e_theme("auritus") |> 
      e_legend(F) |> 
      e_y_axis(show = F) |> 
      e_toolbox_feature("dataZoom", title = list(zoom = "zoom", back = "back")) |> 
      e_title("Anomalies temperature by year.", 
              left = "center",
              textStyle = list(
                color = "gray",
                fontFamily = "Roboto Condensed"
              )
      ) |> 
      e_tooltip(
        axisPointer = list(
          type = "cross"
        ),
        formatter = htmlwidgets::JS("
      function(params){
        return('Date: ' + params.value[0] + '<br />Temperature: ' + params.value[1]
        + '°')
      }
    "
        )
      )
    
    
  })
  
  
  output$mapa_1 <- renderMapboxer({
    
    theme <- if (input$theme == "dark"){
      "mapbox://styles/jorgehdez1998/cm0ac4kky00ta01qv729w9rnd"
    }else{
      "mapbox://styles/jorgehdez1998/cm0c09wnt002i01qr0e6p9ra0"
    }
    
    data_by_count |> 
      group_by(Country) |> 
      summarise(
        temp = mean(AverageTemperature, na.rm = T)/3
      ) |> 
      left_join(
        locs,
        by = c("Country" = "loc")
      ) |> 
      mutate(
        color = scales::col_quantile(c("#1F77B4", "#9467BD", "#FF7F0E", "#FFBB78", "#D62728"), temp)(temp)
      ) |> 
      as_mapbox_source() |> 
      mapboxer(
        #pitch = 30,
        style = theme,
        token = "pk.eyJ1Ijoiam9yZ2VoZGV6MTk5OCIsImEiOiJja2o2dnNyeWUzOGx2MzJteTA1cGp3eHdqIn0.2tlIRcZ5xTzSRR0Pj57G2w"
      ) |> 
      add_circle_layer(
        circle_color = c("get", "color"),
        circle_radius = c("get", "temp")
      )
    
  })
  
  
  data_1_act <- reactive({
    
    data_by_count |> 
      filter(year(dt) == onclick()) |> 
      group_by(Country) |> 
      summarise(
        temp = mean(AverageTemperature, na.rm = T)/3
      ) |> 
      left_join(
        locs,
        by = c("Country" = "loc")
      ) |> 
      mutate(
        color = scales::col_numeric(c("#1F77B4", "#9467BD", "#FF7F0E", "#FFBB78", "#D62728"), temp)(temp)
      )
    
  })
  
  modalVisible <- reactiveVal(FALSE)
  observeEvent(input$show_modal, {
    modalVisible(TRUE)
  })
  
  observeEvent(input$modal_closed, {
    modalVisible(FALSE)
  })
  
  
  output$texto_1 <- renderText({print(input$theme)})
  
  output$modal <- renderReact({
    modal(
      scrollBehavior = "inside",
      isOpen = modalVisible(),
      size = "sm",
      modal_content(
        modal_header("Climate change"),
        modal_body(
          p(
            "Why is climate change a hige problem right now? And what we can do about it? With this app, 
            we will be able to understand better the alarming situation we are living..."
          ),
          p(
            "The purpose of the app is to provide users with an intuitive and accessible tool 
            to visualize data related to climate change and current weather conditions in 
            their locality. By integrating interactive charts, maps, and other visual elements, 
            the app allows users to better understand how climate patterns are changing over time. 
            It also offers real-time information on current weather conditions, such as temperature, 
            wind speed, etc, helping users make informed decisions about their daily activities 
            and promoting greater environmental awareness."
          )
        ),
        modal_footer(paste0("Jorge Hernandez ", year(today())))
      ),
      onClose = JS("() => Shiny.setInputValue('modal_closed', true, {priority: 'event'})")
    )
  })
  
  
  onclick <- reactive({
    
    x <- data_general_plot()$date[input$general_plot_clicked_row]
    x <- year(as_date(x))
    
  })
  
  onclick_color <- reactive({
    x <- data_general_plot()$color[input$general_plot_clicked_row]
  })
  
  
  observeEvent(input$general_plot_clicked_row,{
    
    output$momplot <- renderEcharts4r({
      
      data |> 
        filter(
          Year == onclick()
        ) |> 
        mutate(date = floor_date(make_date(Year, Month, 1), "month")) |> 
        e_charts(date, dispose = F) |> 
        e_area(
          `Month Anomaly`,
          symbol = "none",
          smooth = F
        ) |> 
        e_color(background = "transparent", color = onclick_color()) |> 
        e_theme("auritus") |> 
        e_legend(F) |> 
        e_y_axis(show = F) |> 
        e_toolbox_feature("dataZoom", title = list(zoom = "zoom", back = "back")) |> 
        e_title(paste0("Anomalies temperature by month (",onclick(),")"), 
                left = "center",
                textStyle = list(
                  color = "gray",
                  fontFamily = "Roboto Condensed"
                )
        ) |> 
        e_tooltip(
          axisPointer = list(
            type = "cross"
          )
        )
      
      
    }) 
    
    mapboxer_proxy("mapa_1") |> 
      set_data(data_1_act()) |> 
      update_mapboxer()
    
    
    tabla_data <- reactive({
      
      data_by_count |> 
        filter(year(dt) == onclick()) |> 
        group_by(Country) |> 
        summarise(
          temp = mean(AverageTemperature, na.rm = T)
        ) |> 
        na.omit() |> 
        left_join(
          data_by_count |> 
            filter(year(dt) == onclick()) |> 
            group_by(Country) |> 
            summarise(
              temp_by_month = list(AverageTemperature)
            ),
          by = c("Country" = "Country")
        )
      
    })
    
    
    
    output$tabla_temperatura <- renderReactable({
      
      color <- if_else(input$theme == "dark","#000", "#fff")
      inv_color <- if_else(input$theme == "dark", "#fff", "#000")

      
      tabla_data() |> 
        reactable(
        theme = reactablefmtr::nytimes(background_color = "transparent", border_color = color),
        pagination = F,
        highlight = F,
        height = 400,
        compact = TRUE,
        defaultColDef = colDef(style = paste0("color: ",inv_color,";"), headerStyle = paste0("color: ",inv_color,";
                                                                      background-color: ",color,";
                                                                      font-weight: bold;")),
        columns = list(
          Country = colDef(header = icon("globe")),
          temp = colDef(
            name = "Avg. Temp.",
            format = colFormat(
              digits = 2, suffix = "°"
            )
          ),
          temp_by_month = colDef(cell = function(values) {
            sparkline(values, type = "bar", chartRangeMin = 0, chartRangeMax = max(30))
          }, name = "Temp. by month")
        )
      ) 
      
      
    })
    
  })
  
  
  output$globo <- render_globe({
    
    bg_color <- if (input$theme == "dark"){
      "#18181B"
    }else{
      "#fff"
    }
    
    create_globe(height = "100vh") |> 
      globe_background(color = bg_color) |> 
      globe_img_url(image_url("blue-marble")) |> 
      globe_pov(
        altitude = 2.3,
        0.6345,
        -80.5528
      )
    
    
  })
  
  
  output$map <- renderMapboxer({
    
    theme <- if (input$theme == "dark"){
      "mapbox://styles/jorgehdez1998/cm0byr9xb01e501qq8mug3s6q"
    }else{
      "mapbox://styles/jorgehdez1998/cm0c09wnt002i01qr0e6p9ra0"
    }
    
    
    mapboxer(
      style = theme,
      token = "pk.eyJ1Ijoiam9yZ2VoZGV6MTk5OCIsImEiOiJja2o2dnNyeWUzOGx2MzJteTA1cGp3eHdqIn0.2tlIRcZ5xTzSRR0Pj57G2w",
      center = c(-99,22),
      zoom = 4.5,
      maxZoom = 6.5
    ) 
    
    
  })
  
  coordenadas <- reactive({
    
    dir <- geocode(location = input$direction)
    dir
  })
  
  observeEvent(input$direction,{
    
    req(coordenadas())
    
    update_numeric_input(session, "lat", value = coordenadas()$lat)
    update_numeric_input(session, "lng", value = coordenadas()$lon)
    
  })
  
  
  temperaturas_data <- reactive({
    
    solicitud <- weather_forecast_req(lat = input$lat, lon = input$lng, tibble_format = T)
    
    x <- 
      tibble(
        solicitud$dt, solicitud$main$temp,
        solicitud$main$temp_min,
        solicitud$main$temp_max,
        solicitud |> 
          select(weather) |> 
          tidyr::unnest() |> 
          select(icon)) |> 
      setNames(c("Datetime", "Temp", "Min", "Max", "Icon")) |> 
      mutate(
        Icon = paste0(
          "http://openweathermap.org/img/w/",Icon,".png"
        ),
        Datetime = strftime(Datetime, format = "%A, %I %p"),
        Min = Min -273.15,
        Max = Max -273.15,
        Temp = Temp -273.15,
      )
    
    x
    
  })
  
  output$tabla_temperaturas <- renderReactable({
    
    color <- if_else(input$theme == "dark","#18181B", "#fff")
    inv_color <- if_else(input$theme == "dark", "#fff", "#18181B")
    
    req(temperaturas_data())
    
    temperaturas_data() |> 
      reactable(
        theme = reactablefmtr::nytimes(centered = TRUE, 
                                       header_font_size = 12,
                                       font_color = inv_color,
                                       background_color = "transparent", 
                                       border_color = color
                                       ),
        defaultColDef = colDef(headerStyle = paste0("color: ",inv_color,";
                                              background-color: ",color,";
                                              font-weight: bold;"),
                               vAlign = "center"),
        compact = TRUE,
        language = reactableLang(
          noData = "No data found",
          pageInfo = "{rowStart}\u2013{rowEnd} of {rows} pages",
          pagePrevious = "\u276e",
          pageNext = "\u276f",
        ),
        bordered = F,
        onClick = "select",
        #selection = "single",
        pagination = F,
        height = 390,
        columns = list(
          Datetime = colDef(name = "Dia/hora",minWidth = 60),
          Icon = colDef(
            minWidth = 25,
            header = icon("cloud-sun"),
            cell = function(value) {
              image <- img(src = value, style = "height: 24px;", alt = value)
              tagList(
                div(style = "display: inline-block; width: 45px;", image)
              )
            }
          ),
          Temp = colDef(
            minWidth = 60,
            header = icon("temperature-low"),
            cell = function(value, index){
              Min <- temperaturas_data()$Min[index]
              Max <- temperaturas_data()$Max[index]
              div(
                div(style = "font-weight: 600", value, "°"),
                div(style = "font-size: 0.75rem", paste0("Min: ",Min,"°, Max: ", Max,"°"))
              )
            }
          ),
          Min = colDef(show = F),
          Max = colDef(show = F)
        )
      )
    
    
  }) |> 
    bindEvent(input$temp_find)
  
  output$temperatura_actual <- renderText({
    
    x <- weather_actual_req(lat = input$lat, lon = input$lng, tibble_format = T)
    
    paste0("Current temperature: ", x$main.temp-273.15,"°")
    
  }) |> 
    bindEvent(input$temp_find)
  
  
  
  bounds <- reactive({
    
    x <- c(input$lng,input$lat, input$lng+0.1, input$lat+0.1)
    x
    
  })
  
  
  
  observeEvent(input$temp_find,{
    
    req(bounds())
    
    mapboxer_proxy("map") |>
      fit_bounds(bounds()) |>
      update_mapboxer()
    
  })
  
  
  observeEvent(input$temp_find, {
    globe_proxy("globo") |> 
      globe_pov(
        altitude = 2.3,
        input$lat,
        input$lng
      ) 
  })
  
  
  output$grafico_temperatura <- renderEcharts4r({
    
    req(temperaturas_data())
    
    x <- temperaturas_data()
    
    temperaturas_data() |> 
      e_charts(Datetime) |> 
      e_bar(Temp, symbol = "none", smooth = F, 
            name = "Temp.") |> 
      e_theme("auritus") |> 
      e_color(color = "darkred") |> 
      e_tooltip(trigger = "axis") |> 
      e_y_axis(show = F) |> 
      e_title(" ", left = "center") |> 
      e_legend(bottom = 0, textStyle = list(color = "#fff")) |> 
      e_title("Temperature on next days", 
               left = "center",
               textStyle = list(
                 color = "gray",
                 fontFamily = "Roboto Condensed"
               )
      )
    
  }) |> 
    bindEvent(input$temp_find)
  
  
  
}
