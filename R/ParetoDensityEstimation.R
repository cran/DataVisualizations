ParetoDensityEstimation = function(Data,paretoRadius,kernels=NULL,MinAnzKernels=100,PlotIt=FALSE){
#  V = ParetoDensityEstimation(Data,ParetoRadius,Kernels)
#  V = ParetoDensityEstimation(Data)
#  ParetoDensity=V$paretoDensity
#  Kernels=V$kernels
#  Estimates the Pareto Density for a one dimensional distibution
#  this is the best density estimation to judge Gaussian Mixtures  of the Data see [Ultsch 2003]
# 
#  INPUT
#  Data                    die eindimensional verteilten Daten
#
#  OPTIONAL
#  paretoRadius            der Pareto Radius, wenn nicht angegeben, wird er berechnet
#  kernels                 Data values at which ParetoDensity is measured , use plot(Kernels,ParetoDensity) for display
#                          wird bestimmt, wenn nicht angegeben oder Kernels ==0
#  MinAnzKernels           Minimale Anzahl Kernls, wenn nicht angegeben oder MinAnzKernelss ==0 =>  MinAnzKernels==100	
# 
#  OUTPUT
#  List with
#  kernels                 Data values at which ParetoDensity is measured , use plot(Kernels,ParetoDensity) for display
#  paretoDensity           die mit dem ParatoRadius ermittelte Dichte
#  paretoRadius            der Pareto Radius
# 
#  Author: MT 2019

###############################################
###############################################
 
  if (!is.vector(Data)) {
    Data = as.vector(Data)
    warning('Beware: ParetoDensityEstimation: Data set not univariate !')
  }
  if (!is.numeric(Data)) {
    Data = as.numeric(Data)
    warning('Beware: ParetoDensityEstimation: Data set not numeric !')
  }
  
  if (length(Data) != sum(is.finite(Data))) {
    message('Not all values are finite. Please check of infinite or missing values.')
  }
  Data = Data[is.finite(Data)]
  values = unique(Data)
  
  if (length(values) > 2 & length(values) < 5) {
    warning('Less than 5 unqiue values for density estimation. Function may not work')
  }
  
  if (length(values) < 3) {
    warning(
      '1 or 2 unique values for density estimation. Dirac Delta distribution(s) is(are) assumed. Input of "kernels", "paretoRadius" and "MinAnzKernels" or ignored!'
    )
    
    if (values[1] != 0)
      kernels = seq(from = values[1] * 0.9,
                    to = values[1] * 1.1,
                    by = values[1] * 0.0001)
    else
      kernels = seq(from = values[1] - 0.1,
                    to = values[1] + 0.1,
                    by = 0.0001)
    
    paretoDensity = rep(0, length(kernels))
    paretoDensity[kernels == values[1]] = 1
    
    if (length(values) == 2) {
      if (values[2] != 0)
        kernels2 = seq(from = values[2] * 0.9,
                       to = values[2] * 1.1,
                       by = values[2] * 0.0001)
      else
        kernels2 = seq(from = values[2] - 0.1,
                       to = values[2] + 0.1,
                       by = 0.0001)
      
      
      paretoDensity2 = rep(0, length(kernels2))
      paretoDensity2[kernels2 == values[2]] = 1
      
      paretoDensity = c(paretoDensity, paretoDensity2)
      kernels = c(kernels, kernels2)
    }
    if (isTRUE(PlotIt)) {
      plot(
        kernels,
        paretoDensity,
        type = 'l',
        main = 'RAW PDE rplot',
        xaxs = 'i',
        yaxs = 'i',
        xlab = 'Data',
        ylab = 'PDE'
      )
    }
    return (list(
      kernels = kernels,
      paretoDensity = paretoDensity,
      paretoRadius = 0
    ))
  }
  
  if (length(Data) < 10) {
    warning('Less than 10 datapoints given, ParetoRadius potientially cannot be calcualted.')
  }
  
  if (missing(paretoRadius)) {
    paretoRadius = ParetoRadius(Data)
  } else if (is.null(paretoRadius)) {
    paretoRadius = ParetoRadius(Data)
  } else if (is.na(paretoRadius)) {
    paretoRadius = ParetoRadius(Data)
  } else if (paretoRadius == 0 || length(paretoRadius) == 0) {
    paretoRadius = ParetoRadius(Data)
  } else{
    
  }
  minData = min(Data, na.rm = TRUE)
  maxData = max(Data, na.rm = TRUE)
  if (length(kernels) <= 1) {
    if (length(kernels) == 0 || (length(kernels) == 1 & kernels == 0)) {
      #MT: Korrektur: statt kernels==0 und im Input Kernels=0
      nBins = OptimalNoBins(Data)
      #MT: MinAnzKernels fehlte
      nBins = max(MinAnzKernels , nBins)
      # mindestzahl von Kernels sicherstellen
      if (nBins > 100) {
        if (nBins > 1E4) {
          #MT: Fehlerabdfang bei zu vielen Bins
          nBins = 1E4
          warning('Too many bins estimated, try to transform or sample the data')
        } else{
          nBins = nBins * 3 + 1
        }
      }
      breaks = pretty(c(minData, maxData), n = nBins, min.n = 1)
      nB = length(breaks)
      mids = 0.5 * (breaks[-1L] + breaks[-nB])
      kernels = mids
    }
  }
  #bugfix: MT 2020
  #sicherstellen das alle daten auch in einer ParetoKugel enthalten sind
  if((kernels[1]-paretoRadius)!=minData){
    kernels=c(minData,kernels)
  } 
  if((tail(kernels,1)+paretoRadius)!=maxData){
    kernels=c(kernels,maxData)
  }
  nKernels = length(kernels)
  #Randapproximierung
  #  diese Daten liegen am unteren Rand
  lowBInd =  (Data < (minData + paretoRadius))
  lowR = as.matrix(2 * minData - Data[lowBInd], ncol = 1)
  # diese Daten liegen am obere Rand
  upBInd =  (Data > (maxData - paretoRadius))
  upR <- as.matrix(2 * maxData - Data[upBInd], ncol = 1)
  #extend data by mirrowing
  DataPlus = as.matrix(c(Data, lowR, upR), 1)
  paretoDensity=rep(0, nKernels)
  Fast=TRUE# only for debugging =FALSE
  if(isTRUE(Fast)){
    paretoDensity=c_pde(kernels, nKernels, paretoRadius,  DataPlus)
  }else{
    for (i in 1:nKernels) {
       lb = kernels[i] - paretoRadius
       ub = kernels[i] + paretoRadius
       isInParetoSphere = (DataPlus >= lb) & (DataPlus <= ub)
       paretoDensity[i] = sum(isInParetoSphere)
    }
  }

  #paretoDensity=c_pde_parallel(kernels, nKernels, paretoRadius,  DataPlus)
  
  # for (i in 1:nKernels) {
  #   lb = kernels[i] - paretoRadius
  #   ub = kernels[i] + paretoRadius
  #   isInParetoSphere = (DataPlus >= lb) & (DataPlus <= ub)
  #   paretoDensity[i] = sum(isInParetoSphere)
  # }
  # print(paretoDensity-paretoDensity2)
  # 
  if(requireNamespace('pracma',quietly = TRUE)){ #fuer trapz
		area <- pracma::trapz(kernels, paretoDensity)
  }else{
     warning("ParetoDensityEstimation requires the package (pracma) specified in suggest to be installed. Please install this package. Beware: PDE is now not normalized!")
     area=1
  }
  #adhoc numerical calc (not preferable)
  #idx = 2:length(kernels)
  #area <- (as.double((kernels[idx] - kernels[idx - 1]) %*% (paretoDensity[idx] + paretoDensity[idx - 1]))/2)
  
  #Fall kernel==0 => area==NAN muss abgefangen werden, passiert vermutlich nur bei unique values <2
  if (area < 0.0000000001 || is.na(area)) {
    paretoDensity <- rep(0, nKernels)
  } else{
    paretoDensity <- paretoDensity / area
  }
  if (isTRUE(PlotIt)) {
    plot(
      kernels,
      paretoDensity,
      type = 'l',
      main = 'Raw PDE R plot',
      xaxs = 'i',
      yaxs = 'i',
      xlab = 'Data',
      ylab = 'PDE'
    )
  }
  return (list(
    kernels = kernels,
    paretoDensity = paretoDensity,
    paretoRadius = paretoRadius
  ))
  
}

