### plot variants counts

library("dplyr")
library("ggplot2")
library(plyr)




### load bed files
bed_files<-list.files("~/Dropbox/cancer_reserach/sarcoma/sarcoma_analysis/long_reads/pacbio1/sv_calling/survivor/for_CJ/pacbio_survivor_3matched_SVLEN100_DIS100",pattern 
= "*.bed", full.names= TRUE) 

beds<-lapply(bed_files, function(x){

    bed.data<-read.delim(x, header = FALSE, sep = "\t")[,c(1,2,3,11)]
})

for (i in 1:length(beds)){
    beds[[i]]<-cbind(beds[[i]],bed_files[i])
    }

beds_all<-do.call("rbind",beds)
names(beds_all)[5]<-"path"

type_data_good<-beds_all%>% 
    mutate(sample=sub('.*/\\s*', '', gsub("_survivor_merged_filtered_PacBio_SVLEN100_DIS100.bed","",path)), )  %>% 
    mutate(sample_cell=gsub("1","GCT",
    gsub("2","RD",
    gsub("3","SW",sample)
    ))) %>% select(V1,V2,V3,V11,sample_cell)

#########################    
### load matrix files ###

matrix_files<-list.files("~/Dropbox/cancer_reserach/sarcoma/sarcoma_analysis/long_reads/pacbio1/sv_calling/survivor/for_CJ/pacbio_survivor_3matched_SVLEN100_DIS100",pattern 
= "*.txt", full.names= TRUE)

matrix<-lapply(matrix_files, function(x){
    read.csv(x, header = FALSE, strip.white=T, sep='')
})

for (j in 1:length(matrix)){
    matrix[[j]]<-cbind(matrix[[j]],matrix_files[j])
}

mat_all<-do.call("rbind",matrix)


names(mat_all)[5]<-"raw_id"

good_mat<-mat_all %>% mutate(sample_info=sub('.*/\\s*', 
'',gsub("_survivor_merged_filtered_PacBio_SVLEN100_DIS100_overlapped_3ways_matrix.txt","",raw_id))) %>% 
    mutate(sample_mat=gsub("1","GCT",
    gsub("2","RD",
    gsub("3","SW",sample_info)
    ))) %>% select (V1,V2,V3,V4,sample_mat) %>% 
    mutate(caller_count=rowSums(.[1:4]))


colnames(good_mat)[1:4]<-c("CuteSV" , "nanoSV" ,  "Sniffles","Svim")

bed_mat<-bind_cols(type_data_good,good_mat) %>% 
    mutate(unique_id =paste(sample_cell,V11, sep = "_"))


counts1 <- ddply(bed_mat, .(bed_mat$unique_id, bed_mat$V11), nrow) #### count number of SV per cell line
colnames(counts1)<-c("sampleid_SV","SV_type","SV_count") 
counts1$cell_line<-gsub("_.*$","",counts1$sampleid_SV)



 # Draw stack barplot with grouping & stacking
ggplot(counts1,                        
       aes(x = SV_type,
        y = SV_count,
        fill = cell_line)) + 
        geom_bar(stat = "identity",position = "stack")



ggplot(counts1, aes(fill = cell_line,
                      y = SV_count, x = SV_type))+
geom_bar(position = "dodge", stat = "identity")+
theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

# + ggtitle("Weather Data of 4 Cities !")
#theme(plot.title = element_text(hjust = 0.5))           
