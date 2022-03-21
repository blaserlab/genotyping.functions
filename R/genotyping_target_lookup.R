#' @title Create a New Entry on the Master Bedfile
#' @description Use this function to find a crispr target sequence and write to the master bedfile.  Query should be a 23-letter string corresponding to the gRNA used to make the cripsr, entered 5' to 3'.  The target recognition site should first, followed by the PAM.  By convention, all crispr target names will be converted to upper case.  If either the target range or name are duplicated, an error will result.
#' @param query the guide RNA sequence, using DNA nucleotides
#' @param crispr_target_name The name for the crispr site.
#' @return Nothing.  Adds an entry to the master bedfile.
#' @seealso
#'  \code{\link[rtracklayer]{character(0)}}
#'  \code{\link[Biostrings]{DNAString-class}},\code{\link[Biostrings]{matchPattern}}
#'  \code{\link[BSgenome.Drerio.blaserlabgenotyping.dr11]{BSgenome.Drerio.blaserlabgenotyping.dr11}}
#' @rdname create_target_BEDfile
#' @export
#' @importFrom rtracklayer import export
#' @importFrom Biostrings DNAString vmatchPattern
#' @importFrom BSgenome.Drerio.blaserlabgenotyping.dr11 Drerio
create_target_BEDfile <- function(query, crispr_target_name){

  # import the current master bed file.  No need to parameterize this since it will be fixed.
  master_bed <- rtracklayer::import("data-raw/master.bed", format = "bed")

   # find where the query hits
      crispr_query <- Biostrings::DNAString(query)

   # also no need to parameterize the genome.  Just fix it like you did
      faster_hit <- Biostrings::vmatchPattern(pattern = crispr_query, subject = BSgenome.Drerio.blaserlabgenotyping.dr11::Drerio)

      # if vmatchPattern find no matched hit
      if(length(faster_hit) == 0) {
        stop("No matched hit present in genome. Change query and run again")
      }
      # if vamtchPattern find one matched hit
      else if(length(faster_hit) == 1){

        # add metadata to grange object
        faster_hit$name <- toupper(crispr_target_name)
        faster_hit$score <- 0
        new_master <- c(master_bed, faster_hit)
        # check duplicates, write it out if no duplicate name and ranges
        if(!anyDuplicated(mcols(new_master)) & !anyDuplicated(ranges(new_master))){
          rtracklayer::export(new_master, con = "data-raw/master.bed", format = "bed")
          message("Target genomoe coordinate has been updated to master BEDfile")
        }
        # stop function if new_master has same name in metadata
        else if(anyDuplicated(mcols(new_master)) ){
          stop("Duplicate name, please rename your target")
        }
        # stop function if new_master has same range
        else if(anyDuplicated(ranges(new_master))){
          stop("Duplicate range, please check query")
        }
      }
      # stop function if vamtchPattern find more than one hits
      else{
        stop("More than one hits are found in genome, check query and run again")
      }
    }
