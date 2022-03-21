#' @importFrom fs dir_create
make_genotyping_directories <- function() {
  fs::dir_create("temp/fastq")
  fs::dir_create("temp/fastq_split_R1")
  fs::dir_create("temp/fastq_split_R2")
  fs::dir_create("temp/bam_temp")
  fs::dir_create("temp/fastq_trimmed")
  fs::dir_create("temp/fastq_merged")
  fs::dir_create("temp/fastq_cutadapt")
  fs::dir_create("tmp_output/PEAR_output")
  fs::dir_create("tmp_output/fastqc_files")

}


#' @importFrom stringr str_extract
#' @importFrom fs file_copy
#' @importFrom purrr walk
copy_and_decompress <- function(network_directory) {
  # find the fastqs
  fastq_fp <- list.files(
    network_directory,
    pattern = "*.fastq.gz",
    recursive = TRUE,
    full.names = TRUE
  )

  # get just the names of teh fastqs
  fastq_names <- stringr::str_extract(string = fastq_fp,
                             pattern = "(\\w|\\.)*$")
  # copy over the fastqs
  fs::file_copy(fastq_fp,
            file.path("temp", "fastq", fastq_names))

  purrr::walk(.x = list.files("temp/fastq"),
       .f = \(x) {
         cmd <- paste0("gzip -d temp/fastq/", x)
         message(cmd, "\n")
         system(cmd)

       })

}

#' @importFrom fs file_copy
#' @importFrom stringr str_replace
split_fastq_pairs <- function() {
  # identify the files
  R1_fastqs <-
    list.files(path = "temp/fastq",
               full.names = T,
               pattern = "_R1_")
  R2_fastqs <-
    list.files(path = "temp/fastq",
               full.names = T,
               pattern = "_R2_")

  #copy the files
  fs::file_copy(
    path = R1_fastqs,
    new_path = stringr::str_replace(R1_fastqs,
                           pattern = "fastq",
                           replacement = "fastq_split_R1")
  )

  fs::file_copy(
    path = R2_fastqs,
    new_path = stringr::str_replace(R2_fastqs,
                           pattern = "fastq",
                           replacement = "fastq_split_R2")
  )
}

#' @importFrom purrr pwalk
#' @importFrom stringr str_sub
merge_read_pairs <- function() {
  purrr::pwalk(.l = list(R1file = list.files("temp/fastq_split_R1", full.names = T),
                  R2file = list.files("temp/fastq_split_R2", full.names = T),
                  mid_name = stringr::str_sub(list.files("temp/fastq_split_R1"), start = 1, end = 5)),
        .f = \(R1file, R2file, mid_name, of = "tmp_output") {
          cmd <- paste0("pear -f ",
                        R1file,
                        " -r ",
                        R2file,
                        " -o temp/fastq_merged/",
                        mid_name,
                        " -j 39 > ",
                        of,
                        "/PEAR_output/",
                        mid_name, ".PEARreport.txt")
          message(cmd, "\n")
          system(cmd)
        } )
  unlink("temp/fastq_merged/*unassembled*")
  unlink("temp/fastq_merged/*discarded*")

}

#' @importFrom purrr pwalk
#' @importFrom stringr str_sub
trim_merged <- function() {
  trimmomatic <- system.file("java/Trimmomatic-0.38/trimmomatic-0.38.jar", package = "genotyping.functions")
  return(trimmomatic)
  purrr::pwalk(.l = list(merged_fp = list.files("temp/fastq_merged", full.names = T),
                  mid_name = stringr::str_sub(list.files("temp/fastq_merged", full.names = F),
                                     start = 1,
                                     end = 5)),
        .f = \(merged_fp, mid_name, tmm = trimmomatic) {
          cmd <- paste0("java -jar ",
                        tmm,
                        " SE ",
                        merged_fp,
                        " temp/fastq_trimmed/",
                        mid_name,
                        ".trimmed.fastq ",
                        "LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:100")
          message(cmd, "\n")
          system(cmd)
        })
}

#' @importFrom stringr str_sub
#' @importFrom purrr walk2
#' @importFrom fs file_copy
cutadapt <- function(multiplex) {
  trimmed_fp <- list.files("temp/fastq_trimmed", full.names = T)
  trimmed_names <- list.files("temp/fastq/trimmed", full.names = F)
  mid_name <- stringr::str_sub(
    list.files("temp/fastq_trimmed", full.names = F),
    start = 1,
    end = 5
  )
  if (multiplex) {
    purrr::walk2(.x = trimmed_fp,
          .y = mid_name,

      .f = \(x, y, rf = system.file("extdata/barcodes.fasta", package = "BSgenome.Drerio.blaserlabgenotyping.dr11")) {
          cmd <-
            paste0(
              "cutadapt -g file:",
              rf,
              " -o temp/fastq_cutadapt/{name}.",
              y,
              ".cutadapt.fastq ",
              x
            )
          message(cmd, "\n")
          system(cmd)
      }
    )

  } else {
    fs::file_copy(path = trimmed_fp, new_path = paste0("temp/fastq_cutadapt/", trimmed_names))
  }
  unlink("temp/fastq_cutadapt/unknown*",recursive = TRUE)
}

#' @importFrom purrr walk
fastqc <- function() {
  purrr::walk(.x = list.files("temp/fastq_cutadapt", full.names = T),
       .f = \(x) {
         cmd <- paste0("fastqc -o tmp_output/fastqc_files ", x)
         message(cmd, "\n")
         system(cmd)
       })
}



#' @importFrom stringr str_sub
#' @importFrom purrr walk2 walk
align <-
  function(multiplex,
           cores,
           genome) {
    cutadapt_names <-
      list.files("temp/fastq_cutadapt", full.names = FALSE)
    cutadapt_fp <-
      list.files("temp/fastq_cutadapt", full.names = TRUE)
    if (multiplex) {
      mid_names <- stringr::str_sub(cutadapt_names, 1, 10)
    } else {
      mid_names <- stringr::str_sub(cutadapt_names, 1, 5)
    }

    purrr::walk2(
      .x = list.files("temp/fastq_cutadapt", full.names = T),
      .y = mid_names,
      .f = \(x, y, gen = genome) {
        cmd <-
          paste0("bwa mem -t ",
                 cores,
                 " ",
                 gen,
                 " ",
                 x,
                 " | samtools view -Sb - > temp/bam_temp/",
                 y,
                 ".bam")
        message(cmd, "\n")
        system(cmd)
      }
    )

    purrr::walk(
      .x = list.files("temp/bam_temp", full.names = T),
      .f = \(x) {
        cmd <- paste0("samtools sort ", x, " -o ", x)
        message(cmd, "\n")
        system(cmd)
      }
    )

    purrr::walk(
      .x = list.files("temp/bam_temp", full.names = T),
      .f = \(x) {
        cmd <- paste0("samtools index ", x)
        message(cmd, "\n")
        system(cmd)
      }
    )

  }

#' @importFrom GenomicRanges resize
make_target_region <- function(target, genome_fa, bed) {
  bed_filtered <- bed[bed$name == target]
  bed_extended <-
    GenomicRanges::resize(bed_filtered, width(bed_filtered) + 20, fix = "center")
  reference <- system(paste0(
    "samtools faidx ",
    genome_fa,
    sprintf(
      " %s:%s-%s",
      seqnames(bed_extended)[1],
      start(bed_extended)[1],
      end(bed_extended)[1]
    )
  ),
  intern = TRUE)[[2]]
  return_list <- list(reference, bed_extended)
  names(return_list) <- c("reference", "bed_extended")

  return(return_list)
}


#' @importFrom GenomicRanges strand
#' @importFrom CrispRVariants readsToTarget
#' @importFrom stringr str_replace
make_crispr_set <- function(input_list) {

  if (as.character(GenomicRanges::strand(input_list$bed_extended)) == "-") {
    target_loc <- 13
  } else {
    target_loc <- 30
  }

  target_use <- input_list$bed_extended
  GenomicRanges::strand(target_use) <- "+"
  crispr_set <- CrispRVariants::readsToTarget(
    reads = list.files("temp/bam_temp", pattern = "*.bam$", full.names = T),
    target = target_use,
    reference = input_list$reference,
    chimera.to.target = 20,
    names = stringr::str_replace(string = list.files("temp/bam_temp", pattern = "*.bam$"), pattern = ".bam", replacement = ""),
    target.loc = target_loc,
    collapse.pairs = TRUE,
    split.snv = TRUE #split.snv=FALSE adds SNVs into no variant count
  )
  return_list <- list(crispr_set, input_list$bed_extended)
  names(return_list) <- c("CrisprSet", "bed_extended")
  return(return_list)

}

#' @importFrom GenomicRanges strand
#' @importFrom AnnotationDbi loadDb
#' @importFrom CrispRVariants plotVariants
#' @importFrom IRanges IRanges
#' @importFrom grid unit
plot_crispr_set <-
  function(input_list,
           txdb = system.file("extdata/GRCz11.97_txdb.sqlite",
                              package = "BSgenome.Drerio.blaserlabgenotyping.dr11"),
           threshold = read_threshold) {
    while (!is.null(dev.list()))
      dev.off()

    if (as.character(GenomicRanges::strand(input_list$bed_extended)) == "-") {
      pam_start <- 11
      target_loc <- 13
      guide_start <- 11
      guide_end <- 33
    } else {
      pam_start <- 31
      target_loc <- 30
      guide_start <- 11
      guide_end <- 33

    }
    crispr_set <- input_list$CrisprSet
    txdb <- AnnotationDbi::loadDb(txdb)
    p <- CrispRVariants::plotVariants(
      obj = crispr_set,
      txdb = txdb,
      col.wdth.ratio = c(1, 1),
      plotAlignments.args = list(
        pam.start = pam_start,
        target.loc = target_loc,
        guide.loc = IRanges::IRanges(guide_start, guide_end),
        min.count = threshold,
        tile.height = 0.55
      ),
      plotFreqHeatmap.args = list(
        min.count = threshold,
        plot.text.size = 3,
        x.size = 8,
        legend.text.size = 8,
        legend.key.height = grid::unit(0.5, "lines")
      )
    )
    dev.copy2pdf(file = "tmp_output/crispr_plot.pdf",
                 width = 17,
                 height = 11)
    dev.off()
    return(crispr_set)


  }


#' @importFrom CrispRVariants variantCounts barplotAlleleFreqs
plot_crispr_bars <- function(crispr_set) {
  while (!is.null(dev.list()))
    dev.off()
  var_counts <- CrispRVariants::variantCounts(crispr_set)
  CrispRVariants::barplotAlleleFreqs(var_counts)
  dev.copy2pdf(
    file = paste0("tmp_output/crispr_barplot.pdf"),
    width = 11,
    height = 8.5
  )
  dev.off()
 return(crispr_set)
}

#' @importFrom stringr str_replace_all
#' @importFrom fs dir_copy
#' @importFrom purrr map_chr
#' @importFrom tools md5sum
save_output <-
  function(crispr_set,
           cleanup = TRUE,
           target = crispr_target,
           nd = network_directory) {
    save(crispr_set, file = "tmp_output/crispr_set.rda")
    dt_stamp <-
      stringr::str_replace_all(string = Sys.time(),
                      pattern = "([-\\s:ESTD])",
                      replacement = "_")
    network_output <-
      file.path(nd, paste0(target, "_", dt_stamp))
    fs::dir_copy(path = "tmp_output", new_path = network_output)
    check <- identical(
      purrr::map_chr(
        list.files("tmp_output", full.names = T, recursive = T),
        tools::md5sum
      ),
      purrr::map_chr(
        list.files(
          paste0(network_output, "/tmp_output"),
          full.names = T,
          recursive = T
        ),
        tools::md5sum
      )
    )
    stopifnot("The transfer failed md5sum check." = check == FALSE)
    if (cleanup) {
      unlink("temp", recursive = TRUE)
      unlink("tmp_output", recursive = TRUE)
    }
  }
