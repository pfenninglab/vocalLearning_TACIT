# tianyul3@andrew.cmu.edu
# Usage: 
# Rscript plotPDist.R csv_file output_file (optional)p_value_column_name

library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
input <- args[1]
output <- args[2]

# optional p-column name
if (length(args) >= 3) {
  pName <- args[3]
} else {
  pName <- "Pvalue"
}

data <- read.csv(input)
pVal <- data[[pName]]

plot <- ggplot(data, aes(x = pVal)) +
  geom_histogram(binwidth = 0.01, fill = "lightblue", color = "black") +
  labs(x = "P-values", y = "Count", title = "Distribution of P-values")

ggsave(output, plot, width = 6, height = 4)