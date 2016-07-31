
############################ FUNCTIONS FOR CLEANING DATA ###############################

clean_excel_file <- function(path_to_file,file_name){
  # Input Excel file with the same format as the refugios_nayarit.xlsx given on 27/07/2016
  # Return data frame with clean lat/lon, no NA rows
  # read_excel_allsheets is user defined function
  all_sheets <- read_excel_allsheets(paste0(path_to_file,file_name)) # see line 25
  # Read all the sheets into one centralized dataframe
  shelters_data <- do.call(rbind,all_sheets)
  # Erase empty lines / lines with totals / lines with extra information like MSNM
  shelters_data <- subset(shelters_data,!is.na(shelters_data$Refugio))
  # Change lat lon to readable format for distance and plotting
  # convert_coord is a user defined function
  shelters_data$Latitud <- sapply(X = shelters_data$Latitud,FUN = convert_coord) # see line 38
  # Longitudes should be negative: if inputed as are, they're in Vietnam
  shelters_data$Longitud <- (-1) * sapply(X = shelters_data$Longitud,FUN = convert_coord)
  
  # coordinates 213,281 have unsaveable formatting (digits missing)
  # coordinates 75,83,84,283,336,337,338 are missing
 
  # coordinate 434 is reversed for lat lon and breaks distance functions :(
  # this loop should take care of this kind of problem
  for(i in 1:dim(shelters_data)[2]){
    # Check if coordinates might be switched
    # Input,Output : row of a DataFrame 
    # rough estimate of coordinates that contain Mexico
    if( (shelters_data$Longitud[i] < -120 & shelters_data$Longitud[i] > -80) & (shelters_data$Latitud[i] < 10 & shelters_data$Latitud[i] > 35)){
      # if outside the quadrant, switch them
      lat_temp <- row$Longitud
      lon_temp <- row$Latitud
      # check if the switched coordinates belong to Mexico now
      if ( (lon_temp > -120 & lon_temp < -80) & (lat_temp > 10 & lat_temp < 35)){
        # if they do, assign them
        shelters_data$Longitud[i] <- lon_temp
        shelters_data$Latitud[i] <- lat_temp
      }
    }
  }
  
  
  return(shelters_data)
}

read_excel_allsheets <- function(file_name) {
  # Input xls / xlsx file
  # Return list containing one sheet per list element
  sheets <- excel_sheets(file_name)
  sheet_list <- lapply(sheets, function(X) read_excel(file_name, sheet = X, skip = 5,
                                                      col_names = c('Numero','Refugio','Municipio',
                                                                    'Direccion','Uso_Inmueble','Servicios',
                                                                    'Capacidad_Personas','Latitud','Longitud',
                                                                    'Altitud','Responsable','Telefono')))
  names(sheet_list) <- sheets
  return(sheet_list)
}

convert_coord<-function(coord){
  # Input coord string in degree format 22°29'56.06" 
  # Return coord_n numeric in decimal format 22.49891
  
  splitted_raw_coord= strsplit(coord,"°|º|ª|'|`|-|[|]|[.]|\\\"") # all the different separators there are
  # dropping all empty fields gets rid of duplicate separators, return only numbers
  splitted_num_coord = splitted_raw_coord[[1]][splitted_raw_coord[[1]] != ""]
  
  degrees = as.numeric( splitted_num_coord[1] )
  minutes = as.numeric( splitted_num_coord[2] )
  seconds = as.numeric( splitted_num_coord[3] ) + as.numeric(substr(splitted_num_coord[4],1,2)) / 100
  
  coord_n = degrees+ (minutes/60) + (seconds/3600) 
  
  return( coord_n ) 
} 


############################ FUNCTIONS FOR SHINY ###############################

get_n_closest_shelters <- function(starting_point,n,shelters_data = shelters_data){
  # Input the starting point in (lon,lat) format and a data frame that contains (lon,lat)
  # of shelters on columns named "Longitud" and "Latitud"
  # Output: dataframe with three rows: the three closest shelters to the given startpoint
  
  # Compute distance for all shelters
  # great sphere distance returns meters, dividing by 1000
  shelters_data$Distancia_km <- as.vector (distm (starting_point, 
                                               cbind(shelters_data$Longitud,shelters_data$Latitud))) / 1000
  # Choose top 3
  # order by distance
  shelters_data <- shelters_data %>% arrange(Distancia_km)
  # select three rows
  n_closest_shelters = shelters_data[1:n,]
  return(n_closest_shelters)
}

