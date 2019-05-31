
library(readr)
library(tidyverse)
library(magrittr)

source('get_data.R')

head(jobs_gender)
glimpse(jobs_gender)

jobs_gender$major_category %>% unique()
jobs_gender$minor_category %>% unique()


## what are the top and bottom jobs by share of females 
## what are the highest and lowest paid jobs for women vs men?
## distribution of wages by category


share_by_minor_cat <- jobs_gender %>% 
  top_n(1, year) %>% # latest data
  group_by(minor_category) %>%
  summarise(sum_total_workers = sum(total_workers),
            sum_female = sum(workers_female),
            sum_male = sum(workers_male)) %>%
  mutate(share_of_fem_workers = sum_female/sum_total_workers)

ggplot(data = jobs_gender %>%
         top_n(1,year) %>%
         select(major_category, 
                male= total_earnings_male, 
                female = total_earnings_female) %>%
         mutate(male = male/1000,
                female = female/ 1000) %>%
         gather(gender, earnings_thousands, -major_category)) +
  geom_density(aes(x = earnings_thousands, fill = gender)) + 
  facet_grid( rows= vars(major_category)) +
  labs(title = 'Densities of median salary distributions')


top_5_male_jobs <- jobs_gender %>% 
  top_n(1, year) %>%
  arrange(percent_female) %>%
  top_n(-5, percent_female) %>%
  select(occupation, percent_female)
head(top_5_male_jobs)

top_5_female_jobs <- jobs_gender %>% 
  top_n(1, year) %>%
  arrange(percent_female) %>%
  top_n(5, percent_female) %>%
  select(occupation, percent_female)
head(top_5_female_jobs)


average_of_ratios <- jobs_gender %>% 
  top_n(1, year) %>% # latest data
  # own calculation of ratio:
  # mutate(ratio_female_to_male = 100 * total_earnings_female / total_earnings_male) %>%
  # removed since calculation in the dataset accounts for very small sample size 
  # as some occupations have very small female values
  group_by(minor_category) %>%
  summarise(ratio_female_to_male = mean(wage_percent_of_male, na.rm = T)) %>%
  arrange(ratio_female_to_male)



