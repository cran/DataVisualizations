checkCls=function(Cls,AnzData=NULL,Normalize=TRUE){
  if(is.null(AnzData)){
    warning('No number of data to compare. Something went wrong in the function calling checkCLS. Thus, checkCls is skipped!')
    return(Cls)
  }
  if(!is.numeric(AnzData)){
    warning('No number of data to compare. Something went wrong in the function calling checkCLS. Thus, checkCls is skipped!')
    return(Cls)
  }
  if(AnzData<=0){
    warning('Amount of data is zero! Something went wrong in the function calling checkCLS. Thus, checkCls is skipped!')
    return(Cls)
  }
  if(!is.vector(Cls)){
    warning('Cls is not a vector, calling as.vector')
    Cls=as.vector(Cls)
  }
  if(mode(Cls)!='numeric'){
    warning('Cls is not numeric, calling as.numeric')
    Cls=as.numeric(Cls)
  }
  if (length(Cls) < AnzData) {
    warning(paste("Too few Classes of length", length(Cls),
                 "Dmmy added of length", AnzData))
    NewCls = rep(1,AnzData) * max(Cls) + 1
    NewCls[1:length(Cls)] = Cls
    
    Cls = NewCls
  }
  if (length(Cls) > AnzData) {
    warning("Cls too long, shortened")
    Cls = Cls[1:AnzData]
  }
  if(isTRUE(Normalize)){
    uniqueClasses <- sort(na.last = T, unique(Cls))
    numberOfClasses <- length(uniqueClasses)
    unique2Cls <- NULL
    for (i in 1:length(Cls)) {
      unique2Cls <- c(unique2Cls, which(uniqueClasses == Cls[i]))
    }
    if (numberOfClasses > 0) {
      normalizedClasses <- c(1:numberOfClasses)
      normalizedCls <- normalizedClasses[unique2Cls]
    }
    else {
      normalizedClasses <- Cls
    }
  }else{
      normalizedCls=Cls
  }
  return(normalizedCls)
}