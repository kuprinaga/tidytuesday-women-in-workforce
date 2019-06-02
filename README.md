# tidytuesday-women-in-workforce
TidyTuesday published data from the Census Bureau about women in the workforce. Equality and diversity are close to my heart and I couldn't pass on this data. The data was showing - from all angles - that in categories that were given by Census Bureau, the pay gap is huge. At the same time, using same data, we can see what is the balance of females & males in the industry like.  


## A word about color use
I did not want to go with pink/blue that are typically "assigned" to genders. Instead, I turned to Google and this popped up: https://blog.datawrapper.de/gendercolor/. Very interesting article to glance through; in short I chose to use the same palette as does The Telegraph (and while I do not necessarily agree with the views of the paper, the justification of their use of this colour is awesome):

>The colors are inspired by the “Votes for Women” campaign in the UK as part of the initial suffrage movement in the early 20th century. At the heart of this movement were “Sylvia Pankhurst and Emmeline Pethick-Lawrence and essentially the colors were their choice (apparently symbolizing; purple for freedom and dignity, white for purity, green for hope).”


## Balance of work areas 
First I wanted to know *how balanced are the areas of work*, in other words, how number of women compared to total headcount.


<img src="share_by_area.png" alt="drawing" width="100%"/>


## Wages by work area

<img src="wages_by_area.png" alt="drawing" width="100%"/>

The wage gap is crazy. I did find a few occupations where women are paid more than men, but it's so rare that it's not visible when data is aggregated by area of work.

Original data: https://github.com/rfordatascience/tidytuesday/tree/master/data/2019/2019-04-16 

Libraries used: 

- tidyverse
- lubridate
- scales
- ggthemes
- magrittr
- gridExtra
- ggrepel
- cowplot
