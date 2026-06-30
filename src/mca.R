library(tidyverse)
library(FactoMineR) 
library(tidyverse)


wordnet_semfields <- read.csv2("C:/Users/fpisc/Downloads/VerbiSupporto/VSupp frequencies/analisi_dati/wordnet_semfields.csv", fileEncoding = "UTF-8") %>%
  mutate(nome = iconv(nome, from = "latin1", to = "UTF-8"))  


predicati_denominali <- read.csv2("C:/Users/fpisc/Downloads/VerbiSupporto/VSupp frequencies/analisi_dati/predicati_denominali_confreq.csv", fileEncoding = "UTF-8") %>%
  mutate(nome = iconv(nome, from = "latin1", to = "UTF-8")) 


df <- wordnet_semfields %>%
  left_join(predicati_denominali, by = "nome")


df <- df %>%
  mutate(
    vsupp_bin = ifelse(grepl("yes", vsupp_bin), "yes", "no"),
    vsin_bin = ifelse(grepl("yes", vsin_bin), "yes", "no")
  )

df <- df %>%
  mutate(group = case_when(
    vsupp_bin == "yes" & vsin_bin == "no" ~ "Analitico",
    vsupp_bin == "no" & vsin_bin == "yes" ~ "Sintetico",
    vsupp_bin == "yes" & vsin_bin == "yes" ~ "Analitico&Sintetico",
    vsupp_bin == "no" & vsin_bin == "no" ~ "No"
  ))

df <- df %>%
  select(1:10, 20)



df_mca <- df %>%
  select(group, nome, starts_with("SemField")) %>%  # Seleziona 'group', 'nome', e le colonne 'SemField'
  pivot_longer(cols = starts_with("SemField"), names_to = "sem_field", values_to = "category") %>%
  filter(!is.na(category) & category != "") %>%  # Rimuove NA e categorie vuote
  distinct(group, nome, category) %>%  # Ogni combinazione unica di 'group', 'nome' e 'category'
  mutate(presence = 1) %>%
  pivot_wider(names_from = category, values_from = presence, values_fill = list(presence = 0))


df_mca$group <- df$group[match(df_mca$nome, df$nome)]



df_mca_filtered <- df_mca %>%
  filter(group != "No")


df_mca_filtered <- df_mca_filtered %>%
  mutate(across(-nome, as.factor))

df_mca_filtered$nome <- as.factor(df_mca_filtered$nome)
df_mca_filtered$group <- as.factor(df_mca_filtered$group)



res_mca <- MCA(df_mca_filtered %>% select(-c(group,nome)))


fviz_mca_ind(res_mca, 
             geom = c("point"),
             col.ind = df_mca_filtered$group,  # Colora i punti in base al gruppo
             palette = c("red",  "purple", "grey", "blue"),  # Definisci i colori
             addEllipses = FALSE,  # Aggiungi ellissi per i gruppi
             ellipse.type = "t",
             label = df_mca_filtered$nome,  # Sostituisci le etichette con 'nome'
             legend.title = "Group",  # Titolo della legenda
             title = "MCA - Individui e Variabili con Nomi",  # Titolo del grafico
             axes = c(1, 2))  # Titolo del grafico



coords_1 <- res_mca$var$coord[grep("_1$", rownames(res_mca$var$coord)), ]


contrib_1 <- res_mca$var$contrib[grep("_1$", rownames(res_mca$var$contrib)), ]

# Associations Dim1
top_pos_dim1 <- sort(coords_1[,1], decreasing = TRUE)[1:10]
top_neg_dim1 <- sort(coords_1[,1], decreasing = FALSE)[1:10]

clean_names <- function(x) gsub("_1$", "", x)
names(top_pos_dim1) <- clean_names(names(top_pos_dim1))
names(top_neg_dim1) <- clean_names(names(top_neg_dim1))

top_pos_dim1
top_neg_dim1


coords_1 <- res_mca$var$coord[grep("_1$", rownames(res_mca$var$coord)), ]

# Contribution Dim1
contrib_1 <- res_mca$var$contrib[grep("_1$", rownames(res_mca$var$contrib)), ]

# Associations Dim2
top_pos_dim2 <- sort(coords_1[,2], decreasing = TRUE)[1:10]
top_neg_dim2 <- sort(coords_1[,2], decreasing = FALSE)[1:10]

clean_names <- function(x) gsub("_1$", "", x)
names(top_pos_dim2) <- clean_names(names(top_pos_dim2))
names(top_neg_dim2) <- clean_names(names(top_neg_dim2))

top_pos_dim2
top_neg_dim2


# Clustering
res_hcpc <- HCPC(res_mca, nb.clust = -1, graph = TRUE)
res_hcpc$data.clust$nome <- df_mca_filtered$nome

df_cross <- df_mca_filtered %>%
  select(nome, group) %>%
  left_join(res_hcpc$data.clust %>% select(nome, clust), by = "nome")


table_cluster_group <- table(df_cross$clust, df_cross$group)
print(table_cluster_group)

round(prop.table(table_cluster_group, margin = 2) * 100, 1)

df_mca_filtered <- df_mca_filtered %>%
       left_join(df_cross, by = "nome")

semfield_cols <- setdiff(names(df_mca), c("nome", "group", "group.y", "clust"))

df_mca_numeric <- df_mca_filtered %>%
  mutate(across(all_of(semfield_cols), ~as.numeric(as.character(.))))

# Semfields by cluster
top_semfields <- df_mca_numeric %>%
  group_by(clust) %>%
  summarise(across(all_of(semfield_cols), sum, na.rm = TRUE)) %>%
  pivot_longer(-clust, names_to = "SemField", values_to = "count") %>%
  group_by(clust) %>%
  arrange(desc(count), .by_group = TRUE) %>%
  slice_head(n = 5)  # cambia `n = 5` per avere più/meno top etichette


print(top_semfields, n = 30)

fviz_cluster(res_hcpc, 
             labelsize = 0,
             geom = "point", 
             show.clust.cent = TRUE,
             ellipse.type = "convex",
             ggtheme = theme_minimal(),
             palette = "jco")



corad <- df_mca_filtered$nome[df_mca_filtered$group.x == "Analitico&Sintetico"]
synonyms <- c('arma','azione','bacio','barba','base','battaglia','bisogno','bocca','bottiglia','calcio','cammino','campo','capitano','capo','carattere','carcere','catena','causa','cena','centro','colore','colpa','colpo','commercio','complimento','confessione','consiglio','contatto','coraggio','corno','corte','croce','cura','custode','danno','differenza','direzione','distanza','dolore','dubbio','esame','esempio','esilio','fastidio','favore','festa','fianco','fiato','film','filo','fine','fiore','fondo','forma','forza','fotografia','fronte','frutto','fuga','fumo','funzione','fuoco','gara','ginocchio','gioco','gioia','giro','gloria','grazia','gruppo','guaio','guerra','idea','impressione','inizio','interesse','lavoro','letto','limite','linea','lista','luogo','mare','marito','moglie','movimento','musica','noia','nome','numero','occasione','odio','odore','ombra','onore','ordine','ospite','pace','palla','parte','paura','pena','pensione','peso','pezzo','piano','poeta','polvere','posizione','pranzo','pratica','premio','prezzo','prigione','processo','profumo','progetto','programma','questione','regola','relazione','rischio','rispetto','rivoluzione','rumore','scena','segno','signore','silenzio','simpatia','sostanza','spalla','sposa','tasca','tassa','tempo','termine','titolo','uso','valore','via','viaggio','voto','patto','sogno')

a <- setdiff(corad, synonyms)

a <- synonyms

b <- as.data.frame(a)

b$nome <- a

df_mca_check <- b %>%
  left_join(df_mca, by = "nome")

semfield_cols <- setdiff(names(df_mca_check), c("nome", "group", "group.y", "clust", "a"))

df_mca_numeric <- df_mca_check %>%
  mutate(across(all_of(semfield_cols), ~as.numeric(as.character(.))))

top_semfields <- df_mca_numeric %>%
  summarise(across(all_of(semfield_cols), sum, na.rm = TRUE)) %>%  # Somma delle colonne semfield_cols
  pivot_longer(cols = all_of(semfield_cols), names_to = "SemField", values_to = "count") %>%  # Trasformazione in formato lungo
  arrange(desc(count)) %>%  # Ordinamento per conteggio decrescente
  slice_head(n = 10)

top_semfields
