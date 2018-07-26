#Script for reeding in the presentation data files and converting them to apropriate format.
setwd("D:/Documents/MatechoiceColor2018/PresentationData")

library(reshape2)
library(plyr)

#Defining function for reading in the file
ReadFile <- function(filename){ 
  
  #read in the file and separate it by ";"
  file <- read.csv(filename, sep=";", header = FALSE,
                   col.names = c("","String","Trial","Pres1","Pres2","Pres3","date1","date2",""))
  
  #Separate dates and times
  file <- transform(file, date1 = colsplit(date1, pattern = ",", names = c('date', 'StartTime')))
  file <- transform(file, date2 = colsplit(date2, pattern = ",", names = c('date', 'EndTime')))
  
  #simplify structure
  file["StartTime"] <- file$date1$StartTime
  file["date"] <- file$date1$date
  file["EndTime"] <- file$date2$EndTime
  
  #Separate MaleID wt/tr ans presented to
  file <- transform(file, String = colsplit(String, pattern = " ", 
                                            names = c('MaleID', 'Treatment', "Pres_to")))
  
  #Simplify structure
  file["MaleID"] <- file$String$MaleID
  file["Treatment"] <- file$String$Treatment
  file["Pres_to"] <- file$String$Pres_to
  file <- file[-c(1, 2, 7, 8, 9)]
  file <- file[c(8:10, 1:4, 5, 7, 6)]

  return(file)
}


#Defining function for cleaning the data
     #Here I call three presentations a Trial and five Trials a Round
     #Each (most) male(s) went through four rounds (wt f, wt m, tr f and tr m)
CleanData <- function(datain){
  #Get rid of Rounds with < 5 Trials
  DelRows<- c()                       #Defining the vector of rows to be deleted
  Round <- c(datain[1, "Trial"])      #Going through the first row outside of for-loop
  for (rownr in 2:nrow(datain)){      #For-loop going through data row-by-row
    if (datain[rownr, "Pres_to"] != datain[rownr-1, "Pres_to"] |     #Checking if still in same Round
        datain[rownr, "Treatment"] != datain[rownr-1, "Treatment"]){ #
      if (length(Round) < 5){                                        #Checking number of presentations
        DelRows <- c(DelRows, (rownr-length(Round)):(rownr-1))       #Deleting the round in case of
      }                                                              #to few trials
      Round <- c()                            #Resetting Round
    }
    Round <- c(Round, datain[rownr, "Trial"]) #Appending trial to round
  }
  #print(DelRows)
  dataout <- datain[-c(DelRows), ]            #Deleting the incomplete rounds
  return(dataout)
}

#Defining function for computing means and medians etc
CompData <- function(datain){ 
  #return(dataout)
}

Run <- function(filename){
  Raw <- ReadFile(filename)
  Clean <- CleanData(Raw)
  Comp <- CompData(Clean)
  Outlist <- list(Raw, Clean, Comp)
  names(Outlist) <- c("Raw", "Clean", "Comp")
  return(Outlist)
}


Archive <- Run("RobinCleanData.txt")
PresData <- Archive$Comp

work <- Archive$Raw


