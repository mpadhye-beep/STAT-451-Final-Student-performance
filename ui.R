#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

student_performance_factors = read.csv("StudentPerformanceFactors.csv")


library(shiny)
library(bslib)


# Define UI
ui <- fluidPage(
  # App title
  titlePanel("Student Score Analysis"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      # Input: Dropdown for explanatory variable
      selectInput(
        inputId = "explanatory",
        label = "Pick explanatory",
        choices = colnames(student_performance_factors)
      ),
      selectInput(
        inputId = "statistic",
        label = "Select Statistic",
        choices = c("Min.", "1st Qu.", "Median", "Mean", "3rd Qu.", "Max.")
      )
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      # Outputs
      verbatimTextOutput(outputId = "summary"),
      verbatimTextOutput(outputId = "table"),
      plotOutput(outputId = "plot"),
      plotOutput(outputId = "scatterPlot"),
      textOutput(outputId = "statistic") # 
      
    )
  )
)

