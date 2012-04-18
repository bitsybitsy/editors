###
### Messing about with Brett Terpstra's iOS text/code editors comparison
### Data from http://brettterpstra.com/ios-text-editors/

data <- read.csv("data/editors-data.csv", header=TRUE)

### Drop price for now
data <- data[,-1]

library(cluster)
library(ggplot2)
library(scales)
library(reshape)

d <- daisy(data)
d1 <- daisy(as.data.frame(t(data)))
out.by.name <- agnes(d, method="ward")
out.by.name <- hclust(d, method="ward")
out.by.feature <- agnes(d1, method="ward")
out.by.feature <- hclust(d1, method="ward")

## out.by.name <- diana(data, metric="manhattan")
## out.by.feature <- diana(as.data.frame(t(data)), metric="manhattan")
## plot(h)


##plot(out.by.name)
##plot(out.by.feature)

o.row <- out.by.name$order
o.col <- out.by.feature$order

## data.o <- data[o.row,(ncol(data):1)] ## cluster on Editors only, features in BT's original order
data.o <- data[o.row, o.col] ## sort based on clustering of Editors and Features

## Clean the labels for use below
feature.labels <- gsub("\\."," ", colnames(data.o))
feature.labels <- gsub("preview export", "preview/export", feature.labels)
feature.labels <- gsub("Open in ", "Open in…", feature.labels)
feature.labels <- gsub("Full text", "Full-text", feature.labels)
feature.labels <- gsub("handlers", "handler(s)", feature.labels)


r.names <- factor(rownames(data.o), levels=rownames(data)[o.row], ordered=TRUE)
c.names <- factor(colnames(data.o), levels=colnames(data)[o.col], ordered=TRUE)

data.m <- data.frame(r.names, data.o)
colnames(data.m)[1] <- "Name"

data.melt <- melt(data.m, id.vars="Name")
colnames(data.melt) <- c("Editor", "Feature", "Present")

library(gdata)
data.melt$Present <- reorder.factor(data.melt$Present,
                                     new.order=c("Yes", "No", "$$", "?"))

## No need for this if not clustering on features
data.melt$Feature <- reorder.factor(data.melt$Feature, new.order=c.names)
detach(package:gdata)

my.cols <- brewer.pal(9, "Pastel1")
my.cols <- my.cols[c(3,1,5,9)]

pdf(file="figures/spec-cluster.pdf",height=9,width=16,pointsize=11)
p <- ggplot(data.melt, aes(x=Feature, y=Editor, fill=Present))
p + geom_tile() + scale_fill_manual(values=my.cols) +
  scale_x_discrete(labels=feature.labels) +
  opts(axis.text.x=theme_text(hjust=1, angle=90),
       axis.text.y=theme_text(hjust=1)) + coord_flip()
dev.off()
