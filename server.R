function(input, output, session) {
  
  ##### Switch Views ------------------
  # if user click link to register, go to register view
  observeEvent(input$go_to_register, {
    shinyjs::show("register_panel", anim = TRUE, animType = "fade")
    shinyjs::hide("sign_in_panel")
  }, ignoreInit = TRUE)
  
  observeEvent(input$go_to_sign_in, {
    shinyjs::hide("register_panel")
    shinyjs::show("sign_in_panel", anim = TRUE, animType = "fade")
  }, ignoreInit = TRUE)
  
  # switch between auth sign in/registration and app for signed in user
  observeEvent(session$userData$current_user(), {
    current_user <- session$userData$current_user()
    
    if (is.null(current_user)) {
      shinyjs::show("sign_in_panel")
      shinyjs::hide("main")
      shinyjs::hide("verify_email_view")
      
    } else {
      shinyjs::hide("sign_in_panel")
      shinyjs::hide("register_panel")
      
     # if (current_user$emailVerified == TRUE) {
        shinyjs::show("main")
      # } else {
      #   shinyjs::show("verify_email_view")
      # }
      
    }
    
  }, ignoreNULL = FALSE)
  
  # Signed in user --------------------
  # the `session$userData$current_user()` reactiveVal will hold information about the user
  # that has signed in through Firebase.  A value of NULL will be used if the user is not
  # signed in
  session$userData$current_user <- reactiveVal(NULL)
  
  # input$sof_auth_user comes from front end js in "www/sof-auth.js"
  observeEvent(input$sof_auth_user, {
    
    # set the signed in user
    session$userData$current_user(input$sof_auth_user)
    
  }, ignoreNULL = FALSE)
  
  
  ##### App for signed in user
  
  ##### Get tweets #####
  current_tweets <- shiny::eventReactive(input$search_twitter_now, {
    

    if (is.null(current_urls())==FALSE) {
      rtweet::search_tweets2(q = current_urls() %>% pull(1),
                             n = input$n_tweets,
                             type = input$twitter_type_radio,
                             include_rts = input$include_RT,
                             token = twitter_token,
                             lang = input$tweet_lang)
    } else if (input$twitter_search_what=="tweets") {
      rtweet::search_tweets(q = input$search_twitter_string,
                            n = input$n_tweets,
                            type = input$twitter_type_radio,
                            include_rts = input$include_RT,
                            token = twitter_token,
                            lang = input$tweet_lang)
      
    } else if (input$twitter_search_what=="users") {
      rtweet::search_users(q = input$search_twitter_string,
                           n = input$n_tweets,
                           parse = TRUE,
                           token = twitter_token,
                           verbose = FALSE)
    }

  })
  

  output$tweets <- DT::renderDT({
    current_tweets() %>%
      select(screen_name, text) %>% 
      DT::datatable(options = list(pageLength = 5,
                                   lengthMenu = c(3, 5, 10, 15, 100),
                                   dom = "fpit"),
                    escape = FALSE,
                    rownames = FALSE)
  }, server = TRUE)
  
  output$explore_twitter_users <- DT::renderDT({
    current_tweets() %>%
      distinct(user_id, .keep_all = TRUE) %>% 
      select(screen_name, name, description, followers_count, verified, account_created_at, profile_expanded_url) %>% 
      mutate(account_created_at = as.Date(account_created_at)) %>% 
      rename(website = profile_expanded_url, followers = followers_count) %>% 
      DT::datatable(options = list(pageLength = 5,
                                   lengthMenu = c(3, 5, 10, 15, 100),
                                   dom = "fpit"),
                    escape = FALSE,
                    rownames = FALSE)
  }, server = TRUE)
  
  
  
  # daily_data <- reactiveFileReader(
  #   intervalMillis = 100,
  #   filePath       = 'path/to/shared/data',
  #   readFunc       = readr::read_rds()
  # )
  
  output$cards <- renderUI({
    
    if(nrow(current_tweets()) == 0){
      return(NULL)
    }
    

    
    cards <- tagList()
    
    cards[[1]] <- 
      material_card(
        title = HTML(
          "Tweets extracted"
        ),
        depth = 3,
        HTML(
          scales::number(nrow(current_tweets()))
        ))

    cards[[2]] <- material_card(
      title = HTML(
        "Number of users"
      ),
      depth = 3,
      HTML(
        current_tweets() %>% 
          distinct(screen_name) %>% 
          nrow()
      )
    )
    
    cards[[3]] <- material_card(
      title = HTML(
        "Export"
      ),
      depth = 3,
      downloadButton(outputId = "download_twitter_users",
                     label =  "Download twitter users"),
      HTML("<div><hr /></div>"),
      downloadButton(outputId = "download_tweets",
                     label =  "Download tweets")
    )
    cards   


  })
  
  # output$n_tweets <- renderValueBox({
  #   if(nrow(current_tweets()) == 0){
  #     return(NULL)
  #   }
  #   valueBox( "Tweets extracted", scales::number(nrow(current_tweets())),
  #             icon = icon("twitter"), color = "blue" )
  # })
  # 
  # output$n_users <- renderValueBox({
  #   if(nrow(current_tweets()) == 0){
  #     return(NULL)
  #   }
  #   valueBox( "Number of users", scales::number(current_tweets() %>% 
  #                                                 distinct(screen_name) %>% 
  #                                                 nrow()), icon = icon("user"), color = "purple" )
  # })
  
  ####### Tweet wall ######
  
  output$wall <- renderUI({
    
    if(nrow(current_tweets()) == 0){
      return(NULL)
    }
    
    if (length(input$tweet_includes==0)) {
      tempTweets <- current_tweets()
    } else {
      tempTweets <- current_tweets() %>% 
        filter(stringr::str_detect(string = text, pattern = stringr::regex(pattern = input$tweet_includes, ignore_case = TRUE)))
    }
    
    nrowTempTweets <- nrow(tempTweets)
    wall <- tagList()
    
    if (nrowTempTweets>20) {
      for (i in 1:4) { #create four columns
        j = (i*5-4)
        wall[[i]] <- material_column(
          width = 3,
          material_card(embed_tweet_js(id = tempTweets$status_id[j], i = j)),
          material_card(embed_tweet_js(id = tempTweets$status_id[j+1], i = j+1)),
          material_card(embed_tweet_js(id = tempTweets$status_id[j+2], i = j+2)),
          material_card(embed_tweet_js(id = tempTweets$status_id[j+3], i = j+3)),
          material_card(embed_tweet_js(id = tempTweets$status_id[j+4], i = j+4))
        )
      }
    } else {
      for (i in 1:nrowTempTweets) { 
        wall[[i]] <- material_column(
          width = 3,
          material_card(
            embed_tweet_js(id = tempTweets$status_id[i], i = i)
          )
        )
      }
    }
    wall
  })
  
  output$selected_tweets_wall <- renderUI({
    
    if(nrow(current_tweets()) == 0){
      return(NULL)
    }
    
    if (is.null(input$tweets_rows_selected)) {
      return(NULL)
    }
    
    tempTweets <- current_tweets() %>% 
      slice(input$tweets_rows_selected)
    
    nrowTempTweets <- nrow(tempTweets)
    
    wall <- tagList()
    
    for (i in 1:nrowTempTweets) { 
      wall[[i]] <- material_column(
        width = 3,
        material_card(
          embed_tweet_js(id = tempTweets$status_id[i], i = i)
        )
      )
    }
    material_row(wall)
  })
  
  
  output$selected_profiles_wall <- renderUI({
    
    if(nrow(current_tweets()) == 0){
      return(NULL)
    }
    
    if (is.null(input$explore_twitter_users_rows_selected)) {
      return(NULL)
    }
    
    tempTweets <- current_tweets() %>% 
      slice(input$explore_twitter_users_rows_selected)
    
    nrowTempTweets <- nrow(tempTweets)
    
    wall <- tagList()
    
    for (i in 1:nrowTempTweets) { 
      wall[[i]] <- material_column(
        width = 3,
        material_card(
          embed_profile(screen_name = tempTweets$screen_name[i])
        )
      )
    }
    material_row(wall)
  })
  
  
  ##### UI ######
  
  #### Select project ui ####
  
  output$selectProject_UI <- shiny::renderUI({
    
    projects <- list.dirs(path = "projects",
                          full.names = FALSE,
                          recursive = FALSE)
    
    shiny::selectizeInput(inputId = "selected_projects",
                          label = "Available projects",
                          choices = as.list(c("", projects)),
                          selected = "",
                          multiple = TRUE,
                          width = "95%")
    
  })
  
  #### Create new project ####
  
  shiny::eventReactive(input$create_new_project_now, {
    
  })
  
  
  ##### Import CSV of urls ######
  
  current_urls <- shiny::eventReactive(input$url_input_file, {
   
      in_file <- input$url_input_file
      
      if (is.null(in_file)) return(NULL)
      
      as_tibble(read.csv(file = in_file$datapath, stringsAsFactors = FALSE))
    
  })
  
  output$preview_urls <- renderTable(
    if (is.null(current_urls())==FALSE) {
     current_urls() %>% 
        rename(urls = 1) %>% 
        select(urls) %>% 
        slice(1:10)
    }
  )
  
  #### Facebook engagement
  
  
  fb_engagement_df <- shiny::eventReactive(input$find_facebook_engagement_now, {
    
    in_file <- input$url_input_file
    
    if (is.null(in_file)) return(NULL)
    
    #--- Show the spinner ---#
    material_spinner_show(session, "fb_engagement_dt")
    
    current_urls <- as_tibble(read.csv(file = in_file$datapath, stringsAsFactors = FALSE))
    
    if (is.null(current_urls())) return(NULL)
    
    all_urls <- current_urls() %>% 
      pull(1)
    
    temp <- vector(mode = "list", length = length(all_urls))
    
    for (i in seq_along(all_urls)) {
      temp[[i]] <- bind_cols(find_fb_url_stats(url = all_urls[i],
                                               facebook_token = facebook_token),
                             tibble(url = all_urls[i]))
    }
    
    #--- Hide the spinner ---#
    material_spinner_hide(session, "fb_engagement_dt")
    
    purrr::map_df(.x = temp, .f = bind_rows) %>% 
      select(url, dplyr::everything())

  })
  
  output$fb_engagement_dt <- DT::renderDT({
    
    fb_engagement_df()
  
  })
  
  output$download_fb_engagement <- downloadHandler(
    filename = function() {
      paste('fb_engagement-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(fb_engagement_df(), con)
    }
  )
  
  output$download_twitter_users <- downloadHandler(
    filename = function() {
      paste('twitter_users-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(current_tweets() %>% 
                  select(screen_name, name, description, location, followers_count, friends_count, account_created_at, verified, profile_expanded_url), con)
    }
  )
  
  output$download_tweets <- downloadHandler(
    filename = function() {
      paste('tweets-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(current_tweets() %>% 
                  select(screen_name, text, user_id, status_id, created_at, source, reply_to_status_id, is_quote, is_retweet, favorite_count, retweet_count,  name, description, location, followers_count, friends_count, account_created_at, verified, profile_expanded_url), con)
    }
  )
  
  
}