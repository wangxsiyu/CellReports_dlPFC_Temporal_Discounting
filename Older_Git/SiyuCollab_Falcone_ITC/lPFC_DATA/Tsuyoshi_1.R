## function(init=c(1,1,1),method=1)
## {
  ##method=1:exp 2:hyp

init=c(1,1,1)
method=1
  
## res.mat <- as.matrix(read.csv("C:/Users/Master/Desktop/TSUYOSHI/TOBIAS_for_Setogawa.csv",header=F))

data_files <- list.files("F:/NIH/FILES_CHE_CAMBIANO/ROSSELLA_FALCONE_EXPERIMENTS/SAPORIN_shRNA_EXPERIMENT/ANALISI/shRNA_EXPERIMENT/TERENCE/ACC_SKIP_TASK/RESULTS/FORGLM_eachEXPCOND/") 
data_files  


for(i in 1:1) { ##length(data_files)) {                              
  res.mat = assign(paste0("data", i), as.matrix(read.csv(paste0("F:/NIH/FILES_CHE_CAMBIANO/ROSSELLA_FALCONE_EXPERIMENTS/SAPORIN_shRNA_EXPERIMENT/ANALISI/shRNA_EXPERIMENT/TERENCE/ACC_SKIP_TASK/RESULTS/FORGLM_eachEXPCOND/",data_files[i]),header=T)))
  data_names = sub('\\.csv$', '', data_files[i])

 vedi = unique(res.mat[,1])
 
 for (y in 1:length(vedi)) {
   
   
   
  
   fit <- matrix(nr=9,nc=3)
   rate <- matrix(nr=9,nc=3)
   rew <- c(2,4,6,2,4,6,2,4,6)
  
   time <- c(1,1,1,5,5,5,10,10,10)
 
   c.list <- rep(list(numeric(0)),9)

  for(trial in 1:nrow(res.mat)) {

      if(res.mat[trial,4]==1&&res.mat[trial,3]==2)c.list[[1]] <- c(c.list[[1]],res.mat[trial,5])
      if(res.mat[trial,4]==1&&res.mat[trial,3]==4)c.list[[2]] <- c(c.list[[2]],res.mat[trial,5])
      if(res.mat[trial,4]==1&&res.mat[trial,3]==6)c.list[[3]] <- c(c.list[[3]],res.mat[trial,5])
      if(res.mat[trial,4]==5&&res.mat[trial,3]==2)c.list[[4]] <- c(c.list[[4]],res.mat[trial,5])
      if(res.mat[trial,4]==5&&res.mat[trial,3]==4)c.list[[5]] <- c(c.list[[5]],res.mat[trial,5])
      if(res.mat[trial,4]==5&&res.mat[trial,3]==6)c.list[[6]] <- c(c.list[[6]],res.mat[trial,5])
      if(res.mat[trial,4]==10&&res.mat[trial,3]==2)c.list[[7]] <- c(c.list[[7]],res.mat[trial,5])
      if(res.mat[trial,4]==10&&res.mat[trial,3]==4)c.list[[8]] <- c(c.list[[8]],res.mat[trial,5])
      if(res.mat[trial,4]==10&&res.mat[trial,3]==6)c.list[[9]] <- c(c.list[[9]],res.mat[trial,5])
  }
      
 for(i in 1:9){
   a <-sum(c.list[[i]]==0)
   b <-sum(c.list[[i]]==1)
   rate[i,1] <- time[i]
   rate[i,2] <- rew[i]
   rate[i,3] <- b/(a+b)
  }
   
   fn.exponent<-function(x){
     k<-x[1]
     a<-x[2]
     b<-x[3]
     
     if(method==1)yy<-1/(1+exp(-a*drop/exp(k*delay)-b))
     if(method==2)yy<-1/(1+exp(-a*drop/(1+k*delay)-b))
     se<-sum((choice-yy)^2)
     n<-length(se)
     loglik<--0.5*n*(log(2*pi)+1-log(n)+log(se))
   }
   
  delay <- rate[,1]
  drop <- rate[,2]
  choice <- rate[,3]  
  
  ft<-optim(par=init, fn = fn.exponent, control=list(fnscale=-1))
  
  k.fit<-ft[[1]][1]
  a.fit<-ft[[1]][2]
  b.fit<-ft[[1]][3]
  
  if(method==1)fit[,1] <- drop/exp(k.fit*delay)
  if(method==2)fit[,1] <- drop/(1+k.fit*delay)
  fit[,2] <- 1/(1+exp(-a.fit*fit[,1]-b.fit))
  fit[,3] <- choice
  fit <- data.frame(fit)
  fit <- fit[order(fit$X1),]
  x.max <- max(fit[,1])
  n <- length(fit[,2])
  Se <- var(fit[,2]-fit[,3])*(n-1)
  loglik <- -0.5*n*(log(2*pi)+1-log(n)+log(Se))
  AIC <- 2*2+2-2*loglik
  
 plot(x=fit[,1], y=fit[,2], type="l", xlab="Subjective value", ylab="choice probability", ylim=c(0,1), xlim=c(0,round(x.max,1)))
 par(new=T)
 plot(x=fit[,1], y=fit[,3], xlab="Subjective value", ylab="choice probability", ylim=c(0,1), xlim=c(0,round(x.max,1)),col="red")
 if(method==1)text(x=4/5*x.max, y=0.25, paste("Exponent"))
 if(method==2)text(x=4/5*x.max, y=0.25, paste("Hyperbola"))
 text(x=4/5*x.max, y=0.2, paste("k=",round(k.fit,3)))
 text(x=4/5*x.max, y=0.15, paste("a=",round(a.fit,3)))
 text(x=4/5*x.max, y=0.10, paste("b=",round(b.fit,3)))
 text(x=4/5*x.max, y=0.05, paste("AIC=",round(AIC,3)))
 
 
 tab <- matrix(c(method,a.fit,b.fit,k.fit,AIC), ncol=5, byrow=TRUE)
 colnames(tab) <- c('Method','alpha','Beta','Konstant','AIC')
 rownames(tab) <- c('parameters')
 
 write.xlsx(tab,paste0("F:/NIH/FILES_CHE_CAMBIANO/ROSSELLA_FALCONE_EXPERIMENTS/SAPORIN_shRNA_EXPERIMENT/ANALISI/shRNA_EXPERIMENT/MODELS/TSUYOSHI/PARAMETERS/", data_names,".xlsx"))

 }
}

  ## return(ft)
  
  ##	fm <- nls(choice~a.v*drop/exp(k.v*delay),start=list(a.v=0.1,k.v=0.1))
  ##	fm <- nls(choice~a/(1+b*exp(-c*(drop/exp(k*delay)))),start=list(a=1,b=1,c=1,k=0))
  ##	return(summary(fm))

## }



