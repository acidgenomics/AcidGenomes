% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/organism-methods.R
\name{organism}
\alias{organism}
\alias{organism<-}
\alias{organism,matrix-method}
\alias{organism,Matrix-method}
\alias{organism,data.frame-method}
\alias{organism,Annotated-method}
\alias{organism,DataFrame-method}
\alias{organism,GRanges-method}
\alias{organism,SummarizedExperiment-method}
\alias{organism<-,Annotated-method}
\title{Organism}
\usage{
organism(object)

organism(object) <- value

\S4method{organism}{matrix}(object)

\S4method{organism}{Matrix}(object)

\S4method{organism}{data.frame}(object)

\S4method{organism}{Annotated}(object)

\S4method{organism}{DataFrame}(object)

\S4method{organism}{GRanges}(object)

\S4method{organism}{SummarizedExperiment}(object)

\S4method{organism}{Annotated}(object) <- value
}
\arguments{
\item{object}{Object.}

\item{value}{Value to assign.}
}
\value{
\code{character(1)}.
Latin organism name (e.g. \emph{Homo sapiens}).
}
\description{
Organism
}
\note{
Updated 2020-05-11.
}
\examples{
data(RangedSummarizedExperiment, package = "AcidTest")
rse <- RangedSummarizedExperiment

## SummarizedExperiment ====
BiocGenerics::organism(rse)
}
\seealso{
[detectOrganism()][.
}