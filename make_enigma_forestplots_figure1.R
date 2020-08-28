make_enigma_forestplots_figure1 <- function(data, 
                                            bonferoni=TRUE,
                                            number.of.comparisions = 156) {
  
  
  data$Site <- as.factor(data$Site)
  data$Group <- as.factor(data$Group)
  data$sex <- as.factor(data$sex)
  f.vect <- data.frame()
  options(scipen = 999)
  
  i<-1
  for (ii in 11:dim(data)[2]) {
    f.vect[i,1] <- colnames(data)[ii]
    tmpvar <- as.vector(unlist(data[ii]))
    temp <- Anova(lm(tmpvar ~ data$Site + data$Group + data$ICV.c + data$sex  + data$onset.c + data$duration.c + data$age.c), type=3)
    f.vect[i,2] <- temp[[3]][[3]][[1]]
    f.vect[i,3] <- temp[[4]][[3]][[1]]
    fit <- lm(tmpvar ~ data$Site + data$Group + data$ICV.c + data$sex  + data$onset.c + data$duration.c + data$age.c)
    em <- as.data.frame(emmeans(fit, ~ Group))
    meandiff <- em[2,2] - em[1,2]
    SE <- summary(fit)$coef[11,2]
    f.vect[i,4] <- meandiff/(sqrt(510)*SE) #d
    f.vect[i,5] <- meandiff/((sqrt(510)*SE)/sqrt(510)) #t
    temp <- psych::cohen.d.ci(d = f.vect[i,4], n1 = 248, n2 = 262, alpha=.05)
    f.vect[i,6] <- temp[1,1]
    f.vect[i,7] <- temp[1,3]
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
    
    #Only display ROIs > 0.05 Bonferoni corrected p (156 comparisions)
    bf_p = 0.05/number.of.comparisions
    f.vect.ordered.bf <- f.vect.ordered[which(f.vect.ordered$p < bf_p),]
    
    
    ggplot(data=f.vect.ordered.bf, aes(x=roi, y=cohens.d, ymin=ci.l, ymax=ci.u)) +
      geom_pointrange() + 
      geom_hline(yintercept=0, lty=2) +  # add a dotted line at x=1 after flip
      coord_flip() +  # flip coordinates (puts labels on y axis)
      xlab("ROI") + ylab("Cohens D (95% CI)") +
      theme_bw()
  } else {
    
    ggplot(data=f.vect.ordered, aes(x=roi, y=cohens.d, ymin=ci.l, ymax=ci.u)) +
      geom_pointrange() + 
      geom_hline(yintercept=0, lty=2) +  # add a dotted line at x=1 after flip
      coord_flip() +  # flip coordinates (puts labels on y axis)
      xlab("ROI") + ylab("Cohens D (95% CI)") +
      theme_bw()
  }
  
  
}
