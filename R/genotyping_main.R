#' @title Genotype a Crispr Locus
#' @description Use this function to genotype a target crispr locus.
#' @param crispr_target The name of the crispr target locus.  Must be present on the master BEDfile
#' @param network_directory Network directory containing fastqs.  The fastqs can be nested in a subdirectory; the output will be placed in the directory named.
#' @param multiplex Whether or not to demultiplex, Default: TRUE
#' @param read_threshold Remove alleles with read counts below this threshold, Default: 25
#' @param bed master bedfile to use, Default: 'data-raw/master.bed'
#' @return Nothing; writes out to the network directory.
#' @seealso
#'  \code{\link[rtracklayer]{character(0)}}
#'  \code{\link[parallel]{detectCores}}
#' @rdname genotyping_main
#' @export
#' @importFrom rtracklayer import
#' @importFrom parallel detectCores
genotyping_main <- function(crispr_target,
                            network_directory,
                            multiplex = TRUE,
                            read_threshold = 25,
                            bed = "data-raw/master.bed") {
  bed_check <- rtracklayer::import(bed, format = "bed")

  stopifnot(
    "Your target is not in the supplied BEDfile.\nAdd your target using create_target_BEDfile()." = crispr_target %in% bed_check$name
  )

  gen <- locus_genome_lookup(locus_name = crispr_target,
                             file_name = bed)

  make_genotyping_directories()

  copy_and_decompress(network_directory = network_directory)

  split_fastq_pairs()

  merge_read_pairs()

  trim_merged()

  cutadapt(multiplex = multiplex)

  fastqc()

  align(
    multiplex = multiplex,
    cores = parallel::detectCores(),
    genome = gen
  )

  make_target_region(target = crispr_target,
                     genome_fa = gen,
                     bed = bed_check) |>
    make_crispr_set() |>
    plot_crispr_set(threshold = read_threshold) |>
    plot_crispr_bars() |>
    save_output(target = crispr_target,
                nd = network_directory)

}
