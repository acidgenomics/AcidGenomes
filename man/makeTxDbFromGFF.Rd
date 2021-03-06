% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/makeTxDbFromGFF.R
\name{makeTxDbFromGFF}
\alias{makeTxDbFromGFF}
\title{Make TxDb from a GFF/GTF file}
\usage{
makeTxDbFromGFF(file)
}
\arguments{
\item{file}{\code{character(1)}.
File path.}
}
\value{
\code{TxDb}.
}
\description{
Wrapper for GenomicFeatures \code{makeTxDbFromGFF} importer.
}
\section{Functions}{
\itemize{
\item \code{makeTxDbFromGFF}: Primary function.
}}

\note{
Updated 2021-04-27.
}
\examples{
## GENCODE ====
## > gtfFile <- pasteURL(
## >     "ftp.ebi.ac.uk",
## >     "pub",
## >     "databases",
## >     "gencode",
## >     "Gencode_human",
## >     "release_36",
## >     "gencode.v36.annotation.gtf.gz",
## >     protocol = "ftp"
## > )
## > txdb <- AcidGenomes::makeTxDbFromGFF(file = gtfFile)
## > print(txdb)

## RefSeq ====
## > gffFile <- pasteURL(
## >     "ftp.ncbi.nlm.nih.gov",
## >     "genomes",
## >     "refseq",
## >     "vertebrate_mammalian",
## >     "Homo_sapiens",
## >     "all_assembly_versions",
## >     "GCF_000001405.38_GRCh38.p12",
## >     "GCF_000001405.38_GRCh38.p12_genomic.gff.gz",
## >     protocol = "ftp"
## > )
## > txdb <- AcidGenomes::makeTxDbFromGFF(file = gffFile)
## > print(txdb)
}
\seealso{
\itemize{
\item \code{GenomicFeatures::makeTxDbFromGFF()}.
\item \code{GenomicFeatures::supportedMiRBaseBuildValues()}.
Note that \emph{Homo sapiens} GRCh38 isn't currently supported in mirbase.db.
\item \href{https://bioconductor.org/packages/TxDb.Hsapiens.UCSC.hg38.knownGene/}{TxDb.Hsapiens.UCSC.hg38.knownGene}.
}
}
