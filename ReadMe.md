---
title: "Getting and Cleaning Data Course Project"
author: "Jason"
date: "May 21, 2015"
output: html_document
---
#Introduction
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

You should create one R script called run_analysis.R that does the following. 
Merges the training and the test sets to create one data set.
Extracts only the measurements on the mean and standard deviation for each measurement. 
Uses descriptive activity names to name the activities in the data set
Appropriately labels the data set with descriptive variable names. 
From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Good luck!
Please upload the tidy data set created in step 5 of the instructions. Please upload your data set as a txt file created with write.table() using row.name=FALSE (do not cut and paste a dataset directly into the text box, as this may cause errors saving your submission).

#get data
```{r}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")){
  download.file(fileUrl,destfile="./getdata-projectfiles-UCI HAR Dataset.zip",
  method="curl")
  unzip("getdata-projectfiles-UCI HAR Dataset.zip")
}
```
#read data
```{r}
dataActivityTest  <- read.table(file.path("UCI HAR Dataset", "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "Y_train.txt" ),header = FALSE)

dataSubjectTest  <- read.table(file.path("UCI HAR Dataset", "test" , "subject_test.txt" ),header = FALSE)
dataSubjectTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "subject_train.txt" ),header = FALSE)

dataFeaturesTest  <- read.table(file.path("UCI HAR Dataset", "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "X_train.txt" ),header = FALSE)
```

##Merging
```{r}
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
```

#Naming
```{r}
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
names(dataFeatures)<-read.table(file.path("UCI HAR Dataset", "features.txt"),header=FALSE)$V2
```

#Binding
```{r}
DataUCI<-cbind(dataFeatures, dataSubject, dataActivity)
```

##Subsetting
```{r}
subsetDataUCI<-DataUCI[,c(grep("mean\\(\\)|std\\(\\)", read.table(file.path("UCI HAR Dataset", "features.txt"),header=FALSE)$V2), 562,563)]
```

##activity
```{r}
activityLabels<-read.table(file.path("UCI HAR Dataset", "activity_labels.txt"),header=FALSE)$V2
subsetDataUCI[,68]<-activityLabels[subsetDataUCI[,68]]
```

##Renaming
```{r}
names(subsetDataUCI)<-gsub("^t", "time", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("^f", "frequency", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Acc", "Accelerometer", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Gyro", "Gyroscope", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Mag", "Magnitude", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("BodyBody", "Body", names(subsetDataUCI))
```

##newdata
```{r}
dataFinal<-aggregate(.~subject+activity, subsetDataUCI,mean)
```

##final output
```{r}
write.table(dataFinal, file="final_data.txt", row.name=FALSE)
```
