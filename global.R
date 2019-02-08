if (!require("pacman")) install.packages("pacman")
pacman::p_load("shiny")
pacman::p_load("shinyjs")
pacman::p_load("DT")
pacman::p_load("shinymaterial")
pacman::p_load("shinydashboard")
pacman::p_load("rtweet")
pacman::p_load("dplyr")
pacman::p_load("stringr")
pacman::p_load("jsonlite")

twitter_token <- readRDS(file = "twitter_token.rds")

embed_tweet <- function(id){
  url <- paste0("https://publish.twitter.com/oembed?url=https%3A%2F%2Ftwitter.com%2FInterior%2Fstatus%2F",
                id)
   fromJSON(url)$html
}

embed_tweet_js <- function(id, i) {
  HTML(paste0('<div id="tweetcontainer', i, '"></div>',
"<script>twttr.widgets.createTweet('", id, "',
  document.getElementById('tweetcontainer", i, "'),
  {
    theme: 'light'
  }
); </script>"))
}
