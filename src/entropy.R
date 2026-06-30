install.packages("infotheo")
library(infotheo)

dataset <- read.csv('C:/Users/fpisc/Downloads/VerbiSupporto/VSupp frequencies/analisi_dati/predicati_denominali_confreq.csv', sep = ";", fileEncoding = "Windows-1252")
View(dataset)

dataset$vsin_num <- discretize(dataset$vsin_num)
dataset$vsupp_num <- discretize(dataset$vsupp_num)

condentropy(dataset$vsupp_num,dataset$vsin_num)
entropy(dataset$vsupp_num)

### condentropy(dataset$vsupp_num,dataset$vsin_num)
##[1] 1.363791
### entropy(dataset$vsupp_num)
##[1] 1.384811

dataset$vsin_bin_num <- as.numeric(factor(dataset$vsin_bin, levels = c("no", "yes")))
dataset$vsupp_bin_num <- as.numeric(factor(dataset$vsupp_bin, levels = c("no", "yes")))
## entropy(dataset$vsupp_bin_num)
## [1] 0.6913886
## entropy(dataset$vsin_bin_num)
## [1] 0.670193
##  condentropy(dataset$vsupp_bin_num, dataset$vsin_bin_num)
## [1] 0.6817201
## condentropy(dataset$vsin_bin_num, dataset$vsupp_bin_num)
## [1] 0.6605245

