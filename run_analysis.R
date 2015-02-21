#You should create one R script called run_analysis.R that does the following. 

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

do_column_averages <- function(activity_data) {
    save_factors <- activity_data[ , (1:2)]
    # Remove the two columns with factors, leaving only numeric data
    activity_data <- activity_data[ , -(1:2)]
    column_averages <- colMeans(activity_data)
    # Convert our list of column averages back to a data frame with the two factors restored
    cbind(save_factors[1, ], t(as.data.frame(column_averages)))
}

do_activity_averages <- function(subject_data) {
    # Here we have all the data for a given subject, we split it into
    # groupings based on activities
    activity_list <- split(subject_data, subject_data$activity)
    # Calculate column (measurement) averages for each activity for this subject
    activity_averages <- lapply(activity_list, do_column_averages)
    # Convert back to a data frame
    activity_averages <- do.call(rbind, activity_averages)
    activity_averages
}

run_analysis <- function() {
    # Read in the training data
    subject_train <- read.table("train/subject_train.txt")
    X_train <- read.table("train/X_train.txt")
    y_train <- read.table("train/y_train.txt")
    
    # Read in the test data
    y_test <- read.table("test/y_test.txt")
    subject_test <- read.table("test/subject_test.txt")
    X_test <- read.table("test/X_test.txt")
    
    # Combine the test and training data for X, subject, and y
    X_all <- rbind(X_test, X_train)
    subject_all <- rbind(subject_test, subject_train)
    y_all <- rbind(y_test, y_train)

    # Read the file describing the columns
    columns <- read.table("features.txt", colClasses=c("integer", "character"))
    # Read the file mapping activity numbers to strings
    activities <- read.table("activity_labels.txt", colClasses=c("integer", "character"))
    # Identify which columns contain mean and standard deviation data
    mean_columns <- grep("mean", columns[,2])
    std_columns <- grep("std", columns[,2])
    mean_and_std_columns <- sort(c(mean_columns, std_columns))
    # Extract just the mean and standard deviation data from the combined X data
    mean_and_std_data <- X_all[,mean_and_std_columns]
    
    # Update the column names with descriptive names from the features.txt file
    colnames(mean_and_std_data) <- columns[mean_and_std_columns, 2]
    # Update the column names for the subject and activity data
    colnames(subject_all) <- "subject"
    colnames(y_all) <- "activity"
    # Combine subject, activity, and mean and standard deviation data into on data frame
    full_data <- cbind(subject_all, y_all, mean_and_std_data)
    
    # Replace activity numbers with strings
    full_data$activity <- activities[full_data$activity, 2]
    # Set subject and activity as factors
    full_data[ ,'subject'] <- as.factor(full_data[, 'subject'])
    full_data[ ,'activity'] <- as.factor(full_data[, 'activity'])
    
    # split data by subject
    subject_list <- split(full_data, full_data$subject)
    # calculate averages for this subject
    averages <- lapply(subject_list, do_activity_averages)
    # Convert back to a single data frame
    averages <- do.call(rbind, averages)
    averages
}
