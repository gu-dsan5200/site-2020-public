#' Updating the top header of xaringan slides
#' 
#' This function sets the top header for each slide initially based on a standard 
#' template, and allows for a header to be added below it, making it
#' easier to write sections of slides, and then revert back to just the header
#' by putting `header=NULL`, which is the default. The actual template for the 
#' header can be customized on a case-by-case basis. 
#' 
#' The following CSS specification is required, with obvious bits being customizable:
#' 
#' ```{css}
#' div.my-header {
#' background-color: #272822;
#'   position: absolute;
#' top: 0px;
#' left: 0px;
#' height: 30px;
#' width: 100%;
#' text-align: left;
#' }
#' 
#' div.my-header span{
#'   font-size: 14pt;
#'   color: #F7F8FA;
#'     position: absolute;
#'   left: 15px;
#'   bottom: 2px;
#' }
#' ````

#'
#' @param header 
#'
#' @return
#' @export
#'
#' @examples
#' ```{r, echo=FALSE, results="asis"}
#' update_header("## Why R?")
#' ```
update_header <- function(header = NULL){
  txt <- paste(c('layout: true', 
                 '', 
                 '<div class="my-header">', 
                 '<span>ANLY 503, Scientific and Analytical Visualization</span>', 
                 '</div>'),
               collapse = '\n')
  if(!is.null(header)){
    txt <- paste(c(txt, header), collapse = '\n\n')
  }
  return(cat(txt))
}
