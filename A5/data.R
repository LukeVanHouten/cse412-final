library(tidyverse)

states_df <- read.csv("states.csv") %>%
    select(-wbname)

new_colnames <- c("ISO_A3", paste0(0:109))

names(states_df) = new_colnames

write.csv(states_df, "states_edited.csv", row.names=FALSE)
