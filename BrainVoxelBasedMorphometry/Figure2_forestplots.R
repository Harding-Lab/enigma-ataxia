#Figure2_forestplots

#Make figure 1 forest plots

packages <- c("ggplot2", "metafor", "forestplot", "cowplot", "magick", "compute.es", "dplyr", "Gmisc", "MBESS")
lapply(packages, require, character.only = TRUE)

#####forest plots
source("~/Dropbox/Sid/R_files/enigma_figures/functions/make_enigma_forestplots_figure2.R")

wm_group_diff <- data.frame(
  site=c("Aachen", "Bologna", "Campinas", "Conegliano", "Florence", "Innsbruck", "Essen", "Melbourne","Minnesota","Naples", "Total"), 
  mean_d = c(0.729458, 1.055219, 1.314940, 1.234168, 0.897347, 0.620555, 0.918365, 1.097183, 0.492918, 1.247450, 0.831654), 
  n1 = c(26, 17,52, 39, 17, 13, 15, 31, 19, 19, 248), 
  n2 = c(35, 15, 61, 23, 21, 18, 14, 37, 18, 20, 262), 
  boxsize=c(.36, .27, .62, .49, .27, .23, .25, .41, .29, .29, .9))


gm_group_diff <- data.frame(
  site=c("Aachen", "Bologna", "Campinas", "Conegliano", "Florence", "Innsbruck", "Essen", "Melbourne","Minnesota","Naples", "Total"), 
  mean_d = c(0.433963, 0.703678, 0.563961, 0.594334, 0.191700, 0.830439, 0.410131, 0.350056, 0.599858, 0.392903, 0.478897),
  n1 = c(26, 17,52, 39, 17, 13, 15, 31, 19, 19, 248), 
  n2 = c(35, 15, 61, 23, 21, 18, 14, 37, 18, 20, 262), 
  boxsize=c(.36, .27, .62, .49, .27, .23, .25, .41, .29, .29, .9))



gms_group_diff <- data.frame(
  site=c("Aachen", "Bologna", "Campinas", "Conegliano", "Florence", "Innsbruck", "Essen", "Melbourne","Minnesota","Naples", "Total"), 
  mean_d = c(0.489883, -0.253895, 0.805782, 1.461033, 0.526333, -0.022765, 0.998519, 0.766437, -0.167624, 1.04740, 0.498848
  ),
  n1 = c(26, 17,52, 39, 17, 13, 15, 31, 19, 19, 248), 
  n2 = c(35, 15, 61, 23, 21, 18, 14, 37, 18, 20, 262), 
  boxsize=c(.36, .27, .62, .49, .27, .23, .25, .41, .29, .29, .9))


make_enigma_forestplots_figure(data = gms_group_diff)