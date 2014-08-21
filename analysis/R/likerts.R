
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

# compare HUMAN and MEDIUM condition in data frame dat
study_response <- function(dat) {
  c1 = subset(dat, HR_type=="HUMAN")$answer
  cat("HUMAN: ")
  print(c1)
  cat("Mean", mean(c1), "\n")
  c2 = subset(dat, HR_type=="MEDIUM")$answer
  cat("MEDIUM: ")
  print(c2)
  cat("Mean", mean(c2), "\n")
  res <- wilcox.test(c1, c2, paired=TRUE)
  print(res)
}

# now, work with data

# agent answers, group stages together
cat("\nAgent overall\n")
agent_overall <- aggregate(answer~HR_type+subject, data=subset(data, question_type=="agent"), mean)
study_response(agent_overall)

cat("\nAgent random\n")
agent_random <- aggregate(answer~HR_type+subject, data=subset(data, question_type=="agent" & corpus_type=="RANDOM"), mean)
study_response(agent_random)

cat("\nAgent sequential\n")
agent_sequential <- aggregate(answer~HR_type+subject, data=subset(data, question_type=="agent" & corpus_type=="SEQUENTIAL"), mean)
study_response(agent_sequential)

cat("\nSentence random\n")
sentence_random <- aggregate(answer~HR_type+subject, data=subset(data, question_type=="sentence" & corpus_type=="RANDOM"), mean)
study_response(sentence_random)

