install.packages("tm") #if not already installed
library("tm")
setwd("C:\\work\\NetbeansProjects\\BeckLyrics\\lib\\songs")
a<-Corpus(DirSource())
warnings()
a <- tm_map(a, removeNumbers)
a <- tm_map(a, removePunctuation)
a <- tm_map(a , stripWhitespace)
tdm <- TermDocumentMatrix(a)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d,100)

