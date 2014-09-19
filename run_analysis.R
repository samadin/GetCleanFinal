###------- Runs an Analysis for Getting & Cleaning Data Final Project -------###

#-------------------------- Load and Preprocess Data --------------------------#
# load data 
sub_test    <- read.table(file="./UCI HAR Dataset/test/subject_test.txt",
                          sep="\n",col.names="Subject")
X_test      <- read.table(file="./UCI HAR Dataset/test/X_test.txt",
                          sep="")
Y_test      <- read.table(file="./UCI HAR Dataset/test/y_test.txt",
                          sep="\n",col.names="Activity")
sub_train   <- read.table(file="./UCI HAR Dataset/train/subject_train.txt",
                          sep="\n",col.names="Subject")
X_train     <- read.table(file="./UCI HAR Dataset/train/X_train.txt",
                          sep="")
Y_train     <- read.table(file="./UCI HAR Dataset/train/y_train.txt",
                          sep="\n",col.names="Activity")

Features    <- read.table(file="./UCI HAR Dataset/features.txt",
                          sep="\n")
A_label     <- read.table(file="./UCI HAR Dataset/activity_labels.txt",
                          sep="")
A_label     <- A_label[,2] # remove row names

# add column headers
colnames(X_test)    <- as.factor(Features[,])
colnames(X_train)   <- as.factor(Features[,])

# combines {subject,activity,data} into 1 table for testing, and one for training
ALL_test    <- cbind(sub_test,Y_test,X_test)
ALL_train   <- cbind(sub_train,Y_train,X_train)

# clean up unused tables
rm(list=c("X_test","Y_test","sub_test","X_train","Y_train","sub_train"))

###------ Merges the training and the test sets to create one data set ------###
# recombines the testing and training data sets into a single data table
ALLDATA     <- rbind(ALL_test,ALL_train)

# clean up some more
rm(list=c("ALL_test","ALL_train","Features"))

###-------------- Extract only mean & s.d for each measurement --------------###
# ...by finding all Features containing the word "mean()" or "std()"
pattern <- "(\\W|^)(mean()|std())(\\W|$)"   # match phrase mean() or std()
MSD     <- ALLDATA[,c(1,2,grep(pattern,names(ALLDATA)))] 

###-- Rename activities using descriptive activity names: (A_label values) --###
# Replace numeric values in Activity column with descriptive names in A_label
MSD$Activity    <- A_label[MSD$Activity]

###------ Appropriately label data set with descriptive variable names ------###
# This was done previously during load/preprocessing (see above), as it made
# filtering the data easier. By avoiding a call to the merge() function, we
# avoided the possibility of columns/rows getting out of order as merge can
# sometimes do. Instead, I will do a litte more cleanup here.
rm(list=c("ALLDATA","A_label","pattern")) # only leaves MSD in workspace

###----- Create 2nd, independent tidy data set with the average of each -----###
###------------- variable for each activity and each subject ----------------###
# this is easier using dplyr package but can't get it working
AVGS            <- aggregate.data.frame(MSD,list(MSD$Subject,MSD$Activity),mean)
AVGS$Activity   <- AVGS$Group.2
AVGS            <- AVGS[,-c(1,2)] # cleaning things up a bit
rm(MSD)

# save tidy data set
write.table(AVGS,file="TidyAVGData.txt",row.names=FALSE)