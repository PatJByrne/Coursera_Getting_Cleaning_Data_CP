run_analysis <- function(file_location){
  require(dplyr)
  require(data.table)
  
  #Code runs as such: - Data is read into the tree.  Subject is converted to 2-digit, zero padded
  #so that it can be properly sorted.
  #The y data (aka the activity) is replaced with its English Name using activity labels.txt
  #The data in X_test and X_train are stepped through element by element, and a matrix is created
  #to contain the tidied data.  X is tidied by selecting a row in the tidy matrix based on the 
  #columns and rows in the un tidy data.
  #The data is then averaged by selecting every measurement(across time and frequency, and various measurements,
  #but whatever.  Sensible information isn't really the point of the excersize I guess, and placed in )
  #Runs slow, but it works, I guess.
  
  print('Reading data...')
  train_subj <- read.table(paste(file_location,"/UCI HAR Dataset/train/subject_train.txt",sep=''))
  print(paste(file_location,"/UCI HAR Dataset/train/subject_train.txt done",sep=''))
  test_subj <- read.table(paste(file_location,"/UCI HAR Dataset/test/subject_test.txt",sep=''))
  print(paste(file_location,"/UCI HAR Dataset/test/subject_test.txt done",sep=''))
  subj <- rbind(train_subj,test_subj)
  for(i in seq(length(subj[,1]))){
    subj[i,1] <- sprintf("%02s",subj[i,1])
  }
  
  
  rm(train_subj,test_subj)
  setnames(subj,colnames(subj),"Subject")
  
  y_trn <- read.table(paste(file_location,"/UCI HAR Dataset/train/y_train.txt",sep=''))
  print(paste(file_location,"/UCI HAR Dataset/train/y_train.txt done",sep=''))
  y_tst <- read.table(paste(file_location,"/UCI HAR Dataset/test/y_test.txt",sep=''))
  print(paste(file_location,"/UCI HAR Dataset/test/y_test.txt done",sep=''))
  act <- rbind(y_trn,y_tst)
  rm(y_trn,y_tst)
  act_labels <- read.table(paste(file_location,"/UCI HAR Dataset/activity_labels.txt",sep=''),stringsAsFactors = FALSE)
  
  for (k in seq(nrow(act_labels))){
    act[act == act_labels[k,1]] <- act_labels[k,2]
  }

  features <- read.table(paste(file_location,"/UCI HAR Dataset/features.txt",sep=''),stringsAsFactors = FALSE)
  print(paste(file_location,"/UCI HAR Dataset/features.txt done",sep=''))
  mean_std <- grepl("mean()",features[,2],fixed = TRUE)|grepl("std()",features[,2],fixed = TRUE)
  col_names <- features[mean_std,2]
  
  X_trn <- read.table(paste(file_location,"/UCI HAR Dataset/train/X_train.txt",sep=''))[,mean_std]
  print(paste(file_location,"/UCI HAR Dataset/train/X_train.txt done",sep=''))
  X_tst <- read.table(paste(file_location,"/UCI HAR Dataset/test/X_test.txt",sep=''))[,mean_std]
  print(paste(file_location,"/UCI HAR Dataset/test/X_test.txt done",sep=''))
  X <- rbind(X_trn,X_tst)
  rm(X_trn,X_tst)
  colnames(X) <- gsub('BodyBody','Body',col_names)
  
  Direction <- c('X','Y','Z')
  Direction_filter <- rbind(grepl('X',colnames(X),fixed = TRUE),
                            grepl('Y',colnames(X),fixed = TRUE),
                            grepl('Z',colnames(X),fixed = TRUE))
  
  Domain <- c('time','frequency')
  Domain_filter <- rbind(grepl('^t',colnames(X)),
                         grepl('^f',colnames(X)))
  
  MeasType <- c('Mean','stDev')
  MeasType_filter <- rbind(grepl('mean()',colnames(X),fixed = TRUE),
                           grepl('std()',colnames(X),fixed = TRUE))
  
  MeasSubject <- c('Body','Gravity')
  MeasSubject_filter <- rbind(grepl('Body',colnames(X),fixed = TRUE),
                              grepl('Gravity',colnames(X),fixed = TRUE))
  
  
  Meas <- strsplit(substr(colnames(X),2,max(nchar(colnames(X)))),'-')
  Meas <- sapply(Meas,"[",1)
  Meas <- gsub('Body|Gravity','',Meas)
  
  uniMeas <- unique(Meas)
  mes <- vector('numeric')
  
  for(j in seq(length(uniMeas))){
    mes[which(Meas == uniMeas[j])] <- j
  }
  
  Meas_filter <- cbind(grepl('mean()',colnames(X),fixed = TRUE),
                       grepl('std()',colnames(X),fixed = TRUE))
  
  size = ncol(X)*nrow(X)
  m = matrix(nrow = size,ncol = 8)
  colnames(m)<- c('Subject','Activity','Domain','Direction','Meas_Object','Meas','Analysis_type','Meas_value')
  
  print('tidying: % complete...')
  for (ro in seq(nrow(X))){
    if (ro%%1000 == 0){print(mrow/size*100)}
    for(co in seq(ncol(X))){
      mrow <- co+ncol(X)*(ro-1)

      m[mrow,1] <- subj[ro,1]
      m[mrow,2] <- act[ro,1]
      m[mrow,6] <- uniMeas[mes[co]]
      m[mrow,8] <- X[ro,co]
   
      if(Domain_filter[1,co]){
        m[mrow,3] = Domain[1]
      } else m[mrow,3] = Domain[2]
      
      if(Direction_filter[1,co]){
        m[mrow,4] = 'X' 
        } else if (Direction_filter[2,co]){
        m[mrow,4] = 'Y'
        } else if (Direction_filter[3,co]){
        m[mrow,4] = 'Z'
        }else m[mrow,4] = NA
    
      if(MeasSubject_filter[1,co]){
        m[mrow,5] = 'Body'} else m[mrow,5] = 'Gravity'

      if(MeasType_filter[1,co]){
        m[mrow,7] = 'Mean'
      } else m[mrow,7] = 'Std Dev'
      
    }
  }
  print('calculting means: % complete...')
  rm(X)
  s = sort(unique(subj)[,1])
  a = sort(unique(act)[,1])
  mmean <- matrix(nrow = length(a)*length(s),ncol = 4)
  colnames(mmean)<-c('Activity','Subject','Mean_mean','Mean_stdev')
  mmean[,2] <- rep(sort(s),length(a))
  mmean[,1] <- rep(a,rep(length(s),length(a)))
  for(i in seq(length(s))){
    for(j in seq(length(a))){
      meanrow <- which(mmean[,'Subject']==s[i]&mmean[,'Activity']==a[j])
      indexm <- (m[,'Subject'] == s[i])&(m[,'Activity']==a[j])&(m[,'Analysis_type']=='Mean')
      indexs <- (m[,'Subject'] == s[i])&(m[,'Activity']==a[j])&(m[,'Analysis_type']=='Std Dev')
      mmean[meanrow,3] <- mean(as.numeric(m[indexm,'Meas_value']))
      mmean[meanrow,4] <- mean(as.numeric(m[indexs,'Meas_value']))
      m[indexm,'Subject'] <- sprintf('%02s',s[i])
      m[indexs,'Subject'] <- sprintf('%02s',s[i])
      mmean[meanrow,'Subject'] <- sprintf('%02s',s[i])
    }
    if (i%%2 == 0) print((length(a)*i)/1.8)
  }
  
  #for(i in seq(length(subj[,1]))){
  #  mmean[,Subject[i]]<-sprintf("%02s",mmean[,'Subject'[i]])
  #  m[,Subject[i]]<-sprintf("%02s",m[,'Subject'[i]])
  #}
  
  M <- data.table(m)
  #Mmean <- data.table(Mmean)
  M<-M[order(Activity,Subject)]
  #Mmean<-Mmean[order(Activity,Subject)]
  
  rm(subj)
  rm(act)
  write.table(M,"tidy_data.txt",row.name = FALSE)
  write.table(mmean,'tidy_means.txt',row.name=FALSE)
  print('Done!')
  Mmean
}