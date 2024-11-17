#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(skimr)

student_performance_factors = read.csv("StudentPerformanceFactors.csv")

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  output$summary <- renderPrint({
    dataset <- get(input$explanatory, student_performance_factors)
    summary(dataset)
  })
  
  output$table <- renderPrint({
    x <- get(input$explanatory, student_performance_factors)
    skim(x)
  })
  
  output$plot <- renderPlot({
    ggplot(student_performance_factors, aes(x=Exam_Score, fill = get(input$explanatory)))+
      geom_boxplot()+
      labs(x = "Exam Score",
           title = paste0(input$explanatory, " vs. Exam_Score"),
           fill = input$explanatory)+
      theme(axis.ticks.y = element_blank(),
            axis.text.y=element_blank())
  })
  
  output$scatterPlot <- renderPlot({
    ggplot(student_performance_factors, aes(x = Exam_Score, y = get(input$explanatory), color = get(input$explanatory))) +
      geom_point(alpha = 0.7, size = 3) +
      labs(
        x = "Exam Score",
        #y = get(input$explanatory),
        color = input$explanatory,
        title = paste0("Study Hours vs Exam Score (Colored by ", input$explanatory, ")")
      ) +
      theme_minimal()
  })
  
 
  
  
}

