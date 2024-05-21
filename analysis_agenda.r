# Análisis de Texto en R

Este proyecto realiza un análisis de texto utilizando varias librerías de R para la lectura, tokenización, visualización y análisis de sentimientos.

## Cargamos las librerias

library(readr)
library(tokenizers)
library(tidyverse)
library(stopwords)
library(ggplot2)
library(wordcloud2)
library(tidytext)
library(textdata)
library(syuzhet)
library(tm)
library(textTinyR)
library(igraph)
library(ggraph)
library(patchwork)

# 1. Cargar y preparar los datos
libro <- read_lines(".../Desktop/calendar.rtf")
texto_completo <- paste(libro, collapse = " ")

# 2. Tokenización de palabras y análisis de frecuencias
palabras <- tokenize_words(texto_completo)
count_words(texto_completo)

tabla <- table(palabras[[1]])
(tabla <- tibble(
  palabra = names(tabla),
  recuento = as.numeric(tabla)
) |> arrange(desc(recuento)))

# 3. Tokenización de oraciones
oraciones <- tokenize_sentences(texto_completo)
count_sentences(texto_completo)

oraciones[[1]][1:3] # primeras 3 oraciones
oraciones[[1]][count_sentences(texto_completo)] # última oración

palabras_oracion <- tokenize_words(oraciones[[1]])
longitud_o <- sapply(palabras_oracion, length)
head(longitud_o)

# 4. Filtrado de stopwords
tabla_stopwords <- tibble(palabra = stopwords("en"))

tabla <- tabla |> anti_join(tabla_stopwords)
knitr::kable(tabla[1:20, ], caption = "Palabras más frecuentes (sin palabras vacías)")

# 5. Visualización de las palabras más frecuentes

# Establecer colores y tipografía
background_color <- "#f6f6f6"
color_barras <- "#aad59e"
lato <- "Lato"

# Filtrar las palabras más frecuentes excluyendo las stopwords
tabla_filtrada <- tabla %>% anti_join(tabla_stopwords)

# Crear un gráfico de barras horizontales
ggplot(tabla_filtrada[1:30, ], aes(x = recuento, y = reorder(palabra, recuento))) +
  geom_bar(stat = "identity", fill = color_barras) +
  geom_text(aes(label = recuento), hjust = -0.1, size = 3, family = lato) +
  labs(title = "Most Frequent Words (Excluding Stopwords)",
       x = "Count", y = "Word") +
  theme_minimal() +
  theme(axis.text.y = element_text(hjust = 0, family = lato), 
        panel.background = element_rect(fill = background_color),
        plot.background = element_rect(fill = background_color),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        text = element_text(family = lato))

# 6. Wordcloud

background_color <- "#f6f6f6"
colores_pastel <- c("#FFD700", "#FF69B4", "#ADD8E6", "#98FB98", "#FF6347")

wordcloud2(tabla, color = colores_pastel, backgroundColor = background_color)

# 7. Análisis de sentimientos y detección de emociones

# Tokenizar el texto completo
tabla <- table(tokenize_words(texto_completo)[[1]])

# Crear tibble con recuento de palabras
tabla <- tibble(
  word = names(tabla),
  recuento = as.numeric(tabla)
)

# Filtrar stopwords y ordenar por recuento
tabla <- tabla |> anti_join(tibble(word = stopwords("en"))) |> arrange(desc(recuento))

# Filtrar palabras positivas según sentimientos "bing"
pos <- get_sentiments("bing") |> filter(sentiment == "positive")
pos_EN <- tabla |> semi_join(pos)

# Mostrar tabla de palabras positivas
kable(pos_EN) %>%
  kable_styling(bootstrap_options = c("striped", "hover"))

# Obtener sentimientos "nrc" y visualizar con ggplot
emo <- get_sentiments("nrc")
emo |> ggplot(aes(sentiment)) +
  geom_bar(aes(fill = sentiment), show.legend = FALSE) +
  scale_fill_manual(values = c("#FFD1DC", "#D3D3D3", "#FFD700", "#98FB98", "#ADD8E6", "#FFA07A", "#E6E6FA", "#FFF8DC", "#FFDEAD", "#BDB2FF"))

# Realizar operaciones con la tabla de sentimientos
emo_tab <- tabla |> inner_join(emo)
head(emo_tab, n = 7)

# Crear el gráfico con la paleta de colores pastel
emo_tab |>
  count(sentiment) |>
  ggplot(aes(x = sentiment, y = n)) +
  geom_bar(stat = "identity", aes(fill = sentiment), show.legend = FALSE) +
  geom_text(aes(label = n), vjust = -0.25) +
  scale_fill_manual(values = c("#FFD1DC", "#D3D3D3", "#FFD700", "#98FB98", "#ADD8E6", "#FFA07A", "#E6E6FA", "#FFF8DC", "#FFDEAD", "#BDB2FF")) +
  labs(title = "Sentiment Count") +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = background_color),
    panel.background = element_rect(fill = background_color),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

# 8. Tokenización de n-gramas

bigramas <- tokenize_ngrams(texto_completo, n = 2, stopwords = tabla_stopwords$palabra)
head(bigramas[[1]], n = 3)

trigramas <- tokenize_ngrams(texto_completo, n = 3, stopwords = tabla_stopwords$palabra)
head(trigramas[[1]], n = 3)

texto2 <- tibble(texto = texto_completo)
bigramas <- texto2 |> unnest_tokens(bigram, texto, token = "ngrams", n = 2) |> count(bigram, sort = TRUE)
bigramas[1:5, ]

bigramas_limpios <- bigramas |> separate(bigram, c("word1", "word2"), sep = " ") |> filter(!word1 %in% tabla_stopwords$palabra) |> filter(!word2 %in% tabla_stopwords$palabra) |> unite(bigram, word1, word2, sep = " ")
bigramas_limpios[1:5, ]

bigramas_no <- bigramas |> separate(bigram, c("word1", "word2"), sep = " ") |> filter(word1 == "no") |> count(word1, word2, sort = TRUE)
bigramas_no

# 9. Visualización de bigramas con grafos

set.seed(1)
pastel_palette <- c("#f6c3ae", "#aad59e", "black")
background_color <- "#f6f6f6"

create_graph_plot <- function(graf, title, subtitle) {
  g <- ggraph(graf, layout = "fr") +
    geom_edge_link(arrow = arrow(length = unit(1, "mm")), color = pastel_palette[1]) +
    geom_node_point(size = 4, color = pastel_palette[2]) +
    geom_node_text(aes(label = name), color = pastel_palette[3], size = 4, family = "Lato") +
    theme_void() +
    theme(
      plot.background = element_rect(fill = background_color),
      plot.title = element_text(size = 14, family = "Lato"),
      plot.subtitle = element_text(size = 10, family = "Lato")
    ) +
    labs(title = title, subtitle = subtitle)
  return(g)
}

bigram_graph <- bigramas_limpios %>% 
  filter(n > 2) %>% 
  graph_from_data_frame()

bigram_plot <- create_graph_plot(bigram_graph, "Bigram Network", "Connections between bigrams")

no_graph <- bigramas_no %>% 
  filter(n > 2) %>% 
  graph_from_data_frame()

no_plot <- create_graph_plot(no_graph, 'Bigram Network of "no"', "Connections with 'no' as the first word")

bigram_plot + no_plot








