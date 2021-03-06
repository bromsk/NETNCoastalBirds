% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getSurveyMat.R
\name{getSurveyMat}
\alias{getSurveyMat}
\title{View survey matrix}
\usage{
getSurveyMat(survey, df = NULL, island = NA, year = NA,
  species = NA)
}
\arguments{
\item{survey}{A character vector. Accepts "nest", "creche", "incubation" or "AMOY". 
If "AMOY", only returns dates when AMOY mating paris were reported}

\item{df}{A data frame of the surveys. Supply argument when connection to database 
is not available. If survey is "creche", then must be data frame created from 
CrecheSum() function. If survey is "incubation", then must be data frame created from the
SumIncubation() function. If survey is "nest", then must be data frame created from the
SumNestSurveys() function.}

\item{island}{A  vector of island names. To view summariaes across all islands, 
"All Islands"}

\item{year}{Calendar year(s) to view data by. Useful when wanting to view seasonal 
survey data in a year.}

\item{species}{A  vector of species name codes, e.g. "BCNH"}
}
\value{
This function returns a matrix showing dates of surveys for 
specified arguments indicated as "X".
}
\description{
Constructs survey matrix to show effort based on the inputs
}
\section{Warning}{

User must have Access backend entered as 'NETNCB' in Windows ODBC manager.
}

\examples{
getSurveyMat(survey ="nests", species ="COEI", year = 2009)
getSurveyMat(survey ="creche",  year = 2007:2011)

}
\seealso{
\url{ https://www.nps.gov/im/netn/coastal-birds.htm}
}
