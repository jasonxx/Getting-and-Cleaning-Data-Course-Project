#Getting-and-Cleaning-Data-Course-Project

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")){
  download.file(fileUrl,destfile="./getdata-projectfiles-UCI HAR Dataset.zip",
                method="curl")
  unzip("getdata-projectfiles-UCI HAR Dataset.zip")
}

dataActivityTest  <- read.table(file.path("UCI HAR Dataset", "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "Y_train.txt" ),header = FALSE)

dataSubjectTest  <- read.table(file.path("UCI HAR Dataset", "test" , "subject_test.txt" ),header = FALSE)
dataSubjectTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "subject_train.txt" ),header = FALSE)

dataFeaturesTest  <- read.table(file.path("UCI HAR Dataset", "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain  <- read.table(file.path("UCI HAR Dataset", "train" , "X_train.txt" ),header = FALSE)

dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
names(dataFeatures)<-read.table(file.path("UCI HAR Dataset", "features.txt"),header=FALSE)$V2

DataUCI<-cbind(dataFeatures, dataSubject, dataActivity)

subsetDataUCI<-DataUCI[,c(grep("mean\\(\\)|std\\(\\)", read.table(file.path("UCI HAR Dataset", "features.txt"),header=FALSE)$V2), 562,563)]

activityLabels<-read.table(file.path("UCI HAR Dataset", "activity_labels.txt"),header=FALSE)$V2
subsetDataUCI[,68]<-activityLabels[subsetDataUCI[,68]]

names(subsetDataUCI)<-gsub("^t", "time", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("^f", "frequency", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Acc", "Accelerometer", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Gyro", "Gyroscope", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("Mag", "Magnitude", names(subsetDataUCI))
names(subsetDataUCI)<-gsub("BodyBody", "Body", names(subsetDataUCI))

dataFinal<-aggregate(.~subject+activity, subsetDataUCI,mean)
write.table(dataFinal, file="final_data.txt", row.name=FALSE)