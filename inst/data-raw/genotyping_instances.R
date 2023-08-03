# add calls to genotyping_main below
# new instances should be stacked on top
# old instances should be commented out
# make a new commit referencing each new instance
# network directory should point to the directory where you want the results to go
# network directory should contain fastqs in a subdirectory


devtools::load_all()
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

genotyping_main(network_directory = "/network/X/Labs/Blaser/staff/ngs_archive/oca2_DC_20230227",
                crispr_target = "OCA2_CRISPR",bed = "~/brad_workspace/genotyping/data-raw/master.bed" )


# history -----------------------------------------------------------------
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
