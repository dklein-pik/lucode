#' Renames the scenariofolder and the scenario contained in it
#' 
#' Use this function to change the name of a run after it has finished. 
#' This function renames the run folder, change the run title in the cfg and in the reporting.
#' This can be useful if the initial name of a run was not meaningful. It automatically removes the timestamp from the name.
#' 
#' @usage rename_scenario(map,keep_time_stamp = FALSE)
#' @param map Named vector, containing the new scenario names as elements and the corresponding old folder names as the emelents' names.
#' @importFrom magclass read.report write.report getNames
#' @author David Klein
#' @export

rename_scenario <- function(map,keep_time_stamp = FALSE) {
  if (any(duplicated(map))) stop("The list of new names contains duplicates which would cause the first folder to be overwritten with the last!")
  
  for (f in 1:length(map)) {
    cat("############################################\n")
    old_folder <- names(map[f])
    
    if (dir.exists(old_folder)) {
      # extract date string of the form "_yyyy-mm-dd_hh.mm.ss"
      d <- gsub(".*(_\\d{4}-\\d{2}-\\d{2}_\\d{2}.\\d{2}.\\d{2}$)","\\1",old_folder)
      
      # if no timestamp was found set it to empty string (so it will have no effect in gsub below)
      if (identical(d,old_folder)) d <- ""

      # remove date
      old_scenario <- gsub(d,"",old_folder)
      
      # if timestamp should not be kept set it to empty string (so it will have no effect in paste0 below)
      if (!keep_time_stamp) d <- ""
      new_folder <- paste0(map[f],d)

      new_scenario <- map[f]

      
      cat("Scenario:",old_scenario,"\n      -> ",new_scenario,"\n")
      
      # rename title
      cfg_name <- paste0(old_folder,"/config.Rdata")
      if (file.exists(cfg_name)) {
        load(cfg_name)
        cfg$title <- new_scenario
        save(cfg,file=cfg_name)
      }
    
      # rename scenario in mif: first read MAgPIE report, if not existsing read REMIND report
      mif_name <- paste0(old_folder,"/report.mif")
      new_mif_name <- mif_name
      if(!file.exists(mif_name)) {
        mif_name     <- paste0(old_folder,"/REMIND_generic_",old_scenario,".mif")
        new_mif_name <- paste0(old_folder,"/REMIND_generic_",new_scenario,".mif")
      }
      
      cat("Mif:     ",mif_name,"\n      -> ",new_mif_name,"\n")
      a <- read.report(mif_name,as.list=F)
      getNames(a,dim=1) <- gsub("\\.","",new_scenario)
      write.report(a,new_mif_name)
      
      # rename folder
      cat("Folder:  ",old_folder,"\n      -> ",new_folder,"\n")
      system(paste("mv",old_folder,new_folder))
    } else {
      cat("Could not find",old_folder,"!\n")
    }
  }
}