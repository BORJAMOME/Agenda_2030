# Análisis de la Agenda 2030 con R

![Screenshot 2024-05-21 at 11 57 47](https://github.com/BORJAMOME/Agenda_2030/assets/19588053/f186aba9-5c4c-4a72-9bbf-68bb8443db49)

## Análisis de Texto en R

Este proyecto realiza un análisis de texto utilizando varias librerías de R para la lectura, tokenización, visualización y análisis de sentimientos.

## Requisitos

Asegúrate de tener instaladas las siguientes librerías antes de ejecutar el código:

- `readr`: Se utiliza para leer archivos de texto, en este caso, para cargar el contenido del archivo calendar.rtf.
- `tokenizers`: Permite dividir el texto en unidades más pequeñas, como palabras, oraciones, bigramas y trigramas, facilitando el análisis.
- `tidyverse`: Un conjunto de paquetes que proporcionan herramientas para la manipulación y visualización de datos. Aquí se usa principalmente para transformar y filtrar datos.
- `stopwords`: Proporciona listas de palabras vacías (stopwords) en diferentes idiomas, que se eliminan del análisis para centrarse en las palabras más significativas.
- `ggplot2`: Utilizado para crear gráficos de alta calidad y personalizables, como gráficos de barras y grafos.
- `wordcloud2`: Genera nubes de palabras que visualizan la frecuencia de las palabras de forma atractiva.
- `tidytext`: Facilita el procesamiento y análisis de texto de manera ordenada y estructurada, integrando la manipulación de texto con las herramientas de tidyverse.
- `textdata`: Proporciona diccionarios de sentimientos y emociones, como el NRC y Bing, que se utilizan para el análisis de sentimientos.
- `syuzhet`: Utilizado para extraer y analizar emociones y sentimientos en el texto, proporcionando una visión más profunda del contenido emocional.
- `tm`: Ofrece herramientas para la minería de texto, incluyendo la creación de un corpus y la matriz término-documento.
- `textTinyR`: Proporciona funciones eficientes para la tokenización y análisis de n-gramas, especialmente útil para grandes conjuntos de datos.
- `igraph`: Permite la creación y visualización de grafos, que se utilizan para mostrar las conexiones entre palabras en bigramas y trigramas.
- `ggraph`: Extiende ggplot2 para la visualización de grafos, facilitando la creación de gráficos de red visualmente atractivos.
- `patchwork`: Permite combinar múltiples gráficos en una sola visualización de manera ordenada, útil para mostrar diferentes análisis juntos.

Puedes instalarlas con:

```r
install.packages(c("readr", "tokenizers", "tidyverse", "stopwords", "ggplot2", "wordcloud2", "tidytext", "textdata", "syuzhet", "tm", "textTinyR", "igraph", "ggraph", "patchwork"))
```

# Descripción del Proyecto
## 1. Cargar y preparar los datos
Se carga el archivo de texto y se prepara para el análisis:

```r
library(readr)
libro <- read_lines(".../Desktop/calendar.rtf")
texto_completo <- paste(libro, collapse = " ")
```

## 2. Tokenización de palabras y análisis de frecuencias
Se tokeniza el texto en palabras y se cuenta su frecuencia:
```r
library("tokenizers")
palabras <- tokenize_words(texto_completo)
count_words(texto_completo)

library("tidyverse")
tabla <- table(palabras[[1]])
(tabla <- tibble(
  palabra = names(tabla),
  recuento = as.numeric(tabla)
) |> arrange(desc(recuento)))
```

## 3. Tokenización de oraciones
Se tokeniza el texto en oraciones y se analiza su longitud:

```r
oraciones <- tokenize_sentences(texto_completo)
count_sentences(texto_completo)

oraciones[[1]][1:3] # primeras 3 oraciones
oraciones[[1]][count_sentences(texto_completo)] # última oración

palabras_oracion <- tokenize_words(oraciones[[1]])
longitud_o <- sapply(palabras_oracion, length)
head(longitud_o)
```

## 4. Filtrado de stopwords
Se eliminan las palabras vacías (stopwords) del análisis:

```r
library("stopwords")
tabla_stopwords <- tibble(palabra = stopwords("en"))

tabla <- tabla |> anti_join(tabla_stopwords)
knitr::kable(tabla[1:20, ], caption = "Palabras más frecuentes (sin palabras vacías)")
```
## 5. Visualización de las palabras más frecuentes
Se crea un gráfico de barras horizontales con las palabras más frecuentes:

```r
library(ggplot2)

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
```

![Screenshot 2024-05-21 at 11 37 51](https://github.com/BORJAMOME/Agenda_2030/assets/19588053/54cb529b-4ef2-4b03-8373-93e9741ae459)


## 6. Wordcloud
Se crea una nube de palabras con una paleta de colores pastel:

```r
library(wordcloud2)

background_color <- "#f6f6f6"
colores_pastel <- c("#FFD700", "#FF69B4", "#ADD8E6", "#98FB98", "#FF6347")

wordcloud2(tabla, color = colores_pastel, backgroundColor = background_color)
```
![Screenshot 2024-05-21 at 11 39 30](https://github.com/BORJAMOME/Agenda_2030/assets/19588053/d74c3388-79e1-40dc-8e40-ae263af2ec85)


## 7. Análisis de sentimientos y detección de emociones
Se analizan los sentimientos y emociones del texto:

```r
library("tidytext")
library("textdata")
library("kableExtra")

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
```

## Gráfico de barras con la frecuencia de emociones del léxico NRC.
![Screenshot 2024-05-21 at 11 42 38](https://github.com/BORJAMOME/Agenda_2030/assets/19588053/e0ef667a-58b8-404e-b507-7bc2731a556e)

## Frecuencia de emociones en la Declaración utilizando NRC.
![Screenshot 2024-05-21 at 11 43 09](https://github.com/BORJAMOME/Agenda_2030/assets/19588053/fc741cf4-1f6c-416a-8019-9a3133d56035)

## Wordcloud de la Declaración para tres emociones seleccionadas del NRC.
![Screenshot 2024-05-21 at 11 43 38](https://github.com/BORJAMOME/Agenda_2030/assets/19588053/1699e5e0-6729-43e1-92d6-5502cf3dbe34)

## 9. Visualización de bigramas con grafos
Se crean grafos para visualizar las conexiones entre bigramas:

``` r
library("igraph")
library("ggraph")
library("patchwork")

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
```
![Screenshot 2024-05-21 at 11 44 53](https://github.com/BORJAMOME/Agenda_2030/assets/19588053/b93a3544-0c42-4387-8c7f-dec5c6811893)

## Conclusión
En este proyecto, hemos llevado a cabo un análisis exhaustivo de un texto en R, utilizando una variedad de librerías para la tokenización, filtrado, visualización y análisis de sentimientos. Los principales puntos de interés incluyen:

**- Tokenización y Frecuencia:** Identificamos las palabras más frecuentes y analizamos la longitud de las oraciones.

**- Stopwords:** Eliminamos palabras vacías para obtener una representación más precisa del contenido significativo.

**- Visualización:** Utilizamos gráficos de barras y nubes de palabras para visualizar las palabras más frecuentes.

**- Análisis de Sentimientos:** Detectamos y visualizamos los sentimientos y emociones presentes en el texto.

**- N-gramas:** Exploramos las conexiones entre palabras mediante la tokenización en bigramas y trigramas y visualizamos estas conexiones mediante grafos.

Este análisis proporciona una comprensión más profunda del texto y destaca cómo R puede ser una herramienta poderosa para el análisis de texto. Las visualizaciones y el análisis de sentimientos, en particular, ofrecen valiosos insights sobre el contenido y la estructura emocional del texto.

El uso de librerías como tidyverse, ggplot2, wordcloud2, y igraph facilita la manipulación y visualización de datos, permitiendo una exploración más rica y detallada del texto.

¡Gracias por revisar este proyecto! Espero que encuentres útil y aplicable este enfoque para tus propios análisis de texto.













