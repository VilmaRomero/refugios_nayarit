library(readxl) 

source('utils.R')

path_to_file = "/" # required
file_name = "refugios_nayarit.xlsx"

shelters_data <- clean_excel_file(path_to_file,file_name) # cleaning steps
write.csv(shelters_data, file="refugios_nayarit_limpio.csv",row.names = FALSE)

