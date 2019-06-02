
library(tidyverse)
library(magrittr)
library(scales)
library(ggrepel)
library(glue)
library(grid)
library(gridExtra)
library(gganimate)

source('get_data.R')

head(jobs_gender)
glimpse(jobs_gender)

jobs_gender$major_category %>% unique()
jobs_gender$minor_category %>% unique()

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


salaries <- jobs_gender %>% 
  top_n(1, year) %>% # latest data
  # own calculation of ratio:
  # mutate(ratio_female_to_male = 100 * total_earnings_female / total_earnings_male) %>%
  # removed since calculation in the dataset accounts for very small sample size 
  # as some occupations have very small female values
  group_by(minor_category) %>%
  summarise(ratio_female_to_male = mean(wage_percent_of_male/100, na.rm = T)) %>%
  arrange(ratio_female_to_male) %>%
  mutate(minor_category = factor(minor_category, levels = .$minor_category))

dot_chart_data <- share_by_minor_cat %>% 
  arrange(share_of_fem_workers) %>%
  mutate(minor_category = factor(minor_category, levels = .$minor_category),
         color_label = ifelse(share_of_fem_workers >= 0.5, '#800080', '#1fc3aa'))

##### UNUSED HIGHLIGHTS ######
closest_to_50 <- which.min(abs(dot_chart_data$share_of_fem_workers-0.5))
highlights_dot_plot <- dot_chart_data[closest_to_50,]
highlights_dot_plot %<>%
  rbind(dot_chart_data %>%
          top_n(-2, share_of_fem_workers)) %>%
  rbind(dot_chart_data %>%
          top_n(2, share_of_fem_workers))


####### chart 1 #####
colors_in_data <- dot_chart_data %>% pull(color_label) %>% unique()
gray_for_chart <- 'grey46'
margin <- unit(0.5, "line")


p_total <- ggplot(data = dot_chart_data ) +
  geom_point(aes(x = share_of_fem_workers, y = minor_category),
             color = dot_chart_data$color_label,
             size = 5) +
  geom_segment(aes(y = minor_category, 
                   x = 0.5, 
                   yend = minor_category, 
                   xend = share_of_fem_workers), 
               color = "black") +
  geom_vline(xintercept = 0.5) +
  geom_text(mapping = aes(x = 0.5, y = 20),
            label = 'Perfect balance',
            angle = 90,
            vjust = -1.5,
            color = gray_for_chart) +
  geom_text(mapping = aes(x = 0.7, y = 23.2),
            label = 'More women →',
            size = 5,
            color = colors_in_data[2]) + #make color depend on the data
  geom_text(mapping = aes(x = 0.3, y = 23.2),
            label = '← More men',
            size = 5,
            color = colors_in_data[1]) + 
  scale_x_continuous(limits = c(0,1),
                     labels = percent) +
  theme_classic() +
  theme(text = element_text(size = 16,
                            color = gray_for_chart),
        axis.text.y = element_text(color = dot_chart_data$color_label),
        panel.grid.minor = element_blank()) +
  labs(x = 'Share of female workers from total, %',
       y = '')

title_total <- textGrob(
  label = "Which areas of work are most balanced between men & women?",
  x = unit(0, "lines"), 
  y = unit(0, "lines"),
  hjust = -0.1, vjust = 0,
  gp = gpar(fontsize = 20))


subtitle_total <- textGrob(
  label = "Legal work is more balanced in terms of men to women ratio compared to other areas
  ",
  x = unit(0, "lines"), 
  y = unit(0, "lines"),
  hjust = -0.1, vjust = 0,
  gp = gpar(fontsize = 15))


foot_total <- textGrob(
  label = "Source: Census Bureau 'Full-Time, Year-Round Workers and Median Earnings: 2000 and 2013-2017'
  Plot data: Mean share of female workers by occupation aggregated by work area
  ",
  x = unit(0, "lines"), 
  y = unit(0, "lines"),
  hjust = -0.1, vjust = 0,
  gp = gpar(fontsize = 10, fontfamily = "Arial Narrow"))

p_total <- arrangeGrob(title_total, subtitle_total, p_dot, 
                       heights = unit.c(grobHeight(title_total) + 1.2*margin, 
                                        grobHeight(subtitle_total) + margin, 
                                        unit(1,"null")),
                       bottom = foot_total)
grid.newpage()
grid.draw(p_total)
ggsave(file="share_by_area.png", p_total, width = 13, height = 10)

###### chart 2 #######

p_wages <- ggplot(data = salaries) +
  geom_point(aes(x = ratio_female_to_male,
                 y = minor_category),
             size = 5,
             color = colors_in_data[1]) +
  geom_segment(aes(y = minor_category, 
                   x = 0, 
                   yend = minor_category, 
                   xend = ratio_female_to_male), 
               color = "black") +
  geom_vline(xintercept = 1) +
  geom_text(mapping = aes(x = 1.05, y = 20),
            label = 'Equality',
            angle = 0,
            vjust = 0.1,
            color = gray_for_chart) +
  theme_classic() +
  theme(text = element_text(size = 16,
                            color = gray_for_chart),
        panel.grid.minor = element_blank()) +
  labs(x = "Ratio of female to male salaries; 1 = equal pay",
       y = '')


title_wages <- textGrob(
  label = "Are women paid the same as men?",
  x = unit(0, "lines"), 
  y = unit(0, "lines"),
  hjust = -0.25, vjust = 0,
  gp = gpar(fontsize = 20))

subtitle_wages <- textGrob(
  label = ' While for some specific occupations women are paid more than men, overall there are pay gaps in every work area. 
Legal, one of the more balanced areas between employed men & women, has the highest pay gap (in available data)
  ',
  x = unit(0, "lines"), 
  y = unit(0, "lines"),
  hjust = -0.08, vjust = 0,
  gp=gpar(fontsize=15))


foot_wages <- textGrob(
  label = "Source: Census Bureau 'Full-Time, Year-Round Workers and Median Earnings: 2000 and 2013-2017'
   Plot data: Mean ratio of median salaries by occupation aggregated by work area
  ",
  x = unit(0, "lines"), 
  y = unit(0, "lines"),
  hjust = -0.1, vjust = 0,
  gp = gpar(fontsize = 10, fontfamily = "Arial Narrow"))

g_wages <- arrangeGrob(title_wages, subtitle_wages, p_wages, 
             heights = unit.c(grobHeight(title_wages) + 1.2*margin, 
                              grobHeight(subtitle_wages) + margin, 
                              unit(1,"null")),
             bottom = foot_wages)

grid.newpage()
grid.draw(g_wages)
ggsave(file="wages_by_area.png", g_wages, width = 13, height = 8)



  

