\name{PixelMatrixPlot}
\alias{PixelMatrixPlot}
\alias{PlotPixMatrix}

%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Plot Pixel Matrix }
\description{
  Plots Data matrix as a pixel coulour image
}
\usage{
PixelMatrixPlot(Data, XNames, LowLim, HiLim, YNames, main)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Data}{ [1:n,1:d] Data cases in rows (n), variables in columns (d) }
  \item{LowLim}{ Optional: limits for the color axis }
  \item{HiLim}{ Optional: limits for the color axis }
  \item{XNames}{ Optional: Vector - names for the X-ticks }
  \item{YNames}{ Optional: Vector - names for the Y-ticks }
  \item{main}{Optinal: String - Title of the plot}
}
\author{Michael Thrun, Felix Pape}
\examples{
data("Lsun3D")
Data=Lsun3D$Data
\donttest{
PixelMatrixPlot(Data)
}
\dontshow{
PixelMatrixPlot(Data[1:100,])
}
}
\keyword{PlotPixMatrix}
\keyword{PixelMatrixPlot}

\keyword{heatmap}
\keyword{pixel matrix}
\keyword{image}