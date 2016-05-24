## load packages 
## xlsx
if("xlsx" %in% rownames(installed.packages()) == FALSE) {install.packages("xlsx")}
##install.packages("RSQLite")
if("RSQLite" %in% rownames(installed.packages()) == FALSE) {install.packages("RSQLite")}
## sqldf
if("sqldf" %in% rownames(installed.packages()) == FALSE) {install.packages("sqldf")}
## data.table
if("data.table" %in% rownames(installed.packages()) == FALSE) {install.packages("data.table")}
library(xlsx)
library(RSQLite)
library(sqldf)
library(data.table)

options( stringsAsFactors=F ) 

# Check your locale and set shapefile encoding to UTF-8
#Sys.getlocale("LC_CTYPE")
#Sys.setlocale("LC_TIME", "en_CA.UTF-8")  # ditto
# getCPLConfigOption("SHAPE_ENCODING")
# setCPLConfigOption("SHAPE_ENCODING", "UTF-8")


# input file names 
# file1 <- readline("P & S file ? ")  
# file2  <- readline("TOYOTA Dealers file ? ")
# file3 <- readline("LEXUS Dealers file ? ")



## STAFF INFO
## 10 columns
file1<-"Copy of P & S Feb 2016.xlsx"
rowIndex1 <- 1:1000
colIndex1 <- 1:10

## DEALERS INFO
## 37 columns
file2<-"Lexus Dealer List as of April 18, 2016.xlsx"
file3<-"Toyota Dealer List as of April 15, 2016.xlsx"

rowIndex2 <- 1:1000
colIndex2 <- 1:37


# Read CSV into R
# MyData <- read.csv(file="c:/TheDataIWantToReadIn.csv", header=TRUE, sep=",")
## read Excel into data frame
df1 <- read.xlsx(file=file1, sheetIndex=1, colIndex=colIndex1, rowIndex=rowIndex1, header=TRUE,fileEncoding="utf8", stringsAsFactors=F,encoding="UTF-8")
##df1[,"Dealer"]<-suppressWarnings(as.numeric(df1[,"Dealer"]))

##head(PS.df1)
df2 <- read.xlsx(file=file2, sheetIndex=1, colIndex=colIndex2, rowIndex=rowIndex2, header=TRUE,fileEncoding="utf8", stringsAsFactors=F,encoding="UTF-8")
colnames(df2)[7] <- "Dealer"
##df2[,7]<-suppressWarnings(as.numeric(df2[,7]))

##head(PS.df2)
df3 <- read.xlsx(file=file3, sheetIndex=1, colIndex=colIndex2, rowIndex=rowIndex2, header=TRUE,fileEncoding="utf8", stringsAsFactors=F,encoding="UTF-8")
                 ##stringsAsFactors=FALSE,encoding="UTF-8")

##head(PS.df3)

mydata2 <- merge(df2[,c("Dealer","Parts_City","Parts_Province","Parts_City_and_Province","Parts_Postal_Code","Parts_Phone_Num","Parts_Fax_Num")], df1, by="Dealer") 
mydata3 <- merge(df3[,c("Dealer","Parts_City","Parts_Province","Parts_City_and_Province","Parts_Postal_Code","Parts_Phone_Num","Parts_Fax_Num")], df1, by="Dealer") 

### check French name 
##  mydata3[mydata3$Dealer=="53152",] :  Boucher, Stéphane
##  write(mydata3[mydata3$Dealer=="53152","Student"], file = "stef.txt")

# ## join df1 & df2
# 
#       join_string2 <- "select  'L' as Division, df2.`Parts_City`, df2.`Parts_Province`, df2.`Parts_City_and_Province`, 
#       df2.`Parts_Postal_Code`, df2.`Parts_Phone_Num`, df2.`Parts_Fax_Num`,df1.Dealer, df1.Lang,  df1.Student  
#       from df1 join df2 on df1.Dealer = df2.Dealer"
#       ## join df1 & df3
#       join_string3 <-  "select  'T' as Division, df2.`Parts_City`, df2.`Parts_Province`, df2.`Parts_City_and_Province`, 
#       df2.`Parts_Postal_Code`, df2.`Parts_Phone_Num`, df2.`Parts_Fax_Num`,df1.Dealer, df1.Lang,  df1.Student  
#       from df1 join df3 as df2 on df1.Dealer = df2.Dealer"
#       
#       test_df2 <- sqldf(join_string2,stringsAsFactors = FALSE)
#       test_df3 <- sqldf(join_string3,stringsAsFactors = FALSE)

main_df <- rbind(mydata2, mydata3) 
## check "Boucher, Stéphane" main_df[paste0(main_df$F,main_df$Dealer)=="T53152","Student"]

## subset columns &  dedup
df_out<-unique(main_df[,1:8])##,with=FALSE]

## max number of students
# as.data.table(main_df)[, count := uniqueN(Student), by = "Dealer"]
# max(main_df[,count])

## add new columns  with Student names to output frame

for ( i in paste0(df_out$Division,df_out$Dealer))
{
      ##print(i)
      cnt<-1
      for ( Student in main_df[paste0(main_df$Division,main_df$Dealer)==i,"Student"])
      {
           ## print(paste0(i,":",Student));
            
            ## store student Fname & Lname in output table
            setDT(df_out)[paste0(df_out$Division,df_out$Dealer)==i,c(paste0("LastName",cnt),paste0("FistName",cnt)) := tstrsplit(Student, ",")]
            cnt<-cnt+1
      }
}

con<-file('df_out_T_E.csv',encoding="UTF-8")
write.csv(df_out[df_out$Division=="T"&df_out$Lang=="E"], file = con)
con<-file('df_out_T_F.csv',encoding="UTF-8")
write.csv(df_out[df_out$Division=="T"&df_out$Lang=="F"], file = con)
con<-file('df_out_L_E.csv',encoding="UTF-8")
write.csv(df_out[df_out$Division=="L"&df_out$Lang=="E"], file = con)
con<-file('df_out_L_F.csv',encoding="UTF-8")
write.csv(df_out[df_out$Division=="L"&df_out$Lang=="F"], file = con)