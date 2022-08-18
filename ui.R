library(shiny)
library(rsconnect)
library(shinythemes)
library(shinydashboard)

rsconnect::setAccountInfo(name='alifei', token='27800798B840478BE2817F0931DC5C65', secret='MIMIRt0uVwRFGuWkwrLJhUtyYDNBzS4/Yg0bTldX')

dashboardPage(
  dashboardHeader(disable = TRUE),
  dashboardSidebar(
    fluidPage(
      tags$div(class="title", titlePanel("Joueurs NBA"))
    ),
    sidebarMenu(
      menuItem("Tableau de bord", tabName = "tableau_de_bord", icon = icon("dashboard")),
      menuItem("Analyse univariée", tabName = "analyse_univariee", icon = icon("poll")),
      menuItem("Analyse bivariée", tabName = "analyse_bivariee", icon = icon("shapes")),
      menuItem("Clustering", tabName = "clustering", icon = icon("divide")),
      menuItem("Sources", tabName = "sources", icon = icon("book-open"))
    )
  ),
  dashboardBody(
    tabItems(
      # ---------------------------------------
      # TABLEAU DE BORD
      tabItem(tabName = "tableau_de_bord",
              fluidPage(
                titlePanel("Tableau de bord")
              )
      ),
      
      # ---------------------------------------
      # ANALYSE UNIVARIEE
      tabItem(tabName = "analyse_univariee",
              fluidPage(
                titlePanel("Analyse univariée")
              )
      ),
      
      # ---------------------------------------
      # ANALYSE BIVARIEE
      tabItem(tabName = "analyse_bivariee",
              fluidPage(
                titlePanel("Analyse bivariée")
              ),
              tabsetPanel(
                          tabPanel("Deux variables quantitatives", 
                                   fluidRow(
                                     column(6, selectInput(inputId = "x1", label = "Sélectionner une variable quantitative x :", choices = NULL)),
                                     column(6, selectInput(inputId = "y1", label = "Sélectionner une variable quantitative y :", choices = NULL)),
                                   ),
                                   fluidRow(
                                     column(6, plotOutput("nuagePoints")),
                                     column(6, textOutput("correlation"))
                                   ),
            
                          ),
                          
                          tabPanel("Variable quantitative vs qualitative", 
                                   fluidRow(
                                     column(6, selectInput(inputId = "x2", label = "Sélectionner une variable qualitative x :", choices = NULL)),
                                     column(6, selectInput(inputId = "y2", label = "Sélectionner une variable quantitative y :", choices = NULL)),
                                   ),
                                   fluidRow(
                                     column(6, plotOutput("boxplotGgplot")),
                                     column(6, textOutput("correlation2"))
                                   ),
                          ),
                          
                          tabPanel("Deux variables qualitatives", 
                                   fluidRow(
                                     column(6, selectInput(inputId = "x3", label = "Sélectionner une variable qualitative x :", choices = NULL)),
                                     column(6, selectInput(inputId = "y3", label = "Sélectionner une variable qualitative y :", choices = NULL)),
                                   ),
                                   fluidRow(
                                     column(6, plotOutput("barplotBi")),
                                     column(6, tableOutput("force"))
                                   ),
            
                          )
              ),
      ),
      
      # ---------------------------------------
      # CLUSTERING
      tabItem(tabName = "clustering",
              fluidPage(
                titlePanel("Clustering")
              ),

              pageWithSidebar(
                headerPanel('k-means clustering'),
                sidebarPanel(
                  selectInput(inputId = "x4", label = "X Variable", choices = NULL),
                  selectInput(inputId = "y4", label = "Y Variable", choices = NULL),
                  numericInput('clusters', 'Cluster count', 3, min = 1, max = 9)
                ),
                mainPanel(
                  plotOutput('plot1')
                )
              )
      ),
      
      # ---------------------------------------
      # SOURCES
      tabItem(tabName = "sources",
              fluidPage(
                titlePanel("Sources")
              ),
              fluidRow(
                column(10, 
                       # Bouton de recherche du fichier à charger
                       fileInput(inputId = "file1", label = "Choisir un fichier CSV",
                                 accept = c("text/plain", ".csv")
                       ))
              ),
              fluidRow(
                column(2, 
                       # Buton de chargement 'en retard'
                       actionButton(inputId = "go", label = "Load"))
              ),
              fluidRow(
                dataTableOutput('table')
              )
      )
    ),
    
    # ----------------------------------------------------------------------------------------------------
    # Style
    tags$head(tags$style(HTML('

        /* main sidebar */
        .skin-blue .main-sidebar { background-color: #00162c; font-size: 18px;}

        /* active selected tab in the sidebarmenu */
        .skin-blue .main-sidebar .sidebar .sidebar-menu .active a { background-color: #00162c; color: #ffffff; }

        /* other links in the sidebarmenu */
        .skin-blue .main-sidebar .sidebar .sidebar-menu a{ color: #113a5c; }

        /* other links in the sidebarmenu when hovered */
        .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{ background-color: #00162c; color: gray; }
        
        /* body */
        .content-wrapper, .right-side { background-color: #092749; color: white;}
        
        /* Espace entre les icones et le text */
        .sidebar-menu li .fa { margin-right: 8px;}
        
        /**/
        .sidebar-menu li:first-child {margin-top: 20px;}
        
        /* Titre sidebar */
        .title { margin-top: -50px; width:200px; text-align: left;}
                              
                              
                              '))),
    
    # ----------------------------------------------------------------------------------------------------
    # Script
    # Supprime l'espace du bas crée par la desactivation du header
    # https://stackoverflow.com/questions/39756255/shinydashboard-remove-extra-space-when-header-is-disabled
    
    tags$script('window.onload = function() {
      function fixBodyHeight() {
        var el = $(document.getElementsByClassName("content-wrapper")[0]);
        var h = el.height();
        el.css("min-height", h + 50 + "px !important");
      };
      window.addEventListener("resize", fixBodyHeight);
      fixBodyHeight();
    };')
  )
)
