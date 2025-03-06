options(scipen = 999)
library(dplyr)
library(jsonlite)
library(tidyr)
library(wbstats)
library(magick)


# Define the URL of the website with the medal tally
medal_table_json <- fromJSON("https://api.olympics.kevle.xyz/medals")
medal_table <- as.data.frame(medal_table_json) 

#Split lists into their own columns
medal_table <- medal_table |> 
  unnest_wider(results.country) |> 
  unnest_wider(results.medals) 

#Select variables of interest
medal_table <- medal_table |>  
  select(name, iso_alpha_2, code, gold, silver, bronze, total) |> 
  rename(country = name, country_code = code)

#Select indicators to download from world bank
my_indicators <- c("population" = "SP.POP.TOTL",
                   "GDP" = "NY.GDP.MKTP.CD")

country_statistics <- wb_data(my_indicators) |> 
  filter(date == 2023) |> 
  select(iso2c, population, GDP) |> 
  rename(iso_alpha_2 = iso2c)

medal_table <- left_join(medal_table, country_statistics, by = "iso_alpha_2") |> 
  select(!iso_alpha_2) |> 
  rename(medals = total)


medal_table <- medal_table |> 
  mutate("goldperperson" = gold/population) |> 
  mutate("medalsperperson" = medals/population) |> 
  mutate("goldperGDP" = gold/GDP) |> 
  mutate("medalsperGDP" = medals/GDP)

library(gt)
library(gtExtras)
library(sjlabelled)

medal_table <- remove_all_labels(medal_table) |> 
  select(country, gold, silver, bronze, medals, goldperperson, medalsperperson, goldperGDP, medalsperGDP)


#############################################
library(readr)
Olympic_team_size <- read_csv("Posts/2024-08-03-Paris-2024-Olympic-tallies-done-your-way/Olympic_team_size.csv") 

Olympic_team_size$Olympic_team_size <- as.integer(Olympic_team_size$team_size)
Olympic_team_size <- as.data.frame(Olympic_team_size)



medal_table <- left_join(medal_table, Olympic_team_size, by = "country") |> 
  mutate("goldperathlete" = gold/team_size) |> 
  mutate("medalsperathlete" = medals/team_size) 

str(Olympic_team_size)




medal_table |> 
  gt() |> 
  opt_interactive(use_resizers = TRUE, use_highlight = TRUE, use_page_size_select = FALSE, use_pagination_info = FALSE, use_pagination =  FALSE) |> 
  cols_align(
    align = "center",
    columns = everything()
  ) |> 
  cols_label(
    gold = html(paste0("<img src='https://mattnurse.com/wp-content/uploads/2024/08/gold.png' width='50' height='50'>")), 
    silver = html(paste0("<img src='https://mattnurse.com/wp-content/uploads/2024/08/silver.png' width='50' height='50'>")),
    bronze = html(paste0("<img src='https://mattnurse.com/wp-content/uploads/2024/08/bronze.png' width='50' height='50'>")),  
    medals = html(paste0("<img src='https://mattnurse.com/wp-content/uploads/2024/08/medals.png' width='50' height='50'>")),
    goldperperson = html(paste0("<img src='https://mattnurse.com/wp-content/uploads/2024/08/goldperperson.png' width='50' height='50'>")),
    medalsperperson = html(paste0("<img src='https://mattnurse.com/wp-content/uploads/2024/08/medalsperperson.png' width='50' height='50'>")),
    goldperGDP = html(paste0("<img src='https://mattnurse.com/wp-content/uploads/2024/08/goldperGDP.png' width='50' height='50'>")),
    medalsperGDP = html(paste0("<img src='https://mattnurse.com/wp-content/uploads/2024/08/medalsperGDP.png' width='50' height='50'>")),
    )
