library(tidyverse)

war_batters_df <- read.csv("war-batters.csv") %>%
    select(player_ID, year_ID, lg_ID, WAR) %>%
    filter(year_ID <= 1948) %>%
    mutate(WAR = as.numeric(WAR), WAR = replace(WAR, is.na(WAR), 0),
           lg_ID = replace(lg_ID, is.na(lg_ID), "N_A"),
           segregated = ifelse(lg_ID %in% c("AL", "NL", "AA", "UA", "PL", "FL", 
                                            "NA", "N_A"), 1, 0)) %>%
    select(-lg_ID)

war_pitchers_df <- read.csv("war-pitchers.csv") %>%
    select(player_ID, year_ID, lg_ID, WAR) %>%
    filter(year_ID <= 1948) %>%
    mutate(WAR = as.numeric(WAR), WAR = replace(WAR, is.na(WAR), 0),
           lg_ID = replace(lg_ID, is.na(lg_ID), "N_A"),
           segregated = ifelse(lg_ID %in% c("AL", "NL", "AA", "UA", "PL", "FL", 
                                            "NA", "N_A"), 1, 0)) %>%
    select(-lg_ID)

war_years_df <- bind_rows(war_batters_df, war_pitchers_df) %>%
    group_by(player_ID, year_ID, segregated) %>%
    summarize(WAR = sum(WAR)) %>%
    mutate(segregated = ifelse(player_ID %in% c("walkefl01", "walkewe01", 
                                                "whitebi01") & segregated == 1,
                               0, segregated)) %>%
    group_by(year_ID, segregated) %>%
    summarize(WAR = sum(WAR))

war_years_complete_df <- expand.grid(year_ID = unique(war_years_df$year_ID), 
                                     segregated = c(0, 1)) %>%
    merge(war_years_df, by = c("year_ID", "segregated"), all.x=TRUE) %>%
    mutate(WAR = ifelse(is.na(WAR), 0, WAR)) %>%
    arrange(year_ID, desc(segregated))

total_war_by_year <- war_years_complete_df %>%
    group_by(year_ID) %>%
    summarize(total_WAR = sum(WAR))

war_percent_years_df <- merge(war_years_complete_df, total_war_by_year, 
                              by = "year_ID") %>%
    mutate(WAR_percentage = round((WAR / total_WAR), 4)) %>%
    select(-WAR, -total_WAR) %>%
    pivot_wider(names_from = segregated, values_from = WAR_percentage, 
                names_prefix = "segregated_") %>%
    rename(year = year_ID, mlb = segregated_1, negro_leagues = segregated_0)

write.csv(x = war_percent_years_df, 
          file = "war_percentages_pre_integration.csv", row.names=FALSE)

sabr_df <- read.csv("war_percentages_post_integration.csv")

pre <- ggplot(data = war_percent_years_df, mapping = aes(x = year)) +
    geom_line(aes(y = mlb), color = "red") + 
    geom_line(aes(y = negro_leagues), color = "blue")

post <- ggplot(data = sabr_df, mapping = aes(x = year)) +
    geom_line(aes(y = white), color = "red") + 
    geom_line(aes(y = black), color = "blue") +
    geom_line(aes(y = latino), color = "orange") + 
    geom_line(aes(y = asian), color = "green")