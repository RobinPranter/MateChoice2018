#Script for reeding in the presentation data files and converting them to apropriate format.
#It does the folowing things:
  #Defining functions#
    #ReadData()
    #CleanData()
    #CompData()
    #Run()
  #Runs the shit and retuns an list Archive containing 3 data frames
    #Raw - The Raw datafile as given from the app. A few asthetic modifications are included.
    #Clean - A cleaned up vesion of the above.
      #Trials with no values are deleted
      #Rounds with < 5 Trials are deleted
      #The numbering of the trials are corrected
    #Comp - Same as Clean but with two new columns, TrialValue and RaoundValue
      #Here I call three presentations a Trial and five Trials a Round
      #Each (most) male(s) went through four rounds (wt f, wt m, tr f and tr m)
      #TrialValue - Trial values according to scale (222 -> 1, else -> mean)
      #RoundValue - The Round mean of TrialValues

#Set working directory (correct this if necessary) 
setwd("D:/Documents/MatechoiceColor2018/PresentationData")

#Read in libraries
library(reshape2)
library(plyr)

#Defining function for reading in the file + esthetic modifications
ReadData <- function(filename){ 
  
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
  DelRows <- c()
  NTrials <- 0
  for (rownr in 1:nrow(datain)){
    #Get rid of trials with no presentation values
    if (is.na(datain[rownr, "Pres1"]) & is.na(datain[rownr, "Pres2"]) & is.na(datain[rownr, "Pres3"])){
      DelRows <- c(DelRows,rownr)
    }
    #Get rid of Rounds with < 5 Trials
    NTrials <- NTrials + 1
    if (rownr >1){
      if ((datain[rownr, "Pres_to"] != datain[rownr-1, "Pres_to"] |     #Checking if still in same Round
           datain[rownr, "Treatment"] != datain[rownr-1, "Treatment"]) & NTrials <5){
        DelRows <- c(DelRows, (rownr-NTrials):rownr)
        NTrials <- 0
      }
      #Correct the numbering of the trials
      if (datain[rownr, "Pres_to"] == datain[rownr-1, "Pres_to"] &     #Checking if still in same Round
          datain[rownr, "Treatment"] == datain[rownr-1, "Treatment"]){
        datain[rownr, "Trial"] <- datain[rownr-1, "Trial"] + 1 
      }
    }
  }
  dataout <- datain[-c(DelRows), ]
  return(dataout)
}


#Defining function for computing trial and Round values
CompData <- function(datain){
  #Initiate new columns
  datain["TrialValue"] <- NA
  datain["RoundValue"] <- NA
  dataout <- datain[c(1:7, 11:12, 8:10)]
  Startrow <- 1
  for (rownr in 1:nrow(dataout)){
    #Compute trial and round values
    #2,2,2,->1
    if (identical(dataout[rownr, "Pres1"], as.integer(2)) & identical(dataout[rownr, "Pres2"], as.integer(2))
        & identical(dataout[rownr, "Pres3"], as.integer(2))){
      dataout[rownr, "TrialValue"] <- 1
    }
    #else mean
    else{
      Presentations <- as.numeric(dataout[rownr, 5:7])
      dataout[rownr, "TrialValue"] <- mean(Presentations, na.rm=TRUE)
    }
    #Compute Round values
    if (rownr > 1){
      if (dataout[rownr, "Pres_to"] != dataout[rownr-1, "Pres_to"] |     #Checking if still in same Round
          dataout[rownr, "Treatment"] != dataout[rownr-1, "Treatment"]){
        dataout[rownr-1, "RoundValue"] <- mean(dataout[Startrow:(rownr-1), "TrialValue"])
        Startrow <- rownr
      }
    }
  }
  return(dataout)
}


#Defines function for running the above in successive order with the output from each func as the
#input for the successor.
Run <- function(filename){
  Raw <- ReadData(filename)
  Clean <- CleanData(Raw)
  Comp <- CompData(Clean)
  Outlist <- list(Raw, Clean, Comp)
  names(Outlist) <- c("Raw", "Clean", "Comp")
  return(Outlist)
}

#Running the shit
Archive <- Run("RobinCleanData.txt")
