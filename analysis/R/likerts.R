
# fetch data from there
working_path <- "~/HR/data" 


# log output there
#output_file <- paste(sep="", working_path, "questionnaires_results.txt")
#sink(output_file, split=TRUE)
# end logs
#sink()

# in data path, there should be for each subject a folder named s1, then s2, ...
subjects_list <- dir(working_path, pattern = "s[0-9]", ignore.case = TRUE)

# data from all subjects, will be concatenated
data <- NULL

# fetch data from subjects
for (i in 1:length(subjects_list)) {
  # build full path
  subdir <- paste(working_path, "/", subjects_list[i], sep="")
  # go on if really a folder
  if (file.info(subdir)$isdir) {
    # use folder name as subject ID, keeping only digits -- Lexicographical order not the same as numerial, can't use "i"
    subject_ID = as.numeric(gsub("[a-z]", "", subjects_list[i]))
    cat("Subject:", subject_ID, "in folder", subdir, "( i = ", i, ")\n")
    # look into XP data for processing csv output, no matter the timestamp
    CSV_file <- dir(paste(subdir, "/xp/", sep = ""), pattern = "subject.*.csv", full.names=TRUE)
    # there really should be only one CSV file per folder (one session per subject)
    if (length(CSV_file) !=  1) {
      cat("Error, found ", length(CSV_file), "CSV files instead of 1, skip subject.\n")
    }
    else {
      cat("Open", CSV_file, "\n")
      # load file
      sub_data <- read.table(CSV_file, header=TRUE, sep="\t")
      # add subject ID
      sub_data$subject = subject_ID
      # append to main data
      data <- rbind(data, sub_data)
    }
  }
}

# now, work with data
