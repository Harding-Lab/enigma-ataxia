#make_enigma_forestplots

make_enigma_forestplots_figure2 <- function(data) {
  data["t"] <- NaN 
  data["ci.l"] <- NaN 
  data["ci.u"] <- NaN
  for (i in 1:dim(data)[1]) {
    
    data$t[i] <- data$mean_d[i]*sqrt((data$n1[i]*data$n2[i])/(data$n1[i]+data$n2[i]))
    temp <- tes(data$t[i], data$n1[i],  data$n2[i])
    data$ci.l[i]<- temp$l.d 
    data$ci.u[i]<- temp$u.d 
  }
  
  data[-11,] <- arrange(data[-11,], mean_d) #reorderd by mean d 
  
  data <- add_row(data, .before = TRUE)
  data <- add_row(data, .before = 12)
  
  
  wm_table_text <- cbind(as.character(data$site), data$mean_d, paste("[", data$ci.l ,",",data$ci.u, "]", sep = " "))
  wm_table_text[12,3] <- NA
  wm_table_text[1,] <- c("Site", "Cohens D", "95%CI")
  
  
  #tiff("wm_gd.tiff", height = 650, width = 900)
  
  forestplot(as.matrix(data$site), data$mean_d, data$ci.l,  data$ci.u,
             align = "r",  boxsize = data$boxsize,
             xlab = "Cohens d", zero=0, xticks=c(-1, -0.5, 0, 0.5, 1, 1.5, 2), txt_gp = fpTxtGp(label = gpar(fontfamily = "sans", cex=2), 
                                                                                                xlab = gpar(fontfamily = "sans", cex=2.5),
                                                                                                ticks = gpar(fontfamily = "", cex = 1.8)), 
             fn.ci_norm=matrix(c("fpDrawCircleCI", "fpDrawCircleCI", "fpDrawCircleCI", 
                                 "fpDrawCircleCI", "fpDrawCircleCI", "fpDrawCircleCI",
                                 "fpDrawCircleCI", "fpDrawCircleCI", "fpDrawCircleCI",
                                 "fpDrawCircleCI", "fpDrawCircleCI", "fpDrawCircleCI","fpDrawDiamondCI"), 
                               nrow = 13, ncol=1, byrow=F))
  
  #dev.off()
}
