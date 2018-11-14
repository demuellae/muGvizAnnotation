#' \code{Gviz} annotation data for geneome assembly hg38
#'
#' @format A \code{GvizManager} object with annotation data for genome assembly
#' \describe{
#'   \item{gene annotation}{based on GENCODE v27}
#' }
"gvm_hg38"

#' \code{Gviz} annotation data for geneome assembly hg19
#'
#' @format A \code{GvizManager} object with annotation data for genome assembly
#' \describe{
#'   \item{gene annotation}{based on GENCODE v19}
#' }
"gvm_hg19"

#' \code{Gviz} annotation data for geneome assembly mm10
#'
#' @format A \code{GvizManager} object with annotation data for genome assembly
#' \describe{
#'   \item{gene annotation}{based on GENCODE M16}
#' }
"gvm_mm10"

#' getGvm
#'
#' retrieve the \code{GvizManager} object for a given genome assembly
#'
#' @param assembly  string specifying the genome assembly
#' @return \code{GvizManager} object
#'
#' @export
getGvm <- function(assembly){
	objName <- data(list=paste0("gvm_", assembly), package="muGvizAnnotation")
	return(get(objName))
}
