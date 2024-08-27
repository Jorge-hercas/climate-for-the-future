


items <- tagList(
  tab(
    key = 1,
    title = div(
      class = "flex items-center gap-1",
      icon("home"),
      "Main data"
    ),
    card(
      card_body(
        style = "padding: 0px;",
        echarts4rOutput("general_plot", width = "100%")
      )
    ),
    br(),br(),
    div(
      class = "flex gap-1",
      width = 12,
      align = "center",
      mapboxerOutput("mapa_1", width = 1000, height = 800),
      column(width = 6,
             column(
               width = 12,
               echarts4rOutput("momplot", width = 500)
             ),
             column(
               width = 12,
               align = "center",
               reactableOutput("tabla_temperatura", width = 380)
              )
            )
    )
    
  ),
  tab(
    key = 3,
    title = 
      div(
        class = "flex items-center gap-1",
        icon("earth-americas"),
        "Temperature in your zone"
      ),
    card(
      card_body(
        "How's the temperature in your current zone?",
        br(),
        divider(),
        br(),
        "Lets use the OpenWeather API to know that...",
        br(),br(),
        div(
          class = "flex gap-1",
          text_input(inputId = "direction", label = "Location", value = NULL, placeholder = "Write your location..."),
          numeric_input(inputId ="lat", label = "Latitude", value = NULL,placeholder="..."),
          numeric_input(inputId ="lng", label = "Longitude", value =NULL,placeholder="...")
        ),
        br(),
        div(align = "center", 
            shinyNextUI::actionButton("temp_find", 
                                      label = "Ver clima", 
                                      icon = icon("globe"))
        ),
        br(),
        div(
          class = "flex gap-1",
          column(
            width = 4,
            align = "center",
            globeOutput("globo",
                        width = 350, 
                        height = 250),
            column(width = 12,
                   align = "center",
                   h4(textOutput("temperatura_actual"),style="color:gray"),
                   reactableOutput("tabla_temperaturas"),
                   br(),
                   echarts4rOutput("grafico_temperatura", height = 250, width = 400)
                   )
          ),
          column(
            width = 8,
            mapboxerOutput("map", height = "1000px", width = "1100px")
          )
        )
      )
    )
  )
)


