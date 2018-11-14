gviz_bwScheme_settings <- list(
  GdObject=list(
    fontface.title=1,
    background.title="transparent",
    col.border.title="black",
    fontcolor.title="black",
    col.title="black",
    fontcolor="black"
  ),
  IdeogramTrack=list(
    fontcolor="black"
  ),
  GenomeAxisTrack=list(
    fontcolor="black",
    col="black",
    labelPos="above"
  ),
  AnnotationTrack=list(
    col=NULL,
    fontface.group=1,
    fontcolor.group="black"
  ),
  GeneRegionTrack=list(
    col=NULL,
    col.line="black"
  )
)
#' gviz_bwScheme
#' 
#' A Gviz scheme with black labels and transparent boxes for labels
#' @return (invisibly) the scheme structure
#' @export
gviz_bwScheme <- function() {
  require(Gviz)
  scheme <- getScheme()
  for (typeName in names(gviz_bwScheme_settings)){
    for (settingName in names(gviz_bwScheme_settings[[typeName]])){
      setting <- gviz_bwScheme_settings[[typeName]][[settingName]]
      if (is.null(setting)){
        scheme[[typeName]][settingName] <- list(NULL)
      } else {
        scheme[[typeName]][[settingName]] <- setting
      }
    }
  }
  addScheme(scheme, "bwScheme")
  options(Gviz.scheme="bwScheme")
  invisible(scheme)
}

#' applySchemeToTrack
#' 
#' Applies a Gviz plotting scheme to the display parameters of a track
#' @param track the Gviz track to modify
#' @param scheme the name of the scheme to be applied as a string
#' @return the track with modified display parameters
#' @author Fabian Mueller
#' @export 
applySchemeToTrack <- function(track, scheme="bwScheme"){
  schemeSettings <- get(paste0("gviz_", scheme, "_settings"))
  for (typeName in names(schemeSettings)){
    if (inherits(track, typeName)){
      displayPars(track) <- schemeSettings[[typeName]]
    }
  }
  return(track)
}
