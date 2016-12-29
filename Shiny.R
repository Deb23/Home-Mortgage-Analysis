setwd("//OHFS07/Home/dbasak/My Documents/CapitalOne Data Challenge -Debasmita/CapitalOne")
library(shiny)
library(plyr)
library(ggplot2)
library(dplyr)
library(data.table)
library(scales)
library(ggthemes)

hmda <- hmda_init()
ui <- fluidPage(   
  titlePanel("Home Mortgage Data Analysis"),
  
  sidebarLayout( position="left",
    sidebarPanel(
                 selectInput("stateinput", "State",
                             choices = unique(hmda$State),
                             selected = "MD"),
                 sliderInput("top_n", "Top N", min = 1, max = 5,value=c(25)),
                 selectInput("groupby", "Group By",
                             choices = c("Loan Originated Value","Loan Originated Volume"),
                             selected = "MD"),
                 radioButtons("yearinput", "Year",
                              choices = c("All",sort(unique(hmda$As_of_Year))),
                              selected = "All"), width=3
                 
                 ),
    mainPanel(
      fluidRow(
     splitLayout(cellWidths = c("50%","50%"), plotOutput("byValue"), plotOutput("byVolume"))
      )
    )
  )
  )
  

server <- function(input, output) {
  
  filtered <- reactive({
    if(input$yearinput=="All") {
      
     hmda %>% filter( State == input$stateinput)
    }else{
     hmda %>% 
        filter(State == input$stateinput,
               As_of_Year == input$yearinput)
    }
    
  })
  
  top_n <- reactive({
    
    filter_returned <- filtered()
    
    if(input$groupby=="Loan Originated Value"){
      agg <- aggregate(x=filter_returned[c("Loan_Amount_000")],
                       by = filter_returned[c("Respondent_Name_TS")],
                       FUN = function(y){sum(y)})
      names(agg) <- c("Respondent","Value")
      
    }else{
      agg <- substring(as.data.frame(table(filter_returned$Respondent_Name_TS)),Freq>0)
      names(agg) <- c("Respondent","Value")
      
    }
    
    d <- data.table(agg, key="Value")
    d1 <- d[order(-Value)]
    head(d1,input$top_n[1])
    
  })
  
  output$byValue <- renderPlot({
    
    if(input$groupby=="Loan Originated Value"){
      
      data_value=top_n()
    }
    else
    {
      top_volume <- top_n()
      filter_value <- filtered() %>% 
        filter(Respondent_Name_TS %in% top_volume$Respondent)
      
      data_value <- aggregate(x=filter_value[c("Loan_Amount_000")],
                             by = filter_value[c("Respondent_Name_TS")],
                             FUN = function(y){sum(y)})
      names(data_value) <- c("Respondent","Value")

    }
      
      ggplot(data_value, aes(x=Respondent, y=Value/1000000)) + theme_economist()+scale_colour_economist()+
        geom_bar(stat="identity") +     # contour colour
        guides(fill=guide_legend(reverse=TRUE)) +         # reverse legend
        ggtitle("Competitor Market Share($ Billion)") +
        labs(x="",y=input$groupby)+
        #   geom_text(aes(label = Loan_Amount_000), size = 3, hjust = 0.5, vjust = 3, position ="stack") +                                                # label colour
        scale_fill_brewer(palette="Paired")  +             # colour palette
        coord_flip()
  })
  
  output$byVolume <- renderPlot({
    
    if(input$groupby=="Loan Originated Volume"){
      
      data_volume=top_n()
    }
    else
    {
      top_value <- top_n()
      filter_volume <- filtered() %>% 
        filter(Respondent_Name_TS %in% top_value$Respondent)
      
      data_volume <- subset(as.data.frame(table(filter_volume$Respondent_Name_TS)), Freq>0)
      names(data_volume) <- c("Respondent","Value")
      
    }
      ggplot(data_volume, aes(x=Respondent, y=Value)) + theme_economist()+scale_colour_economist()+
        geom_bar(stat="identity") +     # contour colour
        guides(fill=guide_legend(reverse=TRUE)) +         # reverse legend
        ggtitle("Competitor Market Share(Volume)") +
        labs(x="",y=input$groupby)+
        #   geom_text(aes(label = Loan_Amount_000), size = 3, hjust = 0.5, vjust = 3, position ="stack") +                                                # label colour
        scale_fill_brewer(palette="Paired")  +             # colour palette
        coord_flip()
    
  })
}


shinyApp(ui = ui, server = server)
