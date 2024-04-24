install.packages("devtools")
devtools::install_github("r-lib/conflicted", force = TRUE)
library(conflicted)
library(dplyr)

install.packages("readxl")
install.packages("shiny")
install.packages("httr")
install.packages("stringr")
install.packages("text")
install.packages("jsonlite")
# Load necessary libraries
library(shiny) # For creating web applications
library(httr)        # For making HTTP requests
library(tidyverse)   # For data manipulation and visualization
library(stringr)     # For string manipulation
library(text)        # For text processing
library(readxl)

# Paste your ChatGPT API key here
api_key <- "" #You need to paste your own ChatGPT API key here

# Define the user interface (UI) for the Political Advice Generator application
ui <- fluidPage(
  # Title of the application
  titlePanel("About Villanova University Generator"),
  
  # Layout with a sidebar and main content area
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      # Text input for the user's question with a default value
      textInput("question", "Enter your question:", "What do you want to know about Villanova?"),
      # Button to submit the question
      actionButton("submit", "Submit")
    ),
    # Main content area for displaying outputs
    mainPanel(
      # Display the answer
      h3("Answer"),
      textOutput("answer1"),

    )
  )
)

server <- function(input, output) {
  # Read GloVe matrix and 'The Prince' text
  
  
  process_and_get_response <- function(question) {
    
    data <- read_excel("Reviews_for_Villlanova.xlsx")
    text <- paste(data, collapse = " ")

    message_full <- paste("The following input are student reviews for Villanova University. They are individually denoted by number enclosed in brackets. There are 140 of them. Here they are:", paste(data, collapse = " "), " This is the end of the reviews. The question the user has is: ", question, ", Please be as detailed as possible.")
    message_full <- str_sub(message_full, 1, min(str_length(message_full), 60000)) # Limit the message length
    
    response_full <- POST(
      url = "https://api.openai.com/v1/chat/completions",
      add_headers(Authorization = paste("Bearer", api_key)),
      content_type_json(),
      encode = "json",
      body = list(
        model = "gpt-3.5-turbo-1106",
        messages = list(list(role = "user", content = message_full)),
        temperature = 0.1
      )
    )
    
    resp_full <- content(response_full)
    answer_full <- resp_full$choices[[1]]$message$content
    
    list(answer1 = answer_full)
  }
 
  observeEvent(input$submit, {
    question <- input$question
    # Call your processing function
    response <- process_and_get_response(question)
    # Update UI elements
    output$answer1 <- renderText(response$answer1)
  })
  
  # Initialize output to show before you run a question. 
  output$answer1 <- renderText("Answer will appear here")
}

shinyApp(ui = ui, server = server)