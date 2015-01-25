# Analysis of activity tracking data. date: 25JAN2015.
# read files.
subject_train <- read.table("./coursera/Course-2/UCI HAR Dataset/train/subject_train.txt",col.names = "subject_id")
X_train <- read.table("./coursera/Course-2/UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./coursera/Course-2/UCI HAR Dataset/train/Y_train.txt", col.names = "activity_id")

subject_test <- read.table("./coursera/Course-2/UCI HAR Dataset/test/subject_test.txt", col.names = "subject_id")
X_test <- read.table("./coursera/Course-2/UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("./coursera/Course-2/UCI HAR Dataset/test/Y_test.txt", col.names = "activity_id")

features    <- read.table("./coursera/Course-2/UCI HAR Dataset/features.txt")

# append train and test tables.
dat <- rbind(X_train, X_test)
dat_activity <- rbind(Y_train, Y_test)
dat_subject <- rbind(subject_train, subject_test)

# select the variables of interest from features table.
row_mean <- grep("mean", features$V2)
row_std  <- grep("std", features$V2)
selected_features   <- features[c(row_mean, row_std),]

# clean variable names for mean and std variables.
tmp1 <- gsub("-" , "_", selected_features$V2)
tmp2 <- gsub("\\)" , "", tmp1)
selected_features$V2 <- gsub("\\(" , "", tmp2)

# take the subset of the measurement data.
selected_dat <- dat[,c(row_mean, row_std)]

# merge subject, activity and measurement datasets.
dat_final <- cbind(dat_subject, dat_activity, selected_dat)

# label the activity field.
dat_final$activity_id <- factor(dat_final$activity_id, levels=c(1,2,3,4,5,6), labels=c("WALKING", 
"WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))

#install.packages("dplyr")
library(plyr)
library(dplyr)
# summarise the dataset by taking the average of mean and std variables and group by subject_id and activity_id.
summary_table <- ddply(dat_final, .(activity_id, subject_id), colwise(mean))

# rename the measurement variables by adding "avg" to the beginning of each and apply to the final dataset.
selected_features$V2 <- paste("avg_", selected_features$V2, sep="")
variable_names <- c("activity_id", "subject_id", selected_features$V2)
names(summary_table) <- variable_names

# write the summary table to a txt file.
write.table(summary_table, file="./summary.txt", row.name=FALSE)

# END OF FILE # 
