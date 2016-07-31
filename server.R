
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

## ---- setup-packages ----
# Install CRAN packages (if not already installed)
.packages  <-  c("dplyr", "ggmap", "geosphere", "shiny")
.inst <- .packages %in% installed.packages()
if(any(!.inst)) {
  install.packages(.packages[!.inst], repos = "http://cran.rstudio.com/")
}

# Load packages into session 
sapply(.packages, require, character.only = TRUE)
rm(list = ls()) # Delete all existing variables
graphics.off() # Close all open plots

## ----- main -----

shinyServer(function(input, output) {

  # Script that contains cleaning process and closest shelters filtering
  source('utils.R')
  
  shelters_data <- read.csv("refugios_nayarit_limpio.csv") # cleaning steps
  
  current_street <- reactive({ input$street })
  current_settlement <- reactive({ input$settlement })
  location <- reactive({ paste0(current_street(), ", ", current_settlement(), ", Nayarit, Mexico")})
  # Get lon,lat of the inputed address
  starting_point <- reactive({ geocode(location(), source ="google") })
  
  # get the n closest shelters to the address given
  number_of_shelters <- reactive(input$n_shelters)
  n_closest_shelters <- reactive({ get_n_closest_shelters(starting_point(),number_of_shelters(),shelters_data)})
  shelters_contact_data <- reactive({n_closest_shelters() %>% select(Refugio,Direccion,Municipio,
                                                                         Distancia_km,Responsable,Telefono)})

  output$map_with_shelters <- renderPlot({
    map_centered_on_location <- get_map(location = starting_point(), zoom = input$zoom)
    map_with_shelters <-  ggmap(map_centered_on_location) + 
      geom_point(data= starting_point(),aes(lon,lat),colour='blue',size=3) + # the location of the person
      geom_point(data = n_closest_shelters(),
                 aes( x = Longitud,
                      y = Latitud), color= 'red',size=3,shape=15) +
      geom_point(data = shelters_data,
                 aes( x = Longitud,
                      y = Latitud), color= 'red',size=3,alpha=0.3,shape=15) +
      # erase axis names and values, not useful for viz
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank())
    map_with_shelters
  })
  
  output$shelters_information <- renderTable({
    shelters_contact_data()
  })

})
