% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SumIncubation.R
\name{SumIncubation}
\alias{SumIncubation}
\title{sum incubation surveys}
\usage{
SumIncubation(df = NULL, time, species = NA, output = "graph",
  ByObserver = "no")
}
\arguments{
\item{df}{The user can optionally load the raw incubation data from an R object or connect to the 
Access database to obtain it. Defaults to NULL, which means the Access database will
be used to obtain it.}

\item{time}{Character string equal to "date" or "year". Value must be provided; there is
no default. Choose to sum counts by "date" or "year". Summing by date will sum counts across 
segments of each island for each date. Summing by year sums counts across all surveys conducted 
in that year. Note that some surveys were repeated in the same year.}

\item{species}{To subset data by species, use "COTE", "DCCO","GBBG","HERG". Defaults
to providing output for all species.}

\item{output}{Character string equal to "graph" or "table". 
Defaults to long format (output= "graph") ready for ggplot and the \code{\link{PlotBirds}}
function. For wide format use "table".}

\item{ByObserver}{Character string equal to "yes" or "no".  If "yes" will output the 
survey data counted by each observer for each island 
segment on each date. Only sums across multiple observations by same observer at each segment. 
Defaults to "no".}
}
\value{
Returns a \code{list} with the counts of Gulls, cormorant, and terns observed during 
boat-based surveys per island, species, and date/year. The first  \code{list}  element summarizes 
incubation surveys by Year for graphing. The second element for tabular summary.
}
\description{
Brings in the raw incubation survey data from \code{\link{GetIncubationData}} and
 summarizes the data for plotting and analysis. Currently only sums counts from the primary 
 survey (Carol's) when repeated surveys were conducted. If you specify an argument to "ByObserver" 
 this will return sum counts of all duplicate surveys by observer.
}
\section{Warning}{

User must have Access backend entered as 'NETNCB' in Windows ODBC manager.
}

\examples{
 
SumIncubation(time= "year", species = "DCCO", output = "graph")
SumIncubation(time= "date", species = "DCCO", output = "graph")
SumIncubation(time= "date", ByObserver = "yes")
}
\seealso{
\url{ https://www.nps.gov/im/netn/coastal-birds.htm}
}
