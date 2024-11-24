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
library(corrplot)

student_performance_factors = read.csv("StudentPerformanceFactors.csv")

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  calculate_statistic <- function(variable) {
    switch(input$statistic,
           "Min." = min(variable, na.rm = TRUE),
           "1st Qu." = quantile(variable, 0.25, na.rm = TRUE),
           "Median" = median(variable, na.rm = TRUE),
           "Mean" = mean(variable, na.rm = TRUE),
           "3rd Qu." = quantile(variable, 0.75, na.rm = TRUE),
           "Max." = max(variable, na.rm = TRUE))
  }
  
  output$summary <- renderPrint({
    dataset <- get(input$explanatory, student_performance_factors)
    summary(dataset)
  })
  
  output$table <- renderPrint({
    x <- get(input$explanatory, student_performance_factors)
    skim(x)
  })
  
output$plot <- renderPlot({
    selected_stat <- calculate_statistic(student_performance_factors$Exam_Score)
    ggplot(student_performance_factors, aes(x = Exam_Score, fill = get(input$explanatory))) +
      geom_boxplot() +
      geom_vline(xintercept = selected_stat, color = "red", linetype = "dashed", size = 1) +
      labs(x = "Exam Score",
           title = paste0(input$explanatory, " vs. Exam_Score (", input$statistic, ": ", round(selected_stat, 2), ")"),
           fill = input$explanatory) +
      theme(axis.ticks.y = element_blank(),
            axis.text.y = element_blank())
  })
  
  
  output$scatterPlot <- renderPlot({
    selected_stat <- calculate_statistic(student_performance_factors$Exam_Score)
    explanatory_stat <- student_performance_factors[[input$explanatory]]
    r_squared <- NA
    if(is.numeric(explanatory_stat)) {
      lm_fit <- lm(explanatory_stat ~ Exam_Score, data=student_performance_factors)
      r_squared = summary(lm_fit)$r.squared
      ggplot(student_performance_factors, aes(x = Exam_Score, y = get(input$explanatory), color = get(input$explanatory))) +
        geom_point(alpha = 0.7, size = 3) +
        geom_vline(xintercept = selected_stat, color = "red", linetype = "dashed", size = 1) +
        geom_smooth(method="lm",se=T,color="black")+
        ylim(0,max(explanatory_stat))+
        labs(
          x = "Exam Score",
          y= input$explanatory,
          color = input$explanatory,
          title = paste0(input$explanatory, " vs. Exam_Score (", input$statistic, ": ", round(selected_stat, 2), ")"),
          subtitle=paste0("R squared: ", round(r_squared,3))
        ) +
        theme_minimal()
    } else {
      ggplot(student_performance_factors, aes(x = Exam_Score, y = get(input$explanatory), color = get(input$explanatory))) +
        geom_point(alpha = 0.7, size = 3) +
        geom_vline(xintercept = selected_stat, color = "red", linetype = "dashed", size = 1) +
        labs(
          x = "Exam Score",
          color = input$explanatory,
          title = paste0(input$explanatory, " vs. Exam_Score (", input$statistic, ": ", round(selected_stat, 2), ")"),
          subtitle=paste0("R squared: ", round(r_squared,3))
        ) +
        theme_minimal()
    }
  })
  

  output$histogramPlot <- renderPlot({
    explanatory_var <- student_performance_factors[[input$explanatory]]
    is_categorical <- is.factor(explanatory_var) || is.character(explanatory_var)
    selected_stat <- calculate_statistic(student_performance_factors$Exam_Score)
    
    if (is_categorical) {
      ggplot(student_performance_factors, aes(x = Exam_Score, fill = explanatory_var)) +
        geom_histogram(binwidth = 5, position = "dodge", alpha = 0.7) +
        geom_vline(xintercept = selected_stat, color = "red", linetype = "dashed", size = 1) +
        labs(
          x = "Exam Score",
          y = "Count",
          title = paste("Distribution of Exam Scores by", input$explanatory, "(", input$statistic, ": ", round(selected_stat, 2), ")"),
          fill = input$explanatory
        ) +
        theme_minimal()
    } else {
      ggplot(student_performance_factors, aes(x = Exam_Score)) +
        geom_histogram(aes(fill = ..count..), binwidth = 5, alpha = 0.7, color = "black") +
        geom_vline(xintercept = selected_stat, color = "red", linetype = "dashed", size = 1) +
        labs(
          x = "Exam Score",
          y = "Count",
          title = paste("Distribution of Exam Scores (", input$statistic, ": ", round(selected_stat, 2), ")"),
          fill = "Count"
        ) +
        theme_minimal()
    }
  })

  output$anovaResult <- renderTable({
    if (is.factor(student_performance_factors[[input$explanatory]]) || 
        is.character(student_performance_factors[[input$explanatory]])) {
      
      anova_result <- aov(Exam_Score ~ get(input$explanatory), data = student_performance_factors)
      anova_summary <- summary(anova_result)[[1]]  # Extract the ANOVA table
      
      result_table <- data.frame(
        Source = c("Between Groups", "Within Groups"),
        Df = anova_summary$Df,
        Sum_Sq = anova_summary$`Sum Sq`,
        Mean_Sq = anova_summary$`Mean Sq`,
        F_value = anova_summary$`F value`,
        Pr_F = anova_summary$`Pr(>F)`
      )
      
      result_table$Pr_F <- format(result_table$Pr_F, digits = 3, scientific = T)
      p_value <- anova_summary$`Pr(>F)`[1]  # Get the p-value for the first factor
      significance <- ifelse(p_value < 0.05, "Significant", "Not Significant")
      result_table$Significance_0.05 <- significance
      
      result_table
    } else {
      "ANOVA can only be performed on categorical variables."
    }
  })
  

  filtered_data <- reactive({
    student_performance_factors %>%
      select(where(is.numeric))
  })
  
  output$lmResult <- renderTable({
    explanatory_stat <- student_performance_factors[[input$explanatory]]
    
    if (is.numeric(explanatory_stat)) {
      lm_fit <- lm(explanatory_stat ~ Exam_Score, data = student_performance_factors)
      
      lm_summary <- summary(lm_fit)
      
      result_table <- data.frame(
        Component = c("Intercept", input$explanatory), 
        Estimate = round(lm_summary$coefficients[, 1], 3),
        Std_Error = round(lm_summary$coefficients[, 2], 3),
        t_value = round(lm_summary$coefficients[, 3], 3),
        p_value = lm_summary$coefficients[, 4]
      )
      
      result_table$Significance_0.05 <- ifelse(result_table$p_value < 0.05, "Significant", "Not Significant")
      result_table$p_value <- format(result_table$p_value, digits = 3, scientific = T)
      
      result_table <- rbind(result_table, data.frame(
        Component = "R-squared", 
        Estimate = lm_summary$r.squared,
        Std_Error = NA, t_value = NA, p_value = NA, Significance_0.05 = NA
      ))
      
      result_table
    } else {
      "Linear model can only be performed on numeric variables."
    }
  })
  
  output$significanceStatement <- renderText({
    significance_message <- ""
    
    if (is.factor(student_performance_factors[[input$explanatory]]) || 
        is.character(student_performance_factors[[input$explanatory]])) {
      
      anova_summary <- aov(Exam_Score ~ get(input$explanatory), data = student_performance_factors)
      p_value_anova <- summary(anova_summary)[[1]]$`Pr(>F)`[1]
      
      if (p_value_anova < 0.05) {
        significance_message <- paste(significance_message, "ANOVA result: Explanatory variable is significant (p < 0.05)", sep = "\n")
      } else {
        significance_message <- paste(significance_message, "ANOVA result: Explanatory variable is not significant (p >= 0.05)", sep = "\n")
      }
    }
    
    explanatory_stat <- student_performance_factors[[input$explanatory]]
    
    if (is.numeric(explanatory_stat)) {
      lm_fit <- lm(explanatory_stat ~ Exam_Score, data = student_performance_factors)
      lm_summary <- summary(lm_fit)
      
      p_value_lm <- lm_summary$coefficients[2, 4]  
      
      if (p_value_lm < 0.05) {
        significance_message <- paste(significance_message, "Linear model result: Explanatory variable is Significant (p < 0.05)", sep = "\n")
      } else {
        significance_message <- paste(significance_message, "Linear model result: Explanatory variable is Not Significant (p >= 0.05)", sep = "\n")
      }
    }
    
    return(significance_message)
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

