#figure 1
packages <- c("readxl", "emmeans", "psych", "car", "lazyWeave")
lapply(packages, require, character.only = TRUE)


###Change to sheet 2 for wm, 4 for gm and 5 for crblm gm
data <- read_excel("~/Dropbox/Sid/ENIGMA_ataxia/roi_volumes/all_vol.xlsx", sheet = 4)   
make_enigma_forestplots_figure1(data, bonferoni = F, number.of.comparisions = 156)






