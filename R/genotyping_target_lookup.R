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
#' @importFrom cli cli_abort cli_alert_success
create_target_BEDfile <- function(query,
                                  crispr_target_name,
                                  genome = c("Drerio", "GFP"),
                                  master_bed = "data-raw/master.bed"){

  # import the current master bed file.  No need to parameterize this since it will be fixed.
  master_bedfile <- master_bed
  master_bed <- rtracklayer::import(master_bed, format = "bed")

   # find where the query hits
      crispr_query <- Biostrings::DNAString(query)

   # also no need to parameterize the genome.  Just fix it like you did
      genome <- match.arg(genome, choices = c("Drerio", "GFP"))

      if (genome == "Drerio") {
        faster_hit <- Biostrings::vmatchPattern(pattern = crispr_query, subject = BSgenome.Drerio.blaserlabgenotyping.dr11::Drerio)

      }

      if (genome == "GFP") {

        faster_hit <- Biostrings::matchPattern(pattern = crispr_query, subject = EGFP[[1]])
        faster_hit <- GenomicRanges::GRanges("EGFP", faster_hit)
        GenomeInfoDb::genome(faster_hit) <- "EGFP"
        GenomeInfoDb::seqlengths(faster_hit) <- 720

      }

      # if vmatchPattern find no matched hit
      if(length(faster_hit) == 0) {
        cli::cli_abort("No matched hit present in genome. Change query and run again")
      }
      # if vamtchPattern find one matched hit
      else if(length(faster_hit) == 1){

        # add metadata to grange object
        faster_hit$name <- toupper(crispr_target_name)
        faster_hit$score <- 0
        new_master <- suppressWarnings(c(master_bed, faster_hit))
        # check duplicates, write it out if no duplicate name and ranges
        if(!anyDuplicated(GenomicRanges::mcols(new_master)) & !anyDuplicated(IRanges::ranges(new_master))){
          cli::cli_alert_info("Exporting")
          write_granges_to_bed(gr = new_master, filename = master_bedfile)
          cli::cli_alert_success("Target genome coordinates have been updated to master BEDfile")
        }
        # stop function if new_master has same name in metadata
        else if(anyDuplicated(GenomicRanges::mcols(new_master)) ){
          cli::cli_abort("Duplicate name, please rename your target")
        }
        # stop function if new_master has same range
        else if(anyDuplicated(IRanges::ranges(new_master))){
          cli::cli_abort("Duplicate range, please check query")
        }
      }
      # stop function if vamtchPattern find more than one hits
      else{
        cli::cli_abort("More than one hits are found in genome, check query and genome and run again")
      }
    }

write_granges_to_bed <- function(gr, filename) {
  df <- data.frame(seqnames=seqnames(gr),
                   starts=start(gr)-1,
                   ends=end(gr),
                   names=gr$name,
                   scores=gr$score,
                   strands=strand(gr))

  write.table(df, file=filename, quote=F, sep="\t", row.names=F, col.names=F)
}
