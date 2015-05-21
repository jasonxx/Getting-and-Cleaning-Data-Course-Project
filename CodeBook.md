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

#get data
Getting data from the internet and save, unzip in current directory. if you already have the required data, this part will not be excuted.
```{r}

if(!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")){
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./getdata-projectfiles-UCI HAR Dataset.zip",
  method="curl")
  unzip("getdata-projectfiles-UCI HAR Dataset.zip")
}
```
#Read data
read raw data into R based on the data description. A "big picture"" of the data is explained by David Hood, the TA of this course which is included in the Github directory. 

```{r}
dataActivityTest  <- read.table(file.path("UCI HAR Dataset", "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "Y_train.txt" ),header = FALSE)

dataSubjectTest  <- read.table(file.path("UCI HAR Dataset", "test" , "subject_test.txt" ),header = FALSE)
dataSubjectTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "subject_train.txt" ),header = FALSE)

dataFeaturesTest  <- read.table(file.path("UCI HAR Dataset", "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "X_train.txt" ),header = FALSE)
```

##Merging
merge the data by row. notice that the order is kept the same so that data will not be messed up afterwards 
```{r}
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
```

#Naming
give the columns proper name. the Feature names are read from the features.txt file
```{r}
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
names(dataFeatures)<-read.table(file.path("UCI HAR Dataset", "features.txt"),header=FALSE)$V2
```

#Binding
The merged data can now bind together by row. the new data is saved in DataUCI.
```{r}
DataUCI<-cbind(dataFeatures, dataSubject, dataActivity)
```

##Subsetting
mwan and std data from DataUCI can be subset by regular expression matching, using grep. The subject and activity attributes are included in the subset by the column number 562 and 563.
new data subsetDataUCI created
```{r}
subsetDataUCI<-DataUCI[,c(grep("mean\\(\\)|std\\(\\)", read.table(file.path("UCI HAR Dataset", "features.txt"),header=FALSE)$V2), 562,563)]
```

##Activity
activity lables are read from activity_labels.txt and saved in a frame called activityLabels. the values are assigned to the 68th column of subsetDataUCI based on the value of this column. 
```{r}
activityLabels<-read.table(file.path("UCI HAR Dataset", "activity_labels.txt"),header=FALSE)$V2
subsetDataUCI[,68]<-activityLabels[subsetDataUCI[,68]]
```

##Renaming
several acronyms are replaced by full name in the column names, generating a reader-friendly dataframe.  
```{r}
names(subsetDataUCI)<-gsub("^t", "time", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("^f", "frequency", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Acc", "Accelerometer", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Gyro", "Gyroscope", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Mag", "Magnitude", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("BodyBody", "Body", names(subsetDataUCI))
```

##Newdata
the averages by subject+activity are calculated by aggregate() function and the dataFinal created.
```{r}
dataFinal<-aggregate(.~subject+activity, subsetDataUCI,mean)
```

##Final output
generate file for submission
```{r}
write.table(dataFinal, file="final_data.txt", row.name=FALSE)
```
