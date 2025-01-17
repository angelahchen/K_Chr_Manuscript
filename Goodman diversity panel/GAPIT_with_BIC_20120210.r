##############################################################################################
GAPIT <- function(Y=NULL,G=NULL,GD=NULL,GM=NULL,KI=NULL,Z=NULL,CV=NULL,GP=NULL,GK=NULL,
                group.from=30 ,group.to=1000000,group.by=10,DPP=100000,
                kinship.cluster="average", kinship.group='Mean',kinship.algorithm="VanRaden",
                bin.from=10000,bin.to=10000,bin.by=10000,inclosure.from=10,inclosure.to=10,inclosure.by=10,
                SNP.P3D=TRUE,SNP.effect="Add",SNP.impute="Middle",PCA.total=0, SNP.fraction = 1, seed = 123, BINS = 20,SNP.test=TRUE,
                SNP.MAF=0,FDR.Rate = 1, SNP.FDR=1,SNP.permutation=FALSE,SNP.CV=NULL,SNP.robust="GLM",
                file.from=1, file.to=1, file.total=NULL, file.fragment = 99999,file.path=NULL,
                file.G=NULL, file.Ext.G=NULL,file.GD=NULL, file.GM=NULL, file.Ext.GD=NULL,file.Ext.GM=NULL,
                ngrid = 100, llim = -10, ulim = 10, esp = 1e-10,
                LD.chromosome=NULL,LD.location=NULL,LD.range=NULL,
                sangwich.top=NULL,sangwich.bottom=NULL,QC=TRUE,GTindex=NULL,LD=0.05,
                file.output=TRUE,cutOff=0.01, Model.selection = FALSE){
GAPIT.Version="2.08 (Fixing results contamination among traits)"
#Object: To perform GWAS and GPS (Genomic Prediction/Selection)
#Designed by Zhiwu Zhang
#Writen by Alex Lipka, Feng Tian and Zhiwu Zhang
#Last update: October 24, 2011
##############################################################################################
print("--------------------- Welcome to GAPIT ----------------------------")
echo=TRUE

Timmer=GAPIT.Timmer(Infor="GAPIT")
Memory=GAPIT.Memory(Infor="GAPIT")

#Genotype processing and calculation Kin and PC
#First call to genotype to setup genotype data

myGenotype<-GAPIT.Genotype(G=G,GD=GD,GM=GM,KI=KI,kinship.algorithm=kinship.algorithm,PCA.total=PCA.total,SNP.fraction=SNP.fraction,SNP.test=SNP.test,
                file.path=file.path,file.from=file.from, file.to=file.to, file.total=file.total, file.fragment = file.fragment, file.G=file.G,
                file.Ext.G=file.Ext.G,file.GD=file.GD, file.GM=file.GM, file.Ext.GD=file.Ext.GD,file.Ext.GM=file.Ext.GM,
                SNP.MAF=SNP.MAF,FDR.Rate = FDR.Rate,SNP.FDR=SNP.FDR,SNP.effect=SNP.effect,SNP.impute=SNP.impute,
                LD.chromosome=LD.chromosome,LD.location=LD.location,LD.range=LD.range,
                GP=GP,GK=GK,bin.size=NULL,inclosure.size=NULL, Timmer = Timmer,Memory=Memory,
                sangwich.top=sangwich.top,sangwich.bottom=sangwich.bottom,GTindex=NULL,file.output=file.output)

Timmer=myGenotype$Timmer
Memory=myGenotype$Memory

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Genotype for all")
Memory=GAPIT.Memory(Memory=Memory,Infor="Genotype for all")

#In case of null Y and null GP, return genotype only
if(is.null(Y) & is.null(GP)) return (list(GWAS=NULL,GPS=NULL,compression=NULL,kinship.optimum=NULL,kinship=myGenotype$KI,PCA=myGenotype$PC))

KI=myGenotype$KI
PC=myGenotype$PC

#In case of null Y, return genotype only
if(is.null(Y)) return (list(GWAS=NULL,GPS=NULL,compression=NULL,kinship.optimum=NULL,kinship=myGenotype$KI,PCA=myGenotype$PC))




print("--------------------Processing traits----------------------------------")
if(!is.null(Y)){
print("Phenotype provided!")
if(ncol(Y)<2)  stop ("Phenotype should have taxa name and one trait at least. Please correct phenotype file!")

genoFormat=myGenotype$genoFormat
hasGenotype=myGenotype$hasGenotype
byFile=myGenotype$byFile
fullGD=myGenotype$fullGD
GD=myGenotype$GD
GI=myGenotype$GI
GT=myGenotype$GT
G=NULL

#@@@ improve speed:
rm(myGenotype)
gc()

for (trait in 2: ncol(Y))  {
print(paste("Processing trait: ",colnames(Y)[trait],sep=""))
gapitMain <- GAPIT.Main(Y=Y[,c(1,trait)],G=G,GD=GD,GM=GM,KI=KI,Z=Z,CV=CV,GP=GP,GK=GK,SNP.P3D=SNP.P3D,kinship.algorithm=kinship.algorithm,
                      bin.from=bin.from,bin.to=bin.to,bin.by=bin.by,inclosure.from=inclosure.from,inclosure.to=inclosure.to,inclosure.by=inclosure.by,
				              group.from=group.from,group.to=group.to,group.by=group.by,kinship.cluster=kinship.cluster,kinship.group=kinship.group,name.of.trait = colnames(Y)[trait],
                        file.path=file.path,file.from=file.from, file.to=file.to, file.total=file.total, file.fragment = file.fragment, file.G=file.G,file.Ext.G=file.Ext.G,file.GD=file.GD, file.GM=file.GM, file.Ext.GD=file.Ext.GD,file.Ext.GM=file.Ext.GM,
                        SNP.MAF= SNP.MAF,FDR.Rate = FDR.Rate,SNP.FDR=SNP.FDR,SNP.effect=SNP.effect,SNP.impute=SNP.impute,PCA.total=PCA.total,GAPIT.Version=GAPIT.Version,
                        GT=GT, SNP.fraction = SNP.fraction, seed = seed, BINS = BINS,SNP.test=SNP.test,DPP=DPP, SNP.permutation=SNP.permutation,
                        LD.chromosome=LD.chromosome,LD.location=LD.location,LD.range=LD.range,SNP.CV=SNP.CV,SNP.robust=SNP.robust,
                        genoFormat=genoFormat,hasGenotype=hasGenotype,byFile=byFile,fullGD=fullGD,PC=PC,GI=GI,Timmer = Timmer, Memory = Memory,
                        sangwich.top=sangwich.top,sangwich.bottom=sangwich.bottom,QC=QC,GTindex=GTindex,LD=LD,file.output=file.output,cutOff=cutOff, Model.selection = Model.selection)
}# end of loop on trait

if(ncol(Y>2) &file.output)
{
Timmer=gapitMain$Timmer
Memory=gapitMain$Memory

file=paste("GAPIT.", "All",".Timming.csv" ,sep = "")
write.table(Timmer, file, quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)

file=paste("GAPIT.", "All",".Memory.Stage.csv" ,sep = "")
write.table(Memory, file, quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)
}

if(ncol(Y)==2) {
h2= as.matrix(as.numeric(as.vector(gapitMain$Compression[,5]))/(as.numeric(as.vector(gapitMain$Compression[,5]))+as.numeric(as.vector(gapitMain$Compression[,6]))),length(gapitMain$Compression[,6]),1)
colnames(h2)=c("Heritability")
  print("GAPIT accomplished successfully for single trait. Results are saved. GWAS and GPS are returned!")
  return (list(GWAS=gapitMain$GWAS,GPS=gapitMain$GPS,compression=as.data.frame(cbind(gapitMain$Compression,h2)), kinship.optimum=gapitMain$kinship.optimum,kinship=gapitMain$kinship,PCA=gapitMain$PC))
}else{
  print("GAPIT accomplished successfully for multiple traits. Results are saved")
  return (list(GWAS=NULL,GPS=NULL,compression=NULL,kinship.optimum=NULL,kinship=gapitMain$KI,PCA=gapitMain$PC))
}

}# end ofdetecting null Y

}  #end of GAPIT function


##############################################################################################
GAPIT.Main <- function(Y,G=NULL,GD=NULL,GM=NULL,KI=NULL,Z=NULL,CV=NULL,SNP.P3D=TRUE,GP=NULL,GK=NULL,
                group.from=1000000 ,group.to=1,group.by=10,kinship.cluster="average", kinship.group='Mean',kinship.algorithm=NULL,DPP=50000,
               	ngrid = 100, llin = -10, ulim = 10, esp = 1e-10,
                file.path=NULL,file.from=NULL, file.to=NULL, file.total=NULL, file.fragment = 512, file.G=NULL, file.Ext.G=NULL,file.GD=NULL, file.GM=NULL, file.Ext.GD=NULL,file.Ext.GM=NULL,
                SNP.MAF=0,FDR.Rate=1,SNP.FDR=1,SNP.effect="Add",SNP.impute="Middle",PCA.total=0,  GAPIT.Version=GAPIT.Version,
                name.of.trait, GT = NULL, SNP.fraction = 1, seed = 123, BINS = 20,SNP.test=TRUE,SNP.robust="FaST",
                LD.chromosome=NULL,LD.location=NULL,LD.range=NULL,
                bin.from=10000,bin.to=5000000,bin.by=1000,inclosure.from=10,inclosure.to=1000,inclosure.by=10,
                SNP.permutation=FALSE,SNP.CV=NULL,
                genoFormat=NULL,hasGenotype=NULL,byFile=NULL,fullGD=NULL,PC=NULL,GI=NULL, Timmer = NULL, Memory = NULL,
                sangwich.top=NULL,sangwich.bottom=NULL,QC=TRUE,GTindex=NULL,LD=0.05,
                file.output=TRUE,cutOff=0.01, Model.selection = FALSE){
#Object: To perform GWAS and GPS (Genomic Prediction/Selection)
#Output: GWAS table (text file), QQ plot (PDF), Manhattan plot (PDF), genomic prediction (text file), and
#        genetic and residual variance components
#Authors: Zhiwu Zhang
# Last update: may 12, 2011
##############################################################################################

#Return imediatly in one of these situtiona
shortcut=FALSE
#In case of null Y and null GP, return genotype only
thisY=Y[,2]
thisY=thisY[!is.na(thisY)]
if(length(thisY) <3){
 shortcut=TRUE
 }else{
  if(var(thisY) ==0) shortcut=TRUE
}

if(shortcut){
print(paste("Y is empty. No GWAS/GS performed for ",name.of.trait,sep=""))
return (list(compression=NULL,kinship.optimum=NULL, kinship=KI,PC=PC,GWAS=NULL, GPS=NULL,REMLs=NULL,Timmer=Timmer,Memory=Memory))
}

#QC
print("------------Examing data (QC)------------------------------------------")
if(is.null(Y)) stop ("GAPIT says: Phenotype must exist.")
if(is.null(KI)&missing(GD) & kinship.algorithm!="SUPER") stop ("GAPIT says: Kinship is required. As genotype is not provided, kinship can not be created.")

#When GT and GD are missing, force to have fake ones (creating them from Y),GI is not required in this case
if(is.null(GD) & is.null(GT)) {
	GT=as.matrix(Y[,1])
	GD=matrix(1,nrow(Y),1)
  GI=as.data.frame(matrix(0,1,3) )
  colnames(GI)=c("SNP","Chromosome","Position")
}

#merge CV with PC
if(PCA.total>0&!is.null(CV))CV=GAPIT.CVMergePC(CV,PC)
if(PCA.total>0&is.null(CV))CV=PC

#Create Z as identity matrix from Y if it is not provided
if(kinship.algorithm!="SUPER" & is.null(Z)){
taxa=as.character(Y[,1])
Z=as.data.frame(diag(1,nrow(Y)))
Z=rbind(taxa,Z)
taxa=c('Taxa',as.character(taxa))
Z=cbind(taxa,Z)
}

#Add the part of non proportion in Z matrix
if(kinship.algorithm!="SUPER" & !is.null(Z))
{
  if(nrow(Z)-1<nrow(Y)) Z=GAPIT.ZmatrixFormation(Z=Z,Y=Y)
}

#Create CV with all 1's if it is not provided
if(is.null(CV)){
CV=Y[,1:2]
CV[,2]=1
colnames(CV)=c("taxa","overall")
}

#Remove duplicat and integragation of data
print("QC is in process...")

if(QC)
{
  qc <- GAPIT.QC(Y=Y,KI=KI, GT=GT,CV=CV,Z=Z,GK=GK)
  GTindex=qc$GTindex
  Y=qc$Y
  KI=qc$KI
  CV=qc$CV
  Z=qc$Z
  GK=qc$GK
}

rm(qc)
gc()

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="QC")
Memory=GAPIT.Memory(Memory=Memory,Infor="QC")


byPass.top=FALSE
byPass=FALSE
#if(!is.null(sangwich.bottom)) byPass=((sangwich.bottom=="FaST" | sangwich.bottom=="SUPER" | sangwich.bottom=="DC" )& is.null(GP)   )
if(!is.null(sangwich.top)) byPass.top=((sangwich.top=="FaST" | sangwich.top=="SUPER" | sangwich.top=="DC" )                 )
if(!is.null(sangwich.bottom)) byPass=((sangwich.bottom=="FaST" | sangwich.bottom=="SUPER" | sangwich.bottom=="DC" )                 )

print("Try to group from and to were set to 1")

if(byPass){
print("group from and to were set to 1")
  group.from=1
  group.to=1
}

print("------------Examing data (QC) done-------------------------------------")

#Sagnwich topp bun: To gep GP if it is not provided
if(!is.null(sangwich.top) & is.null(GP))
{
print("-------------------Sandwich top bun-----------------------------------")

  if(is.null(GK)){
    set.seed(1)
    nY=floor(nrow(Y)*.9)
    nG=ncol(GD)
    if(nG>nY){snpsam=sample(1:nG,nY)}else{snpsam=1:nG}
    GK=GD[GTindex,snpsam]
    SNPVar=apply(as.matrix(GK),2,var)
    GK=GK[,SNPVar>0]
    GK=cbind(as.data.frame(GT[GTindex]),as.data.frame(GK)) #add taxa

  }

  #myGD=cbind(as.data.frame(GT),as.data.frame(GD))
  GP=GAPIT.Bread(Y=Y,CV=CV,Z=Z,KI=KI,GK=GK,GD=cbind(as.data.frame(GT),as.data.frame(GD)),GM=GI,method=sangwich.top,GTindex=GTindex,LD=LD)$GWAS
  GK=NULL

print("-------------------Sandwich topp bun: done-----------------------------")

}

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="SagnwichTop")
Memory=GAPIT.Memory(Memory=Memory,Infor="SagnwichTop")

#Sagnwich burger and dressing
print("-------------------Sandwich burger and dressing------------------------")

#Hanler of group boundry
if(group.from>group.to) stop("GAPIT says: group.to should  be larger than group.from. Please correct them!")

if(is.null(CV) | (!is.null(CV)& group.to<ncol(CV))) {
#The minimum of group is number of columns in CV
  group.from=1
  group.to=1
  warning("The upper bound of groups (group.to) is not sufficient. both boundries were set to a and GLM is performed!")
}

if(!is.null(CV)& group.from<1) {
  group.from=1 #minimum of group is number of columns in CV
  warning("The lower bound of groups should be 1 at least. It was set to 1!")
}

if(!is.null(KI))
{
  if(group.to>nrow(KI)) {
    #group.to=min(nrow(KI),length(GTindex)) #maximum of group is number of rows in KI
    group.to=min(nrow(KI) ) #maximum of group is number of rows in KI
    warning("The upper bound of groups is too high. It was set to the size of kinship!")
  }
	if(group.from>nrow(KI)){
    group.from=nrow(KI)
    warning("The lower bound of groups is too high. It was set to the size of kinship!")
  }
}

#bin.fold=ceiling(log2(bin.to/bin.from))
#bin.seq=0:bin.fold
#bin.level=bin.from*2^bin.seq

#Set upper bound for inclosure.to
if(inclosure.to>nrow(Y))inclosure.to=nrow(Y)-1

#set inclosure loop levels
bin.level=seq(bin.from,bin.to,by=bin.by)
inclosure=seq(inclosure.from,inclosure.to,by=inclosure.by)

#Optimization for group number, cluster algorithm and kinship type
GROUP=seq(group.to,group.from,by=-group.by)#The reverse order is to make sure to include full model
if(missing("kinship.cluster")) kinship.cluster=c("ward", "single", "complete", "average", "mcquitty", "median", "centroid")
if(missing("kinship.group")) kinship.group=c("Mean", "Max", "Min", "Median")
numSetting=length(GROUP)*length(kinship.cluster)*length(kinship.group)*length(bin.level)*length(inclosure)

#Reform Y, GD and CV into EMMA format
ys=as.matrix(Y[2])
X0=as.matrix(CV[,-1])

#Initial
count=0
Compression=matrix(,numSetting,6)
colnames(Compression)=c("Type","Cluster","Group","REML","VA","VE")

#add indicator of overall mean
if(min(X0[,1])!=max(X0[,1])) X0 <- cbind(1, X0) #do not add overall mean if X0 has it already at first column


Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="DataProcessing")
Memory=GAPIT.Memory(Memory=Memory,Infor="DataProcessing")

print("-------------------------Iterstion in process--------------------------")
print(paste("Total iterations: ",numSetting,sep=""))

#Loop to optimize cluster algorithm, group number and kinship type
for (bin in bin.level){
for (inc in inclosure){

#Grill: update KI if GK or GP is provided
if(!byPass & (!is.null(GK) | !is.null(GP)))
{
  print("Grilling KI...")

    myGenotype<-GAPIT.Genotype(G=NULL,GD=cbind(as.data.frame(GT),as.data.frame(GD)),GM=GI,KI=NULL,kinship.algorithm=kinship.algorithm,PCA.total=0,SNP.fraction=SNP.fraction,SNP.test=SNP.test,
                  file.path=file.path,file.from=file.from, file.to=file.to, file.total=file.total, file.fragment = file.fragment, file.G=file.G,
                  file.Ext.G=file.Ext.G,file.GD=file.GD, file.GM=file.GM, file.Ext.GD=file.Ext.GD,file.Ext.GM=file.Ext.GM,
                  SNP.MAF=SNP.MAF,FDR.Rate = FDR.Rate,SNP.FDR=SNP.FDR,SNP.effect=SNP.effect,SNP.impute=SNP.impute,
                  LD.chromosome=LD.chromosome,LD.location=LD.location,LD.range=LD.range,
                  GP=GP,GK=GK,bin.size=bin,inclosure.size=inc,SNP.CV=SNP.CV,
                  Timmer = Timmer, Memory = Memory,GTindex=GTindex,sangwich.top=NULL,sangwich.bottom=sangwich.bottom,
                  file.output=file.output)

  Timmer=myGenotype$Timmer
  Memory=myGenotype$Memory

  KI=myGenotype$KI
}

for (ca in kinship.cluster){
for (group in GROUP){
for (kt in kinship.group){

#Do not screen SNP unless existing genotype and one combination
if(numSetting==1 & hasGenotype){
 optOnly=FALSE
}else{
optOnly=TRUE
}
if(!SNP.test) optOnly=TRUE
#Model.selection = TRUE
if(optOnly | Model.selection){
  colInclude=1
  optOnly = TRUE
  
}else{
 colInclude=c(1:ncol(GD))
}

if(!optOnly) print("Compressing and Genome screening..." )
count=count+1

#Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 1")
#Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 1")

if(!byPass)
{
if(count==1)print("-------Mixed model with Kinship-----------------------------")
if(group<ncol(X0)+1) group=1 # the emma function (emma.delta.REML.dLL.w.Z) does not allow K has dim less then CV. turn to GLM (group=1)

#print("Compressing...")
cp <- GAPIT.Compress(KI=KI,kinship.cluster=ca,kinship.group=kt,GN=group,Timmer=Timmer,Memory=Memory)
Timmer=cp$Timmer
Memory=cp$Memory

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_cp")
Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2_cp")

#print("BK...")
bk <- GAPIT.Block(Z=Z,GA=cp$GA,KG=cp$KG)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_bk")
Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2 bk")

#print("ZC...")
zc <- GAPIT.ZmatrixCompress(Z=Z,GAU =bk$GA)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_zc")
Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2 zc")

#print("wraping...")
#Reform KW and Z into EMMA format

zrow=nrow(zc$Z)
zcol=ncol(zc$Z)-1
#Z1=matrix(as.numeric(as.matrix(zc$Z[,-1])),nrow=zrow,ncol=zcol)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Prio PreP3D")
Memory=GAPIT.Memory(Memory=Memory,Infor="Prio PreP3D")

#Evaluating maximum likelohood
#print("Calling EMMAxP3D...")

#print("It made it to here")
print("The dimension of xs is:")
print(dim(as.data.frame(GD[GTindex,colInclude])))
 
 print("The head of X0 just before going into GAPIT.EMMAxP3D is ")
 print(head(X0))

  
p3d <- GAPIT.EMMAxP3D(ys=ys,xs=as.matrix(as.data.frame(GD[GTindex,colInclude])),K = as.matrix(bk$KW) ,Z=matrix(as.numeric(as.matrix(zc$Z[,-1])),nrow=zrow,ncol=zcol),X0=X0,GI=GI,SNP.P3D=SNP.P3D,Timmer=Timmer,Memory=Memory,fullGD=fullGD,
        SNP.permutation=SNP.permutation, GP=GP,
			 file.path=file.path,file.from=file.from,file.to=file.to,file.total=file.total, file.fragment = file.fragment, byFile=byFile, file.G=file.G,file.Ext.G=file.Ext.G,file.GD=file.GD, file.GM=file.GM, file.Ext.GD=file.Ext.GD,file.Ext.GM=file.Ext.GM,
       GTindex=GTindex,genoFormat=genoFormat,optOnly=optOnly,SNP.effect=SNP.effect,SNP.impute=SNP.impute,name.of.trait=name.of.trait)

print("GAPIT.EMMAx.P3D finished")  
 
  
    
Timmer=p3d$Timmer
Memory=p3d$Memory

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Post PreP3D")
Memory=GAPIT.Memory(Memory=Memory,Infor="Post PreP3D")

#print("Cluster algorithm, kinship type, groups, VG, Ve and REML:")
print(paste(count, "of",numSetting,"--","Vg=",round(p3d$vgs,4), "VE=",round(p3d$ves,4),"-2LL=",round(p3d$REMLs,2), "  Clustering=",ca,"  Group number=", group ,"  Group kinship=",kt,sep = " "))

#Recoding the optimum KI
if(count==1){
  KI.save=KI
  LL.save=p3d$REMLs
}else{
  if(p3d$REMLs<LL.save){
    KI.save=KI
    LL.save=p3d$REMLs
  }
}

#print(paste("CA is ",ca))
#print(paste("group is ",group))
#print(paste("kt is ",kt))

#recording Compression profile on array
Compression[count,1]=kt
Compression[count,2]=ca
Compression[count,3]=group
Compression[count,4]=p3d$REMLs
Compression[count,5]=p3d$vgs
Compression[count,6]=p3d$ves
#print("result saved")

}else{# end of if(!byPass)

#Set QTNs
if(count==1)print("-------The burger is SNP-----------------------------------")
  #bin.size=bin
  #inclosure.size=inc

#@@@This section is not useful
if(!is.null(GP))
{

  #print("Being specific...")

  myGenotype<-GAPIT.Genotype(G=NULL,GD=NULL,GM=GI,KI=NULL,kinship.algorithm="SUPER",PCA.total=0,SNP.fraction=SNP.fraction,SNP.test=SNP.test,
                    file.path=file.path,file.from=file.from, file.to=file.to, file.total=file.total, file.fragment = file.fragment, file.G=file.G,
                    file.Ext.G=file.Ext.G,file.GD=file.GD, file.GM=file.GM, file.Ext.GD=file.Ext.GD,file.Ext.GM=file.Ext.GM,
                    SNP.MAF=SNP.MAF,FDR.Rate = FDR.Rate,SNP.FDR=SNP.FDR,SNP.effect=SNP.effect,SNP.impute=SNP.impute,
                    LD.chromosome=LD.chromosome,LD.location=LD.location,LD.range=LD.range,
                    GP=GP,GK=NULL,bin.size=bin,inclosure.size=inc,SNP.CV=SNP.CV,GTindex=GTindex,sangwich.top=NULL,sangwich.bottom=sangwich.bottom,
                    Timmer = Timmer, Memory = Memory,file.output=file.output)

  Timmer=myGenotype$Timmer
  Memory=myGenotype$Memory

  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Genotype for burger")
  Memory=GAPIT.Memory(Memory=Memory,Infor="Genotype for burger")

  #print("Extracting QTNs...")
  #SNP.QTN=myGenotype$SNP.QTN
  #QTN=GD[,SNP.QTN]
  #colnames(QTN)=myGenotype$GI[SNP.QTN,1]
  #QTN=cbind(myGenotype$GT,QTN)   #add taxa
  #colnames(QTN)[1]="taxa"
  GK=GD[GTindex,myGenotype$SNP.QTN]
  SNPVar=apply(as.matrix(GK),2,var)
  GK=GK[,SNPVar>0]
  GK=cbind(as.data.frame(GT[GTindex]),as.data.frame(GK)) #add taxa


  #GP=NULL
}# end of if(is.null(GK))


if(!is.null(GK) & numSetting>1)
{
print("-------Calculating likelihood-----------------------------------")
  myBurger=GAPIT.Burger(Y=Y,CV=CV,GK=GK)
  myREML=myBurger$REMLs
  myVG=myBurger$vg
  myVE=myBurger$ve
}else{
  myREML=NA
  myVG=NA
  myVE=NA
}

#Recoding the optimum GK
if(count==1){
  GK.save=GK
  LL.save=myREML
}else{
  if(myREML<LL.save){
    GK.save=GK
    LL.save=myREML
  }
}

#Put to storage
Compression[count,1]=1
Compression[count,2]=bin
Compression[count,3]=inc
Compression[count,4]=myREML
Compression[count,5]=myVG
Compression[count,6]=myVG
print(Compression[count,])

#print("---------------SUPER 2nd stage: calculating LL ------------------------")



}   # end of if(byPass)

}#end of for (ca in kinship.cluster)

#Skip the rest group in case group 1 is finished
if(group==1) break #To skip the rest group interations

}#end of for (group in GROUP)
}#end of for (kt in kinship.group)

}#end of for (inc in inclosure)
}#end of for (bin in bin.level)

#if(optOnly | Model.selection){
#}


if(Model.selection == TRUE){ 

  print("------------------------Model selection for optimal number of PCs and Covariates-------------------------------------------------")
  #update KI with the best likelihood
  KI=KI.save
  if(numSetting>1){
  Compression=Compression[order(as.numeric(Compression[,4]),decreasing = FALSE),]  #sort on REML
  kt=Compression[1,1]
  ca=Compression[1,2]
  group=Compression[1,3]
  }

  cp <- GAPIT.Compress(KI=KI,kinship.cluster=ca,kinship.group=kt,GN=group,Timmer=Timmer,Memory=Memory)
  Timmer=cp$Timmer
  Memory=cp$Memory

  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_cp")
  Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2_cp")

  bk <- GAPIT.Block(Z=Z,GA=cp$GA,KG=cp$KG)
  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_bk")
  Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2 bk")

  zc <- GAPIT.ZmatrixCompress(Z=Z,GAU =bk$GA)

  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_zc")
  Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2 zc")

  z0=as.matrix(zc$Z[,-1])
  Z1=matrix(as.numeric(z0),nrow=nrow(z0),ncol=ncol(z0))


  
  BIC <- rep(NA,ncol(X0))
  LogLike <- rep(NA, ncol(X0))
  for(i in 1:ncol(X0)){#1 because the first column of X0 is the intercept

    X0.test <- as.matrix(X0[,1:i]) 
    
    #print("The dim of bk$KW is ")
    #print(dim(bk$KW))
    

    p3d <- GAPIT.EMMAxP3D(ys=ys,xs=as.matrix(as.data.frame(GD[,1])),K = as.matrix(bk$KW) ,Z=Z1,X0=X0.test,GI=GI,SNP.P3D=SNP.P3D,Timmer=Timmer,Memory=Memory,fullGD=fullGD,
            SNP.permutation=SNP.permutation, GP=GP,
			      file.path=file.path,file.from=file.from,file.to=file.to,file.total=file.total, file.fragment = file.fragment, byFile=byFile, file.G=file.G,file.Ext.G=file.Ext.G,file.GD=file.GD, file.GM=file.GM, file.Ext.GD=file.Ext.GD,file.Ext.GM=file.Ext.GM,
            GTindex=GTindex,genoFormat=genoFormat,optOnly=TRUE,SNP.effect=SNP.effect,SNP.impute=SNP.impute,name.of.trait=name.of.trait)

    
    
    k.num.param <- 2+i
    #k is (i-1) because we have the following parameters in the likelihood function:
    #  intercept
    #  (i-1) covariates
    #  sigma_g
    #  delta
    
    print(paste("The value of round(p3d$REMLs,5) is ", round(p3d$REMLs,5), sep = ""))
    #print(paste("The value of log(GTindex) is ", log(GTindex), sep = ""))
    #print(paste("The value of 0.5*k.num.param*log(GTindex) is ", 0.5*k.num.param*log(nrow(Z1)), sep = ""))
    
    LogLike[i] <- p3d$logLM
    BIC[i] <- p3d$logLM -(0.5*k.num.param*log(nrow(Z1)))
    
    #print("The value of k.num.param  is: ")
    #print(k.num.param)
    
    #print(paste("The value of nrow(Z1) is ", nrow(Z1), sep = ""))  
    
    }   
    Optimum.from.BIC <- which(BIC == max(BIC))
    
    print(paste("The optimal number of PCs/covariates is ", (Optimum.from.BIC-1), sep = ""))
    
    BIC.Vector <- cbind(as.matrix(rep(0:(ncol(X0)-1))), as.matrix(BIC), as.matrix(LogLike))

           
    #print(seq(0:ncol(X0)))
    
       #print(BIC.Vector)
 
    colnames(BIC.Vector) <- c("Number of PCs/Covariates", "BIC (larger is better)", "log Likelihood Function Value")
    
    write.table(BIC.Vector, paste("GAPIT.", name.of.trait, ".BIC.Model.Selection.Results.csv", sep = ""), quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)
    
    #print(BIC.Vector)
    
    X0 <- X0[,1:(Optimum.from.BIC)]
    
    if(Optimum.from.BIC == 1){
    X0 <- as.matrix(X0)
    }
    print("The dimension of X0 after model selection is:")
    print(dim(X0))
    
    print("The head of X0 after model selection is")
    print(head(X0))
    

}

print("---------------------Sandwich bottom bun-------------------------------")
print("Compression")
print(Compression)

#Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Compression")
#Memory=GAPIT.Memory(Memory=Memory,Infor="Copmression")

if(numSetting==1)
{
  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="GWAS")
  Memory=GAPIT.Memory(Memory=Memory,Infor="GWAS")
}

#Perform GWAS with the optimum setting
#This section is omited if there is only one setting
if((numSetting>1) | Model.selection) {
  print("Genomic screening..." )

optOnly=FALSE  #set default to false and change it to TRUE in these situations:
if(!hasGenotype) optOnly=TRUE
if(!SNP.test) optOnly=TRUE

if(optOnly){
 colInclude=1
}else{
 colInclude=c(1:ncol(GD))
}

#Find the best ca,kt and group
if(numSetting>1){
Compression=Compression[order(as.numeric(Compression[,4]),decreasing = FALSE),]  #sort on REML
kt=Compression[1,1]
ca=Compression[1,2]
group=Compression[1,3]

print(paste("Optimum: ",Compression[1,2],Compression[1,1],Compression[1,3],Compression[1,5], Compression[1,6],Compression[1,4] ,sep = " "))
} #end  if(numSetting>1)
print("--------------  Sandwich bottom ------------------------")

if(!byPass)
{
print("--------------  Sandwich bottom with raw burger------------------------")

 if(Model.selection == FALSE){
  #update KI with the best likelihood
  KI=KI.save

  cp <- GAPIT.Compress(KI=KI,kinship.cluster=ca,kinship.group=kt,GN=group,Timmer=Timmer,Memory=Memory)
  Timmer=cp$Timmer
  Memory=cp$Memory

  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_cp")
  Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2_cp")

  bk <- GAPIT.Block(Z=Z,GA=cp$GA,KG=cp$KG)
  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_bk")
  Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2 bk")

  zc <- GAPIT.ZmatrixCompress(Z=Z,GAU =bk$GA)

  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PreP3D 2_zc")
  Memory=GAPIT.Memory(Memory=Memory,Infor="PreP3D 2 zc")

  #Reform KW and Z into EMMA format

  z0=as.matrix(zc$Z[,-1])
  Z1=matrix(as.numeric(z0),nrow=nrow(z0),ncol=ncol(z0))
   }
 
 print("The head of X0 just before going into GAPIT.EMMAxP3D is ")
 head(X0)
 
 print("--------------EMMAxP3D with the optimum setting-----------------------")
  p3d <- GAPIT.EMMAxP3D(ys=ys,xs=as.matrix(as.data.frame(GD[GTindex,colInclude]))   ,K = as.matrix(bk$KW) ,Z=Z1,X0=as.matrix(X0),GI=GI,SNP.P3D=SNP.P3D,Timmer=Timmer,Memory=Memory,fullGD=fullGD,
          SNP.permutation=SNP.permutation, GP=GP,
    			 file.path=file.path,file.from=file.from,file.to=file.to,file.total=file.total, file.fragment = file.fragment, byFile=byFile, file.G=file.G,file.Ext.G=file.Ext.G,file.GD=file.GD, file.GM=file.GM, file.Ext.GD=file.Ext.GD,file.Ext.GM=file.Ext.GM,
           GTindex=GTindex,genoFormat=genoFormat,optOnly=optOnly,SNP.effect=SNP.effect,SNP.impute=SNP.impute,name.of.trait=name.of.trait)




  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="GWAS")
  Memory=GAPIT.Memory(Memory=Memory,Infor="GWAS")
 print("--------------EMMAxP3D with the optimum setting done------------------")

}#end of if(!byPass)
}#end of if(numSetting>1 & hasGenotype & !SNP.test)

#print("Screening wiht the optimum setting done")

if(byPass)
{
print("---------------Sandwich bottom with grilled burger---------------------")
print("---------------Sandwich bottom: reload bins ---------------------------")

#SUPER: Final screening
  GK=GK.save
  myBread=GAPIT.Bread(Y=Y,CV=CV,Z=Z,GK=GK,GD=cbind(as.data.frame(GT),as.data.frame(GD)),GM=GI,method=sangwich.bottom,GTindex=GTindex,LD=LD)

  print("SUPER saving results...")

  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="GWAS")
  Memory=GAPIT.Memory(Memory=Memory,Infor="GWAS")


}   #end of if(byPass)

print("--------------------Final results presentations------------------------")



#Plotting optimum group kinship
if(!byPass)
{
if(length(bk$KW)>1 &length(bk$KW)<length(KI) & length(bk$KW)<1000 &file.output){
pdf(paste("GAPIT.",name.of.trait,".Kin.Optimum.pdf",sep=""), width = 12, height = 12)
par(mar = c(25,25,25,25))
heatmap.2(as.matrix(bk$KW),  cexRow =.2, cexCol = 0.2, col=rev(heat.colors(256)), scale="none", symkey=FALSE, trace="none")
dev.off()
}
}


#Merge GWAS resultss from files to update ps,maf and nobs in p3d
if(byFile&!fullGD)
{
print("Loading GWAS results from file...")
for (file in file.from:file.to)
{

#Initicalization
frag=1
numSNP=file.fragment

while(numSNP==file.fragment) {     #this is problematic if the read end at the last line

#Initicalization GI to detect reading empty line
#theGI=NULL
#theP=NULL
#theMAF=NULL
#thenobs=NULL

#reload results from files
print(paste("Current file ",file,"Fragment: ",frag))

theGI <- try(read.table(paste("GAPIT.TMP.GI.",name.of.trait,file,".",frag,".txt",sep=""), head = TRUE)   ,silent=TRUE)
theP <- try(read.table(paste("GAPIT.TMP.ps.",name.of.trait,file,".",frag,".txt",sep=""), head = FALSE)   ,silent=TRUE)
theMAF <- try(read.table(paste("GAPIT.TMP.maf.",name.of.trait,file,".",frag,".txt",sep=""), head = FALSE),silent=TRUE)
thenobs <- try(read.table(paste("GAPIT.TMP.nobs.",name.of.trait,file,".",frag,".txt",sep=""),head= FALSE),silent=TRUE)
thersquare_base <- try(read.table(paste("GAPIT.TMP.rsquare.base.",name.of.trait,file,".",frag,".txt",sep=""),head= FALSE),silent=TRUE)
thersquare <- try(read.table(paste("GAPIT.TMP.rsquare.",name.of.trait,file,".",frag,".txt",sep=""),head= FALSE),silent=TRUE)


if(inherits(theGI, "try-error"))  {
#if(nrow(theGI)<1){
  numSNP=0
  #print("This fragment is empty.")
}else{

#print("Records loaded for this fragment.")
  numSNP=nrow(theGI)
  colnames(theP)="P"
  colnames(theMAF )="MAF"
  colnames(thenobs )="nobs"
  colnames(thersquare_base) = "Base.Model.R.square"  
  colnames(thersquare) = "Model.R.square"
  colnames(theGI) = colnames(GI)

#Merge results
  if(file==file.from & frag==1){
    GI=theGI
    allP=theP
    allMAF=theMAF
    allnobs=thenobs
    allrsquare_base=thersquare_base
    allrsquare=thersquare
  }else{
    allP=as.data.frame(rbind(as.matrix(allP),as.matrix(theP))  )
    allMAF=as.data.frame(rbind(as.matrix(allMAF),as.matrix(theMAF)) )
    allnobs=as.data.frame(rbind(as.matrix(allnobs),as.matrix(thenobs)))
    allrsquare_base=as.data.frame(rbind(as.matrix(allrsquare_base),as.matrix(thersquare_base)))
    allrsquare=as.data.frame(rbind(as.matrix(allrsquare),as.matrix(thersquare)))
    GI=as.data.frame(rbind(as.matrix(GI),as.matrix(theGI)))
  }

}#end of  if(inherits(theGI, "try-error")) (else section)

#setup for next fragment
frag=frag+1   #Progress to next fragment

}#end of loop on fragment: while(numSNP==file.fragment)
}#end of loop on file

#update p3d with components from files
  p3d$ps=allP
  p3d$maf=allMAF
  p3d$nobs=allnobs
  p3d$rsquare_base=allrsquare_base
  p3d$rsquare=allrsquare

#Delete all the GAPIT.TMP files
  system('cmd /c del "GAPIT.TMP*.*"')
  print("GWAS results loaded from all files succesfully!")
} #end of if(byFile)

#--------------------------------------------------------------------------------------------------------------------#
#Final report
print("Generating summary" )
GWAS=NULL
GPS=NULL
rm(zc)
gc()

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Final")
Memory=GAPIT.Memory(Memory=Memory,Infor="Final")

#genomic prediction
print("Genomic Breeding Values (GBV) ..." )

if(!byPass)
{
if(length(bk$KW)>ncol(as.matrix(X0))) {
    gs <- GAPIT.GS(KW=bk$KW,KO=bk$KO,KWO=bk$KWO,GAU=bk$GAU,UW=cbind(p3d$BLUP,p3d$PEV))
}

print("Writing GBV and Acc..." )

GPS=NULL
if(length(bk$KW)>ncol(as.matrix(X0))) GPS=gs$BLUP

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="GPS")
Memory=GAPIT.Memory(Memory=Memory,Infor="GPS")

#Make heatmap for distribution of BLUP and PEV
print("GBV and accuracy distribution..." )
if(length(bk$KW)>ncol(as.matrix(X0)) &file.output) {
  GAPIT.GS.Visualization(gsBLUP = gs$BLUP, BINS=BINS,name.of.trait = name.of.trait)
}

#Make a plot Summarzing the Compression Results, if more than one "compression level" has been assessed
print("Compression portfolios..." )
#print(Compression)
if(file.output) GAPIT.Compression.Visualization(Compression = Compression, name.of.trait = name.of.trait)
print("Compression Visualization done")

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Compression.Visualization")
Memory=GAPIT.Memory(Memory=Memory,Infor="Compression.Visualization")

ps=p3d$ps
nobs=p3d$nobs
maf=p3d$maf
rsquare_base=p3d$rsquare_base
rsquare=p3d$rsquare

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Extract p3d results")
Memory=GAPIT.Memory(Memory=Memory,Infor="Extract p3d results")

}else{
  GPS=myBread$BLUP
  ps=myBread$GWAS[,4]
  nobs=myBread$GWAS[,6]
  maf=myBread$GWAS[,4]*0+.5

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Extract bread results")
Memory=GAPIT.Memory(Memory=Memory,Infor="Extract bread results")


}
print("debug begining")
print(length(GI))
print(length(ps))
print(length(maf))
print(length(nobs))
print(length(rsquare_base))
print(length(rsquare))
print("debug end")


#Export BLUP and PEV
if(!byPass &file.output)
{
print("Exporting BLUP")
  try(write.table(gs$BLUP, paste("GAPIT.", name.of.trait,".BLUP.csv" ,sep = ""), quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE))
}

if(byPass)
{
  theK.return=NULL
}else{
  theK.return=cp$KG
}
if(byPass)Compression[1,4]=0 #create a fake value to aloow output of SUPER


print("debug begining 1")
print((hasGenotype))
print((Compression[1,4]))

print("debug end1")

#Export GWAS results
if(hasGenotype &SNP.test &!is.na(Compression[1,4]))     #require not NA REML
{
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Extract GWAS start")
Memory=GAPIT.Memory(Memory=Memory,Infor="Extract GWAS start")


  print("Filtering SNPs with MAF..." )
	index=maf>=SNP.MAF
	PWI.Filtered=cbind(GI,ps,maf,nobs,rsquare_base,rsquare)[index,]
	colnames(PWI.Filtered)=c("SNP","Chromosome","Position ","P.value", "maf", "nobs", "Rsquare.of.Model.without.SNP","Rsquare.of.Model.with.SNP")

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="MAF filtered")
Memory=GAPIT.Memory(Memory=Memory,Infor="MAF filtered")

  print("SNPs filtered with MAF")

  if(!is.null(PWI.Filtered))
  {

  #Run the BH multiple correction procedure of the results
  #Create PWIP, which is a table of SNP Names, Chromosome, bp Position, Raw P-values, FDR Adjusted P-values
  print("Calculating FDR..." )
  PWIP <- GAPIT.Perform.BH.FDR.Multiple.Correction.Procedure(PWI = PWI.Filtered, FDR.Rate = FDR.Rate, FDR.Procedure = "BH")

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Multiple Correction")
Memory=GAPIT.Memory(Memory=Memory,Infor="Multiple Correction")



#PWIP$PWIP <- PWIP$PWIP[-which(is.na(PWIP$PWIP[,4])),]
  
  #QQ plots
  print("QQ plot..." )
  if(file.output) GAPIT.QQ(P.values = PWIP$PWIP[,4], name.of.trait = name.of.trait,DPP=DPP)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="QQ plot")
Memory=GAPIT.Memory(Memory=Memory,Infor="QQ plot")


  #Manhattan Plots
   print("Manhattan plot (Genomewise)..." )
  if(file.output) GAPIT.Manhattan(GI.MP = PWIP$PWIP[,2:4], name.of.trait = name.of.trait, DPP=DPP, plot.type = "Genomewise",cutOff=cutOff)
 print("Manhattan plot (Chromosomewise)..." )
  if(file.output) GAPIT.Manhattan(GI.MP = PWIP$PWIP[,2:4], name.of.trait = name.of.trait, DPP=DPP, plot.type = "Chromosomewise",cutOff=cutOff)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Manhattan plot")
Memory=GAPIT.Memory(Memory=Memory,Infor="Manhattan plot")


  #Association Table
  print("Association table..." )
  #GAPIT.Table(final.table = PWIP$PWIP, name.of.trait = name.of.trait,SNP.FDR=SNP.FDR)
  GWAS=PWIP$PWIP[PWIP$PWIP[,9]<=SNP.FDR,]

print("debug begining 2")
print(dim(GWAS))
print("debug end 2")



  if(file.output) write.table(GWAS, paste("GAPIT.", name.of.trait, ".GWAS.Results.csv", sep = ""), quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)




  } #end of if(!is.null(PWI.Filtered))
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Extract GWAS end")
Memory=GAPIT.Memory(Memory=Memory,Infor="Extract GWAS end")


} #end of if(hasGenotype )

#Log
if(file.output) log=GAPIT.Log(Y=Y,KI=KI,Z=Z,CV=CV,SNP.P3D=SNP.P3D,
				group.from = group.from ,group.to =group.to ,group.by = group.by ,kinship.cluster = kinship.cluster, kinship.group= kinship.group,
                      	ngrid = ngrid , llin = llin , ulim = ulim , esp = esp ,name.of.trait = name.of.trait)
#Memory usage
#GAPIT.Memory.Object(name.of.trait=name.of.trait)

#Timming
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Report")
Memory=GAPIT.Memory(Memory=Memory,Infor="Report")
if(file.output){
file=paste("GAPIT.", name.of.trait,".Timming.csv" ,sep = "")
write.table(Timmer, file, quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)

file=paste("GAPIT.", name.of.trait,".Memory.Stage.csv" ,sep = "")
write.table(Memory, file, quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)
}
print(paste(name.of.trait, "has been analyzed successfully!") )
print(paste("The results are saved in the directory of ", getwd()) )
print("==========================================================================================")

return (list(Timmer=Timmer,Compression=Compression,kinship.optimum=theK.return, kinship=KI,PC=PC,GWAS=GWAS, GPS=GPS,REMLs=Compression[count,4],Timmer=Timmer,Memory=Memory))

}#The function GAPIT.Main ends here


##############################################################################################
GAPIT.EMMAxP3D <- function(ys,xs,K=NULL,Z=NULL,X0=NULL,GI=NULL,GP=NULL,
		file.path=NULL,file.from=NULL,file.to=NULL,file.total=1, genoFormat="Hapmap", file.fragment=NULL,byFile=FALSE,fullGD=TRUE,SNP.fraction=1,
    file.G=NULL,file.Ext.G=NULL,GTindex=NULL,file.GD=NULL, file.GM=NULL, file.Ext.GD=NULL,file.Ext.GM=NULL,
    SNP.P3D=TRUE,Timmer,Memory,optOnly=TRUE,SNP.effect="Add",SNP.impute="Middle", SNP.permutation=FALSE,
    ngrids=100,llim=-10,ulim=10,esp=1e-10,name.of.trait=NULL   ){
#Object: To esimate variance component by using EMMA algorithm and perform GWAS with P3D/EMMAx
#Output: ps, REMLs, stats, dfs, vgs, ves, BLUP,  BLUP_Plus_Mean, PEV
#Authors: Feng Tian, Alex Lipka and Zhiwu Zhang
# Last update: April 26, 2011
# Library used: EMMA (Kang et al, Genetics, Vol. 178, 1709-1723, March 2008)
# Note: This function was modified from the function of emma.REML.t from the library
##############################################################################################

#print("EMMAxP3D started...")
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="P3D Start")
Memory=GAPIT.Memory(Memory=Memory,Infor="P3D Start")


#--------------------------------------------------------------------------------------------------------------------<
#Change data to matrix format if they are not
if(is.null(dim(ys)) || ncol(ys) == 1)  ys <- matrix(ys, 1, length(ys))
if(is.null(X0)) X0 <- matrix(1, ncol(ys), 1)

#handler of special Z and K
if(!is.null(Z)){ if(ncol(Z) == nrow(Z)) Z = NULL }
#if(!is.null(K)) {if(length(K)<2) K = NULL}
if(!is.null(K)) {if(length(K)<= 1) K = NULL}



#Extract dimension information
g <- nrow(ys) #number of traits
n <- ncol(ys) #number of observation

q0 <- ncol(X0)#number of fixed effects
q1 <- q0 + 1  #Nuber of fixed effect including SNP

nr=n
if(!is.null(K)) tv=ncol(K)

#decomposation without fixed effect
#print("Caling emma.eigen.L...")
if(!is.null(K)) eig.L <- emma.eigen.L(Z, K) #this function handle both NULL Z and non-NULL Z matrix

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="eig.L")
Memory=GAPIT.Memory(Memory=Memory,Infor="eig.L")

#print("debuge")
#print(labels(eig.L))
#print(dim((eig.L$values))
#printdim((eig.L$vectors))
#stop("sdgdfg")

      
#decomposation with fixed effect (SNP not included)
#print("Calling emma.eigen.R.w.Z...")
X <-  X0 #covariate variables such as population structure

if(!is.null(Z) & !is.null(K)) eig.R <- try(emma.eigen.R.w.Z(Z, K, X)) #This will be used to get REstricted ML (REML)
if(is.null(Z)  & !is.null(K)) eig.R <- try(emma.eigen.R.wo.Z(   K, X)) #This will be used to get REstricted ML (REML)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="eig.R")
Memory=GAPIT.Memory(Memory=Memory,Infor="eig.R")


 
#print("emma.eigen.R.w.Z called!!!")
#Handler of error in emma

if(!is.null(K)){
if(inherits(eig.R, "try-error"))
       return(list(ps = NULL, REMLs = NA, stats = NULL, dfs = NULL,maf=NULL,nobs = NULL,Timmer=Timmer,Memory=Memory,
        vgs = NA, ves = NA, BLUP = NULL, BLUP_Plus_Mean = NULL,
        PEV = NULL, BLUE=NULL, logLM = NULL))


 }
#-------------------------------------------------------------------------------------------------------------------->
#print("Looping through traits...")
#Loop on Traits
for (j in 1:g)
{


if(optOnly){

  #REMLE <- emma.REMLE(ys[j,], X, K, Z, ngrids, llim, ulim, esp, eig.R)
  #vgs <- REMLE$vg
  #ves <- REMLE$ve
  #REMLs <- REMLE$REML
  #REMLE_delta=REMLE$delta

 if(!is.null(K)){
  REMLE <- emma.REMLE(ys[j,], X, K, Z, ngrids, llim, ulim, esp, eig.R)

  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="REML")
  Memory=GAPIT.Memory(Memory=Memory,Infor="REML")

  rm(eig.R)
  gc()
  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="eig.R removed")
  Memory=GAPIT.Memory(Memory=Memory,Infor="eig.R removed")

  vgs <- REMLE$vg
  ves <- REMLE$ve
  REMLs <- REMLE$REML
  REMLE_delta=REMLE$delta

  rm(REMLE)
  gc()
  }


  vids <- !is.na(ys[j,])
  yv <- ys[j, vids]
  
  if(!is.null(Z) & !is.null(K))  U <- eig.L$vectors * matrix(c(sqrt(1/(eig.L$values + REMLE_delta)),rep(sqrt(1/REMLE_delta),nr - tv)),nr,((nr-tv)+length(eig.L$values)),byrow=TRUE)
  if( is.null(Z) & !is.null(K))  U <- eig.L$vectors * matrix(  sqrt(1/(eig.L$values + REMLE_delta)),nr,length(eig.L$values),byrow=TRUE)

  if( !is.null(Z) & !is.null(K)) eig.full.plus.delta <- as.matrix(c((eig.L$values + REMLE_delta), rep(REMLE_delta,(nr - tv))))
  if( is.null(Z) & !is.null(K))  eig.full.plus.delta <- as.matrix((eig.L$values + REMLE_delta))

  #Calculate the log likelihood function for the intercept only model

   X.int <- matrix(1,nrow(as.matrix(yv)),ncol(as.matrix(yv)))
   iX.intX.int <- solve(crossprod(X.int, X.int))
   iX.intY <- crossprod(X.int, as.matrix(as.matrix(yv)))
   beta.int <- crossprod(iX.intX.int, iX.intY)  #Note: we can use crossprod here becase iXX is symmetric
   X.int.beta.int <- X.int%*%beta.int


   logL0 <- 0.5*((-length(yv))*log(((2*pi)/length(yv))
                 *crossprod((yv-X.int.beta.int),(yv-X.int.beta.int)))
                  -length(yv))
                  
    #print(paste("The value of logL0 inside of the optonly template is is",logL0, sep = ""))              

                  
                                
  
  #print(paste("The value of nrow(as.matrix(ys[!is.na(ys)])) is ",nrow(as.matrix(ys[!is.na(ys)])), sep = ""))
  
  

     if(!is.null(K)){
      yt <- yt <- crossprod(U, yv)
      X0t <- crossprod(U, X0)

     X0X0 <- crossprod(X0t, X0t)
     X0Y <- crossprod(X0t,yt)
     XY <- X0Y
  
     iX0X0 <- try(solve(X0X0))
     if(inherits(iX0X0, "try-error")){
     iX0X0 <- ginv(X0X0)
     print("At least two of your covariates are linearly dependent. Please reconsider the covariates you are using for GWAS and GPS")
     }
    iXX <- iX0X0
    }

      if(is.null(K)){
       iXX <- solve(crossprod(X,X))
       XY = crossprod(X,yv)
      }
      beta <- crossprod(iXX,XY) #Note: we can use crossprod here becase iXX is symmetric
      
      X.beta <- X%*%beta
      
      if(!is.null(K)){
              U.times.yv.minus.X.beta <- crossprod(U,(yv-X.beta))
              logLM <- 0.5*(-length(yv)*log(((2*pi)/length(yv))*crossprod(U.times.yv.minus.X.beta,U.times.yv.minus.X.beta)) 
                    - sum(log(eig.full.plus.delta)) - length(yv))
      }


      if(is.null(K)){
              U.times.yv.minus.X.beta <- yv-X.beta
              logLM <- 0.5*(-length(yv)*log(((2*pi)/length(yv))*crossprod(U.times.yv.minus.X.beta,U.times.yv.minus.X.beta)) - length(yv))
      }




 }#End if(optOnly)

#--------------------------------------------------------------------------------------------------------------------<
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Trait")
Memory=GAPIT.Memory(Memory=Memory,Infor="Trait")

if(!is.null(K)){
  REMLE <- emma.REMLE(ys[j,], X, K, Z, ngrids, llim, ulim, esp, eig.R)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="REML")
Memory=GAPIT.Memory(Memory=Memory,Infor="REML")

rm(eig.R)
gc()
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="eig.R removed")
Memory=GAPIT.Memory(Memory=Memory,Infor="eig.R removed")

  vgs <- REMLE$vg
  ves <- REMLE$ve
  REMLs <- REMLE$REML
  REMLE_delta=REMLE$delta

rm(REMLE)
gc()
}
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="REMLE removed")
Memory=GAPIT.Memory(Memory=Memory,Infor="REMLE removed")

if(!is.null(Z) & !is.null(K))  U <- eig.L$vectors * matrix(c(sqrt(1/(eig.L$values + REMLE_delta)),rep(sqrt(1/REMLE_delta),nr - tv)),nr,((nr-tv)+length(eig.L$values)),byrow=TRUE)
if( is.null(Z) & !is.null(K))  U <- eig.L$vectors * matrix(  sqrt(1/(eig.L$values + REMLE_delta)),nr,length(eig.L$values),byrow=TRUE)

if( !is.null(Z) & !is.null(K)) eig.full.plus.delta <- as.matrix(c((eig.L$values + REMLE_delta), rep(REMLE_delta,(nr - tv))))
if( is.null(Z) & !is.null(K))  eig.full.plus.delta <- as.matrix((eig.L$values + REMLE_delta))


Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="U Matrix")
Memory=GAPIT.Memory(Memory=Memory,Infor="U Matrix")

#rm(eig.L) #We still need eig.L if P3D is implemented
gc()

#Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="eig.L removed")
#Memory=GAPIT.Memory(Memory=Memory,Infor="eig.L removed")

#-------------------------------------------------------------------------------------------------------------------->

#The cases that go though multiple file once
file.stop=file.to
if(optOnly) file.stop=file.from
if(fullGD)  file.stop=file.from
if(!fullGD & !optOnly) print("Screening SNPs from file...")

#Add loop for genotype data files
for (file in file.from:file.stop)
{
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="New Genotype file")
Memory=GAPIT.Memory(Memory=Memory,Infor="New Genotype file")



  frag=1
  numSNP=file.fragment
  myFRG=NULL
while(numSNP==file.fragment) {     #this is problematic if the read end at the last line



  #initial previous SNP storage
  x.prev <- vector(length = 0)

  #force to skip the while loop if optOnly
  if(optOnly) numSNP=0

  #Determine the case of first file and first fragment: skip read file
  if(file==file.from & frag==1& SNP.fraction<1){
    firstFileFirstFrag=TRUE
  }else{
    firstFileFirstFrag=FALSE
  }

#In case of xs is not full GD, replace xs from file
  if(!fullGD & !optOnly & !firstFileFirstFrag )
  {

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Clean myFRG")
Memory=GAPIT.Memory(Memory=Memory,Infor="Clean myFRG")

#update xs for each file
    rm(xs)
    rm(myFRG)
    gc()
    print(paste("Current file: ",file," , Fragment: ",frag,sep=""))

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Read file fragment")
Memory=GAPIT.Memory(Memory=Memory,Infor="Read file fragment")

    myFRG=GAPIT.Fragment( file.path=file.path,  file.total=file.total,file.G=file.G,file.Ext.G=file.Ext.G,
                          seed=seed,SNP.fraction=SNP.fraction,SNP.effect=SNP.effect,SNP.impute=SNP.impute,genoFormat=genoFormat,
                          file.GD=file.GD,file.Ext.GD=file.Ext.GD,file.GM=file.GM,file.Ext.GM=file.Ext.GM,file.fragment=file.fragment,file=file,frag=frag)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Genotype file converted")
Memory=GAPIT.Memory(Memory=Memory,Infor="Genotype file converted")

#print("-----------------------------------------------------------------")

      if(is.null(myFRG$GD)){
        xs=NULL
      }else{
        xs=myFRG$GD[GTindex,]
      }


        if(!is.null(myFRG$GI))    {
          colnames(myFRG$GI)=c("SNP","Chromosome","Position")
          GI=as.matrix(myFRG$GI)
        }


      if(!is.null(myFRG$GI))    {
        numSNP=ncol(myFRG$GD)
      }  else{
       numSNP=0
      }
      if(is.null(myFRG))numSNP=0  #force to end the while loop
  } # end of if(!fullGD)

  if(fullGD)numSNP=0  #force to end the while loop


#Skip REML if xs is from a empty fragment file
if(!is.null(xs))  {



  if(is.null(dim(xs)) || nrow(xs) == 1)  xs <- matrix(xs, length(xs),1)
  m <- ncol(xs) #number of SNPs
  t <- nrow(xs) #number of individuals

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Before cleaning")
Memory=GAPIT.Memory(Memory=Memory,Infor="Before cleaning")
  #allocate spaces for SNPs
  #rm(dfs)
  #rm(stats)
  #rm(ps)
  #rm(nobs)
  #rm(maf)
  #rm(rsquare)
  gc()

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="After cleaning")
Memory=GAPIT.Memory(Memory=Memory,Infor="After cleaning")

  dfs <- matrix(nrow = m, ncol = g)
  stats <- matrix(nrow = m, ncol = g)
  ps <- matrix(nrow = m, ncol = g)
  nobs <- matrix(nrow = m, ncol = g)
  maf <- matrix(nrow = m, ncol = g)
  rsquare_base <- matrix(nrow = m, ncol = g)
  rsquare <- matrix(nrow = m, ncol = g)
  #print(paste("Memory allocated.",sep=""))
  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Memory allocation")
  Memory=GAPIT.Memory(Memory=Memory,Infor="Memory allocation")

  if(optOnly)mloop=0
  if(!optOnly)mloop=m

  #Loop on SNPs
  #print(paste("Number of SNPs is ",mloop," in genotype file ",file, sep=""))

#set starting point of loop
if(file==file.from&frag==1){loopStart=0}else{loopStart=1}

for (i in loopStart:mloop){
#print(i)
#--------------------------------------------------------------------------------------------------------------------<
    normalCase=TRUE

    if((i >0)&(floor(i/1000)==i/1000))  print(paste("Genotype file: ", file,", SNP: ",i," ",sep=""))
    # To extract current snp. It save computation for next one in case they are identical
    if(i ==0&file==file.from&frag==1){
      #For the model without fitting SNP
      vids <- !is.na(ys[j,]) #### Feng changed
      xv <- ys[j, vids]*0+1      #### Feng changed      
    }

    if(i >0 | file>file.from | frag>1){
      vids <- !is.na(xs[,i]) #### Feng changed
      xv <- xs[vids,i]      #### Feng changed
      vids.TRUE=which(vids==TRUE)
      vids.FALSE=which(vids==FALSE)
      ns=length(xv)
      ss=sum(xv)

      maf[i]=min(.5*ss/ns,1-.5*ss/ns)
      nobs[i]=ns

     nr <- sum(vids)
     if(i ==1 & file==file.from&frag==1)  {
       Xt <- matrix(NA,nr, q1)
       iXX=matrix(NA,q1,q1)
     }

    }

    #Situation of no variation for SNP except the fisrt one(synthetic for EMMAx/P3D)
    if((min(xv) ==max(xv) )& (i >0 | file>file.from |frag>1))
    {
      dfs[i, ] <- rep(NA, g)
      stats[i, ] <- rep(NA, g)
      ps[i, ] = rep(1, g)
      rsquare[i, ] <- rep(NA,g)
      rsquare_base[i, ]<-rep(NA,g)
      normalCase=FALSE
    }else if(identical(x.prev, xv))     #Situation of the SNP is identical to previous
    {
      if(i >1 | file>file.from | frag>1){
        dfs[i, ] <- dfs[i - 1, ]
        stats[i, ] <- stats[i - 1, ]
        ps[i, ] <- ps[i - 1, ]
        rsquare[i, ] <- rsquare[i - 1, ]
        rsquare_base[i, ] <-rsquare_base[i - 1, ]
        normalCase=FALSE
      }
    }
#-------------------------------------------------------------------------------------------------------------------->

  if(i == 0 &file==file.from &frag==1){

   #Calculate the log likelihood function for the intercept only model

   #vids <- !is.na(ys[j,])
   yv <- ys[j, vids]

   X.int <- matrix(1,nrow(as.matrix(yv)),ncol(as.matrix(yv)))
   iX.intX.int <- solve(crossprod(X.int, X.int))
   iX.intY <- crossprod(X.int, as.matrix(as.matrix(yv)))
   beta.int <- crossprod(iX.intX.int, iX.intY)  #Note: we can use crossprod here becase iXX is symmetric
   X.int.beta.int <- X.int%*%beta.int




   #X.int <- matrix(1,nrow(as.matrix(ys[!is.na(ys)])),ncol(as.matrix(ys[!is.na(ys)])))
   #iX.intX.int <- solve(crossprod(X.int, X.int))
   #iX.intY <- crossprod(X.int, as.matrix(ys[!is.na(ys)]))
   #beta.int <- crossprod(iX.intX.int, iX.intY)  #Note: we can use crossprod here becase iXX is symmetric
   #X.int.beta.int <- X.int%*%beta.int

   logL0 <- 0.5*((-length(yv))*log(((2*pi)/length(yv))
                 *crossprod((yv-X.int.beta.int),(yv-X.int.beta.int)))
                  -length(yv))


   #logL0 <- 0.5*((-nrow(as.matrix(ys[!is.na(ys)])))*log(((2*pi)/nrow(ys))
   #              *crossprod(((as.matrix(ys[!is.na(ys)]))-X.int.beta.int),((as.matrix(ys[!is.na(ys)]))-X.int.beta.int)))
   #               -nrow(as.matrix(ys[!is.na(ys)])))
                  
    #print(paste("The value of logL0 inside of the calculating SNPs loop is", logL0, sep = ""))              
   }


    #Normal case
    if(normalCase)
    {

#--------------------------------------------------------------------------------------------------------------------<
      #nv <- sum(vids)
      vids1 <- as.matrix(vids)
      yv <- ys[j, vids] #### Feng changed
      nr <- sum(vids) #### Feng changed
      if(!is.null(Z) & !is.null(K))
      {
        r<- ncol(Z) ####Feng, add a variable to indicate the number of random effect
        vran <- vids[1:r] ###Feng, add a variable to indicate random effects with nonmissing genotype
        tv <- sum(vran)  #### Feng changed
      }
      

#-------------------------------------------------------------------------------------------------------------------->

#--------------------------------------------------------------------------------------------------------------------<



      if(i >0 | file>file.from|frag>1) dfs[i, j] <- nr - q1
    	if(i >0 | file>file.from|frag>1) X <- cbind(X0[vids, , drop = FALSE], xs[vids,i])

       #Recalculate eig and REML if not using P3D  NOTE THIS USED TO BE BEFORE the two solid lines
      if(SNP.P3D==FALSE & !is.null(K))
      {
        if(!is.null(Z)) eig.R <- emma.eigen.R.w.Z(Z, K, X) #This will be used to get REstricted ML (REML)
        if(is.null(Z)) eig.R <- emma.eigen.R.wo.Z(   K, X) #This will be used to get REstricted ML (REML)
        if(!is.null(Z)) REMLE <- emma.REMLE(ys[j,], X, K, Z, ngrids, llim, ulim, esp, eig.R)
        if(is.null(Z)) REMLE <- emma.REMLE(ys[j,], X, K, Z = NULL, ngrids, llim, ulim, esp, eig.R)
        if(!is.null(Z) & !is.null(K))  U <- eig.L$vectors * matrix(c(sqrt(1/(eig.L$values + REMLE$delta)),rep(sqrt(1/REMLE$delta),nr - tv)),nr,((nr-tv)+length(eig.L$values)),byrow=TRUE)
        if(is.null(Z) & !is.null(K))  U <- eig.L$vectors * matrix(  sqrt(1/(eig.L$values + REMLE$delta)),nr,length(eig.L$values),byrow=TRUE)

        vgs <- REMLE$vg
        ves <- REMLE$ve
        REMLs <- REMLE$REML
        REMLE_delta=REMLE$delta

      }

      if(n==nr)
      {
        if(!is.null(K))
        {
            yt <- crossprod(U, yv)
            if(i == 0 &file==file.from &frag==1){
             X0t <- crossprod(U, X0)
             Xt <- X0t
            }
            if(i > 0 | file>file.from |frag>1){
              #if(i ==1 & file==file.from&frag==1)  Xt <- matrix(NA,nr, q1)

              #print(paste("i:",i,"q0:",q0,"q1:",q1,"nt:",nr,"XT row",nrow(Xt),"XT col",ncol(Xt),sep=" "))
              xst <- crossprod(U, X[,ncol(X)])
              Xt[1:nr,1:q0] <- X0t
              Xt[1:nr,q1] <- xst
            }
        }else{
        yt=yv
        if(i == 0 &file==file.from &frag==1) X0t <- X0
        if(i > 0 | file>file.from |frag>1) xst <- X[,ncol(X)]
        }

        if(i == 0 &file==file.from &frag==1){
         X0X0 <- crossprod(X0t, X0t)
         #XX <- X0X0
        }
        if(i > 0 | file>file.from |frag>1){
         #if(i == 1)XX=matrix(NA,q1,q1)


         X0Xst <- crossprod(X0t,xst)
         XstX0 <- t(X0Xst)
         xstxst <- crossprod(xst, xst)
         # if(i == 1){
         #  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Calculate_X0Xst_XstX0_xstxst")
         #  Memory=GAPIT.Memory(Memory=Memory,Infor="Calculate_X0Xst_XstX0_xstxst")
         #   }
         #XX <- rbind(cbind(X0X0, X0Xst), cbind(XstX0, xstxst))

         #XX[1:q0,1:q0] <- X0X0
         #XX[q1,1:q0] <- X0Xst
         #XX[1:q0,q1] <- X0Xst
         #XX[q1,q1] <- xstxst


        }


        if(X0X0[1,1] == "NaN")
        {
          Xt[which(Xt=="NaN")]=0
          yt[which(yt=="NaN")]=0
          XX=crossprod(Xt, Xt)
        }
        if(i == 0 &file==file.from & frag==1){
         X0Y <- crossprod(X0t,yt)
         XY <- X0Y
        }
        if(i > 0 | file>file.from |frag>1){
         xsY <- crossprod(xst,yt)
         XY <- c(X0Y,xsY)
#         if(i == 1){
#         Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Calculate_xsY_X0Y")
#         Memory=GAPIT.Memory(Memory=Memory,Infor="Calculate_xsY_X0Y")
#         }
        }
        #XY = crossprod(Xt,yt)
      }

      #Missing SNP
      if(n>nr)
      {
       UU=crossprod(U,U)
       A11=UU[vids.TRUE,vids.TRUE]
       A12=UU[vids.TRUE,vids.FALSE]
       A21=UU[vids.FALSE,vids.TRUE]
       A22=UU[vids.FALSE,vids.FALSE]
       A22i =try(solve(A22) )
       if(inherits(A22i, "try-error")) A22i <- ginv(A22)

       F11=A11-A12%*%A22i%*%A21
       XX=crossprod(X,F11)%*%X
       XY=crossprod(X,F11)%*%yv
      }
      if(i == 0 &file==file.from &frag==1){
       iX0X0 <- try(solve(X0X0))
       if(inherits(iX0X0, "try-error")){
         iX0X0 <- ginv(X0X0)
         print("At least two of your covariates are linearly dependent. Please reconsider the covariates you are using for GWAS and GPS")
       }
       iXX <- iX0X0
      }
      if(i > 0 | file>file.from |frag>1){

      #if(i ==1 &file==file.from &frag==1) iXX=matrix(NA,q1,q1)

       B22 <- xstxst - XstX0%*%iX0X0%*%X0Xst
        invB22 <- 1/B22
        #B12 <- crossprod(iX0X0,X0Xst)
        B21 <- tcrossprod(XstX0, iX0X0)
        NeginvB22B21 <- crossprod(-invB22,B21)
        #B11 <- iX0X0 + B12%*%invB22%*%B21
        B11 <- iX0X0 + as.numeric(invB22)*crossprod(B21,B21)
        #iXX <- rbind(cbind(B11,t(NeginvB22B21)), cbind(NeginvB22B21,invB22))

        iXX[1:q0,1:q0]=B11
        iXX[q1,q1]=1/B22
        iXX[q1,1:q0]=NeginvB22B21
        iXX[1:q0,q1]=NeginvB22B21

        #if(i == 1){
        # Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Calculate_iXX")
        # Memory=GAPIT.Memory(Memory=Memory,Infor="Calculate_iXX")
        #}

      }

      if(is.null(K)){
       iXX <- solve(crossprod(X,X))
       XY = crossprod(X,yv)
      }

      #iXX <- try(solve(XX))
      #if(inherits(iXX, "try-error")) iXX <- ginv(crossprod(Xt, Xt))
      beta <- crossprod(iXX,XY) #Note: we can use crossprod here becase iXX is symmetric


#-------------------------------------------------------------------------------------------------------------------->

#--------------------------------------------------------------------------------------------------------------------<
      if(i ==0 &file==file.from &frag==1 & !is.null(K))
      {
        Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="ReducedModel")
	  Memory=GAPIT.Memory(Memory=Memory,Infor="ReducdModel")


        XtimesBetaHat <- X%*%beta

        YminusXtimesBetaHat <- ys[j,]- XtimesBetaHat
        vgK <- vgs*K
        Dt <- crossprod(U, YminusXtimesBetaHat)

        if(!is.null(Z))  Zt <- crossprod(U, Z)
        if(is.null(Z)) Zt <- t(U)

        if(X0X0[1,1] == "NaN")
        {
        Dt[which(Dt=="NaN")]=0
        Zt[which(Zt=="NaN")]=0
        }

        BLUP <- K %*% crossprod(Zt, Dt) #Using K instead of vgK because using H=V/Vg


      #Clean up the BLUP starf to save memory
      Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="before Dt clean")
      Memory=GAPIT.Memory(Memory=Memory,Infor="before Dt clean")
      rm(Dt)
      gc()
      Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Dt clean")
      Memory=GAPIT.Memory(Memory=Memory,Infor="Dt clean")





        grand.mean.vector <- rep(beta[1], length(BLUP))
        BLUP_Plus_Mean <- grand.mean.vector + BLUP
    	  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="BLUP")
        Memory=GAPIT.Memory(Memory=Memory,Infor="BLUP")

        #PEV
        C11=try(vgs*solve(crossprod(Xt,Xt)))
        if(inherits(C11, "try-error")) C11=vgs*ginv(crossprod(Xt,Xt))

        C21=-K%*%crossprod(Zt,Xt)%*%C11
        Kinv=try(solve(K)    )
        if(inherits(Kinv, "try-error")) Kinv=ginv(K)

        if(!is.null(Z)) term.0=crossprod(Z,Z)/ves
        if(is.null(Z)) term.0=diag(1/ves,nrow(K))

        term.1=try(solve(term.0+Kinv/vgs )  )
        if(inherits(term.1, "try-error")) term.1=ginv(term.0+Kinv/vgs )

        term.2=C21%*%crossprod(Xt,Zt)%*%K
        C22=(term.1-term.2 )
        PEV=as.matrix(diag(C22))

        BLUE=X%*%beta

    	  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PEV")
        Memory=GAPIT.Memory(Memory=Memory,Infor="PEV")

      }#end of if(i ==0&file==file.from   & !is.null(K))
#-------------------------------------------------------------------------------------------------------------------->

#--------------------------------------------------------------------------------------------------------------------<
      if(i ==0 &file==file.from &frag==1 & is.null(K))
      {
        YY=crossprod(yt, yt)
        ves=(YY-crossprod(beta,XY))/(n-q0)
        r=yt-X%*%iXX%*%XY
        REMLs=-.5*(n-q0)*log(det(ves))                  -.5*n                   -.5*(n-q0)*log(2*pi)
#       REMLs=-.5*n*log(det(ves)) -.5*log(det(iXX)/ves) -.5*crossprod(r,r)/ves  -.5*(n-q0)*log(2*pi)
        vgs = 0
        BLUP = 0
        BLUP_Plus_Mean = NaN
        PEV = ves
        #print(paste("X row:",nrow(X)," col:",ncol(X)," beta:",length(beta),sep=""))
       	BLUE=X%*%beta

      }


#Clean up the BLUP starf to save memory
if(i ==0 &file==file.from &frag==1 & !is.null(K))
{
    	  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="K normal")
        Memory=GAPIT.Memory(Memory=Memory,Infor="K normal")
K=1
rm(Dt)
rm(Zt)
rm(Kinv)
rm(C11)
rm(C21)
rm(C22)

gc()
    	  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="K set to 1")
        Memory=GAPIT.Memory(Memory=Memory,Infor="K set to 1")
}




      
      if(i == 0 &file==file.from & frag==1){
      
      X.beta <- X%*%beta
      
      if(!is.null(K)){
              U.times.yv.minus.X.beta <- crossprod(U,(yv-X.beta))
              logLM_Base <- 0.5*(-length(yv)*log(((2*pi)/length(yv))*crossprod(U.times.yv.minus.X.beta,U.times.yv.minus.X.beta)) 
                    - sum(log(eig.full.plus.delta)) - length(yv))
 
      }
      if(is.null(K)){
              U.times.yv.minus.X.beta <- yv-X.beta
              logLM_Base <- 0.5*(-length(yv)*log(((2*pi)/length(yv))*crossprod(U.times.yv.minus.X.beta,U.times.yv.minus.X.beta)) - length(yv))
      }
      rsquare_base_intitialized <- 1-exp(-(2/length(yv))*(logLM_Base-logL0))
      
      }
      
      #calculate t statistics and P-values
      if(i > 0 | file>file.from |frag>1)
      {
        if(!is.null(K)) stats[i, j] <- beta[q1]/sqrt(iXX[q1, q1] *vgs)
        if(is.null(K)) stats[i, j] <- beta[q1]/sqrt(iXX[q1, q1] *ves)
        ps[i, ] <- 2 * pt(abs(stats[i, ]), dfs[i, ],lower.tail = FALSE)
        
      #Calculate the maximum full likelihood function value and the r square
      
      X.beta <- X%*%beta
      if(!is.null(K)){
          U.times.yv.minus.X.beta <- crossprod(U,(yv-X.beta))
          logLM <- 0.5*(-length(yv)*log(((2*pi)/length(yv))*crossprod(U.times.yv.minus.X.beta,U.times.yv.minus.X.beta)) 
                       - sum(log(eig.full.plus.delta))- length(yv))
      }
      if(is.null(K)){  
            U.times.yv.minus.X.beta <- yv-X.beta          
            logLM <- 0.5*(-length(yv)*log(((2*pi)/length(yv))*crossprod(U.times.yv.minus.X.beta,U.times.yv.minus.X.beta)) - length(yv))
      }  

      rsquare_base[i, ] <- rsquare_base_intitialized
      rsquare[i, ] <- 1-exp(-(2/length(yv))*(logLM-logL0))

      }
#-------------------------------------------------------------------------------------------------------------------->

    } # End of if(normalCase)
    x.prev=xv #update SNP

} # End of loop on SNPs

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Screening SNPs")
Memory=GAPIT.Memory(Memory=Memory,Infor="Screening SNPs")

#output p value for the genotype file
if(!fullGD)
{
  write.table(GI, paste("GAPIT.TMP.GI.",name.of.trait,file,".",frag,".txt",sep=""), quote = FALSE, sep = "\t", row.names = FALSE,col.names = TRUE)
  write.table(ps, paste("GAPIT.TMP.ps.",name.of.trait,file,".",frag,".txt",sep=""), quote = FALSE, sep = "\t", row.names = FALSE,col.names = FALSE)
  write.table(maf, paste("GAPIT.TMP.maf.",name.of.trait,file,".",frag,".txt",sep=""), quote = FALSE, sep = "\t", row.names = FALSE,col.names = FALSE)
  write.table(nobs, paste("GAPIT.TMP.nobs.",name.of.trait,file,".",frag,".txt",sep=""), quote = FALSE, sep = "\t", row.names = FALSE,col.names = FALSE)
  write.table(rsquare_base, paste("GAPIT.TMP.rsquare.base.",name.of.trait,file,".",frag,".txt",sep=""), quote = FALSE, sep = "\t", row.names = FALSE,col.names = FALSE)
  write.table(rsquare, paste("GAPIT.TMP.rsquare.",name.of.trait,file,".",frag,".txt",sep=""), quote = FALSE, sep = "\t", row.names = FALSE,col.names = FALSE)

  #rm(dfs,stats,ps,nobs,maf,GI)   #This cause problem on return
  #gc()
}


    frag=frag+1   #Progress to next fragment

} #end of if(!is.null(X))

} #end of repeat on fragment



} # End of loop on file
} # End of loop on traits

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="GWAS done for this Trait")
Memory=GAPIT.Memory(Memory=Memory,Infor="GWAS done for this Trait")


return(list(ps = ps, REMLs = -2*REMLs, stats = stats, rsquare_base = rsquare_base, rsquare = rsquare, dfs = dfs,maf=maf,nobs = nobs,Timmer=Timmer,Memory=Memory,
        vgs = vgs, ves = ves, BLUP = BLUP, BLUP_Plus_Mean = BLUP_Plus_Mean,
        PEV = PEV, BLUE=BLUE, logLM = logLM))

#print("GAPIT.EMMAxP3D accomplished successfully!")
}#end of GAPIT.EMMAxP3D function





##############################################################################################
GAPIT.ZmatrixFormation <- function(Z,Y){
#Object: To expande the proportion Z to final Z
#Output: Z
#Authors: Zhiwu Zhang
# Last update: April 22, 2011
##############################################################################################

#split individuals in Y to the ones that are given Z and the one not
taxa.Z=as.matrix(Z[-1,1])
taxa.Y=as.matrix(Y[,1])
taxa.diff=setdiff(taxa.Y,taxa.Z)
taxa.I=as.matrix(taxa.Y[match(taxa.diff,taxa.Y,nomatch = 0)])
taxa.Z.col=as.matrix(Z[1,-1])

#Create final Z with zero block and identity block
Z0=matrix(data=0,nrow=nrow(taxa.Z),ncol=nrow(taxa.I))
Z1=diag(1,nrow(taxa.I))
ZC=as.matrix(rbind(Z0,Z1))

#To label rows and columns
label.row=rbind(as.matrix(Z[,1]),taxa.I)
label.col=t(taxa.I)

#update the zero block by the given Z matrix
position=t(as.matrix(match(taxa.Z.col,taxa.I,nomatch = 0)))
ZC[1:nrow(taxa.Z),position]=as.matrix(Z[-1,-1])

#habdler of parents do not have phenotype (colums of Z are not in taxa.I)
# To do list

#To form final Z matrix
dataPart=rbind(label.col,ZC)
Z=data.frame(cbind(label.row,dataPart))

#print("GAPIT.ZmatrixFormation accomplished successfully!")
return(Z)
}#The function GAPIT.ZmatrixFormation ends here

##############################################################################################
GAPIT.RemoveDuplicate <- function(Y){
#Object: NA
#Output: NA
#Authors: Zhiwu Zhang
# Last update: Augus 30, 2011
##############################################################################################
return (Y[match(unique(Y[,1]), Y[,1], nomatch = 0), ] )
}

##############################################################################################
GAPIT.QC <- function(Y=NULL,KI=NULL,GT=NULL,CV=NULL,Z=NULL,GK=NULL){
#Object: to do data quality control
#Output: Y, KI, GD, CV, Z, flag
#Authors: Zhiwu Zhang and Alex Lipka
# Last update: April 14, 2011
##############################################################################################

#Remove duplicates
print("Removing duplicates...")
Y=GAPIT.RemoveDuplicate(Y)
CV=GAPIT.RemoveDuplicate(CV)
GK=GAPIT.RemoveDuplicate(GK)
if(!is.null(Z))Z=GAPIT.RemoveDuplicate(Z)


#Remove missing phenotype
print("Removing NaN...")
Y=Y[which(Y[,2]!="NaN"),]

# Remove duplicates for GT
# GT row wise, Z column wise, and KI both direction.
print("Remove duplicates for GT...")

if(!is.null(GT))
{
taxa.kept=unique(GT[,1])
}

# Remove duplicates for KI
print("Remove duplicates for KI...")
#@@@ improve speed: remove t() and use cbind
if(!is.null(KI))
{
  taxa.all=KI[,1]
  taxa.uniqe=unique(taxa.all)
  position=match(taxa.uniqe, taxa.all,nomatch = 0)
  position.addition=cbind(1,t(1+position))
  KI=KI[position,position.addition]
}

# Remove duplicates for Z rowwise
print("Remove duplicates for Z (column wise)...")
if(!is.null(Z))
{
  taxa.all=as.matrix(Z[1,])
  taxa.uniqe=intersect(taxa.all,taxa.all)
  position=match(taxa.uniqe, taxa.all,nomatch = 0)
  Z=Z[,position]
}


#Remove the columns of Z if they are not in KI/GT. KI/GT are allowed to have individuals not in Z
print("Maching Z with Kinship colwise...")
if(!is.null(KI))
{
  taxa.all=KI[,1]
  taxa.kinship=unique(taxa.all)
}

if(!is.null(Z) & !is.null(KI))
{
  #get common taxe between KI and Z
  taxa.Z=as.matrix(Z[1,])
  #taxa.Z=colnames(Z) #This does not work for names starting with numerical or "-"   \
  if(is.null(KI)){
  taxa.Z_K_common=taxa.Z
  }else{
  taxa.Z_K_common=intersect(taxa.kinship,taxa.Z)
  }
  Z <-cbind(Z[,1], Z[,match(taxa.Z_K_common, taxa.Z, nomatch = 0)])

  #Remove the rows of Z if all the ellements sum to 0
  #@@@ improve speed: too many Zs
  print("Maching Z without origin...")
  Z1=Z[-1,-1]
  Z2=data.frame(Z1)
  Z3=as.matrix(Z2)
  Z4=as.numeric(Z3) #one dimemtion
  Z5=matrix(data = Z4, nrow = nrow(Z1), ncol = ncol(Z1))
  RS=rowSums(Z5)>0
  #The above process could be simplified!
  Z <- Z[c(TRUE,RS),]

  #make individuals the same in Z, Y, GT and CV
  print("Maching GT and CV...")
  if(length(Z)<=1)stop("GAPIT says: there is no place to match IDs!")
}# end of  if(!is.null(Z) & !is.null(K))

# get intersect of all the data
taxa=intersect(Y[,1],Y[,1])
if(!is.null(Z))taxa=intersect(Z[-1,1],taxa)
if(!is.null(GT))taxa=intersect(taxa,taxa.kept)
if(!is.null(CV))taxa=intersect(taxa,CV[,1])
if(!is.null(GK))taxa=intersect(taxa,GK[,1])
if(length(taxa)<=1)stop("GAPIT says: There is no individual ID matched to covariate. Please check!")


if(!is.null(Z))
{
  #Remove taxa in Z that are not in others, columnwise
  t=c(TRUE, Z[-1,1]%in%taxa)
  if(length(t)<=2)stop("GAPIT says: There is no individual ID matched among data. Please check!")
  Z <- Z[t,]

  #Remove the columns of Z if all the ellements sum to 0
  print("QC final process...")
  #@@@ improve speed: too many Zs
  Z1=Z[-1,-1]
  Z2=data.frame(Z1)
  Z3=as.matrix(Z2)
  Z4=as.numeric(Z3) #one dimemtion
  Z5=matrix(data = Z4, nrow = nrow(Z1), ncol = ncol(Z1))
  CS=colSums(Z5)>0
  #The above process could be simplified!
  Z <- Z[,c(TRUE,CS)]
}

#Filtering with comman taxa
Y <- Y[Y[,1]%in%taxa,]
if(!is.null(CV)) CV=CV[CV[,1]%in%taxa,]
if(!is.null(GK)) GK=GK[GK[,1]%in%taxa,]
if(!is.null(GT)) taxa.kept=data.frame(taxa.kept[taxa.kept%in%taxa])
#Y <- Y[Y[,1]%in%taxa.kept,]

print("size of taxa.kept")
print(dim(taxa.kept))

#To sort Y, GT, CV and Z
Y=Y[order(Y[,1]),]
CV=CV[order(CV[,1]),]
if(!is.null(GK))GK=GK[order(GK[,1]),]
if(!is.null(Z))Z=Z[c(1,1+order(Z[-1,1])),]

#get position of taxa.kept in GT
position=match(taxa.kept[,1], GT[,1],nomatch = 0)
order.taxa.kept=order(taxa.kept[,1])
GTindex=position[order.taxa.kept]
flag=nrow(Y)==nrow(Z)-1&nrow(Y)==nrow(GT)&nrow(Y)==nrow(CV)

print("GAPIT.QC accomplished successfully!")
return(list(Y = Y, KI = KI, GT = GT, CV = CV, Z = Z, GK = GK, GTindex=GTindex, flag=flag))
}#The function GAPIT.QC ends here

##############################################################################################
GAPIT.Compress <- function(KI,kinship.cluster = "average",kinship.group = "Mean",GN=nrow(KI),Timmer,Memory){
#Object: To cluster individuals into groups based on kinship
#Output: GA, KG
#Authors: Alex Lipka and Zhiwu Zhang
# Last update: April 14, 2011
##############################################################################################

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="CP start")
Memory=GAPIT.Memory(Memory=Memory,Infor="cp start")

# Extract the line names
line.names <- KI[,1]

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Does this change memory0")
Memory=GAPIT.Memory(Memory=Memory,Infor="Does this change memory0")

# Remove the first column of the kinship matrix, which is the line names
KI <- KI[ ,-1]

# Convert kinship to distance
#distance.matrix <- 2 - KI


#distance.matrix.as.dist <- as.dist(distance.matrix)
#distance.matrix.as.dist <- as.dist(2 - KI)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="CP distance")
Memory=GAPIT.Memory(Memory=Memory,Infor="cp distance")

#print(paste("The value of kinship.cluster is ", kinship.cluster, sep = ""))



# hclust() will perform the hiearchical cluster analysis
#cluster.distance.matrix <- hclust(distance.matrix.as.dist, method = kinship.cluster)
cluster.distance.matrix <- hclust(as.dist(2 - KI), method = kinship.cluster)


Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="CP cluster")
Memory=GAPIT.Memory(Memory=Memory,Infor="cp cluster")

# Cutree will assign lines into k clusters
group.membership <- cutree(cluster.distance.matrix, k = GN)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="CP cutree")
Memory=GAPIT.Memory(Memory=Memory,Infor="cp cutree")

#calculate group kinship
if(kinship.group == "Mean"){
#This matrix ooperation is much faster than tapply function for  "Mean"
x=as.factor(group.membership)
#b = model.matrix(~x-1)
n=max(as.numeric(as.vector(x)))
b=diag(n)[x,]

KG=t(b)%*%as.matrix(KI)%*%b
CT=t(b)%*%(0*as.matrix(KI)+1)%*%b
KG=as.matrix(KG/CT)
rownames(KG)=c(1:nrow(KG))
colnames(KG)=c(1:ncol(KG))

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="CP calculation original")
Memory=GAPIT.Memory(Memory=Memory,Infor="cp calculation original")



}else{

gm=as.factor(group.membership)
kv=as.numeric(as.matrix(KI))
kvr=rep(gm,ncol(KI))
kvc=as.numeric(t(matrix(kvr,nrow(KI),ncol(KI))))

kInCol=t(rbind(kv,kvr,kvc))

rm(gm)
rm(kv)
rm(kvr)
rm(kvc)
rm(KI)
gc()



#This part does not work yet
#if(kinship.group == "Mean")
#    KG<- tapply(kInCol[,1], list(kInCol[,2], kInCol[,3]), mean)
if(kinship.group == "Max")
    KG <- tapply(kInCol[,1], list(kInCol[,2], kInCol[,3]), max)
if(kinship.group == "Min")
    KG <- tapply(kInCol[,1], list(kInCol[,2], kInCol[,3]), min)
if(kinship.group == "Median")
    KG <- tapply(kInCol[,1], list(kInCol[,2], kInCol[,3]), median)
} #this is end of brancing "Mean" and the rest

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="CP calculation")
Memory=GAPIT.Memory(Memory=Memory,Infor="cp calculation")

# add line names
GA <- data.frame(group.membership)
GA <- data.frame(cbind(as.character(line.names),as.numeric(group.membership) ))

#Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="CP Final")
#Memory=GAPIT.Memory(Memory=Memory,Infor="CP Final")

#write.table(KG, paste("KG_from_", kinship.group, "_Method.txt"), quote = FALSE, sep = "\t", row.names = FALSE,col.names = FALSE)

#print("GAPIT.Compress accomplished successfully!")
return(list(GA=GA, KG=KG,Timmer=Timmer,Memory=Memory))
}#The function GAPIT.Compress ends here

##############################################################################################
GAPIT.Block <- function(Z,GA,KG){
#Object: To split a group kinship into two blocks containing individuals with and without phenotype
#Output: GAU,KW,KO,KWO
#Authors: Zhiwu Zhang and Alex Lipka
# Last update: April 14, 2011
##############################################################################################

# To separate group kiship into two blocks: with and without phenotype.
# A group goes to with phenotype as loog as it has one phenotyped individual.

#find position in group assignment (GA) for the individual associate with phenotype (specified by Z)
#taxa=unique(intersect(as.matrix(Z[1,-1]),GA[,1]))

taxa.Z=as.matrix(Z[1,-1])
taxa.GA=as.matrix(GA[,1])
position=taxa.GA%in%taxa.Z

#Initial block as 2
GAU=cbind(GA,2)

#Assign block as 1 if the individual has phenotype
GAU[position,3]=1

#Modify the non-phenotyped individuals if they in a group with phenotyped individuals
#To find the groups with phenotyped individuals
#update block assignment for all these groups
#get list of group that should be block 1

#grp.12=as.matrix(unique(GAU[,2]))
#grp.1=as.matrix(unique(GAU[which(GAU[,3]==1),2]))
#grp.2= as.matrix(setdiff(grp.12,grp.1))

grp.12=as.matrix(as.vector(unique(GAU[,2])) )
grp.1=as.matrix(as.vector(unique(GAU[which(GAU[,3]==1),2])) )
grp.2= as.matrix(as.vector(setdiff(grp.12,grp.1)))

numWithout=length(grp.2)

order.1=1:length(grp.1)
order.2=1:length(grp.2)
if(numWithout >0) grpblock=as.matrix(rbind(cbind(grp.1,1,order.1), cbind(grp.2,2,order.2)))
if(numWithout==0) grpblock=as.matrix(      cbind(grp.1,1,order.1),                       )

order.block=order(as.matrix(GAU[,3]))
colnames(grpblock)=c("grp","block","ID")

GAU0 <- merge(GAU[order.block,-3], grpblock, by.x = "X2", by.y = "grp")
GAU=GAU0[,c(2,1,3,4)]


KW=KG[grp.1,grp.1]
KO=KG[grp.2,grp.2]
KWO=KG[grp.1,grp.2]

#write.table(GAU, "GAU.txt", quote = FALSE, sep = "\t", row.names = TRUE,col.names = TRUE)

#print("GAPIT.Block accomplished successfully!")
return(list(GAU=GAU,KW=KW,KO=KO,KWO=KWO))
}#The function GAPIT.Block ends here


##############################################################################################
GAPIT.ZmatrixCompress <- function(Z,GAU){
#Object: To assign the fraction of a individual belonging to a group
#Output: Z
#Authors: Zhiwu Zhang
# Last update: April 14, 2011
##############################################################################################
#Extraction of GAU coresponding to Z, sort GAU rowwise to mach columns of Z, and make design matrix
effect.Z=as.matrix(Z[1,-1])
effect.GAU=as.matrix(GAU[,1])
taxa=as.data.frame(Z[-1,1])

GAU0=GAU[effect.GAU%in%effect.Z,]
order.GAU=order(GAU0[,1])
GAU1 <- GAU0[order.GAU,]
id.1=GAU1[which(GAU1[,3]==1),4]
n=max(as.numeric(as.vector(id.1)))
x=as.numeric(as.matrix(GAU1[,4]))
DS=diag(n)[x,]
#@@@@
#sort Z column wise
order.Z=order(effect.Z)
Z=Z[-1,-1]
Z <- Z[,order.Z]

#Z matrix from individual to group
#Z1.numeric <- as.numeric(as.matrix(Z))
Z <- matrix(as.numeric(as.matrix(Z)), nrow = nrow(Z), ncol = ncol(Z))
Z=Z%*%DS

#Z3=data.frame(cbind(as.character(Z[-1,1]),Z2))
Z=data.frame(cbind(taxa,Z))

#Z=Z3[order(Z3[,1]),]

Z=Z[order(as.matrix(taxa)),]


#print("GAPIT.ZmatrixCompress accomplished successfully!")
return(list(Z=Z))
}#The function GAPIT.ZmatrixCompress ends here

##############################################################################################
GAPIT.GS <- function(KW,KO,KWO,GAU,UW){
#Object: to derive BLUP for the individuals without phenotype
#Output: BLUP
#Authors: Zhiwu Zhang
# Last update: April 17, 2011
##############################################################################################

UO=try(t(KWO)%*%solve(KW)%*%UW)
if(inherits(UO, "try-error")) UO=t(KWO)%*%ginv(KW)%*%UW

n=ncol(UW) #get number of columns, add additional for individual name

#Assign BLUP of group to its individuals
BLUP=data.frame(as.matrix(GAU[,1:4]))

BLUP.W=BLUP[which(GAU[,3]==1),]
order.W=order(as.numeric(as.matrix(BLUP.W[,4])))
ID.W=as.numeric(as.matrix(BLUP.W[order.W,4]))
n.W=max(ID.W)
DS.W=diag(n.W)[ID.W,]
ind.W=DS.W%*%UW
all.W=cbind(BLUP.W[order.W,],ind.W)
all=all.W

BLUP.O=BLUP[which(GAU[,3]==2),]
if(nrow(BLUP.O)>0){
order.O=order(as.numeric(as.matrix(BLUP.O[,4])))
ID.O=as.numeric(as.matrix(BLUP.O[order.O,4]))
n.O=max(ID.O)
DS.O=diag(n.O)[ID.O,]
ind.O=DS.O%*%UO
all.O=cbind(BLUP.O[order.O,],ind.O)
all=rbind(all.W,all.O)
}

colnames(all)=c("Taxa", "Group", "RefInf","ID","BLUP","PEV")

#print("GAPIT.GS accomplished successfully!")
return(list(BLUP=all))
}#The function GAPIT.GS ends here

##############################################################################################
GAPIT.Numericalization <- function(x,bit=2,effect="Add",impute="None"){
#Object: To convert character SNP genotpe to numerical
#Output: Coresponding numerical value
#Authors: Feng Tian and Zhiwu Zhang
# Last update: May 30, 2011
##############################################################################################
if(bit==1)  {
x[x=="X"]="N"
x[x=="-"]="N"
x[x=="+"]="N"
x[x=="/"]="N"
x[x=="K"]="Z" #K (for GT genotype)is is replaced by Z to ensure heterozygose has the largest value
}

if(bit==2)  {
x[x=="XX"]="N"
x[x=="--"]="N"
x[x=="++"]="N"
x[x=="//"]="N"
x[x=="NN"]="N"
}

n=length(x)
lev=levels(as.factor(x))
lev=setdiff(lev,"N")
#print(lev)
len=length(lev)
#print(lev)

#Genotype counts
count=1:len
for(i in 1:len){
	count[i]=length(x[(x==lev[i])])
}
#make two  bit order genotype as AA,AT and TT, one bit as A(AA),T(TT) and X(AT)
if(bit==1 & len==3){
	temp=count[2]
	count[2]=count[3]
	count[3]=temp
}
position=order(count)

#1status other than 2 or 3
if(len<=1 | len> 3)x=0

#2 status
if(len==2)x=ifelse(x=="N",NA,ifelse(x==lev[1],0,2))

#3 status
if(bit==1){
	if(len==3)x=ifelse(x=="N",NA,ifelse(x==lev[1],0,ifelse(x==lev[3],1,2)))
}else{
	if(len==3)x=ifelse(x=="N",NA,ifelse(x==lev[1],0,ifelse(x==lev[3],2,1)))
}

#print(paste(lev,len,sep=" "))
#print(position)

#missing data imputation
if(impute=="Middle") {x[is.na(x)]=1 }

if(len==3){
	if(impute=="Minor")  {x[is.na(x)]=position[1]  -1}
	if(impute=="Major")  {x[is.na(x)]=position[len]-1}

}else{
	if(impute=="Minor")  {x[is.na(x)]=2*(position[1]  -1)}
	if(impute=="Major")  {x[is.na(x)]=2*(position[len]-1)}
}

#alternative genetic models
if(effect=="Dom") x=ifelse(x==1,1,0)
if(effect=="Left") x[x==1]=0
if(effect=="Right") x[x==1]=2

return(matrix(x,n,1))
}#end of GAPIT.Numericalization function


##############################################################################################
GAPIT.HapMap <- function(G,SNP.effect="Add",SNP.impute="Middle",heading=TRUE){
#Object: To convert character SNP genotpe to numerical
#Output: Coresponding numerical value
#Authors: Feng Tian and Zhiwu Zhang
# Last update: May 30, 2011
##############################################################################################

print(paste("Converting hampmap format to numerical under model of ", SNP.impute,sep=""))
#gc()
#GAPIT.Memory.Object(name.of.trait="HapMap.Start")

#GT=data.frame(G[1,-(1:11)])
if(heading){
GT= t(G[1,-(1:11)])
GI= G[-1,c(1,3,4)]
}else{
GT=NULL
GI= G[,c(1,3,4)]
}


#Set column names
if(heading)colnames(GT)="taxa"
colnames(GI)=c("SNP","Chromosome","Position")

#Initial GD
GD=NULL
bit=nchar(as.character(G[2,12])) #to determine number of bits of genotype
#print(paste("Number of bits for genotype: ", bit))

print("Perform numericalization")
if(heading){
  GD= apply(G[-1,-(1:11)],1,function(one) GAPIT.Numericalization(one,bit=bit,effect=SNP.effect,impute=SNP.impute))
}else{
  GD= apply(G[  ,-(1:11)],1,function(one) GAPIT.Numericalization(one,bit=bit,effect=SNP.effect,impute=SNP.impute))
}

#set GT and GI to NULL in case of null GD
if(is.null(GD)){
  GT=NULL
  GI=NULL
}

print(paste("Succesfuly finished converting hampmap which has bits of ", bit,sep=""))
return(list(GT=GT,GD=GD,GI=GI))
}#end of GAPIT.HapMap function


##############################################################################################
GAPIT.CVMergePC<- function(X,Y){
#Object: To convert character SNP genotpe to numerical
#Output: Coresponding numerical value
#Authors: Feng Tian and Zhiwu Zhang
# Last update: May 30, 2011
##############################################################################################

#Z=X+Y

Z <- merge(X, Y, by.x = colnames(X)[1], by.y = colnames(Y)[1])

return(Z)
}#end of GAPIT.CVMergePCfunction



##############################################################################################
GAPIT.Memory <- function(Memory =NULL,Infor){
#Object: To report memory usage
#Output: Memory
#Authors: Zhiwu Zhang
# Last update: June 6, 2011
##############################################################################################
gc()
size <- memory.size()
#print(paste("Memory usage: ",size," for", Infor))
if(is.null(Memory)) {
Increased=0
Memory =cbind(Infor,size ,Increased)
}else{
Increased=0
Memory.current=cbind(Infor,size ,Increased)
Memory=rbind(Memory,Memory.current)
Memory[nrow(Memory),3]=as.numeric(as.matrix(Memory[nrow(Memory),2]))-as.numeric(as.matrix(Memory[nrow(Memory)-1,2]))
}

return (Memory)
}#end of GAPIT.Memory function

##############################################################################################
GAPIT.Memory.Object <- function(name.of.trait="Trait"){
# Object: To report memoery usage
# Authors: Heuristic Andrew
# http://heuristically.wordpress.com/2010/01/04/r-memory-usage-statistics-variable/
# Modified by Zhiwu Zhang
# Last update: may 29, 2011
##############################################################################################

# print aggregate memory usage statistics
print(paste('R is using', memory.size(), 'MB out of limit', memory.limit(), 'MB'))

# create function to return matrix of memory consumption
object.sizes <- function()
{
    return(rev(sort(sapply(ls(envir=.GlobalEnv), function (object.name)
        object.size(get(object.name))))))
}

# export file in table format
memory=object.sizes()
file=paste("GAPIT.", name.of.trait,".Memory.Object.csv" ,sep = "")
write.table(memory, file, quote = FALSE, sep = ",", row.names = TRUE,col.names = TRUE)


# export file in PDF format
pdf(paste("GAPIT.", name.of.trait,".Memory.Object.pdf" ,sep = ""))
# draw bar plot
barplot(object.sizes(),
    main="Memory usage by object", ylab="Bytes", xlab="Variable name",
    col=heat.colors(length(object.sizes())))
# draw dot chart
dotchart(object.sizes(), main="Memory usage by object", xlab="Bytes")
# draw pie chart
pie(object.sizes(), main="Memory usage by object")
dev.off()
}



##############################################################################################
GAPIT.Timmer <- function(Timmer=NULL,Infor){
#Object: To report current time
#Output: Timmer
#Authors: Zhiwu Zhang
# Last update: may 8, 2011
##############################################################################################

Time<- Sys.time()
if(is.null(Timmer)) {
Elapsed=0
Timmer=cbind(Infor,Time,Elapsed)
}else{
Elapsed=0
Timmer.current=cbind(Infor,Time,Elapsed)
Timmer=rbind(Timmer,Timmer.current)
Timmer[nrow(Timmer),3]=as.numeric(as.matrix(Timmer[nrow(Timmer),2]))-as.numeric(as.matrix(Timmer[nrow(Timmer)-1,2]))
}

#print(paste('Time used: ', Timmer[nrow(Timmer),3], ' seconds for ',Infor,sep="" ))
return (Timmer)
}#end of GAPIT.EMMAxP3D function


##############################################################################################
GAPIT.Log <- function(Y=Y,KI=KI,Z=Z,CV=CV,SNP.P3D=SNP.P3D,
				group.from = group.from ,group.to =group.to ,group.by = group.by ,kinship.cluster = kinship.cluster, kinship.group= kinship.group,
                      	ngrid = ngrid , llin = llin , ulim = ulim , esp = esp ,name.of.trait = name.of.trait){
#Object: To report model factors
#Output: Text file (GAPIT.Log.txt)
#Authors: Zhiwu Zhang
# Last update: may 16, 2011
##############################################################################################

#Creat storage
facto <- list(NULL)
value <- list(NULL)

#collecting model factors

facto[[1]]="Trait"
value[[1]]=paste(dim(Y))

facto[[2]]="group.by "
value[[2]]=group.by

facto[[3]]="Trait name "
value[[3]]=name.of.trait

facto[[4]]="Kinship"
value[[4]]=dim(KI)

facto[[5]]="Z Matrix"
value[[5]]=dim(Z)

facto[[6]]="Covariate"
value[[6]]=dim(CV)

facto[[7]]="SNP.P3D"
value[[7]]=SNP.P3D

facto[[8]]="Clustering algorithms"
value[[8]]=kinship.cluster

facto[[9]]="Group kinship"
value[[9]]=kinship.group

facto[[10]]="group.from "
value[[10]]=group.from

facto[[11]]="group.to "
value[[11]]=group.to



theLog=as.matrix(cbind(facto,value))
#theLog=as.character(as.matrix(cbind(facto,value)))
colnames(theLog)=c("Model", "Value")
file=paste("GAPIT.", name.of.trait,".Log.csv" ,sep = "")
write.table(theLog, file, quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)

return (theLog)
}


##############################################################################################
GAPIT.Perform.BH.FDR.Multiple.Correction.Procedure <- function(PWI = PWI, FDR.Rate = 0.05, FDR.Procedure = "BH"){
#Object: Conduct the Benjamini-Hochberg FDR-Controlling Procedure
#Output: PWIP, number.of.significant.SNPs
#Authors: Alex Lipka and Zhiwu Zhang
# Last update: May 5, 2011
##############################################################################################


    #Make sure that your compouter has the latest version of Bioconductor (the "Biobase" package) and multtest

if(is.null(PWI))
{
PWIP=NULL
number.of.significant.SNPs = 0
}

if(!is.null(PWI))
{

    #library(multtest)

    if(dim(PWI)[1] == 1){
     PWIP <- cbind(PWI, PWI[4])
     colnames(PWIP)[9] <- "FDR_Adjusted_P-values"
    }

    if(dim(PWI)[1] > 1){
    #mt.rawp2adjp Performs the Simes procedure.  The output should be two columns, Left column: originial p-value
    #Right column: Simes corrected p-value
    res <- mt.rawp2adjp(PWI[,4], FDR.Procedure)

    #This command should order the p-values in the order of the SNPs in the data set
  adjp <- res$adjp[order(res$index), ]

  #round(adjp[1:7,],4)
    #Logical statment: 0, if Ho is not rejected; 1, if  Ho is rejected, by the Simes corrected p-value
#  temp <- mt.reject(adjp[,2], FDR.Rate)

    #Lists all number of SNPs that were rejected by the BY procedure
  #temp$r

    #Attach the FDR adjusted p-values to AS_Results

  PWIP <- cbind(PWI, adjp[,2])

    #Sort these data by lowest to highest FDR adjusted p-value
  PWIP <- PWIP[order(PWIP[,4]),]

  colnames(PWIP)[9] <- "FDR_Adjusted_P-values"
#  number.of.significant.SNPs = temp$r
  }
  #print("GAPIT.Perform.BH.FDR.Multiple.Correction.Procedure accomplished successfully!")
}
  #return(list(PWIP=PWIP, number.of.significant.SNPs = number.of.significant.SNPs))
  return(list(PWIP=PWIP))

}



##############################################################################################
GAPIT.Pruning <- function(values,DPP=5000){
#Object: To get index of subset that evenly distribute
#Output: Index
#Authors: Zhiwu Zhang
# Last update: May 28, 2011
##############################################################################################

#No change if below the requirement
if(length(values)<=DPP)return(c(1:length(values)))

#values= log.P.values

values=sqrt(values)  #This shift the weight a little bit to the low building.
theMin=min(values)
theMax=max(values)
range=theMax-theMin
interval=range/DPP

ladder=round(values/interval)
ladder2=c(ladder[-1],0)
keep=ladder-ladder2
index=which(keep>0)

return(index)
}#end of GAPIT.Pruning



##############################################################################################
GAPIT.QQ <- function(P.values, plot.type = "log_P_values", name.of.trait = "Trait",DPP=50000){
#Object: Make a QQ-Plot of the P-values
#Options for plot.type = "log_P_values" and "P_values"
#Output: A pdf of the QQ-plot
#Authors: Alex Lipka and Zhiwu Zhang
# Last update: May 9, 2011
##############################################################################################


# Sort the data by the raw P-values
print("Sorting p values")
print(paste("Number of P values: ",length(P.values)))
if(length(P.values[P.values>0])<1) return(NULL)

DPP=round(DPP/4) #Reduce to 1/4 for QQ plot


P.values <- P.values[order(P.values)]

#Set up the p-value quantiles
print("Setting p_value_quantiles...")
p_value_quantiles <- (1:length(P.values))/(length(P.values)+1)


if(plot.type == "log_P_values")
{
    log.P.values <- -log10(P.values)
    log.Quantiles <- -log10(p_value_quantiles)

    index=GAPIT.Pruning(log.P.values,DPP=DPP)
    log.P.values=log.P.values[index ]
    log.Quantiles=log.Quantiles[index]

    pdf(paste("GAPIT.", name.of.trait,".QQ-Plot.pdf" ,sep = ""))
    par(mar = c(5,5,5,5))
    qqplot(log.Quantiles, log.P.values, xlim = c(0,max(log.Quantiles)), ylim = c(0,max(log.P.values)),
           cex.axis=1.5, cex.lab=2, lty = 1, lwd = 1, col = "Blue" ,xlab =expression(Expected~~-log[10](italic(p))),
           ylab = expression(Observed~~-log[10](italic(p))), main = paste(name.of.trait,sep=" "))
    abline(a = 0, b = 1, col = "red")
    dev.off()
}


if(plot.type == "P_values")
{
  pdf(paste("QQ-Plot_", name.of.trait,".pdf" ,sep = ""))
  par(mar = c(5,5,5,5))
  qqplot(p_value_quantiles, P.values, xlim = c(0,1),
         ylim = c(0,1), type = "l" , xlab = "Uniform[0,1] Theoretical Quantiles",
         lty = 1, lwd = 1, ylab = "Quantiles of P-values from GWAS", col = "Blue",
         main = paste(name.of.trait,sep=" "))
  abline(a = 0, b = 1, col = "red")
  dev.off()
}


  #print("GAPIT.QQ  accomplished successfully!")


}


##############################################################################################
GAPIT.Manhattan <- function(GI.MP = NULL, name.of.trait = "Trait",
                   plot.type = "Genomewise",DPP=50000,cutOff=0.01){
#Object: Make a Manhattan Plot
#Options for plot.type = "Separate_Graph_for_Each_Chromosome" and "Same_Graph_for_Each_Chromosome"
#Output: A pdf of the Manhattan Plot
#Authors: Alex Lipka, Zhiwu Zhang, and Meng Li
# Last update: May 10, 2011
##############################################################################################

print("Manhattan ploting...")

#do nothing if null input
if(is.null(GI.MP)) return

GI.MP=matrix(as.numeric(as.matrix(GI.MP) ) ,nrow(GI.MP),ncol(GI.MP))

#Remove all SNPs that do not have a choromosome and bp position
GI.MP <- GI.MP[!is.na(GI.MP[,1]),]
GI.MP <- GI.MP[!is.na(GI.MP[,2]),]

#Remove all SNPs that have P values above 0 (not na etc)
GI.MP <- GI.MP[GI.MP[,3]>0,]
numMarker=nrow(GI.MP)
bonferroniCutOff=-log10(cutOff/numMarker)

print("debug for plot")
print(numMarker)
print(bonferroniCutOff)

#Replace P the -log10 of the P-values
GI.MP[,3] <-  -log10(GI.MP[,3])
y.lim <- ceiling(max(GI.MP[,3]))
chm.to.analyze <- unique(GI.MP[,1])
chm.to.analyze=chm.to.analyze[order(chm.to.analyze)]
numCHR= length(chm.to.analyze)

#Chromosomewise plot
if(plot.type == "Chromosomewise")
{
print("Manhattan ploting Chromosomewise")

  pdf(paste("GAPIT.", name.of.trait,".Manhattan-Plot.Chromosomewise.pdf" ,sep = ""), width = 10)
  par(mar = c(5,5,4,3), lab = c(8,5,7))
  for(i in 1:numCHR)
  {
    #Extract SBP on this chromosome
    subset=GI.MP[GI.MP[,1]==chm.to.analyze[i],]
  	#print(paste("CHR: ",i, " #SNPs: ",length(subset),sep=""))
  	#print(dim(subset))
  	#print((subset))
  	y.lim <- ceiling(max(subset[,3]))  #set upper for each chr

  	if(length(subset)>3){
      x <- as.numeric(subset[,2])/10^(6)
      y <- as.numeric(subset[,3])
    }else{
      x <- as.numeric(subset[2])/10^(6)
      y <- as.numeric(subset[3])
    }
 	  #print(paste("befor prune: chr: ",i, "length: ",length(x),"max p",max(y), "min p",min(y), "max x",max(x), "Min x",min(x)))



  	#Prune most non important SNPs off the plots
    order=order(y,decreasing = TRUE)
    y=y[order]
    x=x[order]

    index=GAPIT.Pruning(y,DPP=round(DPP/numCHR))

  	x=x[index]
  	y=y[index]


 	  #print(paste("after prune: chr: ",i, "length: ",length(x),"max p",max(y), "min p",min(y), "max x",max(x), "Min x",min(x)))

    #color.vector <- subset(temp.par.data[,7], temp.par.data[,4] == i)
    plot(y~x,type="p", ylim=c(0,y.lim), xlim = c(min(x), max(x)), col = "navy", xlab = expression(Base~Pairs~(x10^-6)), ylab = "-Log Base 10 p-value", main = paste("Chromosome",chm.to.analyze[i],sep=" "))

abline(h=bonferroniCutOff,col="forestgreen")
  	#print("manhattan plot (chr) finished")
  }
  dev.off()
  print("manhattan plot on chromosome finished")
} #Chromosomewise plot


#Genomewise plot
if(plot.type == "Genomewise")
{
print("Manhattan ploting Genomewise")

#write.table(GI.MP, "GI.MP.csv", quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)

  GI.MP <- GI.MP[order(GI.MP[,2]),]
  GI.MP <- GI.MP[order(GI.MP[,1]),]
  color.vector <- rep(c("orangered","navyblue"),numCHR)
  ticks=NULL
  lastbase=0

#print("Manhattan data sorted")
#print(chm.to.analyze)


  #change base position to accumulatives
  for (i in chm.to.analyze)
  {
    index=(GI.MP[,1]==i)
    ticks <- c(ticks, lastbase+mean(GI.MP[index,2]))
    GI.MP[index,2]=GI.MP[index,2]+lastbase
    lastbase=max(GI.MP[index,2])
  }

  #print("Manhattan chr processed")

    x0 <- as.numeric(GI.MP[,2])
    y0 <- as.numeric(GI.MP[,3])
    z0 <- as.numeric(GI.MP[,1])
	position=order(y0,decreasing = TRUE)
    index0=GAPIT.Pruning(y0[position],DPP=DPP)
	index=position[index0]
	x=x0[index]
	y=y0[index]
	z=z0[index]

#print("Manhattan XY created")

  pdf(paste("GAPIT.", name.of.trait,".Manhattan-Plot.Genomewise.pdf" ,sep = ""), width = 10)
  par(mar = c(5,5,5,1))

 plot(y~x,xlab=expression(Chromosome),ylab=expression(-log[10](italic(p))) ,
       cex.lab=2,col=ifelse(z%%2==0,"orangered","navy"),axes=FALSE,type = "p",pch=20,main = paste(name.of.trait,sep=" "))
 abline(h=bonferroniCutOff,col="forestgreen")

 axis(1, at=ticks,cex.axis=1.5,labels=chm.to.analyze,tick=F)
  axis(2, at=1:y.lim,cex.axis=1.5,labels=1:y.lim,tick=F)
  box()
  dev.off()
print("Manhattan done Genomewise")

} #Genomewise plot

  print("GAPIT.Manhattan accomplished successfully!")
} #end of GAPIT.Manhattan


##############################################################################################
GAPIT.Compression.Visualization <- function(Compression = Compression, name.of.trait = name.of.trait){
#Object: Conduct the Benjamini-Hochberg FDR-Controlling Procedure
#Output: Three pdfs: One of the log likelihood function, one of the genetic and error variance component,
#                    and one of the heritabilities
#Authors: Alex Lipka and Zhiwu Zhang
# Last update: May 10, 2011
##############################################################################################

#Graph the optimum compression

#print("Compression")
#print(Compression)

if(length(Compression)<=6) Compression=t(as.matrix(Compression[which(Compression[,4]!="NULL" | Compression[,4]!="NaN"),]))
if(length(Compression)==6) Compression=matrix(Compression,1,6)
#print("Compression matrix")
#print(Compression)
#print(length(Compression) )

if(length(Compression)>6) Compression=Compression[which(Compression[,4]!="NULL" | Compression[,4]!="NaN"),]

#print("Checking")
if(length(Compression)<1) return() #no result

#Pie chart for the optimum setting
#-------------------------------------------------------------------------------
print("Pie chart")
LL=as.numeric(Compression[,4])
Compression.best=Compression[1,]
variance=as.numeric(Compression.best[5:6])
colors <- c("grey50","grey70")
labels0 <- round(variance/sum(variance) * 100, 1)
labels <- paste(labels0, "%", sep="")
LL.best0=as.numeric(Compression.best[4]  )
LL.best=floor(LL.best0*100)/100
theOptimum=paste(c(Compression.best[c(1:3)],LL.best) )

pdf(paste("GAPIT.", name.of.trait,".Optimum.pdf", sep = ""), width = 14)
par(mfrow = c(1,1), mar = c(1,1,5,5), lab = c(5,5,7))
pie(variance,  col=colors, labels=labels,angle=45)
legend(1.0, 0.5, c("Genetic variance","Residual variance"), cex=1.5,
   fill=colors)

#Display the optimum compression
text(1.5,.0, "The optimum compression", col= "red")
for(i in 1:4){
text(1.5,-.1*i, theOptimum[i], col= "red")
}
dev.off()

#sort Compression by group number for plot order
Compression=Compression[order(as.numeric(Compression[,3])),]

#Graph compression with multiple groups
#print("Graph compression with multiple groups")


if(length(Compression)==6) return() #For to exit if only one row


#print("It should not go here")

if(length(unique(Compression[,3]))>1)
{
#Create a vector of colors
#print("Setting colors")
color.vector.basic <- c("red","blue","black", "blueviolet","indianred","cadetblue","orange")
color.vector.addition <- setdiff(c(colors()[grep("red",colors())], colors()[grep("blue",colors())]),color.vector.basic )
color.vector.addition.mixed <- sample(color.vector.addition,max(0,((length(unique(Compression[,1])) * length(unique(Compression[,2])))-length(color.vector.basic))))
color.vector <- c(color.vector.basic,color.vector.addition.mixed )


#Create a vector of numbers for the line dot types
line.vector <-  rep(1:(length(unique(Compression[,1])) * length(unique(Compression[,2]))))

#We want to have a total of three plots, one displaying the likelihood function, one displaying the variance components, and one displaying the
# heritability

pdf(paste("GAPIT.", name.of.trait,".Compression.multiple.group.", ".pdf", sep = ""), width = 14)
par(mfrow = c(2,3), mar = c(5,5,1,1), lab = c(5,5,7))

# Make the likelihood function plot
#print("Likelihood")
k <- 1
for(i in 1:length(unique(Compression[,1]))){
  for(j in 1:length(unique(Compression[,2]))){

     if((i == 1)&(j == 1)) {
      Compression.subset <- Compression[which( (Compression[,1] == as.character(unique(Compression[,1])[i])) & (Compression[,2] == as.character(unique(Compression[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,4])
      plot(y~x,type="l", pch = 30, lty = line.vector[i], ylim=c(min(as.numeric(Compression[,4])),max(as.numeric(Compression[,4]))), xlim = c(min(as.numeric(Compression[,3])),max(as.numeric(Compression[,3]))),
      col = color.vector[j], xlab = "Number of Groups", ylab = "-2Log Likelihoood", )
      label = paste(c(as.character(unique(Compression[,1]))[k]," ",as.character(unique(Compression[,2]))[j]), collapse = "")
      }

    if((i != 1)|(j != 1)) {
      k <- k+1
      Compression.subset <- Compression[which( (Compression[,1] == as.character(unique(Compression[,1])[i])) & (Compression[,2] == as.character(unique(Compression[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,4])
      lines(y~x,type="l", pch = 30, lty = line.vector[i], col = color.vector[j])
      label = c(label, paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = ""))
      }
   }
 }
 #Make a legend
  #legend("topright",  label, fill = color.vector)



# Make the genetic variance component plots
#print("genetic variance")
k <- 1
for(i in 1:length(unique(Compression[,1]))){
  for(j in 1:length(unique(Compression[,2]))){

     if((i == 1)&(j == 1)) {
      Compression.subset <- Compression[which( (Compression[,1] == as.character(unique(Compression[,1])[i])) & (Compression[,2] == as.character(unique(Compression[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,5])
      plot(y~x,type="l", pch = 17,  lty = line.vector[i], ylim=c(min(as.numeric(Compression[,5])),max(as.numeric(Compression[,5]))), xlim = c(min(as.numeric(Compression[,3])),max(as.numeric(Compression[,3]))),
      col = color.vector[j], xlab = "Number of Groups", ylab = "Genetic Variance", )
      #label = paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = "")
      }

    if((i != 1)|(j != 1)) {
      k <- k+1
      Compression.subset <- Compression[which( (Compression[,1] == as.character(unique(Compression[,1])[i])) & (Compression[,2] == as.character(unique(Compression[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,5])
      lines(y~x,type="l", pch = 17, lty = line.vector[i], col = color.vector[j])
      #label = c(label, paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = ""))
      }
   }
 }
 #Make a legend
  #legend("topleft",  label, fill = color.vector)


# Make the residual variance component plots
k <- 1
for(i in 1:length(unique(Compression[,1]))){
  for(j in 1:length(unique(Compression[,2]))){

     if((i == 1)&(j == 1)) {
      Compression.subset <- Compression[which( (Compression[,1] == as.character(unique(Compression[,1])[i])) & (Compression[,2] == as.character(unique(Compression[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,6])
      plot(y~x,type="l", pch = 17,  ylim=c(min(as.numeric(Compression[,6])),max(as.numeric(Compression[,6]))), xlim = c(min(as.numeric(Compression[,3])),max(as.numeric(Compression[,3]))),
      col = color.vector[j], xlab = "Number of Groups", ylab = "Residual Variance", )
      #label = paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = "")
      }

    if((i != 1)|(j != 1)) {
      k <- k+1
      Compression.subset <- Compression[which( (Compression[,1] == as.character(unique(Compression[,1])[i])) & (Compression[,2] == as.character(unique(Compression[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,6])
      lines(y~x,type="l", pch = 17, lty = line.vector[i], col = color.vector[j])
      #label = c(label, paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = ""))
      }
   }
 }
 #Make a legend
  #legend("topright",  label, fill = color.vector)


#calculate total variance and h2
#print("h2")
heritablilty.vector <- as.numeric(Compression[,5])/(as.numeric(Compression[,5]) + as.numeric(Compression[,6]))
totalVariance.vector <- as.numeric(as.numeric(Compression[,5]) + as.numeric(Compression[,6]))
Compression.h2 <- cbind(Compression, heritablilty.vector,totalVariance.vector)

# Make the total variance component plots
#print("Total variance")
k <- 1
for(i in 1:length(unique(Compression.h2[,1]))){
  for(j in 1:length(unique(Compression.h2[,2]))){

     if((i == 1)&(j == 1)) {
      Compression.subset <- Compression.h2[which( (Compression.h2[,1] == as.character(unique(Compression.h2[,1])[i])) & (Compression.h2[,2] == as.character(unique(Compression.h2[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,8])
      plot(y~x,type="l", pch = 17,  lty = line.vector[k], ylim=c(min(as.numeric(Compression.h2[,8])),max(as.numeric(Compression.h2[,8]))), xlim = c(min(as.numeric(Compression.h2[,3])),max(as.numeric(Compression.h2[,3]))),
      col = color.vector[1], xlab = "Number of Groups", ylab = "Total Variance", )
      #label = paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = "")
      }

    if((i != 1)|(j != 1)) {
      k <- k+1
      Compression.subset <- Compression.h2[which( (Compression.h2[,1] == as.character(unique(Compression.h2[,1])[i])) & (Compression.h2[,2] == as.character(unique(Compression.h2[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,8])
      lines(y~x,type="l", pch = 17, lty = line.vector[i], col = color.vector[j])
      #label = c(label, paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = ""))
      }
   }
 }
 #Make a legend
  #legend("topright",  label, fill = color.vector)


# Make the heritability plots
#print("h2 plot")
k <- 1
for(i in 1:length(unique(Compression[,1]))){
  for(j in 1:length(unique(Compression[,2]))){

     if((i == 1)&(j == 1)) {
      Compression.subset <- Compression.h2[which( (Compression.h2[,1] == as.character(unique(Compression.h2[,1])[i])) & (Compression.h2[,2] == as.character(unique(Compression.h2[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,7])

      plot(y~x,type="l", pch = 17,  lty = line.vector[k], ylim=c(min(as.numeric(Compression.h2[,7])),max(as.numeric(Compression.h2[,7]))), xlim = c(min(as.numeric(Compression.h2[,3])),max(as.numeric(Compression.h2[,3]))),
      col = color.vector[1], xlab = "Number of Groups", ylab = "Heritability", )
      #label = paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = "")
      }

    if((i != 1)|(j != 1)) {
      k <- k+1
      Compression.subset <- Compression.h2[which( (Compression.h2[,1] == as.character(unique(Compression.h2[,1])[i])) & (Compression.h2[,2] == as.character(unique(Compression.h2[,2])[j]))  ),              ]
      x <- as.numeric(Compression.subset[,3])
      y <- as.numeric(Compression.subset[,7])
      lines(y~x,type="l", lty = line.vector[i], pch = 17, col = color.vector[j])
      #label = c(label, paste(c(as.character(unique(Compression[,1]))[i]," ",as.character(unique(Compression[,2]))[j]), collapse = ""))
      }
   }
 }

 #Make a legend
  #legend("topleft",  label, fill = color.vector)

legend.col= 1+floor(length(unique(Compression[,1])) * length(unique(Compression[,2]))/20)
line.style=rep(1:length(unique(Compression[,1])), each = length(unique(Compression[,2])))
line.color=rep(1:length(unique(Compression[,2])), length(unique(Compression[,1])))



# Make labels
      plot(0~0,axes=FALSE,type="l",ylab = "",xlab = "",frame.plot=FALSE)
      legend("topleft",  label, col = color.vector[line.color], lty = line.style, ncol=legend.col,horiz=FALSE)


dev.off()
}#end of Graph compression with multiple groups

#Graph compression with single groups
#print("Graph compression with single groups")
if(length(unique(Compression[,3]))==1& length(unique(Compression[,1]))*length(unique(Compression[,2]))>1)
{

#Graph the compression with only one group
pdf(paste("GAPIT.Compression.single.group.", name.of.trait, ".pdf", sep = ""), width = 14)
par(mfrow = c(2,2), mar = c(5,5,1,1), lab = c(5,5,7))

nkt=length(unique(Compression[,1]))
nca=length(unique(Compression[,2]))
kvr=rep(c(1:nkt),nca)
kvc0=rep(c(1:nca),nkt)
kvc=as.numeric(t(matrix(kvc0,nca,nkt)))
kt.name=Compression[1:nkt,1]

ca.index=((1:nca)-1)*nkt+1
ca.name=Compression[ca.index,2]

KG<- t(tapply(as.numeric(Compression[,4]), list(kvr, kvc), mean))
colnames(KG)=kt.name
barplot(as.matrix(KG),  ylab= "-2 Log Likelihood",beside=TRUE, col=rainbow(length(unique(Compression[,2]))))


KG<- t(tapply(as.numeric(Compression[,5]), list(kvr, kvc), mean))
colnames(KG)=kt.name
barplot(as.matrix(KG),  ylab= "Genetic varaince", beside=TRUE, col=rainbow(length(unique(Compression[,2]))))

KG<- t(tapply(as.numeric(Compression[,6]), list(kvr, kvc), mean))
colnames(KG)=kt.name
barplot(as.matrix(KG),  ylab= "Residual varaince", beside=TRUE, col=rainbow(length(unique(Compression[,2]))))

KG<- t(tapply(as.numeric(Compression[,5])/(as.numeric(Compression[,5])+as.numeric(Compression[,6])), list(kvr, kvc), mean))
colnames(KG)=kt.name
barplot(as.matrix(KG),  ylab= "Heritability", beside=TRUE, col=rainbow(length(unique(Compression[,2]))),ylim=c(0,1))

legend("topleft", paste(t(ca.name)), cex=0.8,bty="n", fill=rainbow(length(unique(Compression[,2]))),horiz=TRUE)
dev.off()
} #end of Graph compression with single groups

print("GAPIT.Compression.Visualization accomplished successfully!")

}#GAPIT.Compression.Plots ends here





##############################################################################################
GAPIT.Table <- function(final.table = final.table, name.of.trait = name.of.trait,SNP.FDR=1){
#Object: Make and export a table of summary information from GWAS
#Output: A table summarizing GWAS results
#Authors: Alex Lipka and Zhiwu Zhang
# Last update: May 10, 2011
##############################################################################################

#Filter SNPs by FDR
index=(final.table[,7]<=SNP.FDR)
final.table=final.table[index,]

#Export this summary table as an excel file
write.table(final.table, paste("GAPIT.", name.of.trait, ".GWAS.Results.csv", sep = ""), quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)


#print("GAPIT.Table accomplished successfully!")


}   #GAPIT.Table ends here



##############################################################################################
GAPIT.GS.Visualization <- function(gsBLUP = gsBLUP, BINS=BINS, name.of.trait = name.of.trait){
#Object: To build heat map to show distribution of BLUP and PEV
#Output: pdf
#Authors: Zhiwu Zhang
# Last update: May 15, 2011
##############################################################################################


nBin=BINS

BLUP= gsBLUP[,5]
PEV = gsBLUP[,6]

if(BLUP[1]=="NaN"){
  warning ("It was not converged. BLUP was not created!")
}
if(BLUP[1]!="NaN" )
{


BLUP.max=try(max(BLUP))
BLUP.min=try(min(BLUP))
if(inherits(BLUP.max, "try-error"))  return()

  range.BLUP=BLUP.max-BLUP.min
  range.PEV=max(PEV)-min(PEV)

  interval.BLUP=range.BLUP/nBin
  interval.PEV=range.PEV/nBin


  bin.BLUP=floor(BLUP/max(BLUP)*nBin)*max(BLUP)/nBin
  bin.PEV=floor(PEV/max(PEV)*nBin)*max(PEV)/nBin


  distinct.BLUP=unique(bin.BLUP)
  distinct.PEV=unique(bin.PEV)

  if((length(distinct.BLUP)<2)  | (length(distinct.PEV)<2) ) return() #nothing to plot

  Position.BLUP=match(bin.BLUP,distinct.BLUP,nomatch = 0)
  Position.PEV=match(bin.PEV,distinct.PEV,nomatch = 0)

  value=matrix(1,length(Position.BLUP))
  KG<- (tapply(as.numeric(value), list(Position.BLUP, Position.PEV), sum))

  rownames(KG)=round(distinct.BLUP, digits = 4)
  colnames(KG)=round(distinct.PEV, digits = 4)

  #Sort the rows and columns in order from smallest to largest

  rownames(KG) <- rownames(KG)[order(as.numeric(rownames(KG)))]
  colnames(KG) <- colnames(KG)[order(as.numeric(colnames(KG)))]

  #write.table(KG, "Input_Matrix_for_GS_Heat_Map.txt", quote = FALSE, sep = "\t", row.names = FALSE,col.names = FALSE)

  pdf(paste("GAPIT.", name.of.trait,".GPS.BLUPvsPEV", ".pdf", sep = ""),width = 9)
  #par(mfrow = c(1,1), mar = c(1,1,5,5), lab = c(5,5,7))
  par(mar = c(5,5,6,5))

  nba_heatmap <- heatmap(KG, Rowv=NA, Colv=NA,  col =  rev(heat.colors(256)),   scale="column",
  xlab = "PEV", ylab = "BLUP", main = " ")

  #nba_heatmap <- heatmap.2(KG,  cexRow =.2, cexCol = 0.2, scale="none", symkey=FALSE, trace="none" )


  #cexRow =0.9, cexCol = 0.9)
  dev.off()
}
#print("GAPIT.GS.Visualization accomplished successfully!")

}   #GAPIT.GS.Visualization ends here



##############################################################################################
GAPIT.kinship.loiselle <- function(snps, method="additive", use="all") {
# Object: To calculate the kinship matrix using the method of Loiselle et al. (1995)
# Authors: Alex Lipka and Hyun Min Kang
# Last update: May 31, 2011
##############################################################################################


  #Number of SNP types that are 0s
  n0 <- sum(snps==0,na.rm=TRUE)
  #Number of heterozygote SNP types
  nh <- sum(snps==1,na.rm=TRUE)
  #Number of SNP types that are 1s
  n1 <- sum(snps==2,na.rm=TRUE)
  #Number of SNP types that are missing
  nNA <- sum(is.na(snps))



  #Self explanatory
  dim(snps)[1]*dim(snps)[2]
  #stopifnot(n0+nh+n1+nNA == length(snps))


  #Note that the two lines in if(method == "dominant") and if(method == "recessive") are found in
  #if(method == "additive").  Worry about this only if you have heterozygotes, which you do not.
  if( method == "dominant" ) {
    flags <- matrix(as.double(colMeans(snps,na.rm=TRUE) > 1),ncol(snps),nrow(snps))
    snps[!is.na(snps) && (snps == 1)] <- flags[!is.na(snps) && (snps == 1)]
  }
  else if( method == "recessive" ) {
    flags <- matrix(as.double(colMeans(snps,na.rm=TRUE) < 1),ncol(snps),nrow(snps))
    snps[!is.na(snps) && (snps == 1)] <- flags[!is.na(snps) && (snps == 1)]
  }
  else if( ( method == "additive" ) && ( nh > 0 ) ) {
    dsnps <- snps
    rsnps <- snps
    flags <- matrix(as.double(colMeans(snps,na.rm=TRUE) > 1),ncol(snps),nrow(snps))
    dsnps[!is.na(snps) && (snps==1)] <- flags[is.na(snps) && (snps==1)]
    flags <- matrix(as.double(colMeans(snps,na.rm=TRUE) < 1),ncol(snps),nrow(snps))
    rsnps[!is.na(snps) && (snps==1)] <- flags[is.na(snps) && (snps==1)]
    snps <- cbind(dsnps,rsnps)
  }

  #mafs is a (# lines)x(# SNPs)x matrix.  The rows mafs are identical, and the ij^th element is the average
  #allele frequency for the SNP in the j^th column.

  #if(use == "all") imputes missing SNP type values with the expected (average) allele frequency.
  if( use == "all" ) {
    mafs <- matrix(colMeans(snps,na.rm=TRUE),ncol(snps),nrow(snps))
    snps[is.na(snps)] <- mafs[is.na(snps)]
  }
  else if( use == "complete.obs" ) {
    mafs <- matrix(colMeans(snps,na.rm=TRUE),ncol(snps),nrow(snps))
    snps <- snps[colSums(is.na(snps))==0,]
  }
  mafs_comp <- 1-mafs
  snps_comp <- 1-snps


  n <- nrow(snps)
  K <- matrix(nrow=n,ncol=n)
  diag(K) <- 1
  #Create the k term on page 1422 of Loiselle et al. (1995)

  missing <- rep(NA, dim(snps)[2])
  for(i in 1:dim(snps)[2]) {
    missing[i] <- sum(is.na(snps[,i]))
  }


  for(i in 1:(n-1)) {
    for(j in (i+1):n) {
      Num_First_Term_1 <- (snps[i,]-mafs[i,])*(snps[j,]-mafs[j,])
      Num_First_Term_2 <- (snps_comp[i,]-mafs_comp[i,])*(snps_comp[j,]-mafs_comp[j,])
      First_Term <- sum(Num_First_Term_1)+sum(Num_First_Term_2)

      Num_Second_Term_1 <- mafs[,i]*(1-mafs[,i])
      Num_Second_Term_2 <- mafs_comp[,i]*(1-mafs_comp[,i])
      Num_Second_Term_Bias_Correction <- 1/((2*n)-missing - 1)
      Num_Second_Term <-  Num_Second_Term_1 + Num_Second_Term_2
      Second_Term <- sum(Num_Second_Term*Num_Second_Term_Bias_Correction)

      Third_Term <- sum(Num_Second_Term)

      f <- (First_Term + Second_Term)/Third_Term
      if(f <= 0){
            K[i,j] <- 0
      }
      else{
            K[i,j] <- f
      }
      K[j,i] <- K[i,j]
    }
  }
  return(K)
}


##############################################################################################

GAPIT.PCA <- function(X,taxa, PC.number = min(ncol(X),nrow(X)),file.output=TRUE){
# Object: Conduct a principal component analysis, and output the prinicpal components into the workspace,
#         a text file of the principal components, and a pdf of the scree plot
# Authors: Alex Lipka and Hyun Min Kang
# Last update: May 31, 2011
##############################################################################################

#Conduct the PCA
PCA.X <- prcomp(X)

#Create a Scree plot
if(file.output) {
pdf("GAPIT.PCA.eigenValue.pdf", width = 12, height = 12)
par(mar = c(5,5,5,5))
screeplot(PCA.X, type="lines")
dev.off()

pdf("GAPIT.PCA.pdf", width = 12, height = 12)
par(mar = c(5,5,5,5))
for(i in 1:(as.numeric(PC.number[1])-1)){
for(j in (i+1):(as.numeric(PC.number[1]))){
plot(PCA.X$x[,i],PCA.X$x[,j],xlab=paste("PC",i,sep=""),ylab=paste("PC",j,sep=""),pch=1,col="red",cex=1.0,cex.lab=1.5, cex.axis=1.2, lwd=2,las=1)
}
}
dev.off()
}

#Extract number of PCs needed
PCs <- cbind(taxa,as.data.frame(PCA.X$x[,1:PC.number]))

#Remove duplicate (This is taken care by QC)
#PCs.unique <- unique(PCs[,1])
#PCs <-PCs[match(PCs.unique, PCs[,1], nomatch = 0), ]

#Write the PCs into a text file
if(file.output) write.table(PCs, "GAPIT.PCA.csv", quote = FALSE, sep = ",", row.names = FALSE,col.names = TRUE)

#Return the PCs
return(PCs)
}




##############################################################################################
GAPIT.kinship.loiselle <- function(snps, method="additive", use="all") {
# Object: To calculate the kinship matrix using the method of Loiselle et al. (1995)
# Authors: Alex Lipka and Hyun Min Kang
# Last update: May 31, 2011
##############################################################################################

  #Number of SNP types that are 0s
  n0 <- sum(snps==0,na.rm=TRUE)
  #Number of heterozygote SNP types
  nh <- sum(snps==0.5,na.rm=TRUE)
  #Number of SNP types that are 1s
  n1 <- sum(snps==1,na.rm=TRUE)
  #Number of SNP types that are missing
  nNA <- sum(is.na(snps))



  #Self explanatory
  dim(snps)[1]*dim(snps)[2]
  #stopifnot(n0+nh+n1+nNA == length(snps))


  #Note that the two lines in if(method == "dominant") and if(method == "recessive") are found in
  #if(method == "additive").  Worry about this only if you have heterozygotes, which you do not.
  if( method == "dominant" ) {
    flags <- matrix(as.double(rowMeans(snps,na.rm=TRUE) > 0.5),nrow(snps),ncol(snps))
    snps[!is.na(snps) && (snps == 0.5)] <- flags[!is.na(snps) && (snps == 0.5)]
  }
  else if( method == "recessive" ) {
    flags <- matrix(as.double(rowMeans(snps,na.rm=TRUE) < 0.5),nrow(snps),ncol(snps))
    snps[!is.na(snps) && (snps == 0.5)] <- flags[!is.na(snps) && (snps == 0.5)]
  }
  else if( ( method == "additive" ) && ( nh > 0 ) ) {
    dsnps <- snps
    rsnps <- snps
    flags <- matrix(as.double(rowMeans(snps,na.rm=TRUE) > 0.5),nrow(snps),ncol(snps))
    dsnps[!is.na(snps) && (snps==0.5)] <- flags[is.na(snps) && (snps==0.5)]
    flags <- matrix(as.double(rowMeans(snps,na.rm=TRUE) < 0.5),nrow(snps),ncol(snps))
    rsnps[!is.na(snps) && (snps==0.5)] <- flags[is.na(snps) && (snps==0.5)]
    snps <- rbind(dsnps,rsnps)
  }

  #mafs is a (# SNPs)x(# lines) matrix.  The columns of mafs are identical, and the ij^th element is the average
  #allele frequency for the SNP in the i^th row.

  #if(use == "all") imputes missing SNP type values with the expected (average) allele frequency.
  if( use == "all" ) {
    mafs <- matrix(rowMeans(snps,na.rm=TRUE),nrow(snps),ncol(snps))
    snps[is.na(snps)] <- mafs[is.na(snps)]
  }
  else if( use == "complete.obs" ) {
    mafs <- matrix(rowMeans(snps,na.rm=TRUE),nrow(snps),ncol(snps))
    snps <- snps[rowSums(is.na(snps))==0,]
  }
  mafs_comp <- 1-mafs
  snps_comp <- 1-snps


  n <- ncol(snps)
  K <- matrix(nrow=n,ncol=n)
  diag(K) <- 1
  #Create the k term on page 1422 of Loiselle et al. (1995)

  missing <- rep(NA, dim(snps)[1])
  for(i in 1:dim(snps)[1]) {
    missing[i] <- sum(is.na(snps[i,]))
  }


  for(i in 1:(n-1)) {
    for(j in (i+1):n) {
      Num_First_Term_1 <- (snps[,i]-mafs[,i])*(snps[,j]-mafs[,j])
      Num_First_Term_2 <- (snps_comp[,i]-mafs_comp[,i])*(snps_comp[,j]-mafs_comp[,j])
      First_Term <- sum(Num_First_Term_1)+sum(Num_First_Term_2)

      Num_Second_Term_1 <- mafs[,i]*(1-mafs[,i])
      Num_Second_Term_2 <- mafs_comp[,i]*(1-mafs_comp[,i])
      Num_Second_Term_Bias_Correction <- 1/((2*n)-missing - 1)
      Num_Second_Term <-  Num_Second_Term_1 + Num_Second_Term_2
      Second_Term <- sum(Num_Second_Term*Num_Second_Term_Bias_Correction)

      Third_Term <- sum(Num_Second_Term)

      f <- (First_Term + Second_Term)/Third_Term

      K[i,j] <- f
      if(K[i,j]<0) K[i,j]=0

      K[j,i] <- K[i,j]
    }
  }
  return(K)
}

##############################################################################################
GAPIT.replaceNaN <- function(LL) {
#handler of grids with NaN log
#Authors: Zhiwu Zhang
# Last update: may 12, 2011
##############################################################################################

#handler of grids with NaN log
index=(LL=="NaN")
if(length(index)>0) theMin=min(LL[!index])
if(length(index)<1) theMin="NaN"
LL[index]=theMin
return(LL)
}

################################################################################################################
emma.REMLE <- function(y, X, K, Z=NULL, ngrids=100, llim=-10, ulim=10,
              esp=1e-10, eig.L = NULL, eig.R = NULL) {
# Authors: Hyun Min Kang
# Modified (only one line) by Zhiwu Zhang to handle non-defined LL ("NaN") by replacing it with the worst LL.
# Last update: June 8, 2011
################################################################################################################


  n <- length(y)
  t <- nrow(K)
  q <- ncol(X)

#  stopifnot(nrow(K) == t)
  stopifnot(ncol(K) == t)
  stopifnot(nrow(X) == n)

  if( det(crossprod(X,X)) == 0 ) {
    warning("X is singular")
    return (list(REML=0,delta=0,ve=0,vg=0))
  }

  if(is.null(Z) ) {
    if(is.null(eig.R) ) {
      eig.R <- emma.eigen.R.wo.Z(K,X)
    }
    etas <- crossprod(eig.R$vectors,y)

    logdelta <- (0:ngrids)/ngrids*(ulim-llim)+llim
    m <- length(logdelta)
    delta <- exp(logdelta)
    Lambdas <- matrix(eig.R$values,n-q,m) + matrix(delta,n-q,m,byrow=TRUE)
    Etasq <- matrix(etas*etas,n-q,m)
    LL <- 0.5*((n-q)*(log((n-q)/(2*pi))-1-log(colSums(Etasq/Lambdas)))-colSums(log(Lambdas)))
    dLL <- 0.5*delta*((n-q)*colSums(Etasq/(Lambdas*Lambdas))/colSums(Etasq/Lambdas)-colSums(1/Lambdas))

    optlogdelta <- vector(length=0)
    optLL <- vector(length=0)
    if( dLL[1] < esp ) {
      optlogdelta <- append(optlogdelta, llim)
      optLL <- append(optLL, emma.delta.REML.LL.wo.Z(llim,eig.R$values,etas))
    }
    if( dLL[m-1] > 0-esp ) {
      optlogdelta <- append(optlogdelta, ulim)
      optLL <- append(optLL, emma.delta.REML.LL.wo.Z(ulim,eig.R$values,etas))
    }

    for(i in 1:(m-1) )
      {
        if( ( dLL[i]*dLL[i+1] < 0 ) && ( dLL[i] > 0 ) && ( dLL[i+1] < 0 ) )
        {
          r <- uniroot(emma.delta.REML.dLL.wo.Z, lower=logdelta[i], upper=logdelta[i+1], lambda=eig.R$values, etas=etas)
          optlogdelta <- append(optlogdelta, r$root)
          optLL <- append(optLL, emma.delta.REML.LL.wo.Z(r$root,eig.R$values, etas))
        }
      }
#    optdelta <- exp(optlogdelta)
  }
  else {
    if(is.null(eig.R) ) {
      eig.R <- emma.eigen.R.w.Z(Z,K,X)
    }
    etas <- crossprod(eig.R$vectors,y)
    etas.1 <- etas[1:(t-q)]
    etas.2 <- etas[(t-q+1):(n-q)]
    etas.2.sq <- sum(etas.2*etas.2)

    logdelta <- (0:ngrids)/ngrids*(ulim-llim)+llim
    m <- length(logdelta)
    delta <- exp(logdelta)
    Lambdas <- matrix(eig.R$values,t-q,m) + matrix(delta,t-q,m,byrow=TRUE)
    Etasq <- matrix(etas.1*etas.1,t-q,m)
    dLL <- 0.5*delta*((n-q)*(colSums(Etasq/(Lambdas*Lambdas))+etas.2.sq/(delta*delta))/(colSums(Etasq/Lambdas)+etas.2.sq/delta)-(colSums(1/Lambdas)+(n-t)/delta))

    optlogdelta <- vector(length=0)
    optLL <- vector(length=0)
    if( dLL[1] < esp ) {
      optlogdelta <- append(optlogdelta, llim)
      optLL <- append(optLL, emma.delta.REML.LL.w.Z(llim,eig.R$values,etas.1,n,t,etas.2.sq))
    }
    if( dLL[m-1] > 0-esp ) {
      optlogdelta <- append(optlogdelta, ulim)
      optLL <- append(optLL, emma.delta.REML.LL.w.Z(ulim,eig.R$values,etas.1,n,t,etas.2.sq))
    }

    for(i in 1:(m-1) )
      {
        if( ( dLL[i]*dLL[i+1] < 0 ) && ( dLL[i] > 0 ) && ( dLL[i+1] < 0 ) )
        {
          r <- uniroot(emma.delta.REML.dLL.w.Z, lower=logdelta[i], upper=logdelta[i+1], lambda=eig.R$values, etas.1=etas.1, n=n, t1=t, etas.2.sq = etas.2.sq )
          optlogdelta <- append(optlogdelta, r$root)
          optLL <- append(optLL, emma.delta.REML.LL.w.Z(r$root,eig.R$values, etas.1, n, t, etas.2.sq ))
        }
      }
#    optdelta <- exp(optlogdelta)
  }

  maxdelta <- exp(optlogdelta[which.max(optLL)])

  #handler of grids with NaN log
  optLL=GAPIT.replaceNaN(optLL)

  maxLL <- max(optLL)
  if(is.null(Z) ) {
    maxva <- sum(etas*etas/(eig.R$values+maxdelta))/(n-q)
  }
  else {
    maxva <- (sum(etas.1*etas.1/(eig.R$values+maxdelta))+etas.2.sq/maxdelta)/(n-q)
  }
  maxve <- maxva*maxdelta

  return (list(REML=maxLL,delta=maxdelta,ve=maxve,vg=maxva))
}



##############################################################################################
GAPIT.kinship.VanRaden<- function(snps,hasInbred=TRUE) {
# Object: To calculate the kinship matrix using the method of VanRaden (2009, J. Dairy Sci. 91:4414???C4423)
# Authors: Zhwiu Zhang
# Last update: August 15, 2011
##############################################################################################

print("Calculating kinship with VanRaden method...")

#snps=hm$GD
nSNP=ncol(snps)
nInd=nrow(snps)
n=nInd
snpMean= apply(snps,2,mean)
snps=snps-snpMean
print("Getting X'X...")
K=tcrossprod((snps), (snps))

print("Adjusting...")
#Extract diagonals
i =1:n
j=(i-1)*n
index=i+j
d=K[index]
DL=min(d)
DU=max(d)
floor=min(K)

K=(K-floor)/(DL-floor)
MD=(DU-floor)/(DL-floor)

#Handler of diagonals over 2
#print("MD")
#print(MD)
#print(K[1:5,1:5])

if(is.na(K[1,1])) stop ("GAPIT says: Missing data is not allowed for numerical genotype data")
if(MD>2)K[index]=K[index]/(MD-1)+1

#Handler of inbred
if(MD<2 & hasInbred) K=2*K/((DU-floor)/(DL-floor))

print("Calculating kinship with VanRaden method: done")

return(K)
}

##############################################################################################
GAPIT.Fragment <- function(file.path=NULL,file.from=NULL, file.to=NULL,file.total=NULL,file.G=NULL,
                          file.Ext.G=NULL,seed=123,SNP.fraction=1,SNP.effect="Add",SNP.impute="Middle",
                          genoFormat=NULL, file.GD=NULL, file.Ext.GD=NULL, file.GM=NULL, file.Ext.GM=NULL, file.fragment=NULL,
                          file=1,frag=1,LD.chromosome=NULL,LD.location=NULL,LD.range=NULL){
#Object: To load SNPs on a (frag)ment in file (this is to replace sampler)
#Output: genotype data sampled
#Authors: Alex Lipka and Zhiwu Zhang
# Last update: August 18, 2011
##############################################################################################

#print("Fragmental reading...")
genoFormat="hapmap"
if(!is.null(file.GD)&is.null(file.G)) genoFormat="EMMA"

if(genoFormat=="hapmap"){
        #Initical G
        #print("Reading file...")
        G=NULL
        if(frag==1){
          skip.1=0
          G <- try(read.delim(paste(file.path,file.G,file, ".",file.Ext.G,sep=""),
                          head = FALSE,skip = skip.1, nrows = file.fragment+1),silent=TRUE)
        }else{
          skip.1 <- (frag-1)*file.fragment +1
          G <- try(read.delim(paste(file.path,file.G,file, ".",file.Ext.G,sep=""),
                          head = FALSE,skip = skip.1, nrows = file.fragment),silent=TRUE )
        }

        #print("processing the data...")
        if(inherits(G, "try-error"))  {
          G=NULL
          #print("File end reached for G!!!")
        }

        if(is.null(G)){
        #print("The above error indicating reading after end of file (It is OK).")
        return(list(GD=NULL,GI=NULL,GT=NULL,linesRead=NULL,GLD=NULL,heading=NULL) )
        }

        #print("Calling hapmap...")
        heading=(frag==1)

        #Recording number of lineas read
        if(heading){
          n= nrow(G)-1
        }else{
          n= nrow(G)
        }

       linesRead=n

        #Sampling
       if(SNP.fraction<1){

          #print("Number of SNP in this pragment:")
          #print(n)

           set.seed(seed+(file*1000)+frag)
          #mySample=sample(1:n,max(2,floor(n*as.numeric(as.vector(SNP.fraction)))))
          mySample=sample(1:n,max(2,floor(n*SNP.fraction)))

          #print(length(mySample))
          if(heading){
            G=G[c(1,(1+mySample)),]
          }else{
            G=G[mySample,]
          }
        } #end of if(SNP.fraction<1)


        print("Call hapmap from fragment")
        hm=GAPIT.HapMap(G,SNP.effect=SNP.effect,SNP.impute=SNP.impute,heading=heading)

        #print("Extracting snps for LD plot...")
        #Extract SNPs for LD plot
        if(!is.null(LD.chromosome) & !is.null(hm$GD)){
          index=(G[,3]==LD.chromosome[1]) & abs((as.numeric(G[,4])-as.numeric(LD.location[1]))<(as.numeric(LD.range[1])/2))
          GLD=G[index,]
        }else{
          GLD=NULL
        }

        rm(G)
        gc()
        print("hapmap called sucesfuly from fragment")

        return(list(GD=hm$GD,GI=hm$GI,GT=hm$GT,linesRead=linesRead,GLD=GLD,heading=heading))

          print("ERROR: It should no get here!!!")
} #end of "hapmap"



if(genoFormat=="EMMA"){
#print("The file is a numerical format!")
        #Initial GD
        GD=NULL
        skip.1 <- (frag-1)*file.fragment
        #Skip the remaining columns
        GD.temp <- try(read.table(paste(file.path,file.GD, file, ".", file.Ext.GD,sep=""), head = TRUE, nrows = 1),silent=TRUE)
        num.SNP <- ncol(GD.temp)-1
        rm(GD.temp)
        read.in <- min(file.fragment,(num.SNP-skip.1))
        skip.2 <- max((num.SNP - (skip.1 + read.in)),0)


        GD <- try(read.table(paste(file.path,file.GD,file, ".",file.Ext.GD,sep=""), head = TRUE,
                  colClasses = c("factor", rep("NULL", skip.1), rep("numeric", read.in),
                  rep("NULL", skip.2))) ,silent=TRUE)
        GI <- try(read.table(paste(file.path,file.GM,file, ".",file.Ext.GM,sep=""), head = TRUE,
                  skip=skip.1, nrows=file.fragment) ,silent=TRUE)

        if(inherits(GD, "try-error"))  {
          GD=NULL
          print("File end reached for GD!!!")
        }
        if(inherits(GI, "try-error"))  {
          GI=NULL
          print("File end reached for GI!!!")
        }

        if(is.null(GD)) return(list(GD=NULL, GI=NULL,GT=NULL,linesRead=NULL,GLD=NULL))

        GT=GD[,1]  #Extract infividual names

        GD=GD[,-1] #Remove individual names
#print("Numerical file read sucesfuly from fragment")
        linesRead=ncol(GD)
        if(SNP.fraction==1) return(list(GD=GD, GI=GI,GT=GT,linesRead=linesRead,GLD=NULL))

        if(SNP.fraction<1){
          n= ncol(GD)
          set.seed(seed+file)
          sample=sample(1:n,floor(n*SNP.fraction))
          return(list(GD=GD[,sample], GI=GI[sample,],GT=GT,linesRead=linesRead,GLD=NULL))
        }
    } # end of the "EMMA"
#print("fragment ended succesfully!")
}#End of fragment

##############################################################################################
GAPIT.Specify <- function(GI=NULL,GP=NULL,bin.size=10000000,inclosure.size=NULL,MaxBP=1e10){
#Object: To get indicator (TURE or FALSE) for GI based on GP
#Straitegy
#       1.set bins for all snps in GP
#       2.keep the snp with smallest P value in each bin, record SNP ID
#       3.Search GI for SNP with SNP ID from above
#       4.return the position for SNP selected
#Input:
#GI: Data frame with three columns (SNP name, chr and base position)
#GP: Data frame with seven columns (SNP name, chr and base position, P, MAF,N,effect)
#Output:
#theIndex: a vector indicating if the SNPs in GI belong to QTN or not)
#Authors: Zhiwu Zhang
#Last update: September 24, 2011
##############################################################################################

#print("Specification in process...")
if(is.null(GP))return (list(index=NULL,BP=NULL))

#set inclosure bin in GP

#Create SNP ID: position+CHR*MaxBP
ID.GP=as.numeric(as.vector(GP[,3]))+as.numeric(as.vector(GP[,2]))*MaxBP

#Creat bin ID
bin.GP=floor(ID.GP/bin.size )

#Create a table with bin ID, SNP ID and p value (set 2nd and 3rd NA temporately)
binP=as.matrix(cbind(bin.GP,NA,NA,ID.GP,as.numeric(as.vector(GP[,4])))  )
n=nrow(binP)

#Sort the table by p value and then bin ID (e.g. sort p within bin ID)
binP=binP[order(as.numeric(as.vector(binP[,5]))),]  #sort on P alue
binP=binP[order(as.numeric(as.vector(binP[,1]))),]  #sort on bin

#set indicator (use 2nd 3rd columns)
binP[2:n,2]=binP[1:(n-1),1]
binP[1,2]=0 #set the first
binP[,3]= binP[,1]-binP[,2]


#Se representives of bins
ID.GP=binP[binP[,3]>0,]


#Choose the most influencial bins as estimated QTNs
ID.GP=ID.GP[order(as.numeric(as.vector(ID.GP[,5]))),]  #sort on P alue
ID.GP=ID.GP[!is.na(ID.GP[,4]),4] #must have chr and bp information, keep SNP ID only

if(!is.null(inclosure.size)) ID.GP=ID.GP[1:inclosure.size] #keep the top ones selected

#create index in GI
theIndex=NULL
if(!is.null(GI)){
ID.GI=as.numeric(as.vector(GI[,3]))+as.numeric(as.vector(GI[,2]))*MaxBP
theIndex=ID.GI %in% ID.GP
}
#print("Specification in process done")
return (list(index=theIndex,CB=ID.GP))
} #end of GAPIT.Specify


##############################################################################################
GAPIT.get.LL= function(pheno,geno=NULL,snp.pool,X0=NULL){
# evaluation of the maximum likelihood
#Input: ys, xs, vg, delta, Z, X0, snp.pool
#Output: LL
#Authors: Qishan Wang, Feng Tian and Zhiwu Zhang
#Last update: November 11, 2011
################################################################################

y=pheno
p=0

if(is.null(X0)) {
    X0 = matrix(1, nrow(snp.pool), 1)
}

#snp.test=as.numeric(geno[,1])
#X <- cbind(X0, snp.test)
X=X0

#########SVD of X
K.X.svd= svd(snp.pool)
U1=K.X.svd$u
d=K.X.svd$d
d=d^2  #####has been squared
n=nrow(U1)
I= diag(1,nrow(U1))

U1TX=crossprod(U1,X)
U1TY=crossprod(U1,y)
yU1TY<- y-U1%*%U1TY
XU1TX<- X-U1%*%U1TX  ### i is out of bracket
IUU=(I-tcrossprod(U1,U1))
IUX=crossprod(IUU,X )
IUY=crossprod(IUU,y)

#Iteration on the range of delta (-5 to 5 in glog scale)
for (m in seq(-5,5,by=0.1))
{
p=p+1
delta<- exp(m)

#----------------------------calculate beta-------------------------------------
#######get beta compnents 1
beta1=0
for(i in 1:length(d)){
one=matrix(U1TX[i,], nrow=1)
beta=crossprod(one,(one/(d[i]+delta)))  #This is not real beta, confusing
beta1= beta1+beta
}

#######get beta components 2
beta2=0
for(i in 1:nrow(U1)){
one=matrix(IUX[i,], nrow=1)
dim(one)
beta=crossprod(one,one)
beta2= beta2+beta
}
beta2<-beta2/delta

#######get b3
beta3=0
for(i in 1:length(d)){
one1=matrix(U1TX[i,], nrow=1)
one2=matrix(U1TY[i,], nrow=1)
beta=crossprod(one1,(one2/(d[i]+delta)))  #This is not real beta, confusing
beta3= beta3+beta
}

###########get beta4
beta4=0
for(i in 1:nrow(U1)){
one1=matrix(IUX[i,], nrow=1)
one2=matrix(IUY[i,], nrow=1)
beta=crossprod(one1,one2)       #This is not real beta, confusing
beta4= beta4+beta
}
beta4<-beta4/delta

#######get final beta
zw1=solve(beta1+beta2)
zw2=(beta3+beta4)
beta=crossprod(zw1,zw2)  #This is the real beta

#----------------------------calculate LL---------------------------------------
####part 1
part11<-n*log(2*3.14)
part12<-0
for(i in 1:length(d)){
part12_pre=log(d[i]+delta)
part12= part12+part12_pre
}
part13<- (nrow(U1)-length(d))*log(delta)
part1<- -1/2*(part11+part12+part13)

######  part2
part21<-nrow(U1)
######part221

part221=0
for(i in 1:length(d)){
one1=matrix(U1TX[i,], nrow=1)
one2=matrix(U1TY[i,], nrow=1)
part221_pre=(one2-one1%*%beta)^2/(d[i]+delta) ###### beta contain covariate and snp %*%
part221= part221+part221_pre
}

######part222
part222=0

for(i in 1:n){
one1=matrix(XU1TX[i,], nrow=1)
one2=matrix(yU1TY[i,], nrow=1)
part222_pre=((one2-one1%*%beta)^2)/delta
part222= part222+part222_pre
}
part22<-n*log((1/n)*(part221+part222))
part2<- -1/2*(part21+part22)

################# likihood
LL<-part1+part2
part1<-0
part2<-0

#-----------------------Save the optimum---------------------------------------
if(p==1){
  beta.save=beta
  delta.save=delta
  LL.save=LL
}else{
  if(LL>LL.save){
   beta.save=beta
   delta.save=delta
   LL.save=LL
  }
}

} # end of Iteration on the range of delta (-5 to 5 in glog scale)

#--------------------update with the optimum------------------------------------
beta=beta.save
delta=delta.save
LL=LL.save
names(delta)=NULL
names(LL)=NULL

#--------------------calculating Va and Vem-------------------------------------
#sigma_a1
U1TX=crossprod(U1,X)
U1TY=crossprod(U1,y)
sigma_a1=0
for(i in 1:length(d)){
one1=matrix(U1TX[i,], nrow=1)
one2=matrix(U1TY[i,], nrow=1)
sigma_a1_pre=(one2-one1%*%beta)^2/(d[i]+delta)
sigma_a1= sigma_a1+sigma_a1_pre
}

### sigma_a2
IU=I-tcrossprod(U1,U1)    #This needs to be done only once
IUX=crossprod(IU,X)
IUY=crossprod(IU,y)
sigma_a2=0

for(i in 1:nrow(U1)){
one1=matrix(IUX[i,], nrow=1)
one2=matrix(IUY[i,], nrow=1)
sigma_a2_pre<-(one2-one1%*%beta)^2
sigma_a2= sigma_a2+sigma_a2_pre
}

sigma_a2<-sigma_a2/delta
sigma_a<- 1/n*(sigma_a1+sigma_a2)
sigma_e<-delta*sigma_a

return(list(beta=beta, delta=delta, LL=LL, vg=sigma_a,ve=sigma_e))
}

################################################################################
GAPIT.SUPER.FastMLM <- function(ys, xs, vg, delta, Z = NULL, X0 = NULL, snp.pool=NULL,LD=0.1,method="FaST") {
#Input: ys, xs, vg, delta, Z, X0, snp.pool
#Output: GWAS
#Authors: Qishan Wang, Feng Tian and Zhiwu Zhang
#Last update: November 11, 2011
################################################################################

#Set data to the require format
ys=unlist(ys)
if(is.null(dim(ys)) || ncol(ys) == 1)  ys <- matrix(ys, 1, length(ys))
if(is.null(dim(xs)) || ncol(xs) == 1)  xs <- matrix(xs, 1, length(xs))
if(is.null(X0))  X0 <- matrix(1, nrow(snp.pool), 1)

#Exract data size
g <- nrow(ys)
n <- nrow(xs)
m <- ncol(xs)
t <- nrow(xs)
q0 <- ncol(X0)
q1 <- q0 + 1

#Allocate space
dfs <- matrix(nrow = m, ncol = g)
stats <- matrix(nrow = m, ncol = g)
ps <- matrix(nrow = m, ncol = g)
betavalue <- matrix(nrow = m, ncol = g)

#Configration
LDsqr=sqrt(LD)
K.X= snp.pool
if(method!="SUPER")
{
  eig.L <- svd(K.X)
  U <- eig.L$u*matrix(sqrt(1/(eig.L$d^2 + delta)), nrow(K.X), ncol(K.X), byrow = TRUE)
} #end of if(method=="SUPER")


#Iteration on trait (j) and SNP (i)
for(j in 1:g)
{

  if(method!="SUPER") yt <- crossprod(U, ys[j,])
  print(paste("Total SNPs: ",m,sep=""))

for (i in 1:m)
{
  if((i >0)&(floor(i/500)==i/500))  print(paste("SNP: ",i," ",sep=""))


  #No variation on the SNP
  if(min(xs[,i])==max(xs[,i]))
  {
    dfs[i,j] <- n - q1
    betavalue[i,j]=0
    stats[i,j] <- 0
  }
  #The SNP has variation
  if(min(xs[,i])!=max(xs[,i]))
  {

    #SUPER staff
    if(method=="SUPER")
    {
      #SUPER
      snp.corr=cor(xs[,i],snp.pool)
      index.k= snp.corr<=LDsqr
      K.X= snp.pool[,index.k]

      eig.L <- svd(K.X)
      U <- eig.L$u*matrix(sqrt(1/(eig.L$d^2 + delta)), nrow(K.X), ncol(K.X), byrow = TRUE)
      yt <- crossprod(U, ys[j,])
    } #end of if(method=="SUPER")

    #The following need improving for non-SUPER
    X <- cbind(X0, as.numeric(xs[,i]))
    Xt <- crossprod(U, X)
    iXX <- solve(crossprod(Xt, Xt))
    beta <- crossprod(iXX , crossprod(Xt, yt)  )

    betavalue[i,j]=beta[q1]
    stats[i,j] <- beta[q1]/sqrt(iXX[q1, q1] * vg)
    dfs[i,j] <- n - q1
  } #end of SNP variation stutus detection
} #loop for markers

#print("Calculating p-values...")
ps[,j] <- 2 * pt(abs(stats[,j]), dfs[,j],  lower.tail = FALSE)
} #end of loop on traits

return(list(beta=betavalue, ps = ps, stats = stats, dfs = dfs,effect=betavalue))
} #Enf of SUPER.FastMLM



##############################################################################################
GAPIT.Burger <- function(Y=NULL,CV=NULL,GK=NULL){
#Object: To calculate likelihood, variances and ratio
#Straitegy: NA
#Output: P value
#intput:
#Y: phenotype with columns of taxa,Y1,Y2...
#CV: covariate variables with columns of taxa,v1,v2...
#GK: Genotype data in numerical format, taxa goes to row and snp go to columns. the first column is taxa (same as GAPIT.bread)
#Authors: Zhiwu Zhang
#Last update: November 2, 2011
##############################################################################################

#print("GAPIT.Burger in progress...")

myFaSTREML=GAPIT.get.LL(pheno=matrix(Y[,-1],nrow(Y),1),geno=NULL,snp.pool=as.matrix(GK[,-1]),X0=as.matrix(cbind(matrix(1,nrow(CV),1),CV[,-1])))

REMLs=-2*myFaSTREML$LL
delta=myFaSTREML$delta
vg=myFaSTREML$vg
ve=myFaSTREML$ve

#print("GAPIT.Burger succeed!")
return (list(REMLs=REMLs,vg=vg,ve=ve,delta=delta))
} #end of GAPIT.Burger


##############################################################################################
GAPIT.Bread <- function(Y=NULL,CV=NULL,Z=NULL,KI=NULL,GK=NULL,GD=NULL,GM=NULL,
              method=NULL,delta=NULL,vg=NULL,ve=NULL,LD=0.05,GTindex=NULL){
#Object: To calculate p-values of SNPs by using method of GLM, MLM, CMLM, FaST, SUPER and DC
#Straitegy: NA
#Output: GWAS, GPS,REMLs,vg,ve,delta
#intput:
#Y: phenotype with columns of taxa,Y1,Y2...
#CV: covariate variables with columns of taxa, v1,v2...
#GD: same as GK. This is the genotype to screen, the columns are taxa,SNP1,SNP2,...
#GK: Genotype data in numerical format, taxa goes to row and snp go ti columns. the first column is taxa
#GM: Genotype map with columns of snpID,chromosome and position
#method: Options are GLM, MLM, CMLM, FaST, SUPER and DC
#Authors: Zhiwu Zhang
#Last update: November 2, 2011
##############################################################################################
#print("GAPIT.SUPER in progress...")

#Performing first screening with GLM
if(method=="GLM"){
#print("---------------screening by GLM----------------------------------")

  myGAPIT <- GAPIT(
  Y=Y,
  CV=CV,
  Z=Z,
  KI=KI,
  GD=GD,
  GM=GM,
  group.from=5,
  group.to=5,
  QC=FALSE,
  GTindex=GTindex
  )
  GWAS=myGAPIT$GWAS
  GPS=myGAPIT$GPS
  REMLs=myGAPIT$REMLs
  delta=myGAPIT$ve/myGAPIT$va
  vg=myGAPIT$vg
  ve=myGAPIT$ve
}

#Performing first screening with MLM
if(method=="MLM"){
#print("---------------screening by MLM----------------------------------")

  myGAPIT <- GAPIT(
  Y=Y,
  CV=CV,
  Z=Z,
  KI=KI,
  GD=GD,
  GM=GM,
  group.from=nrow(Y),
  group.to=nrow(Y),
  QC=FALSE,
  GTindex=GTindex
  )
  GWAS=myGAPIT$GWAS
  GPS=myGAPIT$GPS
  REMLs=myGAPIT$REMLs
  delta=myGAPIT$ve/myGAPIT$va
  vg=myGAPIT$vg
  ve=myGAPIT$ve
}

#Performing first screening with Compressed MLM
if(method=="CMLM"){
#print("---------------screening by CMLM----------------------------------")
  myGAPIT <- GAPIT(
  Y=Y,
  CV=CV,
  Z=Z,
  KI=KI,
  GD=GD,
  GM=GM,
  group.from=1,
  group.to=nrow(Y),
  QC=FALSE,
  GTindex=GTindex
  )
  GWAS=myGAPIT$GWAS
  GPS=myGAPIT$GPS
  REMLs=myGAPIT$REMLs
  delta=myGAPIT$ve/myGAPIT$va
  vg=myGAPIT$vg
  ve=myGAPIT$ve
}



#Performing first screening with FaST-LMM
if(method=="FaST" | method=="SUPER"| method=="DC")
{
  GWAS=NULL
  GPS=NULL
  if(!is.null(vg) & !is.null(vg) & is.null(delta)) delta=ve/vg
  if(is.null(vg) & is.null(ve))
  {

    myFaSTREML=GAPIT.get.LL(pheno=matrix(Y[,-1],nrow(Y),1),geno=NULL,snp.pool=as.matrix(GK[,-1]),X0=as.matrix(cbind(matrix(1,nrow(CV),1),CV[,-1])))

#print("Transfer data...")
    REMLs=-2*myFaSTREML$LL
    delta=myFaSTREML$delta
    vg=myFaSTREML$vg
    ve=myFaSTREML$ve
    #GPS=myFaSTREML$GPS
  }

mySUPERFaST=GAPIT.SUPER.FastMLM(ys=matrix(Y[,-1],nrow(Y),1),X0=as.matrix(cbind(matrix(1,nrow(CV),1),CV[,-1])),snp.pool=as.matrix(GK[-1]), xs=as.matrix(GD[GTindex,-1]),vg=vg,delta=delta,LD=LD,method=method)
GWAS=cbind(GM,mySUPERFaST$ps,mySUPERFaST$stats,mySUPERFaST$dfs,mySUPERFaST$effect)
}#End of if(method=="FaST" | method=="SUPER")

#print("GAPIT.Bread succeed!")
return (list(GWAS=GWAS, GPS=GPS,REMLs=REMLs,vg=vg,ve=ve,delta=delta))
} #end of GAPIT.Bread


##############################################################################################
GAPIT.Genotype <- function(G=NULL,GD=NULL,GM=NULL,KI=NULL,
  kinship.algorithm=NULL,SNP.effect="Add",SNP.impute="Middle",PCA.total=0,seed=123, SNP.fraction =1,
  file.path=NULL,file.from=NULL, file.to=NULL, file.total=NULL, file.fragment = 1000,SNP.test=TRUE,
  file.G =NULL,file.Ext.G =NULL,
  file.GD=NULL,file.Ext.GD=NULL,
  file.GM=NULL,file.Ext.GM=NULL,
  SNP.MAF=0.05,FDR.Rate = 0.05,SNP.FDR=1,
  Timmer=NULL,Memory=NULL,
  LD.chromosome=NULL,LD.location=NULL,LD.range=NULL, SNP.CV=NULL,
  GP = NULL,GK = NULL,GTindex=NULL,
  bin.size = 1000,inclosure.size = 100,
  sangwich.top=NULL,sangwich.bottom=NULL,
  file.output=TRUE ){
#Object: To unify genotype and calculate kinship and PC if required:
#       1.For G data, convert it to GD and GI
#       2.For GD and GM data, nothing change
#       3.Samling GD and create KI and PC
#       4.Go through multiple files
#       5.In any case, GD must be returned (for QC)
#Output: GD, GI, GT, KI and PC
#Authors: Zhiwu Zhang
#Last update: August 11, 2011
##############################################################################################

print("Genotyping: numericalization, sampling kinship, PCs and much more...")

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Genotype start")
Memory=GAPIT.Memory(Memory=Memory,Infor="Genotype start")

#Create logical variables
byData=!is.null(G) | !is.null(GD)
byFile=!is.null(file.G) | !is.null(file.GD)
hasGenotype=(byData | byFile  )
needKinPC=(is.null(KI) | PCA.total>0)

if(!is.null(KI) & !byData & !byFile & !SNP.test &kinship.algorithm!="SUPER") {
print("It return unexpected")
return (list(GD=NULL,GI=NULL,GT=NULL,hasGenotype=FALSE, genoFormat=NULL, KI=KI,PC=NULL,byFile=FALSE,fullGD=TRUE,Timmer=Timmer,Memory=Memory))
}


#Set indicator for full GD
fullGD=FALSE
if(byData) fullGD=TRUE
if(byFile & SNP.fraction==1 & needKinPC) fullGD=TRUE

#SET GT to NULL in case of no genotype
if(!byData & !byFile & is.null(GK) &kinship.algorithm!="SUPER") {
if(is.null(KI) & is.null(GP) & is.null(GK)) stop("GAPIT says: Kinship has to be provided or estimated from genotype!!!")
return (list(GD=NULL,GI=NULL,GT=NULL,hasGenotype=FALSE, genoFormat=NULL, KI=KI,PC=NULL,byFile=FALSE,fullGD=TRUE,Timmer=Timmer,Memory=Memory))
}

genoFormat="hapmap"
if(is.null(G)&is.null(file.G)) genoFormat="EMMA"

#Multiple genotype files

#In one of the 3 situations, calculate KI with the algorithm specified, otherwise skip cit by setting algorithm to "SUPER"
kinship.algorithm.save=kinship.algorithm
kinship.algorithm="SUPER"
#Normal
if(is.null(sangwich.top) & is.null(sangwich.bottom) ) kinship.algorithm=kinship.algorithm.save

#TOP or Bottom is MLM
pass.top=FALSE
if(!is.null(sangwich.top))   pass.top=!(sangwich.top=="FaST" | sangwich.top=="SUPER" | sangwich.top=="DC")
pass.bottom=FALSE
if(!is.null(sangwich.bottom))   pass.bottom=!(sangwich.bottom=="FaST" | sangwich.bottom=="SUPER" | sangwich.bottom=="DC")

if(pass.top | pass.bottom )kinship.algorithm=kinship.algorithm.save



#Compatibility of input

#agreement among file from, to and total
if(!is.null(file.from) &!is.null(file.to) &!is.null(file.total)){
if(file.total!=(file.to-file.from+1))  stop("GAPIT says: Conflict among file (from, to and total)")
}
if(!is.null(file.from) &!is.null(file.to)) {
  if(file.to<file.from)  stop("GAPIT says: file.from should smaller than file.to")
}
#file.from and file.to must be in pair
if(is.null(file.from) &!is.null(file.to) ) stop("GAPIT says: file.from and file.to must be in pair)")
if(!is.null(file.from) &is.null(file.to) ) stop("GAPIT says: file.from and file.to must be in pair)")

#assign file.total
if(!is.null(file.from) &!is.null(file.to) ) file.total=file.to-file.from+1
if(byFile& is.null(file.total)) stop("GAPIT says: file.from and file.to must be provided!)")

if(!is.null(GP) & !is.null(GK) ) stop("GAPIT Says: You can not provide GP and GK at same time")
if(!is.null(GP) & !is.null(KI) ) stop("GAPIT Says: You can not provide GP and KI at same time")
if(!is.null(GK) & !is.null(KI))   stop("GAPIT says: You can not specify GK and KI at same time!!!")

#GP does not allow TOP
if(!is.null(GP) & !is.null(sangwich.top) ) stop("GAPIT Says: You provided GP. You can not spycify sangwich.top")

#Top require a bottom
if(!is.null(sangwich.top) & is.null(sangwich.bottom) ) stop("GAPIT Says: Top require its Bottom")

#naked bottom require GP or GK
if(is.null(sangwich.top) & !is.null(sangwich.bottom) & (is.null(GP) & is.null(GK)) ) stop("GAPIT Says: Uncovered Bottom (without TOP) requires GP or GK")

#Pseudo top (GK or GP) requires a bottom
if(is.null(sangwich.top) & is.null(sangwich.bottom) & (!is.null(GP)|!is.null(GK  ))) stop("GAPIT Says: You have provide GP or GK, you need to provide Bottom")

#if(!is.null(KI) &!is.null(kinship.algorithm))  stop("GAPIT says: You can not specify kinship.algorithm and provide kinship at same time!!!")



if(!needKinPC &SNP.fraction<1)  stop("GAPIT says: You did not require calculate kinship or PCs. SNP.fraction should not be specified!!!")
if(!SNP.test & is.null(KI) & !byData & !byFile)  stop("GAPIT says: For SNP.test optioin, please input either use KI or use genotype")

#if(is.null(file.path) & !byData & byFile) stop("GAPIT Ssays: A path for genotype data should be provided!")
if(is.null(file.total) & !byData & byFile) stop("APIT Ssays: Number of file should be provided: >=1")
if(!is.null(G) & !is.null(GD)) stop("APIT Ssays: Both hapmap and EMMA format exist, choose one only.")

if(!is.null(file.GD) & is.null(file.GM) & (!is.null(GP)|!is.null(GK)) ) stop("APIT Ssays: Genotype data and map files should be in pair")
if(is.null(file.GD) & !is.null(file.GM) & (!is.null(GP)|!is.null(GK)) ) stop("APIT Ssays: Genotype data and map files should be in pair")

if(!is.null(GD) & is.null(GM) & (is.null(GP)&is.null(GK)) &kinship.algorithm!="SUPER") stop("APIT Says: Genotype data and map files should be in pair")
if(is.null(GD) & !is.null(GM) & (is.null(GP)&is.null(GK)) &kinship.algorithm!="SUPER") stop("APIT Says: Genotype data and map files should be in pair")


#if(!byData & !byFile) stop("APIT Ssays: Either genotype data or files should be given!")
#if(byData&(!is.null(file.path))) stop ("APIT Ssays: You have provided geotype data. file.path should not be provided!")

#print("Pass compatibility of input")
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Genotype loaded")
Memory=GAPIT.Memory(Memory=Memory,Infor="Genotype loaded")

#Inital GLD
GLD=NULL
SNP.QTN=NULL #Intitial
GT=NULL

#Handler of read data in numeric format (EMMA)
#Rename GM as GI
if(!is.null(GM))GI=GM
rm(GM)
gc()
#Extract GD and GT from read data GD
if(!is.null(GD) )
{
GT=as.matrix(GD[,1])  #get taxa
GD=as.matrix(GD[,-1]) #remove taxa column
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="GT created from GD)")
Memory=GAPIT.Memory(Memory=Memory,Infor="GT created from GD")
}

#Hapmap format
if(!is.null(G))
{

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Before HapMap")
Memory=GAPIT.Memory(Memory=Memory,Infor="Before HapMap")

#Convert HapMap to numerical
print(paste("Converting genotype...",sep=""))
hm=GAPIT.HapMap(G,SNP.effect=SNP.effect,SNP.impute=SNP.impute)

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="after HapMap")
Memory=GAPIT.Memory(Memory=Memory,Infor="after HapMap")


#Extracting SNP for LD plot
if(!is.null(LD.chromosome)){
#print("Extracting SNP for LD plot...")
  chromosome=(G[,3]==LD.chromosome[1])
  bp=as.numeric(as.vector(G[,4]))
  deviation=abs(bp-as.numeric(as.vector(LD.location[1])) )
  location=deviation< as.numeric(as.vector(LD.range[1])  )
  index=chromosome&location
  GLD=G[index,]

}else{
#print("No data in GLD")
  GLD=NULL
}

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="HapMap")
Memory=GAPIT.Memory(Memory=Memory,Infor="HapMap")
print(paste("Converting genotype done.",sep=""))
rm(G)
gc()
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="G removed")
Memory=GAPIT.Memory(Memory=Memory,Infor="G removed")

GT=hm$GT
GD=hm$GD
GI=hm$GI


rm(hm)
gc()
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="hm removed")
Memory=GAPIT.Memory(Memory=Memory,Infor="hm removed")
}

#From files
if(!byData & byFile){
#print("Loading genotype from files...")

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="byFile")
Memory=GAPIT.Memory(Memory=Memory,Infor="byFile")

  numFileUsed=file.to
  if(!needKinPC)numFileUsed=file.from

  #Initial GI as storage
  GD=NULL
  GT=NULL
  GI=NULL
  GLD=NULL

  #multiple fragments or files
  for (file in file.from:numFileUsed){

    frag=1
    numSNP=file.fragment
    myFRG=NULL
   #print(paste("numSNP  before while is ",numSNP))

    while(numSNP==file.fragment) {     #this is problematic if the read end at the last line
    print(paste("Reading file: ",file,"Fragment: ",frag))

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Before Fragment")
Memory=GAPIT.Memory(Memory=Memory,Infor="Before Fragment")

      myFRG=GAPIT.Fragment( file.path=file.path,file.from=file.from, file.to=file.to,file.total=file.total,file.G=file.G,file.Ext.G=file.Ext.G,
                            seed=seed,SNP.fraction=SNP.fraction,SNP.effect=SNP.effect,SNP.impute=SNP.impute,genoFormat=genoFormat,
                            file.GD=file.GD,file.Ext.GD=file.Ext.GD,file.GM=file.GM,file.Ext.GM=file.Ext.GM,
                            file.fragment=file.fragment,file=file,frag=frag,
                            LD.chromosome=LD.chromosome,LD.location=LD.location,LD.range=LD.range)
   #print(paste("numSNP after while is ",numSNP))
     #print(paste("OK with file: ",file,"Fragment: ",frag))

     Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="After Fragment")
     Memory=GAPIT.Memory(Memory=Memory,Infor="After Fragment")


      if(is.null(GT) & !is.null(myFRG$GT))GT= as.matrix(myFRG$GT)

      if(is.null(GD)){
        GD= myFRG$GD
      }else{
        if(!is.null(myFRG$GD))    {
          GD=cbind(GD,myFRG$GD)
        }
      }

      if(is.null(GI)){
        GI= myFRG$GI
      }else{
        if(!is.null(myFRG$GI))    {
          colnames(myFRG$GI)=c("SNP","Chromosome","Position")
          GI=as.data.frame(rbind(as.matrix(GI),as.matrix(myFRG$GI)))
        }
      }

      if(is.null(GLD)){
        GLD= myFRG$GLD
      }else{
        if(!is.null(myFRG$GLD))    {
          if(myFRG$heading){
          GLD=as.data.frame(rbind(as.matrix(GLD),as.matrix(myFRG$GLD[-1,])))
          }else{
          GLD=as.data.frame(rbind(as.matrix(GLD),as.matrix(myFRG$GLD)))
          }
        }
      }

      #print("This fragment is joined")

      if(file==file.from & frag==1)GT=as.matrix(myFRG$GT)

      frag=frag+1
      if(!is.null(myFRG$GI))    {
        numSNP=myFRG$linesRead[1]
      }else{
       numSNP=0
      }

      if(!needKinPC)numSNP=0  #force to end the while loop
      if(is.null(myFRG))numSNP=0  #force to end the while loop

     Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="END this Fragment")
     Memory=GAPIT.Memory(Memory=Memory,Infor="END this Fragment")



    } #end of repeat on fragment
   # print("This file is OK")
  } #end of file loop
  print("All files loaded")
} #end of if(!byData&byFile)


#print("file loaded")

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Sampling genotype")
Memory=GAPIT.Memory(Memory=Memory,Infor="Sampling genotype")

#Plot thirt part kinship
if(!is.null(KI) &file.output) {



  if(nrow(KI)<1000){
    print("Plotting Kinship")

    theKin=as.matrix(KI[,-1])
    colnames(theKin)=KI[,1]
    rownames(theKin)=KI[,1]

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="set kinship")
Memory=GAPIT.Memory(Memory=Memory,Infor="set kinship")

    print("Creating heat map for kinship...")
    pdf(paste("GAPIT.Kin.thirdPart.pdf",sep=""), width = 12, height = 12)
    par(mar = c(25,25,25,25))
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="prepare heatmap")
Memory=GAPIT.Memory(Memory=Memory,Infor="prepare heatmap")

    heatmap.2(theKin,  cexRow =.2, cexCol = 0.2, col=rev(heat.colors(256)), scale="none", symkey=FALSE, trace="none")
    dev.off()
    print("Kinship heat map PDF created!")

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="plot heatmap")
Memory=GAPIT.Memory(Memory=Memory,Infor="plot heatmap")


  } #end of if(nrow(KI)<1000)
} #end of if(!is.null(KI))

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Before SUPER")
Memory=GAPIT.Memory(Memory=Memory,Infor="Before SUPER")

#SUPER
if(!is.null(GP) & kinship.algorithm=="SUPER" & !is.null(bin.size) & !is.null(inclosure.size)){
  mySpecify=GAPIT.Specify(GI=GI,GP=GP,bin.size=bin.size,inclosure.size=inclosure.size)
  SNP.QTN=mySpecify$index

  if(!is.null(GD)){
    GK=GD[GTindex,SNP.QTN]
    SNPVar=apply(as.matrix(GK),2,var)
    GK=GK[,SNPVar>0]
    GK=cbind(as.data.frame(GT[GTindex]),as.data.frame(GK)) #add taxa
    #print("QTN extracted")
  }


}

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Before creating kinship")
Memory=GAPIT.Memory(Memory=Memory,Infor="Before creating kinship")


#Create kinship from genotype if not provide
if(is.null(KI) & (!is.null(GD) |!is.null(GK)) & kinship.algorithm!="SUPER")
{
  print("Calculating kinship...")

  if(!is.null(GK)){
    thisGD=GK[,-1]
    myGT=as.matrix(GK[,1])
    print("GK is used to create KI")
  }else{
    thisGD=GD
    myGT=GT

    if(!is.null(GTindex)){
      thisGD=thisGD[GTindex,]
      myGT=myGT[GTindex]
    }
  }

 print(paste("Number of individuals and SNPs are ",nrow(thisGD)," and ",ncol(thisGD)))

  if(kinship.algorithm=="EMMA")theKin= emma.kinship(snps=t(as.matrix(.5*thisGD)), method="additive", use="all")
  if(kinship.algorithm=="Loiselle")theKin= GAPIT.kinship.loiselle(snps=t(as.matrix(.5*thisGD)), method="additive", use="all")
  if(kinship.algorithm=="VanRaden")theKin= GAPIT.kinship.VanRaden(snps=as.matrix(thisGD))

  colnames(theKin)=myGT
  rownames(theKin)=myGT
 print("kinship calculated")

  if(length(GT)<1000 &file.output){
    #Create heat map for kinship
    print("Creating heat map for kinship...")

    pdf(paste("GAPIT.Kin.",kinship.algorithm,".pdf",sep=""), width = 12, height = 12)
    par(mar = c(25,25,25,25))
    heatmap.2(theKin,  cexRow =.2, cexCol = 0.2, col=rev(heat.colors(256)), scale="none", symkey=FALSE, trace="none")
    dev.off()
    print("Kinship heat map created")
  }

  print("Adding IDs to kinship...")
  #Write the kinship into a text file
  KI=cbind(myGT,as.data.frame(theKin)) #This require big memory. Need a way to solve it.


  print("Writing kinship to file...")
  if(file.output) write.table(KI, paste("GAPIT.Kin.",kinship.algorithm,".csv",sep=""), quote = FALSE, sep = ",", row.names = FALSE,col.names = FALSE)
  print("Kinship save as file")

  rm(theKin)
  gc()

  Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Estimating kinship")
  Memory=GAPIT.Memory(Memory=Memory,Infor="Estimating kinship")
  print("Kinship created!")
}  #end of if(is.null(KI)&!is.null(GD))

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="after creating kinship")
Memory=GAPIT.Memory(Memory=Memory,Infor="after creating kinship")


#Create PC
PC=NULL
if(PCA.total>0){
PC=GAPIT.PCA(X = GD, taxa = GT, PC.number = PCA.total,file.output=file.output)
Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="PCA")
Memory=GAPIT.Memory(Memory=Memory,Infor="PCA")
print("PC created")
}

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="Before LD plot")
Memory=GAPIT.Memory(Memory=Memory,Infor="Before LD plot")

#LD plot
#print("LD section")
if(!is.null(GLD) &file.output){

if(nrow(GLD)>500){
  GLD=GLD[1,]
  print("WARNING: The number of SNPs requested is beyond limitation. No LD plot created.")
}
if(nrow(GLD)>1)
{
print("Plot LD...")

hapmapgeno= data.frame(as.matrix(t(GLD[,-c(1:11)])))

hapmapgeno[hapmapgeno=="NN"]=NA
hapmapgeno[hapmapgeno=="XX"]=NA
hapmapgeno[hapmapgeno=="--"]=NA
hapmapgeno[hapmapgeno=="++"]=NA
hapmapgeno[hapmapgeno=="//"]=NA

LDdist=as.numeric(as.vector(GLD[,4]))
LDsnpName=GLD[,1]
colnames(hapmapgeno)=LDsnpName

#Prune SNM names
#LDsnpName=LDsnpName[GAPIT.Pruning(LDdist,DPP=7)]
LDsnpName=LDsnpName[c(1,length(LDsnpName))] #keep the first and last snp names only

#print(hapmapgeno)
print("Getting genotype object")

LDsnp=makeGenotypes(hapmapgeno,sep="",method=as.genotype)   #This need to be converted to genotype object

print("Caling LDheatmap...")
pdf(paste("GAPIT.LD.chromosom",LD.chromosome,"(",round(max(0,LD.location-LD.range)/1000000),"_",round((LD.location+LD.range)/1000000),"Mb)",".pdf",sep=""), width = 12, height = 12)
#pdf(paste("GAPIT.LD.pdf",sep=""), width = 12, height = 12)
par(mar = c(25,25,25,25))
MyHeatmap <- try(LDheatmap(LDsnp, LDdist, LDmeasure="r", add.map=TRUE,
  SNP.name=LDsnpName,color=rev(cm.colors(20)), name="myLDgrob", add.key=TRUE,geneMapLabelY=0.1) )

if(!inherits(MyHeatmap, "try-error")) {
  #Modify the plot
  grid.edit(gPath("myLDgrob", "Key", "title"), gp=gpar(cex=.5, col="blue"))  #edit key title size and color
  grid.edit(gPath("myLDgrob", "geneMap", "title"), gp=gpar(just=c("center","bottom"), cex=0.8, col="black")) #Edit gene map title
  grid.edit(gPath("myLDgrob", "geneMap","SNPnames"), gp = gpar(cex=0.3,col="black")) #Edit SNP name
}else{
  print("Warning: error in converting genotype. No LD plot!")
}

dev.off()
print("LD heatmap crated")
#grid.edit(gPath("myLDgrob", "heatMap","title"), gp=gpar(cex=1.0))   #Make title smaler
#grid.edit(gPath("myLDgrob", "geneMap", "title"), gp=gpar(just=c("right","bottom"), cex=0.5, col="blue")) #Edit gene map title
#grid.edit(gPath("myLDgrob", "Key", "labels"), gp=gpar(cex=.5, col="black"))  #edit key lable size and color
}else{ # alternative of if(nrow(GLD)>1)
  print("Warning: There are less than two SNPs on the region you sepcified. No LD plot!")
} #end of #if(nrow(GLD)>1)
}#end of if(!is.null(GLD))

Timmer=GAPIT.Timmer(Timmer=Timmer,Infor="after LD plot")
Memory=GAPIT.Memory(Memory=Memory,Infor="after LD plot")


#print("Genotype successfully acomplished")
return (list(GD=GD,GI=GI,GT=GT,hasGenotype=hasGenotype, genoFormat=genoFormat, KI=KI,PC=PC,byFile=byFile,fullGD=fullGD,Timmer=Timmer,Memory=Memory,SNP.QTN=SNP.QTN))
}
