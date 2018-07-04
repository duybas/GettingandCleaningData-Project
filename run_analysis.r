library(data.table)
library(tidyr)
#   The URL of the data for the project
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('UCI HAR Dataset')) {
    z <- tempfile()
    download.file(url, z, method = 'curl')
    unzip(z,exdir = '.')
    remove(z)
}
#   ID of the subject who performed the activity. Its range is from 1 to 30
subjectTest <- fread('./UCI HAR Dataset/test/subject_test.txt')
subjectTrain <- fread('./UCI HAR Dataset/train/subject_train.txt')
subject <- rbindlist(list(subjectTrain, subjectTest))
#   Actual training and test sets
test <- fread('./UCI HAR Dataset/test/X_test.txt')
train <- fread('./UCI HAR Dataset/train/X_train.txt')
data <- rbindlist(list(train, test))
#   Label of six activities (WALKING, WALKING_UPSTAIRS, 
#   WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING). 
#   Its range is from 1 to 6.
labelTest <- fread('./UCI HAR Dataset/test/y_test.txt')
labelTrain <- fread('./UCI HAR Dataset/train/y_train.txt')
label <- rbindlist(list(labelTrain, labelTest))

rm(test, train, labelTest, labelTrain, subjectTest, subjectTrain)

features <- fread('./UCI HAR Dataset/features.txt')
setnames(data, 1:dim(data)[2], features$V2)
#pattern <- 'mean\\(\\)|std\\(\\)'
cols <- grep('mean\\(\\)|std\\(\\)', features$V2, value = T)
data <- data[, cols, with=FALSE]

activities <- fread('./UCI HAR Dataset/activity_labels.txt')
activity <- activities[label$V1,V2]


data[,subject:= subject]
data[,activity := activity]

rm(features, activities, subject,activity, label)

data <- data %>%
    gather(feature, value, -subject:-activity) %>%
    separate(feature, 
             into = c('featurehead', 'featureStat', 'featureAxial'), 
             sep = '-') %>%
    data.table()

data$featureStat <- gsub("\\(|\\)", '',data$featureStat)
data$featureStat <- gsub("std", "standard deviation",data$featureStat)
data[, featureDomain := ifelse(grepl('^t', data$featurehead),
                               'time', 'frequency')]
data[, featureAccSignal := ifelse(grepl('Gravity', data$featurehead),
                               'gravitational', 'body')]
data[, featureSource := ifelse(grepl('Acc', data$featurehead),
                               'accelerometer', 'gyroscope')]
data[, featureJerk := ifelse(grepl('Jerk', data$featurehead),
                               'Jerk', NA)]
data[, featureMag := ifelse(grepl('Mag', data$featurehead),
                               'magnitude', NA)]
data[,featurehead:=NULL]
colorder <- c('subject','activity','featureDomain',
             'featureAccSignal', 'featureSource',
             'featureJerk', 'featureMag', 'featureStat',
             'featureAxial', 'value')

cols <- setdiff(colorder, 'value')
data[, (cols) := lapply(.SD, factor), .SDcols = cols]

setcolorder(data, colorder)
setkey(data, 'subject','activity','featureDomain',
       'featureAccSignal', 'featureSource',
       'featureJerk', 'featureMag', 'featureStat',
       'featureAxial')
#   Second, independent tidy data set with the average of 
#   each variable for each activity and each subject.


averagedData <- data[,list(count = .N,
                      average= mean(value)), 
                by =key(data)]