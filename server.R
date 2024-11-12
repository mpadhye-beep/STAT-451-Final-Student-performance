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

}
