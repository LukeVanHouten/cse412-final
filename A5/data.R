library(tidyverse)

states_df <- read.csv("states.csv") %>%
    select(-wbname)

new_colnames <- c("ISO_A3", paste0(seq(2000, -3450, -50)))

names(states_df) = new_colnames

write.csv(states_df, "states_edited.csv", row.names=FALSE)
