hidden(fluidRow(
  id = "main",
  material_page(
    title = "SocialAnalyseR",
    nav_bar_color = "teal lighten-3",
    nav_bar_fixed = TRUE,
    # Place side-nav in the beginning of the UI
    material_side_nav(
      fixed = TRUE,
      image_source = "blue_tridoku.png",
      # Place side-nav tabs within side-nav
      material_side_nav_tabs(
        side_nav_tabs = c(
          "Extract Tweets" = "extract_tweets",
          "Explore Tweets" = "explore_tweets",
          "Explore Twitter users" = "explore_twitter_users"
        ),
        icons = c("search", "explore", "people")
      )
    ),
    
    material_side_nav_tab_content(
      ##### Extract tweets #####
      side_nav_tab_id = "extract_tweets",
      tags$h2("Extract tweets"),
      inputPanel(textInput(inputId = "search_twitter_string", label = "Search Twitter"), 
                 material_radio_button(input_id = "twitter_type_radio",
                                       label = "Search type",
                                       as.list(c("recent", "popular", "mixed"))),
                 material_switch(input_id = "include_RT",
                                 label = "Include retweets?",
                                 initial_value = FALSE),
                 textInput(inputId = "tweet_lang",
                           label = "Language (2-letter code)"),
                 shiny::sliderInput(inputId = "n_tweets",
                                    label = "Number of tweets to extract",
                                    min = 0, max = 1000, value = 100, round = TRUE),
                 material_button(input_id = "search_twitter_now",
                                 label = "Search now!", icon = "search")),
      uiOutput("cards")
    ),
    material_side_nav_tab_content(
      side_nav_tab_id = "explore_tweets",
      tags$h2("Explore tweets"),
      material_card(title = "Tweets", 
                    DT::dataTableOutput(outputId = "tweets"))
    ),
    material_side_nav_tab_content(
      side_nav_tab_id = "explore_twitter_users",
      tags$h2("Explore Twitter users"),
      material_card(title = "Bio and selected data", 
                    DT::dataTableOutput(outputId = "explore_twitter_users"))
    )
  )
)
)