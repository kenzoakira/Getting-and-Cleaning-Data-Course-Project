
#create "data" folder to store dataset
dir.create("./data")
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url=url,destfile="./data/sourcedata.zip",method="curl",quiet=TRUE)
unzip("./data/sourcedata.zip",exdir="./data")
folder<-"./data/UCI HAR Dataset"

#load the train and test data
train<-read.table(paste(folder,"/train/X_train.txt",sep=""))
test<-read.table(paste(folder,"/test/X_test.txt",sep=""))
colnames<-read.table(paste(folder,"/features.txt",sep=""))


#merge train and test data, and select the columns, whose names contain mean() or std()
data<-rbind(train,test)
names(data)<-colnames[,2]
meanmatch<-grepl("mean()",names(data),fixed=TRUE)
stdmatch<-grepl("std()",names(data),fixed=TRUE)
strData<-data[,meanmatch|stdmatch]
trainlabel<-read.table(paste(folder,"/train/y_train.txt",sep=""))
trainsub<-read.table(paste(folder,"/train/subject_train.txt",sep=""))
testlabel<-read.table(paste(folder,"/test/y_test.txt",sep=""))
testsub<-read.table(paste(folder,"/test/subject_test.txt",sep=""))
datalabel<-rbind(trainlabel,testlabel)
datasub<-rbind(trainsub,testsub)
strData<-cbind(datalabel,datasub,strData)
names(strData)[1]<-"Activity.Label"
names(strData)[2]<-"Subject.ID"
labelname<-read.table(paste(folder,"/activity_labels.txt",sep=""))
names(labelname)<-c("Activity.Label","Activity.Name")
strData<-merge(labelname,strData,by.x="Activity.Label",by.y="Activity.Label")
strData[,1]<-as.factor(strData[,1])
strData[,2]<-as.factor(strData[,2])
strData[,3]<-as.factor(strData[,3])

#combine label and subject class to create a new data frame based on step4 
aggData<-aggregate(.~Activity.Label+Activity.Name+Subject.ID,data=strData,mean)
aggData<-aggData[order(aggData$Activity.Label,aggData$Subject.ID),]
#write aggregated data to a txt file
write.table(aggData,"./data/tidyData.txt",row.names=FALSE)

y<-read.table("./data/tidyData.txt",header=TRUE)

