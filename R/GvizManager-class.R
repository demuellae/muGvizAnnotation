################################################################################
# GvizManager
# a class for easier managing of Gviz browser plots
################################################################################
require(GenomicRanges)

#' @include schemes.R
NULL

#' GvizManager
#'
#' A class for storing information on pipeline jobs.
#'
#' @section Slots:
#' \describe{
#'   \item{\code{assembly}}{
#'		Genome assembly as string
#'   }
#'   \item{\code{txdb}}{
#'		\code{TxDb} object for the gene model
#'   }
#'   \item{\code{geneAnnot}}{
#'		\code{GRanges} object with gene annotation (such as gene identifiers and symbols)
#'   }
#' }
#'
#' @section Methods:
#' \describe{
#'    \item{\code{\link{firstMethod,GvizManager-method}}}{
#'      Description of the first method
#'    }
#' }
#'
#' @name GvizManager-class
#' @rdname GvizManager-class
#' @author Fabian Mueller
#' @exportClass GvizManager
setClass("GvizManager",
	slots = list(
		assembly			= "character",
		geneModelName		= "character",
		geneAnnot			= "GRanges",
		iTrackL             = "list",
		geneTrackL          = "list"
	),
	package = "muRtools"
)
setMethod("initialize", "GvizManager",
	function(
		.Object,
		assembly,
		geneModel,
		txdb,
		geneAnnot
	) {
		require(Gviz)

		.Object@assembly			<- assembly
		.Object@geneModelName	    <- geneModel
		.Object@geneAnnot			<- geneAnnot

		chroms <- names(getSeqlengths4assembly(assembly, onlyMainChrs=TRUE, adjChrNames=TRUE))
		.Object@iTrackL <- lapply(chroms, function(cc){IdeogramTrack(genome=assembly, chromosome=cc)})
		names(.Object@iTrackL) <- chroms

		.Object@geneTrackL <- lapply(chroms, function(cc){
			rr <- GeneRegionTrack(txdb, genome=assembly, chromosome=cc, name=geneModel, transcriptAnnotation="symbol")
			symbol(rr) <- elementMetadata(geneAnnot)[gene(rr), ".symbol"]
			return(rr)
		})
		names(.Object@geneTrackL) <- chroms

		.Object
	}
)

#' @param assembly		Parameter description
#' @noRd
#' @export
GvizManager <- function(assembly, geneModel=NULL){
	geneModelMap <- c(
		"hg38"="gencode.v27",
		"hg19"="gencode.v19",
		"mm10"="gencode.vM16",
		"mm9"="gencode.vM1"
	)
	if (is.null(geneModel)) geneModel <- geneModelMap[assembly]
	txdb <- getTxDb.gencode(geneModel)
	geneAnnot <- genes(txdb)
	elementMetadata(geneAnnot)[, ".id_ensembl_long"] <- elementMetadata(geneAnnot)[, "gene_id"]
	elementMetadata(geneAnnot)[, ".id_ensembl"] <- gsub("\\.[0-9]+$", "", elementMetadata(geneAnnot)[, "gene_id"])
	elementMetadata(geneAnnot)[, ".symbol"] <- getGeneAnnotMap(assembly, from="ENSEMBL", to="SYMBOL", multiMap="paste")[elementMetadata(geneAnnot)[, ".id_ensembl"]]
	obj <- new("GvizManager",
		assembly,
		geneModel,
		txdb,
		geneAnnot
	)
	return(obj)
}
# fp <- "~/tmp_work"
# for (aa in c("hg38", "mm10", "hg19")){
#   logger.status(c("Assembly:", aa))
# 	gvm <- GvizManager(aa)
# 	saveRDS(gvm, file.path(fp, paste0("GvizManager_", aa, ".rds")))
# }

################################################################################
# Display
################################################################################
setMethod("show","GvizManager",
	function(object) {
		cat("GvizManager object for genome assembly", paste0("'", object@assembly, "'"), "\n")
		cat("contains:\n")
		cat(" *", "Data for", length(object@iTrackL),  "chromosomes\n")
		cat(" *", "Gene model:", object@geneModelName, paste0("(", length(object@geneAnnot), " genes)"), "\n")
	}
)

################################################################################
# Getters
################################################################################
if (!isGeneric("getIdeogramTrack")) {
	setGeneric(
		"getIdeogramTrack",
		function(object, ...) standardGeneric("getIdeogramTrack"),
		signature=c("object")
	)
}
#' getIdeogramTrack-methods
#'
#' Get a \code{Gviz} ideogram track for a specified chromosome
#'
#' @param object	\code{\linkS4class{GvizManager}} object
#' @param chrom		name of the chromosome for which the track should be returned
#' @param applyScheme apply the display parameters of the currently active Gviz scheme to the result
#' @return \code{Gviz::IdeogramTrack} for the specified chromosome
#'
#' @rdname getIdeogramTrack-GvizManager-method
#' @docType methods
#' @aliases getIdeogramTrack
#' @aliases getIdeogramTrack,GvizManager-method
#' @author Fabian Mueller
#' @export
setMethod("getIdeogramTrack",
	signature(
		object="GvizManager"
	),
	function(
		object,
		chrom,
		applyScheme=TRUE
	) {
		res <- object@iTrackL[[chrom]]
		if (applyScheme) res <- applySchemeToTrack(res, getOption("Gviz.scheme"))
		return(res)
	}
)

################################################################################

if (!isGeneric("getGeneTrack")) {
	setGeneric(
		"getGeneTrack",
		function(object, ...) standardGeneric("getGeneTrack"),
		signature=c("object")
	)
}
#' getGeneTrack-methods
#'
#' Get a \code{Gviz} gene annotation track for a specified chromosome
#'
#' @param object	\code{\linkS4class{GvizManager}} object
#' @param chrom		name of the chromosome for which the track should be returned
#' @param applyScheme apply the display parameters of the currently active Gviz scheme to the result
#' @return \code{Gviz::GeneRegionTrack} for the specified chromosome
#'
#' @rdname getGeneTrack-GvizManager-method
#' @docType methods
#' @aliases getGeneTrack
#' @aliases getGeneTrack,GvizManager-method
#' @author Fabian Mueller
#' @export
setMethod("getGeneTrack",
	signature(
		object="GvizManager"
	),
	function(
		object,
		chrom,
		applyScheme=TRUE
	) {
		res <- object@geneTrackL[[chrom]]
		if (applyScheme) res <- applySchemeToTrack(res, getOption("Gviz.scheme"))
		return(res)
	}
)

################################################################################

if (!isGeneric("getGeneRegionBySymbol")) {
	setGeneric(
		"getGeneRegionBySymbol",
		function(object, ...) standardGeneric("getGeneRegionBySymbol"),
		signature=c("object")
	)
}
#' getGeneRegionBySymbol-methods
#'
#' Retrieve the coordinates of a gene given the gene symbol
#'
#' @param object	\code{\linkS4class{GvizManager}} object
#' @param symbol	character specifying the gene symbol for which coordinates should be retrieved
#' @param offsetUp  offset for retrieving a flanking region upstream of the gene. Can be an \code{integer} (e.g. \code{5L}) for the absolute number of bases
#'                  or a \code{double} that specifies the relative length of the gene
#' @param offsetDown offset for retrieving a flanking region downstream of the gene. Can be an \code{integer} (e.g. \code{5L}) for the absolute number of bases
#'                  or a \code{double} that specifies the relative length of the gene
#' @param exactMatch should the symbol match exactly or should it just be contained in the symbol annotation
#' @param ignore.case ignore the case when matching the symbol
#' @return a \code{GRanges} object containing the gene coordinates
#'
#' @rdname getGeneRegionBySymbol-GvizManager-method
#' @docType methods
#' @aliases getGeneRegionBySymbol
#' @aliases getGeneRegionBySymbol,GvizManager-method
#' @author Fabian Mueller
#' @export
setMethod("getGeneRegionBySymbol",
	signature(
		object="GvizManager"
	),
	function(
		object,
		symbol,
		offsetUp=0.1,
		offsetDown=0.1,
		exactMatch=TRUE,
		ignore.case=FALSE
	) {
		
		if (exactMatch){
			if (ignore.case) {
				idx <- which(toupper(elementMetadata(object@geneAnnot)[,".symbol"])==toupper(symbol))
			} else {
				idx <- which(elementMetadata(object@geneAnnot)[,".symbol"]==symbol)
			}
		} else {
			idx <- grep(symbol, elementMetadata(object@geneAnnot)[,".symbol"], ignore.case=ignore.case)
		}
		gr <- object@geneAnnot[idx]

		if (is.double(offsetUp) && offsetUp >= 0){
			offsetUp <- ceiling(width(gr)*offsetUp)
		} else if (!is.integer(offsetUp) || offsetUp < 0){
			stop("Invalid parameter: offsetUp")
		}
		if (is.double(offsetDown) && offsetDown >= 0){
			offsetDown <- ceiling(width(gr)*offsetDown)
		} else if (!is.integer(offsetDown) || offsetDown < 0){
			stop("Invalid parameter: offsetDown")
		}
		if (offsetDown > 0) gr <- resize(gr, width=width(gr)+offsetDown, fix="start")
		if (offsetUp > 0) gr <- resize(gr, width=width(gr)+offsetUp, fix="end")
		return(gr)
	}
)

################################################################################

if (!isGeneric("getGeneRegionById")) {
	setGeneric(
		"getGeneRegionById",
		function(object, ...) standardGeneric("getGeneRegionById"),
		signature=c("object")
	)
}
#' getGeneRegionById-methods
#'
#' Retrieve the coordinates of a gene given the gene identifier
#'
#' @param object	\code{\linkS4class{GvizManager}} object
#' @param id    	character specifying the gene id for which coordinates should be retrieved
#' @param offsetUp  offset for retrieving a flanking region upstream of the gene. Can be an \code{integer} (e.g. \code{5L}) for the absolute number of bases
#'                  or a \code{double} that specifies the relative length of the gene
#' @param offsetDown offset for retrieving a flanking region downstream of the gene. Can be an \code{integer} (e.g. \code{5L}) for the absolute number of bases
#'                  or a \code{double} that specifies the relative length of the gene
#' @param type      type of identifier. currently only \code{'ensembl'} and \code{'ensembl_long'} are supported
#' @return a \code{GRanges} object containing the gene coordinates
#'
#' @rdname getGeneRegionById-GvizManager-method
#' @docType methods
#' @aliases getGeneRegionById
#' @aliases getGeneRegionById,GvizManager-method
#' @author Fabian Mueller
#' @export
setMethod("getGeneRegionById",
	signature(
		object="GvizManager"
	),
	function(
		object,
		id,
		offsetUp=0.1,
		offsetDown=0.1,
		type="ensembl"
	) {
		cname <- paste0(".id_", type)

		if (!is.element(cname, colnames(elementMetadata(object@geneAnnot)))){
			stop(paste("Unknown identifier type:", type))
		}
		idx <- which(elementMetadata(object@geneAnnot)[,cname]==id)
		if (length(idx) < 1) warning(paste("Could not find gene id:", id))
		gr <- object@geneAnnot[idx]

		if (is.double(offsetUp) && offsetUp >= 0){
			offsetUp <- ceiling(width(gr)*offsetUp)
		} else if (!is.integer(offsetUp) || offsetUp < 0){
			stop("Invalid parameter: offsetUp")
		}
		if (is.double(offsetDown) && offsetDown >= 0){
			offsetDown <- ceiling(width(gr)*offsetDown)
		} else if (!is.integer(offsetDown) || offsetDown < 0){
			stop("Invalid parameter: offsetDown")
		}
		if (offsetDown > 0) gr <- resize(gr, width=width(gr)+offsetDown, fix="start")
		if (offsetUp > 0) gr <- resize(gr, width=width(gr)+offsetUp, fix="end")
		return(gr)
	}
)
