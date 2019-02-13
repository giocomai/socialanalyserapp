hidden(fluidRow(
  id = "main",
  tags$head(tags$script(src="https://platform.twitter.com/widgets.js")),
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
          "Manage projects" = "manage_projects",
          "Explore Tweets" = "explore_tweets",
          "Tweet wall" = "tweet_wall",
          "Explore Twitter users" = "explore_twitter_users",
          "Facebook engagement" = "explore_facebook_engagement"
        ),
        icons = c("search", "folder", "explore", "dashboard", "people", "thumb_up")
      )
    ),
    
    material_side_nav_tab_content(
      ##### Extract tweets #####
      side_nav_tab_id = "extract_tweets",
      tags$h2("Extract tweets"),
      material_column(material_card(title = "Search Twitter",
        textInput(inputId = "search_twitter_string", label = "Search Twitter"), 
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
                        label = "Search now!", icon = "search")), width = 3),
      material_column(
        uiOutput("cards"),
        width = 3
      ),
      material_column(
        shinymaterial::material_card(title = "URL import",
                                     shinymaterial::material_file_input(input_id = "url_input_file", label = "Upload csv"),
                                     tableOutput("preview_urls")),
        width = 3
      )
    ),
    ##### Manage projects #####
    material_side_nav_tab_content(
      side_nav_tab_id = "manage_projects",
      tags$h2("Manage projects"),
      material_row(
        material_column(
          material_card(title = "New project",
                        textInput(inputId = "new_project_name", label = "Name of new project"),
                        material_button(input_id = "create_new_project_now",
                                        label = "Create new project!", icon = "create_new_folder"))  
        ), 
        material_column(
          material_card(title = "Load project", 
                        uiOutput(outputId = "selectProject_UI"))
        )
      )), 
    ##### Explore tweets #####
    material_side_nav_tab_content(
      side_nav_tab_id = "explore_tweets",
      tags$h2("Explore tweets"),
      material_card(title = "Tweets", 
                    DT::DTOutput(outputId = "tweets")),
      material_card(uiOutput(outputId = "selected_tweets_wall"))
    ),
    ##### Tweet wall #####
    material_side_nav_tab_content(
      side_nav_tab_id = "tweet_wall",
      tags$h2("Tweet wall"),
      inputPanel(textInput(inputId = "tweet_includes", label = "Tweet includes")),
      uiOutput("wall")
      
    ),
    #### Explore twitter users #####
    material_side_nav_tab_content(
      side_nav_tab_id = "explore_twitter_users",
      tags$h2("Explore Twitter users"),
      material_card(title = "Bio and selected data", 
                    DT::dataTableOutput(outputId = "explore_twitter_users")),
      material_card(uiOutput(outputId = "selected_profiles_wall"))
    ),
    material_side_nav_tab_content(
      side_nav_tab_id = "explore_facebook_engagement",
      tags$h2("Explore Facebook engagement"),
      material_button(input_id = "find_facebook_engagement_now",
                      label = "Find FB engagement now!",
                      icon = "search"),
      material_card(title = "Facebook engagement on selected URLs", 
                    DT::DTOutput(outputId = "fb_engagement_dt")),
      downloadButton(outputId = "download_fb_engagement",
                     label =  "Download as csv")
    )
  )
))
