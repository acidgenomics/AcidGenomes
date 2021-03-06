#' Map input to human gene orthologs
#'
#' @export
#' @note Updated 2021-04-27.
#'
#' @details
#' Genes with identifier versions (e.g. "ENSMUSG00000000001.5") are not
#' currently supported.
#'
#' @inheritParams AcidRoxygen::params
#'
#' @return `DataFrame`.
#'   Data frame containing mapping columns:
#'
#'   - `geneId`
#'   - `geneName`
#'   - `humanGeneId`
#'   - `humanGeneName`
#'
#' @seealso
#' - `biomaRt::listEnsemblArchives()`.
#' - `biomaRt::listMarts()`.
#' - `biomaRt::useMart()`.
#'
#' @examples
#' genes <- c(
#'     "ENSMUSG00000000001", "ENSMUSG00000000003",
#'     "ENSMUSG00000000028", "ENSMUSG00000000031",
#'     "ENSMUSG00000000037", "ENSMUSG00000000049"
#' )
#' ## Protect against Ensembl timeouts causing build checks to fail.
#' ## > if (goalie::hasInternet("https://ensembl.org")) {
#' ## >     x <- mapHumanOrthologs(genes = genes, ensemblRelease = 87L)
#' ## >     print(x)
#' ## > }
mapHumanOrthologs <- function(
    genes,
    organism = NULL,
    ensemblRelease = NULL
) {
    pkgs <- .packages()
    requireNamespaces("biomaRt")
    assert(
        isCharacter(genes),
        isOrganism(organism, nullOK = TRUE),
        isInt(ensemblRelease, nullOK = TRUE)
    )
    if (is.null(organism)) {
        organism <- detectOrganism(genes)
    }
    ## Don't allow the user to pass in human genes, since this makes no sense.
    assert(!identical(organism, "Homo sapiens"))
    ## Match the Ensembl release to the archive host name, required for biomaRt.
    ## e.g. Ensembl 99: http://jan2020.archive.ensembl.org
    host <- mapEnsemblReleaseToURL(ensemblRelease)
    ## e.g. "mmusculus_gene_ensembl".
    dataset <- paste0(
        tolower(sub(
            pattern = "^([A-Z])([a-z]+)\\s([a-z]+)$",
            replacement = "\\1\\3",
            x = organism
        )),
        "_gene_ensembl"
    )
    alert(sprintf(
        fmt = paste(
            "Matching orthologs against {.var %s} ({.url %s}) with",
            "{.pkg biomaRt} %s."
        ),
        dataset, host, packageVersion("biomaRt")
    ))
    ## Can use "ENSEMBL_MART_ENSEMBL" instead of "ensembl" here.
    mart <- tryCatch(
        expr = biomaRt::useMart(
            biomart = "ensembl",
            dataset = dataset,
            host = host,
            verbose = FALSE
        ),
        error = function(e) {
            stop("'biomaRt::useMart()' error: ", e)
        }
    )
    map <- tryCatch(
        expr = biomaRt::select(
            x = mart,
            keys = genes,
            keytype = "ensembl_gene_id",
            columns =  c(
                "ensembl_gene_id",
                "hsapiens_homolog_ensembl_gene"
            )
        ),
        error = function(e) {
            stop("'biomaRt::select()' error: ", e)
        }
    )
    if (!hasRows(map)) {
        stop("Failed to map any genes.")
    }
    map <- as(map, "DataFrame")
    colnames(map) <- c("geneId", "humanGeneId")
    map <- map[complete.cases(map), , drop = FALSE]
    map <- map[order(map), , drop = FALSE]
    keep <- !duplicated(map[["geneId"]])
    if (!all(keep)) {
        dupes <- unique(map[["geneId"]][!keep])
        alertWarning(sprintf(
            paste(
                "%d gene %s multimap to multiple human genes.",
                "Selecting first match by oldest Ensembl identifier."
            ),
            length(dupes),
            ngettext(
                n = length(dupes),
                msg1 = "identifier",
                msg2 = "identifiers"
            )
        ))
        map <- map[keep, , drop = FALSE]
    }
    keep <- !duplicated(map[["humanGeneId"]])
    if (!all(keep)) {
        dupes <- unique(map[["humanGeneId"]][!keep])
        alertWarning(sprintf(
            paste(
                "%d duplicate human gene %s detected.",
                "Selecting first match."
            ),
            length(dupes),
            ngettext(
                n = length(dupes),
                msg1 = "identifier",
                msg2 = "identifiers"
            )
        ))
    }
    map <- map[keep, , drop = FALSE]
    assert(
        hasRows(map),
        hasNoDuplicates(map[["geneId"]]),
        hasNoDuplicates(map[["humanGeneId"]])
    )
    alertInfo(sprintf(
        "%d gene %s mapped 1:1 from {.emph %s} to {.emph %s}.",
        nrow(map),
        ngettext(
            n = nrow(map),
            msg1 = "identifier",
            msg2 = "identifiers"
        ),
        organism, "Homo sapiens"
    ))
    alert(sprintf("Getting {.emph %s} gene symbols.", organism))
    g2s <- makeGene2SymbolFromEnsembl(
        organism = organism,
        release = ensemblRelease,
        ignoreVersion = TRUE,
        format = "unmodified"
    )
    g2s <- as(g2s, "DataFrame")
    assert(identical(colnames(g2s), c("geneId", "geneName")))
    alert("Getting {.emph Homo sapiens} gene symbols.")
    g2sHuman <- makeGene2SymbolFromEnsembl(
        organism = "Homo sapiens",
        release = ensemblRelease,
        ignoreVersion = TRUE,
        format = "unmodified"
    )
    g2sHuman <- as(g2sHuman, "DataFrame")
    colnames(g2sHuman) <- c("humanGeneId", "humanGeneName")
    ## Return.
    out <- map
    out <- leftJoin(out, g2s, by = "geneId")
    out <- leftJoin(out, g2sHuman, by = "humanGeneId")
    rownames(out) <- out[["geneId"]]
    out <- out[, sort(colnames(out))]
    assert(
        !all(is.na(out[["geneName"]])),
        !all(is.na(out[["humanGeneId"]]))
    )
    forceDetach(keep = pkgs)
    out
}
