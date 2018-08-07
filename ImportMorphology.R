#
#Script for reading in the morphology data and transforming it from pixels to mm.
#
#Defined functions:
##ReadData:
###Reads in the file and ads a column wit the conversion factor
#
##ConvData:
###Converts all measurements from pixels to mm.
###Deletes the "five_mm" and "ConvFact" columns.
#


#Setting working directory, (change this if necesarry)
WorkDirectory <- "D:/Documents/MatechoiceColor2018/MorphologyPhotos"

#Defining function for reading in the data
ReadData <- function(wd){
  setwd(wd)
  pixels <- read.csv("measurements.txt", sep="\t")
  pixels <- within(pixels, ConvFact <- five_mm/5)
  return(pixels)
}

#Defining function for convertingfrom pixels to mm
ConvData <- function(pixels){
  mm <- pixels
  for (column in 2:ncol(pixels)){
    print(column)
    for (row in 1:nrow(pixels)){
      print(row)
      mm[row,column] <- pixels[row, column]/pixels[row,"ConvFact"]
    }
  }
  mm <- mm[ , 1:7]
  return(mm)
}

#Defining function for running the above functions in soccessive order. 
Run <- function(wd){
  pixels <- ReadData(wd)
  mm <- ConvData(pixels)
  return(mm)
}

#Runing the shit
PhotoMorphology <- Run(WorkDirectory)

