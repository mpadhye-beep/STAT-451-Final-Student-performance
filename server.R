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
  
  output$histogramPlot <- renderPlot({
    explanatory_var <- student_performance_factors[[input$explanatory]]
    is_categorical <- is.factor(explanatory_var) || is.character(explanatory_var)
    
    if (is_categorical) {
      ggplot(student_performance_factors, aes(x = Exam_Score, fill = explanatory_var)) +
        geom_histogram(binwidth = 5, position = "dodge", alpha = 0.7) +
        labs(
          x = "Exam Score",
          y = "Count",
          title = paste("Distribution of Exam Scores by", input$explanatory),
          fill = input$explanatory
        ) +
        theme_minimal()
    } else {
      ggplot(student_performance_factors, aes(x = Exam_Score)) +
        geom_histogram(aes(fill = ..count..), binwidth = 5, alpha = 0.7, color = "black") +
        labs(
          x = "Exam Score",
          y = "Count",
          title = paste("Distribution of Exam Scores"),
          fill = "Count"
        ) +
        theme_minimal()
    }
  }) 

  output$anovaResult <- renderPrint({
    if (is.factor(student_performance_factors[[input$explanatory]]) || 
        is.character(student_performance_factors[[input$explanatory]])) {
      anova_result <- aov(Exam_Score ~ get(input$explanatory), data = student_performance_factors)
      summary(anova_result)
    } else {
      "ANOVA can only be performed on categorical variables."
    }
  })
  
  output$anovaPlot <- renderPlot({
    if (is.factor(student_performance_factors[[input$explanatory]]) || 
        is.character(student_performance_factors[[input$explanatory]])) {
      ggplot(student_performance_factors, aes(x = get(input$explanatory), y = Exam_Score)) +
        geom_boxplot(fill = "skyblue", alpha = 0.7) +
        labs(title = paste("Boxplot of Exam Scores by", input$explanatory),
             x = input$explanatory, y = "Exam Score") +
        theme_minimal()
    } else {
      ggplot() + theme_void()
    }
  })

  filtered_data <- reactive({
    student_performance_factors %>%
      select(where(is.numeric))
  })
  
  output$correlationHeatmap <- renderPlot({
    cor_matrix <- cor(filtered_data(), use = "complete.obs")
    
    corrplot(cor_matrix, method = "circle", type = "upper", order = "hclust", 
             title = "Correlation Heatmap of Numerical Variables", 
             tl.cex = 0.8, number.cex = 0.7,
             addCoef.col = "black",
             insig = "blank", 
             p.mat = cor.mtest(filtered_data(), conf.level = 0.95)$p,
             mar = c(5, 5, 3, 5))
  })
}

