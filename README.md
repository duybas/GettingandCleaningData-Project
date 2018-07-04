# GettingandCleaningData-Project
Data Science Specialization Course Project

* The `run_analysis.r` script downloads and extracts the file that is given in the `url` if it is not already there.
* It then loads the files to datasets and merges the data for training and test sets. 
* It combines `subject` and `activity` datasets with the dataset `data` which contains the measurement data and at the same time uses descriptive activity names to name the activities in the data set
* It extracts the measurements on the mean and standard deviation for each measurement. 
* By separating the measured features to its components, it appropriately labels the data set with descriptive variable names.
* It orders the variables in the dataset with the help of the `colorder` character vector.
* It creates a second, independent tidy data set, `averagedData` with the average of each variable for each activity and each subject.