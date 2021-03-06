#' Connect to AnnotationHub
#'
#' @note Updated 2021-04-27.
#' @noRd
#'
#' @details
#' On a fresh install this will print a txProgressBar to the console. We're
#' using [utils::capture.output()] here to suppress the console output, since
#' it's not very informative and can cluster R Markdown reports.
.annotationHub <- function() {
    requireNamespaces("AnnotationHub")
    invisible(capture.output({suppressMessages({
        ah <- AnnotationHub::AnnotationHub()
    })}))
    assert(is(ah, "AnnotationHub"))
    ah
}



#' Get Ensembl/Entrez mappings from NCBI OrgDb via AnnotationHub
#'
#' @note Updated 2021-04-27.
#' @noRd
.getEnsembl2EntrezFromOrgDb <- function(
    keys,
    keytype,
    columns,
    organism,
    strict = TRUE
) {
    requireNamespaces(c("AnnotationDbi", "AnnotationHub"))
    pkgs <- .packages()
    assert(
        isCharacter(keys),
        hasNoDuplicates(keys),
        isString(keytype),
        isCharacter(columns),
        isOrganism(organism),
        isFlag(strict)
    )
    alert(sprintf(
        "Matching identifiers using NCBI {.var %s} via {.pkg %s} %s.",
        "OrgDb",
        "AnnotationHub",
        packageVersion("AnnotationHub")
    ))
    ah <- .annotationHub()
    ahs <- AnnotationHub::query(ah, pattern = c(organism, "NCBI", "OrgDb"))
    id <- tail(names(ahs), n = 1L)
    suppressMessages({
        orgdb <- ah[[id]]
    })
    assert(is(orgdb, "OrgDb"))
    alertInfo(sprintf(
        "{.val %s} (%s): %s.",
        id,
        mcols(ahs)[id, "title"],
        mcols(ahs)[id, "description"]
    ))
    suppressMessages({
        df <- AnnotationDbi::select(
            x = orgdb,
            keys = keys,
            keytype = keytype,
            columns = columns
        )
    })
    assert(is.data.frame(df))
    if (isTRUE(strict)) {
        df <- df[complete.cases(df), , drop = FALSE]
        if (!areSetEqual(keys, unique(df[[keytype]]))) {
            setdiff <- setdiff(keys, unique(df[[keytype]]))
            stop(sprintf(
                "Match failure: %s.",
                toString(setdiff, width = 200L)
            ))
        }
    }
    colnames(df)[colnames(df) == "ENSEMBL"] <- "ensemblId"
    colnames(df)[colnames(df) == "ENTREZID"] <- "entrezId"
    df[["entrezId"]] <- as.integer(df[["entrezId"]])
    forceDetach(keep = pkgs)
    df <- as(df, "DataFrame")
    df
}
