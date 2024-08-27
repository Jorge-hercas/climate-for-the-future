

nextui_page(
  shinymanager::fab_button(inputId = "show_modal", label = "About the app"),
  reactOutput("modal"),
  dark_mode = T,
  h1(typed(c("SHINY CONTEST 2024", "CLIMATE CHANGE IN THE WORLD"),typeSpeed = 20,backSpeed = 20), id = "titlepanel"),
  tags$style(HTML("#titlepanel{color: #8d8f8e;
                          font-size: 50px;
                           }")),
  div(
    style = "height:50px",
    class = "grid gap-4 grid-cols-3 grid-rows-3 m-5",
    user(
      name = "By Jorge Hernandez Castelan",
      description = "Data analyst",
      avatarProps = JS(paste0(
        "{
        src: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Earth_icon_2.png/640px-Earth_icon_2.png'
      }"
      ))
    )
  ),
  div(
    class = "flex gap-1"
  ),
  spacer(y = 2),
  tabs(inputId = "tabs1",
       align = "center",
       items
  ),
  div(
    class = "grid gap-4 grid-cols-3 grid-rows-3 m-5"
  )
)


