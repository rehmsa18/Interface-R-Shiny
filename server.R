library(shiny)
library(rsconnect)
library(shinythemes)
library(tidyverse)
library(reshape2)
library(ggplot2)

rsconnect::setAccountInfo(name='alifei', token='27800798B840478BE2817F0931DC5C65', secret='MIMIRt0uVwRFGuWkwrLJhUtyYDNBzS4/Yg0bTldX')

function(input, output, session) {
  output$contents <- renderTable({
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    read.csv(inFile$datapath, header=FALSE)
  })
  
  # Recherche et chargement du fichier de données
  data <- eventReactive(input$go, {
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    read.csv(inFile$datapath, header = TRUE)
  })

  # table avec uniquement des variables quantitatives
  data_num <- eventReactive(input$go, {
    data() %>% select_if(is.numeric)
  })
  
  # table avec uniquement des colonnes qualitatives  
  data_cat <- eventReactive(input$go, {
    data() %>% select_if(negate(is.numeric))
  })
  
  # Données brutes
  # ----
  output$table <- renderDataTable(data(), options = list(pageLength = 10))
  

  observe({
    updateSelectInput(session, 'x1', choices = names(data_num()))
  })
  observe({
    updateSelectInput(session, 'y1', choices = names(data_num()))
  })
  
  observe({
    updateSelectInput(session, 'x2', choices = names(data_cat()))
  })
  observe({
    updateSelectInput(session, 'y2', choices = names(data_num()))
  })
  
  
  observe({
    updateSelectInput(session, 'x3', choices = names(data_cat()))
  })
  observe({
    updateSelectInput(session, 'y3', choices = names(data_cat()))
  })
  
  
  observe({
    updateSelectInput(session, 'x4', choices = names(data_num()))
  })
  observe({
    updateSelectInput(session, 'y4', choices = names(data_num()))
  })

  
  # Nuage de points
  output$nuagePoints <- renderPlot({
    x.var = input$x1; y.var = input$y1;
    plot(x = data()[, x.var], y = data()[, y.var], col = "blue",
         las = 2, cex.axis = 0.7,
         main = paste(y.var, "en fonction de", x.var),
         xlab = x.var, ylab = y.var, cex.lab = 1.2
    )
    options(scipen=0)
    
  })
  
  # Boîtes parallèles
  output$boxplotGgplot <- renderPlot({
    x.var = input$x2; y.var = input$y2;
    ggplot(data(), aes_string(x = isolate(x.var), y = y.var)) + geom_boxplot()

  })
  
  # Diagramme en barres
  # Bidimensionnel
  output$barplotBi <- renderPlot({
    x.var = input$x3; y.var = input$y3;
    ggplot(data(), aes_string(x = isolate(x.var), fill = y.var)) + geom_bar()
  })
  
  
  # k-means
  # Combine the selected variables into a new data frame
  selectedData <- reactive({
    data()[, c(input$x4, input$y4)]
  })
  
  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })
  
  output$plot1 <- renderPlot({
    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
              "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
    
    par(mar = c(5.1, 4.1, 0, 1))
    plot(selectedData(),
         col = clusters()$cluster,
         pch = 20, cex = 3)
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  })
  
  
  # Calcul et affichage du coefficient de corélation linéaire entre 2 var quantitative
  # ---
  output$correlation <- renderText({
    x.var = input$x1; y.var = input$y1;
    coeff.tmp <- cov(data()[, x.var], data()[, y.var])/(sqrt(var(data()[, x.var])*var(data()[, y.var])))
    paste("Coefficient de corrélation linéaire =", round(coeff.tmp,digits = 2))
  })
  
  
  # Calcul et affichage le rapport de corrélation entre une var qualif et une var quant
  # ---
  output$correlation2 <- renderText({
    # Calcul de la variance expliquée
    x.var = input$x2; y.var = input$y2;
    tmp.mean.y = mean(as.vector(as.matrix(data()[, y.var])))
    tmp.mean.yr = tapply(data()[, y.var], data()[, x.var], mean)
    tmp.nl = nrow(data())
    sE2 = (1/sum(tmp.nl))*sum(tmp.nl*(tmp.mean.yr-tmp.mean.y)^2)

    # Calcul de la variance résiduelle
    tmp.var.yr = tapply(data()[, y.var], data()[, x.var], var)
    sR2 = (1/sum(tmp.nl))*sum(tmp.nl*tmp.var.yr)

    # Calcul du rapport de corrélation
    rCor = sqrt(sE2/(sE2+sR2))
    paste("Rapport de corrélation =", round(rCor, digits = 2))
  })
  
  
  # Force de la liaison entre 2 variables qualitatives
  # ----
  output$force <- renderTable({
    force.df <- as.data.frame(matrix(NA, nrow = 3, ncol = 1))
    rownames(force.df) = c("X2", "Phi2", "Cramer")
    
    # La table de contingence des profils observés
    x.var = input$x3; y.var = input$y3;
    tab = table(data()[, x.var], data()[, y.var])
    # La table de contigence s'il y a indépendence
    tab.indep = tab
    n = sum(tab)
    tab.rowSum = apply(tab, 2, sum)
    tab.colSum = apply(tab, 1, sum)
    
    for(i in c(1:length(tab.colSum))){
      for(j in c(1:length(tab.rowSum))){
        tab.indep[i,j] = tab.colSum[i]*tab.rowSum[j]/n
      }
    }
    
    # Calcul du X²
    force.df[1,1] = sum((tab-tab.indep)^2/tab.indep)
    # Calcul du Phi²
    force.df[2,1] = force.df[1,1]/n
    # Calcul du Cramer
    force.df[3,1] = sqrt(force.df[2,1]/(min(nrow(tab), ncol(tab))-1))
    
    force.df
    
  }, rownames=TRUE, colnames=FALSE)
  
}