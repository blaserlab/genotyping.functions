# add calls to genotyping_main below
# new instances should be stacked on top
# old instances should be commented out
# make a new commit referencing each new instance
# network directory should point to the directory where you want the results to go
# network directory should contain fastqs in a subdirectory

library("blaseRtemplates")
library("blaseRdata")
library("blaseRtools")
library("conflicted")
library("tidyverse")
library("lazyData")
library("genotyping.functions")
library("GenomicRanges")
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")
conflict_prefer("select", "dplyr")
conflict_prefer("rename", "dplyr")
conflict_prefer("count", "dplyr")
conflict_prefer("Drerio", "blaseRdata")


# current -----------------------------------------------------------------

genotyping_main(network_directory = fs::path("~/network/X/Labs/Blaser/staff/ngs_archive/velegraki_AA/fastq/E/"),
                multiplex = TRUE,
                split_snv = FALSE,
                crispr_target = "LRRC32_TARGET_2", bed = "inst/data-raw/master.bed")

load("~/network/X/Labs/Blaser/staff/ngs_archive/velegraki_AA/fastq/E/LRRC32_TARGET_2_2024_10_15_12_23_38.244918/crispr_set.rda")
crispr_set$pars
genotyping_main(network_directory = fs::path("~/network/X/Labs/Blaser/staff/ngs_archive/velegraki_AA/fastq/S/"),
                multiplex = TRUE,
                split_snv = FALSE,
                crispr_target = "LRRC32_TARGET_2")
# history -----------------------------------------------------------------
# genotyping_main(network_directory = fs::path("~/network/X/Labs/Blaser/staff/ngs_archive/bcor_DK_20240715/"),
#                 multiplex = TRUE,
#                 crispr_target = "BCOR_RANK1")

# genotyping_main(network_directory = fs::path("~/network/X/Labs/Blaser/staff/ngs_archive/bcor_DJ_20240617/"),
#                 multiplex = TRUE,
#                 crispr_target = "BCOR_RANK1")


# genotyping_main(network_directory = fs::path("~/network/X/Labs/Blaser/staff/ngs_archive/bcor_DI_20240524/"),
#                 multiplex = TRUE,
#                 crispr_target = "BCOR_RANK1")

# genotyping_main(network_directory = fs::path("~/network/X/Labs/Blaser/staff/ngs_archive/bcor_DH_20240326/"),
#                 multiplex = TRUE,
#                 crispr_target = "BCOR_RANK1")

# genotyping_main(network_directory = "~/network/X/Labs/Blaser/staff/ngs_archive/lrrc32_DG_20240222/fastq/sample_1", multiplex = FALSE, crispr_target = "LRRC32_TARGET_2")
#
# genotyping_main(network_directory = "~/network/X/Labs/Blaser/staff/ngs_archive/lrrc32_DG_20240222/fastq/sample_2", multiplex = FALSE, crispr_target = "LRRC32_TARGET_7")
# genotyping_main(network_directory = "~/network/X/Labs/Blaser/staff/ngs_archive/bcor_DE_20231016/fastq/sample1/",multiplex = FALSE, crispr_target = "BCOR_RANK1")
#
#
# genotyping_main(network_directory = "~/network/X/Labs/Blaser/staff/ngs_archive/bcor_DE_20231016/fastq/sample2/",multiplex = FALSE, crispr_target = "BCOR_RANK2")
#
#
#
# genotyping_main(network_directory = "~/network/X/Labs/Blaser/staff/ngs_archive/bcor_DE_20231016/fastq/sample3/",multiplex = FALSE, crispr_target = "BCOR_RANK4")

# genotyping_main(network_directory = "~/network/X/Labs/Blaser/staff/ngs_archive/btk_crispr_set2_DD_20230907/",
#                 crispr_target = "BTK_CRISPR_1")
# genotyping_main(network_directory = "~/network/X/Labs/Blaser/staff/ngs_archive/btk_casper_DC_20230804",
#                 crispr_target = "BTK_CRISPR_1")

# genotyping_main(network_directory = "~/network/X/Labs/Blaser/staff/ngs_archive/oca2_DC_20230227",
#                 crispr_target = "OCA2_CRISPR", )

 # genotyping_main(network_directory = "~/network/X/Labs/Blaser/ngs_archive/prkcha_CW",
 #                 crispr_target = "PRKCHA_CRISPR")


# genotyping_main(network_directory = "~/network/X/Labs/Blaser/ngs_archive/prkcba_DA_20220310",
#                 crispr_target = "PRKCBA_CRISPR")


# genotyping_main(network_directory = "/home/OSUMC.EDU/blas02/network/X/Labs/Blaser/ngs_archive/prkchb_CT_20211021",
#                 crispr_target = "PRKCHB_TARGET_1")

#
# genotyping_main(network_directory = "/home/OSUMC.EDU/blas02/network/X/Labs/Blaser/ngs_archive/oca2_BI_20200306",
#                 crispr_target = "OCA2_CRISPR")
#
#
#
# genotyping_main(network_directory = "/home/OSUMC.EDU/blas02/network/X/Labs/Blaser/ngs_archive/prkcda_CR_20210506",
#                 crispr_target = "PRKCDA_TARGET_1")
