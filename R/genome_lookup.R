#' @importFrom rtracklayer import export
#' @importFrom GenomicRanges seqnames
#' @importFrom fs path
locus_genome_lookup <- function(locus_name, file_name, genome) {
  if (genome == "Drerio") {
    gr <- rtracklayer::import(file_name)
    filtered <- gr[gr$name == locus_name]
    chromosome <- as.character(seqnames(filtered))
    output <-
      system.file(paste0("extdata/GRCz11/", chromosome, ".fa"), package = "BSgenome.Drerio.blaserlabgenotyping.dr11")
    return(output)

  }

  if (genome == "GFP") {
    rtracklayer::export(EGFP,
                        con = fs::path(tempdir(), "EGFP.fa"),
                        format = "fasta")
    return(fs::path(tempdir(), "EGFP.fa"))
  }
}
