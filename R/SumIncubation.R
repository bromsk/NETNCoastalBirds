#' @include GetIncubationData.R

#' @title sum incubation surveys
#'
#' @import dplyr 
#' @importFrom tidyr spread gather
#' @importFrom magrittr %>% 
#' @importFrom tibble add_column
#' @importFrom lubridate year month
#' @importFrom plyr mapvalues
#' 
#' @description Brings in the raw incubation survey data from \code{\link{GetIncubationData}} and
#'  summarizes the data for plotting and analysis. Currently only sums counts from the primary 
#'  survey (Carol's) when repeated surveys were conducted. If you specify an argument to "ByObserver" 
#'  this will return sum counts of all duplicate surveys by observer.
#' @section Warning:
#' User must have Access backend entered as 'NETNCB' in Windows ODBC manager.
#' @param time Character string equal to "date" or "year". Value must be provided; there is
#' no default. Choose to sum counts by "date" or "year". Summing by date will sum counts across 
#' segments of each island for each date. Summing by year sums counts across all surveys conducted 
#' in that year. Note that some surveys were repeated in the same year. 
#' @param species To subset data by species, use "COTE", "DCCO","GBBG","HERG". Defaults
#' to providing output for all species.
#' @param output Character string equal to "graph" or "table". 
#' Defaults to long format (output= "graph") ready for ggplot and the \code{\link{PlotBirds}}
#' function. For wide format use "table".
#' @param ByObserver Character string equal to "yes" or "no".  If "yes" will output the 
#' survey data counted by each observer for each island 
#' segment on each date. Only sums across multiple observations by same observer at each segment. 
#' Defaults to "no".
#' @param df  The user can optionally load the raw incubation data from an R object or connect to the 
#' Access database to obtain it. Defaults to NULL, which means the Access database will
#' be used to obtain it.
#' 
#' @return Returns a \code{list} with the counts of Gulls, cormorant, and terns observed during 
#' boat-based surveys per island, species, and date/year. The first  \code{list}  element summarizes 
#' incubation surveys by Year for graphing. The second element for tabular summary.
#' @seealso \url{ https://www.nps.gov/im/netn/coastal-birds.htm} 
#' @examples  
#' SumIncubation(time= "year", species = "DCCO", output = "graph")
#' SumIncubation(time= "date", species = "DCCO", output = "graph")
#' SumIncubation(time= "date", ByObserver = "yes")
#' @export
#' 
#
SumIncubation <- function(df = NULL, time, species = NA, output = "graph", ByObserver = "no") {
  # this function summarizes the number of adults on nests per island, year, and by observer
  
  if (is.null(df)) {
    df <- GetIncubationData(x) # import data from the database if needed
    #head(df)
  }
  

    # Setup and create molten dataframe
  #############################################################################
  
  # subset by species if provided 
  if(!anyNA(species)) df <- df[df$Species_Code %in% species, ] 
  
  # exclude LETE
  df<-df[!df$Species_Code %in% "LETE",]
 
  ### Sum data across each segement as raw numbers by observer 
  
  if (time == "date" & ByObserver == "yes") {
    graph.final <- df %>%
      group_by(Island, Segment, Observer, Species_Code, 
               Date, month, year, Survey_Duplicate, Survey_Complete) %>% 
      dplyr::summarise(value = sum(Unit_Count, na.rm=TRUE)) %>% 
      dplyr::rename(time = year) %>% 
      inner_join(species_tlu, ., by= "Species_Code") # add species names to data
    return(graph.final)
  }else{

    df.melt <- df %>%
      dplyr::select(Island, Segment, Date, year, month, Survey_Primary,
                      Survey_Duplicate, Survey_Complete, Species_Code, Unit_Count) %>%
      dplyr::filter(Survey_Primary == "Yes" ) %>% # grab only the records from the primary survey to avoid counting multi-obs of same event
      #dplyr::filter(Survey_Duplicate == "No" ) %>% # grab only the records from the first survey if repeated
      tidyr::gather(variable, value, -Island, -Segment, -Date, -year, -month, -Survey_Primary, 
             -Survey_Duplicate, -Survey_Complete, -Species_Code) %>% 
      dplyr::mutate(variable = NULL)
    # head(df.melt)

  }
  
  #######################################
  ## Sum the number of adults observed on nests
  #################################################
  
  ### Sum counts per year or across all surveys per island across segements
    # Note that there can be more than one primary survey per year
    # Because of thie the summary below first takes the max count per segment per year then sums these values to get the annual count per island.
  
  if (time == "year") {
    SumBySelect <- df.melt %>% 
      group_by(Species_Code, Island, Segment,year) %>% 
      dplyr::summarise(value = max(value, na.rm = TRUE)) %>% # find the maximum nest count per segment when >1 surveys per year 
      group_by(Species_Code, Island, year) %>% 
      dplyr::summarise(value = sum(value, na.rm = TRUE), n=n()) %>% # find the total no. nests per year
      dplyr::rename(time = year)
    
    ## Sum the number of adults in each year across all islands
    ### Calculate for all Islands
    SumByBOHA <- df.melt %>% 
      group_by(Species_Code, Island, Segment,year) %>% 
      dplyr::summarise(value = max(value, na.rm = TRUE)) %>% # find the maximum nest count per segment when >1 primarysurveys per year 
      group_by(Species_Code, year) %>% 
      dplyr::summarise(value = sum(value, na.rm = TRUE), n=n()) %>% # find the total no. nests per year
      tibble::add_column(Island = "All Islands")  %>% 
      dplyr::rename(time = year)
      }
  
  ### Sum counts per date for all surveys counted on the same island across segements
    # Note that there can be more than one primary survey per day
    # Because of thie the summary below first takes the max count per segment per date then sums these values to get the daily count per island.
  
  if (time == "date") {
    SumBySelect <- df.melt %>% 
      group_by(Species_Code, Island, Segment, Date, month, year) %>% 
      dplyr::summarise(value = max(value, na.rm = TRUE)) %>% # find the maximum nest count per segment when >1 primary surveys per date. 
      group_by(Species_Code, Island, Date, month,year) %>% 
      dplyr::summarise(value = sum(value, na.rm = TRUE), n=n())%>% 
      dplyr::rename(time = Date)
    
    ## Sum the number of adults on each date across all islands
    ### Calculate for all Islands
    SumByBOHA <- df.melt %>% 
      group_by(Species_Code, Island, Segment, Date, month, year) %>% 
      dplyr::summarise(value = max(value, na.rm = TRUE)) %>% # find the maximum nest count per segment when >1 primary surveys per date. 
      group_by(Species_Code, Date, month, year) %>% 
      dplyr::summarise( value = sum(value, na.rm=TRUE)) %>% 
      tibble::add_column(Island = "All Islands") %>% 
      dplyr::rename(time = Date)
  }
    
    # bind together
    SumBySelection <- bind_rows(SumBySelect, SumByBOHA) %>% 
      inner_join(species_tlu, ., by = "Species_Code") # add species names to data
    
    graph.final <- SumBySelection %>%
      mutate(FullLatinName = as.character(FullLatinName),
             CommonName = as.character(CommonName),
             variable = "Incubating adults")
  
  # output data for graphing
  
  if(output == "graph") {
    return(graph.final)
    #write.table(graph.final, "./Data/Incubationsurveys.csv", sep=",", row.names= FALSE)
  }
  
  ### make wide for tabular display
  if(output == "table") {
    table.final <- spread(graph.final, CommonName, value, drop = TRUE) %>% 
      ungroup() %>%  
      mutate(Species_Code = NULL, FullLatinName = NULL)
    #write.table(table.final, "./Data/Incubationsurveys.csv", sep=",", row.names= FALSE)
    return(table.final)
  }
}