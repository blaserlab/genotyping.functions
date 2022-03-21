#' @importFrom rtracklayer import
locus_genome_lookup <- function(locus_name, file_name){
  gr <- rtracklayer::import(file_name)
  filtered <- gr[gr$name == locus_name]
  chromosome <- as.character(seqnames(filtered))
  output <- system.file(paste0("extdata/GRCz11/", chromosome, ".fa"), package = "BSgenome.Drerio.blaserlabgenotyping.dr11")
  return(output)
}
