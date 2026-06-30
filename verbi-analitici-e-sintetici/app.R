#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# =========================
# LIBRERIE
# =========================
library(dplyr)
library(shiny)
library(plotly)
library(RColorBrewer)
library(purrr)
library(crosstalk)

# =========================
# CARICAMENTO DATI
# =========================
clusters <- read.csv("clusters.csv", sep=";")
verbi_sint <- read.csv("verbi_sintetici.csv", sep=";")
pred_anal <- read.csv("pred_analitici_expanded.csv", sep=";")
sinonimi <- read.csv("sinonimia_expanded.csv", sep=";")
predicati_w2v <- read.csv("predicati_umap_w2v.csv", sep=";")
predicati_fasttext <- read.csv("predicati_umap_ft.csv", sep=";")

pred_anal$verbo <- pred_anal$Var1

# =========================
# PREPARAZIONE DATI
# =========================
# Selezione colonne coherent
verbi_sint <- verbi_sint %>% select(verbo, nome)
pred_anal <- pred_anal %>% select(verbo, nome)

# Dizionario verbo → nome
lexicon <- bind_rows(verbi_sint, pred_anal) %>% distinct(verbo, .keep_all = TRUE)

# Unione con UMAP
predicati_w2v <- predicati_w2v %>% left_join(lexicon, by = "verbo")
predicati_fasttext <- predicati_fasttext %>% left_join(lexicon, by = "verbo")

# Normalizza cluster
clusters$cluster <- as.character(clusters$cluster)
clusters$cluster[clusters$cluster=="1"] <- "Cluster 1 (perlopiù nomi astratti)"
clusters$cluster[clusters$cluster=="2"] <- "Cluster 2 (perlopiù nomi animati)"
clusters$cluster[clusters$cluster=="3"] <- "Cluster 3 (perlopiù nomi inanimati concreti)"

predicati_w2v$nome <- trimws(predicati_w2v$nome)
predicati_fasttext$nome <- trimws(predicati_fasttext$nome)
clusters$nome <- trimws(clusters$nome)

predicati_w2v <- predicati_w2v %>% left_join(clusters %>% select(nome, cluster), by = "nome")
if("cluster.y" %in% colnames(predicati_w2v)) predicati_w2v$cluster <- predicati_w2v$cluster.y
predicati_w2v$cluster[is.na(predicati_w2v$cluster)] <- "unknown"

# Rimuove duplicati
predicati_w2v <- predicati_w2v %>% distinct(verbo, .keep_all = TRUE)

predicati_fasttext <- predicati_fasttext %>% left_join(clusters %>% select(nome, cluster), by = "nome")
if("cluster.y" %in% colnames(predicati_fasttext)) predicati_fasttext$cluster <- predicati_fasttext$cluster.y
predicati_fasttext$cluster[is.na(predicati_fasttext$cluster)] <- "unknown"

# Rimuove duplicati
predicati_fasttext <- predicati_fasttext %>% distinct(verbo, .keep_all = TRUE)

# =========================
# CREA LISTA SINONIMI SOLO SE "sinonimia" == "y"
# =========================
sinonimi <- sinonimi %>% filter(sinonimia == "y")


# Lista vuota
syn_list <- list()

# Funzione per aggiungere un sinonimo
add_syn <- function(v1, v2, lst){
  if (is.null(lst[[v1]])) lst[[v1]] <- character(0)
  if (is.null(lst[[v2]])) lst[[v2]] <- character(0)
  lst[[v1]] <- unique(c(lst[[v1]], v2))
  lst[[v2]] <- unique(c(lst[[v2]], v1))
  lst
}

# Costruisci la lista
syn_list <- reduce(
  seq_len(nrow(sinonimi)),
  .init = syn_list,
  .f = function(lst, i){
    add_syn(sinonimi$Var1[i], sinonimi$Var2[i], lst)
  }
)

# =========================
# UI
# =========================
ui <- fluidPage(
  titlePanel("Verbi sintetici e analitici: spazio semantico dei predicati denominali (proiezione UMAP)"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "embedding_model",
        "Modello embedding:",
        choices = c("Word2Vec" = "w2v", "FastText" = "fasttext"),
        selected = "w2v"
      ),
      
      selectInput(
        "color_mode",
        "Colora per:",
        choices = c(
          "Nessuno" = "none",
          "Tipo di predicato",
          "Classe semantica della base",
          "Coradicali sinonimi (analitico vs sintetico)",
          "Processo formativo"
        ),
        selected = "none"
      ),
      
      conditionalPanel(
        condition = "input.color_mode == 'Processo formativo'",
        selectInput(
          "sint_choice",
          "Predicati sintetici:",
          choices = c(
            "Nessuno" = "",
            "Processo" = "processo_formativo_process",
            "Schema"   = "processo_formativo_schema"
          ),
          selected = ""
        ),
        selectInput(
          "anal_choice",
          "Predicati analitici:",
          choices = c(
            "Nessuno" = "",
            "Schema" = "processo_formativo_pattern",
            "Schema parzialmente riempito" = "processo_formativo_pattern_semispec",
            "Verbo supporto" = "processo_formativo_vsupp"
          ),
          selected = ""
        )
      ),
      
      selectInput(
        "display_mode",
        "Modalità visualizzazione:",
        choices = c(
          "Solo testo" = "text",
          "Solo marker" = "markers",
          "Marker + testo" = "markers+text"
        ),
        selected = "markers+text"
      ),
      
      
      tags$hr(),
      
      tags$div(
        style = "font-size: 13px; color: #555; line-height: 1.4;",
        tags$b("Descrizione:"), br(),
        "La figura rappresenta una proiezione bidimensionale UMAP degli embedding lessicali dei predicati sintetici e analitici formati a partire da nomi,
      utilizzata per visualizzare le relazioni di similarità semantica nello spazio vettoriale.", br(), br(),
        
        "Sono disponibili due modelli di embedding: Word2Vec
      e FastText; quest'ultimo integra informazioni sub-lessicali attraverso n-grammi di caratteri", br(), br(),
        
        "La colorazione dei punti consente di esplorare diverse dimensioni linguistiche e morfosintattiche,
      tra cui il tipo di predicato, la classe semantica della base, il processo formativo e le relazioni tra coradicali sinonimi
      (forme analitiche vs sintetiche).", br(),
        "(N.B., Nella modalità 'Coradicali sinonimi', passando il mouse su un punto vengono evidenziati i coradicali annotati come sinonimi).",
        
        br(), br(),
        
        tags$b("Description (Eng):"), br(), br(),
        
        "The figure shows a two-dimensional UMAP projection of lexical embeddings of Italian synthetic and analytic denominal predicates,
  used to visualize semantic similarity relationships in the vector space.", br(), br(),
        
        "Two embedding models are available: Word2Vec and FastText; the latter incorporates sub-lexical information through character n-grams.", br(), br(),
        
        "Point coloring allows the exploration of different linguistic and morphosyntactic dimensions,
  including predicate type, semantic class of the base, derivational process, and relationships between cognate synonyms
  (analytic vs synthetic forms).
  (Note: in 'Coradicali sinonimi' (Cognate synonyms) mode, hovering over a point highlights its annotated synonymous cognates.)"
      )
    ),
    
    mainPanel(
      plotlyOutput("plot", height = "850px")
    )
  )
)

server <- function(input, output, session) {
  
  output$plot <- renderPlotly({
    df <- if (input$embedding_model == "fasttext") predicati_fasttext else predicati_w2v
    
    # Flag sinonimi
    df$has_syn <- sapply(df$verbo, function(v) {
      syns <- syn_list[[v]]
      !is.null(syns) && length(syns) > 0
    })
    
    # Colore default grigio
    df$color_group <- "gray80"
    
    # =========================
    # Colorazione dinamica per le altre schede
    # =========================
    if(input$color_mode == "Tipo di predicato" & !all(is.na(df$tipo))){
      df$color_group[!is.na(df$tipo)] <- df$tipo[!is.na(df$tipo)]
    } else if(input$color_mode == "Classe semantica della base"){
      df$color_group[!is.na(df$cluster)] <- df$cluster[!is.na(df$cluster)]
    } else if(input$color_mode == "Processo formativo"){
      
      df$color_group <- "gray80"
      
      sint_active <- !is.null(input$sint_choice) && input$sint_choice != ""
      anal_active <- !is.null(input$anal_choice) && input$anal_choice != ""
      
      # sintetici
      if(sint_active && input$sint_choice %in% colnames(df)){
        sel <- df$tipo == "sintetico" & !is.na(df[[input$sint_choice]])
        df$color_group[sel] <- df[[input$sint_choice]][sel]
      }
      
      # analitici
      if(anal_active && input$anal_choice %in% colnames(df)){
        sel <- df$tipo == "analitico" & !is.na(df[[input$anal_choice]])
        df$color_group[sel] <- df[[input$anal_choice]][sel]
      }
      
      # Se solo uno è attivo → l'altro resta grigio (trasparenza visiva)
    }
    
    
    # Hovertext
    # Hovertext (versione migliorata)
    df$hovertext <- sapply(df$verbo, function(v){
      syns <- syn_list[[v]]
      syns_text <- if(!is.null(syns)) paste(syns, collapse=", ") else "nessuno"
      
      tipo <- df$tipo[df$verbo == v]
      
      label <- if(tipo == "analitico"){
        "Coradicali sinonimi (sintetici)"
      } else if(tipo == "sintetico"){
        "Coradicali sinonimi (analitici)"
      } else {
        "Coradicali sinonimi"
      }
      
      paste0("<b>", v, "</b><br>",
             "Tipo: ", tipo, "<br>",
             "Cluster: ", df$cluster[df$verbo==v], "<br>",
             label, ": ", syns_text)
    })
    
    
    # =========================
    # Palette colori
    # =========================
    lvl <- unique(df$color_group)
    other_lvl <- setdiff(lvl, "gray80")
    n_needed <- length(other_lvl)
    base_colors <- RColorBrewer::brewer.pal(min(8, n_needed), "Set2")
    if(n_needed > 8) base_colors <- colorRampPalette(base_colors)(n_needed)
    names(base_colors) <- other_lvl
    color_vec <- c("gray80" = "lightgray", base_colors)
    
    use_marker <- grepl("markers", input$display_mode)
    
    # =========================
    # Branch separato: sinonimi o normale
    # =========================
    if(input$color_mode == "Coradicali sinonimi (analitico vs sintetico)"){
      # Mantieni solo punti con sinonimi
      df <- df[df$has_syn, ]
      
      # Crea key per hover highlight dei sinonimi
      df$key <- df$verbo
      syn_map <- do.call(rbind, lapply(seq_len(nrow(df)), function(i){
        v <- df$verbo[i]
        syns <- syn_list[[v]]
        syns_in_df <- syns[syns %in% df$verbo]
        if(length(syns_in_df) > 0){
          tmp <- df[df$verbo %in% syns_in_df, ]
          tmp$key <- v
          tmp
        } else NULL
      }))
      df <- rbind(df, syn_map)
      
      # Plot con highlight dei sinonimi
      p <- highlight_key(df, ~key) %>%
        plot_ly(
          x = ~x,
          y = ~y,
          type = 'scatter',
          mode = input$display_mode,
          color = ~color_group,
          colors = color_vec,
          text = ~verbo,
          hovertext = ~hovertext,
          hoverinfo = 'text'
        ) %>%
        highlight(
          on = "plotly_hover",
          off = "plotly_doubleclick",
          dynamic = TRUE,
          persistent = FALSE,
          opacityDim = 0.2,
          color = "red",
          showlegend = FALSE
        )
    } else {
      # Modalità normale, nessun highlight
      df$key <- NA
      p <- plot_ly(
        df,
        x = ~x,
        y = ~y,
        type = 'scatter',
        mode = input$display_mode,
        color = ~color_group,
        colors = color_vec,
        text = ~verbo,
        hovertext = ~hovertext,
        hoverinfo = 'text'
      )
    }
    
    if(use_marker) p <- p %>% layout(marker = list(size = 10, opacity = 0.8))
    
    # Layout finale
    p %>% layout(
      xaxis = list(showgrid = FALSE, title = "Dimensione UMAP 1", zeroline = FALSE, showticklabels = FALSE),
      yaxis = list(showgrid = FALSE, title = "Dimensione UMAP 2", zeroline = FALSE, showticklabels = FALSE),
      legend = list(title = list(text = input$color_mode))
    )
    
  })
  
}






# =========================
# LANCIO APP
# =========================
shinyApp(ui, server)