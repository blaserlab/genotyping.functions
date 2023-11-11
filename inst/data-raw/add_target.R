# use this script to add targets to the master bedfile
# target queries should be entered 5' to 3' using DNA alphabet
# always in the form of [20-nt recognition sequence][PAM]
# comment out the function call after you use it
source("R/dependencies.R")
source("R/configs.R")


create_target_BEDfile(query = "cgcgccgaggtgaagttcgaggg", crispr_target_name = "GFP_TARGET_2", master_bed = "inst/data-raw/master.bed", genome = "GFP")
create_target_BEDfile(query = "ttcaagtccgccatgcccgaagg", crispr_target_name = "GFP_TARGET_4", master_bed = "inst/data-raw/master.bed", genome = "GFP")
create_target_BEDfile(query = "ccccgaccacatgaagcagcacg", crispr_target_name = "GFP_TARGET_7", master_bed = "inst/data-raw/master.bed", genome = "GFP")
create_target_BEDfile(query = "GCAACCATGGAGTCTACCAGAGG", crispr_target_name = "BCOR_RANK1", master_bed = "inst/data-raw/master.bed")
# create_target_BEDfile(query = "GAGGAAGGACTTCTGTACAGAGG", crispr_target_name = "BCOR_RANK2")
# create_target_BEDfile(query = "TCGATGCCGAGCGCACTGAGAGG", crispr_target_name = "BCOR_RANK4")
# create_target_BEDfile(query = "GTATTCGTATTCAGCTATAACGG", crispr_target_name = "BTK_CRISPR_1")
# create_target_BEDfile(query = "CATCACGGCGTGGCGCATGGAGG", crispr_target_name = "PRKCHA_CRISPR")
# create_target_BEDfile(query = "GTCATCGGATTCAGATGGCAAGG", crispr_target_name = "PRKCBA_CRISPR")
# create_target_BEDfile(query = "CTGGCAGCTCTGGCTTTCATTGG", crispr_target_name = "OCA2_CRISPR")
# create_target_BEDfile(query = "GGATCGCCAAGCAGGATACATGG", crispr_target_name = "PRKCDA_TARGET_1")
# create_target_BEDfile(query = "GGATCGCCAAGCAGGATACATGG", crispr_target_name = "PRKCDA_TARGET_1")
# create_target_BEDfile(query = "GAGACTGCATATTCGCGAGGCGG", crispr_target_name = "PRKCHB_TARGET_1")
