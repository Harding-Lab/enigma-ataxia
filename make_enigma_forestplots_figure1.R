make_enigma_forestplots_figure1 <- function(data, 
                                            bonferoni=TRUE,
                                            number.of.comparisions = 160, 
                                            ylab=F,
                                            xlab=F) {
  
  
  data$Site <- as.factor(data$Site)
  data$Group <- as.factor(data$Group)
  data$sex <- as.factor(data$sex)
  f.vect <- data.frame()
  options(scipen = 999)
  
  i<-1
  for (ii in 11:dim(data)[2]) {
    f.vect[i,1] <- colnames(dataset)[ii]
    tmpvar <- as.vector(unlist(dataset[ii]))
    temp <- Anova(lm(tmpvar ~ dataset$Site + dataset$Group + dataset$ICV.c + dataset$sex  + dataset$onset.c + dataset$duration.c + dataset$age.c), type=3)
    
    #new method 29/02/2021
    p <- temp$`Pr(>F)`[3]
    f <- temp$`F value`[3]
    t <- sqrt(f)
    d <- (2*t)/sqrt(494)
    f.vect[i,2] <- d
    temp <- psych::cohen.d.ci(d = f.vect[i,2], n1 = 248, n2 = 262, alpha=.05)
    f.vect[i,3] <- temp[1,1]
    f.vect[i,4] <- temp[1,3]
    f.vect[i,5] <- p
  
    i<-i+1
  }
  
  colnames(f.vect) <- c("roi", "f", "p", "cohens.d", "t" ,"ci.l", "ci.u")
  
  #reorder
  f.vect.ordered <- arrange(f.vect, cohens.d)
  f.vect.ordered$roi <- factor(f.vect.ordered$roi, levels = f.vect.ordered$roi)
  
  
  #Only use this for priting sup table
  #changeSciNot <- function(n) {
  #  output <- format(n, scientific = TRUE) #Transforms the number into scientific notation even if small
  #  output <- sub("e", "*10^", output) #Replace e with 10^
  #  output <- sub("\\+0?", "", output) #Remove + symbol and leading zeros on expoent, if > 1
  #  output <- sub("-0?", "-", output) #Leaves - symbol but removes leading zeros on expoent, if < 1
  #  output
  #}
  ##for table
  #temp <- pvalString(f.vect.ordered$p, format ="scientific", digits=3)
  
  
  if(bonferoni==TRUE) {
    temp <-p.adjust(f.vect.ordered$p, method = "bonferroni") 
    
    f.vect$roi <- factor(f.vect$roi, levels = f.vect$roi)
    
    #Only display ROIs > 0.05 Bonferoni corrected p (160 comparisions)
    bf_p = 0.05/number.of.comparisions
    f.vect.ordered.bf <- f.vect.ordered[which(f.vect.ordered$p < bf_p),]
    
    
    plot <- ggplot(data=f.vect.ordered.bf, aes(x=roi, y=cohens.d, ymin=ci.l, ymax=ci.u)) +
      geom_pointrange() + 
      geom_hline(yintercept=0, lty=2) +  # add a dotted line at x=1 after flip
      coord_flip() +   ylab("Cohens D (95% CI)") + # flip coordinates (puts labels on y axis)
      xlab("ROI") + theme_bw() + scale_y_continuous(limits = c(-0.1,3)) + theme(text = element_text(size=15))
    
    if (xlab == F){plot = plot +  theme(text = element_text(size=15), 
                                        axis.title.x=element_blank())} 
    
    
    if (ylab == F){plot = plot +  theme(text = element_text(size=15), 
                                        axis.title.y=element_blank())} 
    
  } else {
    
    ggplot(data=f.vect.ordered, aes(x=roi, y=cohens.d, ymin=ci.l, ymax=ci.u)) +
      geom_pointrange() + 
      geom_hline(yintercept=0, lty=2) +  # add a dotted line at x=1 after flip
      coord_flip() +  # flip coordinates (puts labels on y axis)
      xlab("ROI") +     ylab("Cohens D (95% CI)") + #
      theme_bw()  + scale_y_continuous(limits = c(-0.1,3)) + theme(text = element_text(size=15))
    
    
    if (xlab == F){plot = plot +  theme(text = element_text(size=15), 
                                        axis.title.x=element_blank())} 
    
    if (ylab == F){plot = plot +  theme(text = element_text(size=15), 
                                        axis.title.y=element_blank())} 
    
  }
  
  return(plot)
  
}
