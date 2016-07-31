
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

## ---- setup-packages ----
# Install CRAN packages (if not already installed)
.packages  <-  c("shiny")
.inst <- .packages %in% installed.packages()
if(any(!.inst)) {
  install.packages(.packages[!.inst], repos = "http://cran.rstudio.com/")
}

# Load packages into session 
sapply(.packages, require, character.only = TRUE)
rm(list = ls()) # Delete all existing variables
graphics.off() # Close all open plots

## ----- main -----

shinyUI(fluidPage(
  # Application title
  titlePanel("Refugios Cercanos a tu Ubicación"),
  
  fluidRow(
  # Input: address and number of shelters to query

  column(4,
         wellPanel(style = "background-color: #ffffff;",
          # Nayarit images         
          img(src='nayarit.png', align = "right", width="125" , height="50"),
          img(src='proteccion_civil.png', align = "right", width="50" , height="50"),
          img(src='bomberos.png', align = "left", width="50" , height="50"),
          # Inputs
          textInput("street", "Calle y Número", value = "San José del Valle 30"),
          textInput("settlement", "Colonia y/o Localidad y/o Municipio", value = "Bahía de Banderas"),
          numericInput("n_shelters","Número de Refugios", value = 3),
          sliderInput("zoom","Zoom",min=11,max=20,value=16,ticks = FALSE),
          # This HTML is just for the zoom bar not to have values, just a plain slider
          tags$script(HTML("
          $(document).ready(function() {setTimeout(function() {
                           supElement = document.getElementById('zoom').parentElement;
                           $(supElement).find('span.irs-max, span.irs-min, span.irs-single, span.irs-from, span.irs-to').remove();
                           }, 50);})
                           ")),
          # Just some info for the user
          "Tu dirección se mostrará con un círculo azul y los refugios más cercanos, con cuadrados rojos."
         )
  ),
  
    # Map containing location and shelters
    column(8,
      plotOutput("map_with_shelters"),
      tags$head(tags$style("#text1{color: red;
                                 font-size: 20px;
                           font-style: italic;
                           }"
                         )
      )
      ),
    
    # Information like phone number and address
    
    column(12,
           div(tableOutput("shelters_information"), style = "font-size:75%")
    )
    
    )
  )
)
