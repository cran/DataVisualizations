Classplot=function(X, Y,Cls,Names=NULL,na.rm=FALSE, xlab = "X", ylab = 'Y', 
                       main = "Class Plot", Colors,Size=8,LineColor=NULL,
					   LineWidth=1,LineType=NULL,Showgrid=TRUE, Plotter,SaveIt = FALSE){
  

  
  if(missing(Cls)) Cls=rep(1,length(X))
  
  X=checkFeature(X,'X')
  Y=checkFeature(Y,'Y')
  Cls=checkCls(Cls,length(Y))
  if(length(X)!=length(Y)) stop('X and Y have to have the same length')
  
  if(isTRUE(na.rm)){ #achtung irgendwas stimmt hier nicht
    noNaNInd <- which(is.finite(X)&is.finite(Y))
    X = X[noNaNInd]
    Y = Y[noNaNInd]
    Cls=Cls[noNaNInd]
    
    if(!is.null(Names)){
      Names=Names[noNaNInd]
    }
  }
  uu=unique(Cls)
  if(missing(Colors)){
    mc=length(uu)
    if(is.null(Names))
    Colors=DataVisualizations::DefaultColorSequence[1:mc]
    else
      Colors=DataVisualizations::DefaultColorSequence[-2][1:mc] #no yellow
  }
  
  if(missing(Plotter)){
    if(is.null(Names))
      Plotter="plotly"
    else
      Plotter="ggplot"
  }
  if(Plotter=="ggplot2") Plotter="ggplot"
  
  
  if(Plotter=="plotly"){
    if (!requireNamespace('plotly',quietly = TRUE)){
    
    message('Subordinate package (plotly) is missing. No computations are performed.
Please install the package which is defined in "Suggests".')
    
    return('Subordinate package (plotly) is missing. No computations are performed.
Please install the package which is defined in "Suggests".')
  }
  p <- plotly::plot_ly(type='scatter',mode='markers',colors=Colors,marker = list(size = Size))
  
  if(!is.null(LineColor)){
    p <- plotly::add_lines(p, x = ~X, y = ~Y,line = list(color = LineColor, width = LineWidth, dash = LineType), name = 'Line')
  }
   
  if(is.null(Names)){
    p <- plotly::add_trace(p, x = ~X, y = ~Y,color=~as.factor(Cls), name = ' ')
  }else{
    #p <- plotly::add_trace(p, x = ~X, y = ~Y,color=~as.factor(Cls))
    p <- plotly::add_text(p = p,x = ~X, y = ~Y,text = Names, textposition = "top right",color=~as.factor(Cls))
  }

  
  p <- plotly::layout(p, title = main, 
                      xaxis = list(title = xlab, showgrid = Showgrid), 
                      yaxis = list(title = ylab, showgrid = Showgrid))

    p

  
    if (isTRUE(SaveIt)) {
      requireNamespace("htmlwidgets")
      htmlwidgets::saveWidget(p, file = "Classplot.html")
    }
    return(p)
  }
  
  if(Plotter=="ggplot"){
    
    df=data.frame(X=X,Y=Y,Cls=Cls)
    if(!is.null(Names))
      df$Names=rownames(Names)

    ColorVec=Cls*0
    k=1
    for(i in uu){
      ColorVec[Cls==i]=Colors[k]
      k=k+1
    }
   #    
    colMat <- grDevices::col2rgb(ColorVec)
    hex=rgb(red = colMat[1, ]/255, green = colMat[2, ]/255, blue = colMat[3,]/255)


    df$Colors=ColorVec
    
    colMat <- grDevices::col2rgb(Colors)
    hex=grDevices::rgb(red = colMat[1, ]/255, green = colMat[2, ]/255, blue = colMat[3,]/255)
    
    p <- ggplot2::ggplot(df, ggplot2::aes_string(x = "X",y =  "Y", label = "Names",group="Cls",color="Colors")) + ggplot2::geom_point(size=Size)+
      ggplot2::theme_bw()+ggplot2::scale_color_identity()
    
    if(!is.null(LineType))
      p=p+geom_line(aes_string(group = "Cls"))
    
    if(!is.null(Names))
      p <- p + ggrepel::geom_text_repel() 

    
    p=p+ ggplot2::labs(title = main)+ggplot2::xlab(xlab)+ggplot2::ylab(ylab)
    p
    
    
    if (isTRUE(SaveIt)) {
      ggplot2::ggsave(filename ="Classplot.png" ,plot=p,device = "png")
   
    }
    
    return(p)
  }
  
  message('Incorrect plotter selected, performing simple native plot')
  
  if(Size==8) 
    Size=Size-6 #adapting default size
  
  plot(X,Y,col=Colors,main=main,xlab=xlab,ylab = xlab,type='p',cex=Size,pch=20)
}

