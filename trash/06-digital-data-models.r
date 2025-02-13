### ----------------------------------------------------------
### election forecasting
### simon munzert
### ----------------------------------------------------------

# get packages
p_needed <- c("haven", "plyr", "dplyr", "ROAuth", "streamR", "pageviews", "statsgrokse", "stringr", "gtrendsR", "lubridate")
packages <- rownames(installed.packages())
p_to_install <- p_needed[!(p_needed %in% packages)]
if (length(p_to_install) > 0) {
  install.packages(p_to_install)
}
lapply(p_needed, require, character.only = TRUE)


## getting live data from Twitter ---------------------------

# how to register at Twitter as developer, obtain and use access tokens
browseURL("https://mkearney.github.io/rtweet/articles/auth.html")

# how to interact with the streamR package
browseURL("http://pablobarbera.com/blog/archives/1.html")

# Stream keywords used to filter tweets
q <- c("cdu","csu","spd","fdp","grüne","linke","afd","schulz","merkel","btw17")

# load authentication credentials for Twitter. You have to have registered your app online and performed the OAuth authentication process to have this
load("twitter_auth.RData")

filterStream("german_parties.json", track = q, timeout = 60*1, oauth = twitCred)
tweets <- parseTweets("german_parties.json", simplify = TRUE)
names(tweets)
cat(tweets$text[1])

cdu <- str_detect(tweets$text, regex("cdu|csu|merkel", ignore_case = TRUE))
spd <- str_detect(tweets$text, regex("spd|schulz", ignore_case = TRUE))
fdp <- str_detect(tweets$text, regex("fdp", ignore_case = TRUE))
gru <- str_detect(tweets$text, regex("grüne", ignore_case = TRUE))
lin <- str_detect(tweets$text, regex("linke", ignore_case = TRUE))
afd <- str_detect(tweets$text, regex("afd", ignore_case = TRUE))
mentions_df <- data.frame(cdu, spd, fdp, gru, lin, afd)
colMeans(mentions_df)




## getting pageviews from Wikipedia ---------------------------

## IMPORTANT: If you want to gather pageviews data before July 2015, you need the statsgrokse package. Check it out here:
browseURL("https://github.com/cran/statsgrokse")

ls("package:pageviews")

trump_views <- article_pageviews(project = "en.wikipedia", article = "Donald Trump", user_type = "user", start = "2015070100", end = "2017040100")
head(trump_views)
clinton_views <- article_pageviews(project = "en.wikipedia", article = "Hillary Clinton", user_type = "user", start = "2015070100", end = "2017040100")

plot(ymd(trump_views$date), trump_views$views, col = "red", type = "l")
lines(ymd(clinton_views$date), clinton_views$views, col = "blue")

german_parties_views <- article_pageviews(
  project = "de.wikipedia", 
  article = c("Christlich Demokratische Union Deutschlands", "Christlich-Soziale Union in Bayern", "Sozialdemokratische Partei Deutschlands", "Freie Demokratische Partei", "Bündnis 90/Die Grünen", "Die Linke", "Alternative für Deutschland"),
  user_type = "user", 
  start = "2015090100", 
  end = "2017040100"
)
table(german_parties_views$article)

parties <- unique(german_parties_views$article)
dat <- filter(german_parties_views, article == parties[1])
plot(ymd(dat$date), dat$views, col = "black", type = "l")
dat <- filter(german_parties_views, article == parties[2])
lines(ymd(dat$date), dat$views, col = "blue")
dat <- filter(german_parties_views, article == parties[3])
lines(ymd(dat$date), dat$views, col = "red")
dat <- filter(german_parties_views, article == parties[7])
lines(ymd(dat$date), dat$views, col = "brown")


## getting data from Google Trends ---------------------------

# IMPORTANT: The current gtrendsR version that is available on CRAN does not work. Install the develper version from GitHub by uncommenting the following line and running it (you might have to install the devtools package before that)
#devtools::install_github('PMassicotte/gtrendsR')
library(gtrendsR)
gtrends_merkel <- gtrends("Merkel", geo = c("DE"), time = "2017-01-01 2017-06-14")
gtrends_schulz <- gtrends("Schulz", geo = c("DE"), time = "2017-01-01 2017-06-14")

plot(gtrends_merkel)
plot(gtrends_schulz)

