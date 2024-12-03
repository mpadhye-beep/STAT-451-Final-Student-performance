library(shiny)
library(bslib)

# Read the data
student_performance_factors = read.csv("StudentPerformanceFactors.csv")

# Define UI
ui <- fluidPage(
  # Apply custom CSS for fonts and styling
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap');
      
      body {
        background-color: #f0f8ff; /* Light blue background */
        font-family: 'Roboto', sans-serif; /* Apply Roboto font */
        color: #333; /* Dark gray text for better contrast */
      }
      
      h1, h2, h3, h4, h5, h6 {
        font-family: 'Roboto', sans-serif;
        font-weight: 500; /* Medium font weight for headings */
        color: #007BA7; /* Teal for headings to match theme */
      }
      
      .sidebar {
        background-color: #e6f7ff; /* Sidebar with light blue background */
        padding: 15px;
        border-radius: 5px;
        box-shadow: 0 0 5px rgba(0,0,0,0.1);
      }
      
      .main-panel {
        background-color: #ffffff; /* White background for main panel */
        padding: 15px;
        border-radius: 5px;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
      }
      
      .form-group label {
        font-weight: 500; /* Make input labels slightly bolder */
      }
      
      .tab-content {
        font-size: 16px; /* Slightly larger font for tab content */
      }
      
      .nav-tabs > li > a {
        font-weight: 500; /* Bold font for tab titles */
      }
      
      .blurb {
        font-size: 14px;
        color: #555; /* Slightly lighter gray for blurbs */
        margin-bottom: 20px; /* Added space between blurbs */
      }
      
      .sidebar img {
        width: 100%; /* Ensure the image fits well in the sidebar */
        border-radius: 5px;
        margin-bottom: 15px;
      }
    "))
  ),
  
  # App title
  titlePanel("Student Score Analysis"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      class = "sidebar",
      # Add an image to the sidebar
      #img(src = "https://via.placeholder.com/300x200.png?text=Student+Performance", alt = "Student Performance"),
      
      h4("Why This App Matters"),
      p("This app helps analyze the relationship between key factors and student performance, enabling educators and students to identify trends and improve outcomes. 
        Use the dropdowns below to explore statistics like mean and median for deeper insights."),
      
      br(),
      
      # Add a list of steps
      h5("Steps to Use:"),
      tags$ol(
        tags$li("Select an explanatory variable from the dropdown."),
        tags$li("Choose a statistic to analyze the data."),
        tags$li("Navigate through tabs to view different analyses."),
        tags$li("Interpret the results using the descriptions provided.")
      ),
      
      br(), 
      
      # Input: Dropdown for explanatory variable
      selectInput(
        inputId = "explanatory",
        label = "Pick Explanatory Variable",
        choices = colnames(student_performance_factors)
      ),
      selectInput(
        inputId = "statistic",
        label = "Select Statistic",
        choices = c("Min.", "1st Qu.", "Median", "Mean", "3rd Qu.", "Max.")
      ),
      
      p("The selected statistic will be highlighted as a red dotted line in applicable graphs."),
      
      br(),
      # Add a link to a guide
      tags$a(href = "https://www.kaggle.com/datasets/lainguyn123/student-performance-factors", target = "_blank", "Want to learn access the dataset? Click here!")
    ),
    
    # Main panel for displaying outputs
    #mainPanel(
    # Outputs
    #verbatimTextOutput(outputId = "summary"),
    #verbatimTextOutput(outputId = "table"),
    #plotOutput(outputId = "plot"),
    #plotOutput(outputId = "scatterPlot"),
    #textOutput(outputId = "statistic"), 
    #plotOutput(outputId = "histogramPlot"),
    #verbatimTextOutput(outputId = "anovaResult"),
    #plotOutput(outputId = "anovaPlot"),
    #plotOutput(outputId = "correlationHeatmap")
    #)
    
    # Potential alternative mainPanel using tabPanels (Maybe lessens overwhelming factor on users?: 
    mainPanel(
      class = "main-panel",
      tabsetPanel(
        tabPanel("Summary", 
                 br(),
                 div(class = "blurb", 
                     "The summary tab provides basic descriptive statistics (e.g., minimum, maximum, mean) for the selected variable. Use this to understand the distribution of the data."),
                 verbatimTextOutput(outputId = "summary")),
        
        tabPanel("Statistics Table", 
                 br(),
                 div(class = "blurb", 
                     "This table displays detailed statistical summaries for all variables. Use it to compare values across different factors."),
                 verbatimTextOutput(outputId = "table")),
        
        tabPanel("Box Plot", 
                 br(),
                 div(class = "blurb", 
                     "The box plot shows the distribution of the selected variable, including median, quartiles, and potential outliers. Look for spread and symmetry."),
                 plotOutput(outputId = "plot")),
        
        tabPanel("Scatter Plot", 
                 br(),
                 div(class = "blurb", 
                     "The scatter plot shows the relationship between two variables. Look for trends or patterns, such as positive/negative correlations."),
                 plotOutput(outputId = "scatterPlot")),
        
        tabPanel("Histogram", 
                 br(),
                 div(class = "blurb", 
                     "The histogram shows the frequency distribution of the selected variable. Use it to identify the shape of the data, such as normality or skewness."),
                 plotOutput(outputId = "histogramPlot")),
        
        tabPanel("Significance Results", 
                 br(),
                 div(class = "blurb", 
                     "The significance results tab compares the significance of explanatory variables. 
                     The ANOVA table examines means across groups to determine if there are statistically 
                     significant differences. The linear regression table identifies whether a numerical 
                     explanatory variable is significant, using a linear model. Both find significance at the
                     alpha of 0.05."),
                 tableOutput("anovaResult"),
                 tableOutput("lmResult"),
                 textOutput("significanceStatement")),
                
        
                 
        
        tabPanel("Correlation Heatmap", 
                 br(),
                 div(class = "blurb", 
                     "The correlation heatmap visualizes the strength and direction of relationships between variables. Darker colors indicate stronger correlations."),
                 plotOutput(outputId = "correlationHeatmap"))
      )
    )
    #
  )
)
