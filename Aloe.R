library(usdm)###for multicoliniarity cheking VIF
library(raster)### reading raster data
library(terra)###reading data manuplation
library(biomod2)####used for modelling aloe speceis 
library(sp)# Spatial data classes
library(corrplot)##plooting
library(gbm)####Gradient boost machine alogorithm
library(xgboost)
library(randomForest)#####random forest alogorithm 
library(dplyr)#####data manupulation
library(data.table)###reading csv data 
library(CoordinateCleaner)####removing uncertainity
library(ggplot2)#####plotinng
library(spThin)###spatial auto correlation
#############Occerance_data_GBIF###########
GBIF_DATA <-fread("C:/Users/ADMIN/Desktop/Simon_Data/Simon_data_aloe_project/OCCURENCE/ALOE/0007628-241126133413365.csv")
###REMOVING MISSING COOORDINATE####
Mask_vap<-is.na(GBIF_DATA $decimalLatitude+GBIF_DATA $decimalLongitude)

GBIF_DATA <-GBIF_DATA[!Mask_vap,]
#testing coordinate cleaner
test <-c("capitals","centroids","equal","gbif","institutions","zeros")
flags<- clean_coordinates(x=GBIF_DATA,lon = "decimalLongitude",lat = "decimalLatitude",
                          species = "species",countries = "countryCode",tests = "test")
##inaturalist data#
kenya <- read.csv("C:/Users/ADMIN/Desktop/Simon_Data/Simon_data_aloe_project/OCCURENCE/CLEANED/Kenya.csv")
Final_data <-merge(kenya,gbif_occurence,by=c("latitude","longitude"),all=TRUE)
Final_data <-unique(Final_data)
Final_data <-unique(Final_data)
Final_data$species <-"aloe"
ready_data<-as.datframe(Final_data)
# Spatial thinning (1km minimum distance)
thinned_results <-thin(loc.data=ready_data,
                       lat.col ="latitude",
                       long.col = "longitude",
                       spec.col = "species",
                       thin.par =1,# 1km threshold
                       reps=100,
                       locs.thinned.list.return = TRUE,
                       write.files = TRUE,
                       max.files = 2,
                       out.dir="C:/Users/ADMIN/Desktop/Simon_Data/Simon_data_aloe_project/OCCURENCE/CLEANED/thinned/newthinned",
                       out.base = "thinned_data",
                       write.log.file = TRUE,
                       log.file = "spatial_thin_log.txt",
                       verbose = TRUE
)
write.csv(Final_data, file = "C:/Users/ADMIN/Desktop/Simon_Data/Simon_data_aloe_project/OCCURENCE/CLEANED/thinned/kenya.csv",row.names = FALSE)
###Predictor Variable Preparation##########
# Load environmental layers,resampling,and projection####
##########Bioclimatic Variables######
Bioclimatic_layer <-stack(list.files(path = "C:/Users/ADMIN/Desktop/New_Data/BIOCLIMATIC/MODEL_FITTING_AREA",pattern = ".tif$",full.names = TRUE))
crs(Bioclimatic_layer)
ext(Bioclimatic_layer)
res(Bioclimatic_layer)  
#########Dem variables#####
Dem_layer <- stack(list.files(path = "C:/Users/ADMIN/Desktop/New_Data/DEM/MODEL_FITTING_AREA_DEM",pattern = ".tif$",full.names = TRUE))
crs(Dem_layer)
plot(Dem_layer)
ext(Dem_layer)
res(Dem_layer)
Dem_layer<-resampled(Dem_layer,Bioclimatic_layer)#resampled to match Bioclimatic variable
Dem_layer<- projectRaster(Dem_layer,Bioclimatic_layer,crs=4326)#Projected  to match Bioclimatic variable
#######Soil_variables######
Soil_layer <- stack(list.files(path="C:/Users/ADMIN/Desktop/New_Data/SOIL/MODEL_FITTING_AREA/R",pattern=".tif$",full.names=TRUE))
crs(Soil_layer)
plot(Soil_layer)
ext(Soil_layer)
res(Soil_layer)
Soil_layer<-scale(Soil_layer)
Soil_layer<-resampled(Soil_layer,Bioclimatic_layer)#resampled to match bioclimatic variable
Soil_layer<- projectRaster(Soil_layer,Bioclimatic_layer,crs=4326)#projected to match bioclimatic variable
all_layer <- stack(Bioclimatic_layer,Dem_layer,Soil_layer)#all the stack layer
all_layer <-scale(all_layer)#standadize all the data
plot(all_layer)
############Muliti_collinearirty_testing #######
collinear_data <-extract(all_layer,data[,c("longitude","latitude")])
collinear_data<-as.data.frame(collinear_data)
class(collinear_data)
collinear_data <- collinear_data%>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .)))

result<-vifcor(collinear_data, th=0.8)###Variance Inflaction factor using vifcor function usdm pakage
print(result)
collinera<-cor(collinear_data,method="pearson")#pearson correlation
symnum(collinera)
print(collinera)
corrplot(collinera)
ggcorrplot(collinera, lab = TRUE,lab_size = 2,title="Pearson Correlation ")
##plotting Pearson correlation
cor_melt <- melt(collinera )
ggplot(cor_melt, aes(Var1, Var2, fill = value)) +
  geom_tile() + 
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Adjust text size for better readability
        axis.text.y = element_text(size = 12), 
        axis.title = element_blank(), 
        plot.title = element_text(size = 14, face = "bold"),
        panel.grid = element_blank()) + 
  labs(title = "Correlation Matrix") +
  theme(plot.margin = unit(c(1,1,1,1), "cm"))

#########removing high corelated variable #####
Read_data <- dropLayer(all_layer, c(
  "BIO_1", "BIO_5","BIO_6", "BIO_16", "BIO_14","BIO_9", "BIO_12", "BIO_10", "BIO_11","BIO_8","BIO_2",
  "BIO_13", "BIO_17"
))
plot(Read_data)
class(data)
data$present <-1
#############Preparing  data for biomod2 , pseudo absence data  ######
Biomod_data<- BIOMOD_FormatingData(
  resp.name = "Aloe",
  resp.var = data$present,
  expl.var = Read_data,  
  resp.xy = data[,c("longitude","latitude")],
  PA.nb.rep = 3,  #number of times pseudo absence data is to drawn
  PA.nb.absence =256, #number of pseudo absence data to be generated
  PA.strategy = "random",## randomly selected 
  na.rm = TRUE,
  filter.raster = TRUE,
)
summary(Biomod_data)
######################tunning the model#################
opt<- bm_ModelingOptions(data.type = "binary",
                         models = c("RF","GBM","XGBOOST"),
                         strategy = "bigboss",
                         bm.format=Biomod_data)
opt@options
###Random forest tunning###
tune.rf <- bm_Tuning(
  model = 'RF',
  tuning.fun = 'rf',
  do.formula = TRUE,
  bm.options = opt@options$RF.binary.randomForest.randomForest,
  bm.format = Biomod_data,
  params.train = list(  
    Aloe ~ BIO_15 + BIO_18 + BIO_19 + BIO_3 + BIO_4 + BIO_7 + Aspect + elevation + Slope + TRI + CEC + Drainage + SoilPh + Texture, 
    data = Read_data, 
    ntree =c(500, 1000, 1500),         
    mtry = c(3,5,7),            
    nodesize = c(1, 3, 5, 10, 20),        
    maxnodes =c(50, 100, 250, 500),       
    importance = TRUE,   
    do.trace = TRUE      
  )
  
)
tune.xgboost <- bm_Tuning(
  model = 'XGBOOST',
  tuning.fun = 'xgbTree',
  do.formula = TRUE,
  bm.options = opt@options$XGBOOST.binary.xgboost.xgboost,
  bm.format = Biomod_data,
  params.train = list(
    Aloe ~ BIO_15 + BIO_18 + BIO_19 + BIO_3 + BIO_4 + BIO_7 + Aspect + elevation + Slope + TRI + CEC + Drainage + SoilPh + Texture, 
    data = Read_data,
    max_depth = 20,         
    eta = 0.01,           
    gamma = 0.1,           
    colsample_bytree = 0.8,  
    min_child_weight = 4,     
    subsample = 0.8,      
    nrounds = 150,        
    verbose = 1           
  )
)
tune.gbm <- bm_Tuning(
  model = 'GBM',
  tuning.fun = 'gbm',
  do.formula = TRUE,
  bm.options = opt@options$GBM.binary.gbm.gbm,
  bm.format = Biomod_data,
  params.train = list(
    Aloe ~ BIO_15 + BIO_18 + BIO_19 + BIO_3 + BIO_4 + BIO_7 + Aspect + elevation + Slope + TRI + CEC + Drainage + SoilPh + Texture, 
    data = Read_data,
    n.trees =c(1500,1000,500),      
    interaction.depth = c(10,8,6), 
    shrinkage = c(0.05,0.1,0.01),      
    bag.fraction =c(0.75, 0.7, 0.5),    
    train.fraction = 1,    
    cv.folds = 0,         
    n.cores = 4,          
    verbose =FALSE,
    keep.data = TRUE
  )
)
#######modelling option tobe ready for modelling aloe species
user.val<-list(RF.binary.randomForest.randomForest=tune.rf,
               GBM.binary.gbm.gbm=tune.gbm,
               XGBOOST.binary.xgboost.xgboost=tune.xgboost)
myopt<- bm_ModelingOptions(data.type = "binary",
                           models = c("RF","GBM","XGBOOST"),
                           strategy = "user.defined",
                           user.val=user.val,
                           user.base ="bigboss",
                           bm.format=Biomod_data,
)
#########modelling  idvidual alogorithm ######
ALOE_MODE<-BIOMOD_Modeling(bm.format =Biomod_data,
                           models = c("RF","XGBOOST","GBM"),
                           CV.strategy = "kfold",
                           CV.nb.rep = 1,
                           CV.k=5,
                           bm.options =opt,
                           metric.eval = c("TSS","ROC"),
                           var.import = 3,
                           do.progress = TRUE,
                           CV.do.full.models = FALSE,
                           nb.cpu=1,
                           seed.val = 234
                           
                           
)

str(ALOE_MODE)
bm_PlotEvalMean(bm.out = ALOE_MODE, dataset = 'validation')#Model perfromance on the test data 
###########getting variable importance#########
var<-get_variables_importance(ALOE_MODE)
var2<-as.data.frame(var)

var2$algo <- factor(var2$algo, levels = c("RF", "GBM", "XGBoost"))
unique(var2$algo)
var2$algo[is.na(var2$algo)] <- "XGBoost"
var2$algo <- factor(var2$algo, levels = c("RF", "GBM", "XGBoost"))
var_melt_clean <- var2[!is.na(var2$algo), ]
head(var_melt_clean)
#####ploatin 2d plots of variable importance for the model
ggplot(var_melt_clean, aes(x = expl.var, y = var.imp, fill = algo)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  labs(title = "Variable Importance by Algorithm",x = "Explanatory Variable",y = "Relative Importance") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = c("RF" = "blue", "GBM" = "green", "XGBoost" = "red"))
################ Current prediction on inividula model projection ditribution ###########
get_built_models(ALOE_MODE)
projection <- BIOMOD_Projection(
  bm.mod = ALOE_MODE,
  new.env= STACKED_FUTURE ,  ######can feed new data
  proj.name = "Current_distribution_of_aloe_model_fitting _BARINGO126",
  models.chosen=c("all" ),
  metric.binary = c("TSS"),
  metric.filter = c("TSS"),
  metric.threshold=c(0.57),
  build.clamping.mask=TRUE,######uncertinity 
  do.stack=TRUE,
  nb.cpu=1,
  seed.val=5678
)
plot(projection)
####Ensembling all the modells##
ensembled <- BIOMOD_EnsembleModeling(
  bm.mod = ALOE_MODE,
  models.chosen = "all",
  em.by = 'PA+run',##Ensemble by number of run ande pseudoabsence 
  em.algo ='EMmedian' ,##ensembel by median probabilities of the models
  metric.select = c("TSS","ROC"), 
  metric.select.thresh= c("0.57","0.60"),#eexcluding model <than 0.57 and ROC<0.60
  metric.eval = c("TSS","ROC"),####model performance using ROC and TSS metric from biomode2
  metric.select.dataset = "validation", #ensembled by the test data during training and testing
  var.import = 0,
  do.progress = TRUE,
  nb.cpu = 1,
  seed.val = 156
)
bm_PlotEvalMean(bm.out = ensembled, dataset = 'validation')#####plooting model performance 
bm_PlotEvalMean(bm.out = ensembled,group.by = c('PA','run'))

#############current prediction data ########
Bioclimatic_current <-stack(list.files(path = "C:/Users/ADMIN/Desktop/New_Data/BIOCLIMATIC/BARINGO/Done_offset",pattern = ".tif$",full.names = TRUE))
crs(Bioclimatic_current)
plot(Bioclimatic_current)                             
#########dem variable  consider static variabel static variable
Dem_current <-stack(list.files(path = "C:/Users/ADMIN/Desktop/New_Data/DEM/BARINGO",pattern = ".tif$",full.names = TRUE))
crs(Dem_current)
plot(Dem_current)
res(Dem_current)
Dem_current<-projectRaster(Dem_current,Bioclimatic_current ,crs=4326)

##########soil variables consider static static variable
Soil_current <-stack(list.files(path = "C:/Users/ADMIN/Desktop/New_Data/SOIL/BARINGO",pattern = ".tif$",full.names = TRUE))
crs(r_resampled )
plot(Soil_current)
res(r_resampled )
Soil_current<- projectRaster(Soil_current,Bioclimatic_current,crs = 4326)
current_stack <- stack(Bioclimatic_current,Dem_current,Soil_current)
plot(current_stack)
###############future prediction in 2050s data################
#########scenario_data  SSP 126 data #########
FUTURE126<- stack(list.files(path = "C:/Users/ADMIN/Desktop/New_Data/MODEL_FITTING_AREA_FUTURE/SSP126",".tif$",full.names = TRUE))
plot(STACKED_FUTURE)
STACKED_FUTURE <-stack(FUTURE126,Dem_current,Soil_current)
################ senario_data SSP 585######
FUTURE585 <-stack(list.files(path = "C:/Users/ADMIN/Desktop/New_Data/MODEL_FITTING_AREA_FUTURE/SSP585","tif$",full.names = TRUE))
STACKED_FUTURE585<-stack(FUTURE585,Dem_current,Soil_current)
plot(STACKED_FUTURE585)
############Current and future prediction ditribution by Ensembled model #####
ensembel_bar <-BIOMOD_EnsembleForecasting(
  bm.em=ensembled,
  proj.name = "Current_distribution_of_aloe_BARINGO_585",
  new.env = STACKED_FUTURE585,###both data interchangebly SSP585 & SSP126
  new.env.xy = NULL,
  models.chosen = "all",
  metric.binary = c("TSS"),
  
  build.clamp = TRUE,
  nb.cpu = 1,
  na.rm = TRUE,
  do.stack=TRUE,
  build.clamping.mask =)
