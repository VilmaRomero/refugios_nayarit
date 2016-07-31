
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
  
  titlePanel("Refugios cercanos a tu ubicación"),
  
  fluidRow(
  # Input: address and number of shelters to query

  column(4,
         wellPanel(style = "background-color: #ffffff;",
          # Nayarit images         
          img(src='nayarit.png', align = "right", width="125" , height="50"),
          img(src='proteccion_civil.png', align = "right", width="50" , height="50"),
          img(src='bomberos.png', align = "left", width="50" , height="50"),
          # Inputs
           textInput("street", "Calle y Número", value = "Abasolo 435"),
           textInput("settlement", "Colonia y/o Localidad y/o Municipio", value = "Acaponeta"),
           numericInput("n_shelters","Número de Refugios", value = 3)
         )
  ),
  
    # Map containing location and shelters
    column(8,
      plotOutput("map_with_shelters")
      ),
    
    # Information like phone number and address
    
    column(12,
           tableOutput("shelters_information")
    )
    
    )
  )
)
