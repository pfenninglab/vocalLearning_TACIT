#Used to add a column 'qvalue' to adjust p value with qvalue
#Requires hal.yml 
# Usage1:
# Rscript qValue.R input.csv output.csv
# Usage2:
# Rscript qValue.R input.csv output.csv Pvalue

library(qvalue)
args <- commandArgs(trailingOnly = TRUE)
input <- args[1]
output <- args[2]
# optional adjust column name
if (length(args) >= 3) {
  pName <- args[3]
} else {
  pName <- "Exp_Pvalue"
}
data <- read.csv(input)
pval <- data[[pName]]
qval <- qvalue(pval)
data$qvalue=qval$qvalues
# sort table
sorted <- data[order(data$qvalue),]
write.table(sorted,output,sep=",",row.names = FALSE,quote = FALSE)