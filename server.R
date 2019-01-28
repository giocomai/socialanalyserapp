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

      if (current_user$emailVerified == TRUE) {
        shinyjs::show("main")
      } else {
        shinyjs::show("verify_email_view")
      }

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
  
  # Get tweets
  current_tweets <- shiny::eventReactive(input$search_twitter_now, {
    rtweet::search_tweets(q = input$search_twitter_string,
                          n = input$n_tweets,
                          type = input$twitter_type_radio,
                          include_rts = input$include_RT,
                          token = twitter_token,
                          lang = input$tweet_lang)
  })
  
  
  output$tweets <- DT::renderDataTable({
    current_tweets() %>%
      select(screen_name, text) %>% 
      DT::datatable(options = list(pageLength = 5,
                                   lengthMenu = c(3, 5, 10, 15, 100),
                                   dom = "fpit"),
                    escape = FALSE,
                    rownames = FALSE)
  })
  
  output$explore_twitter_users <- DT::renderDataTable({
    current_tweets() %>%
      distinct(user_id, .keep_all = TRUE) %>% 
      select(screen_name, description, followers_count, verified, account_created_at, profile_expanded_url) %>% 
      mutate(account_created_at = as.Date(account_created_at)) %>% 
      rename(website = profile_expanded_url, followers = followers_count) %>% 
      DT::datatable(options = list(pageLength = 5,
                                   lengthMenu = c(3, 5, 10, 15, 100),
                                   dom = "fpit"),
                    escape = FALSE,
                    rownames = FALSE)
  })
  
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
    
    cards[[1]] <- material_column(
      width = 2,
      material_card(
        title = HTML(
          "Tweets extracted"
        ),
        depth = 3,
        HTML(
          scales::number(nrow(current_tweets()))
        )
      )
    )
    
    cards[[2]] <-     material_column(
      width = 2,
      material_card(
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
    )
    
    cards
    
  })
  
  

}
