# VerbiSinteticiAnalitici
Dati e codici utilizzati nell'articolo _Strategie di verbalizzazione a confronto: un’analisi corpus-based sulla sostituibilità tra verbi sintetici e analitici nell’italiano contemporaneo_

Di seguito è illustrato il contenuto dei file e dei codici.
Al link [https://fla-pi.shinyapps.io/verbi-analitici-e-sintetici/](https://fla-pi.shinyapps.io/verbi-analitici-e-sintetici/) è possibile visualizzare interattivamente gli embeddings ottenuti con word2vec (vd. 4) dei predicati analitici e sintetici analizzati.

## 1. Dataset
1. [verbi_sintetici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici.csv): contiene la lista di verbi sintetici raccolta in Iacobini & De Rosa (2024).
2. [nomi.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/nomi.csv): contiene la lista dei nomi del VdB, utilizzate per raccogliere i verbi sintetici, e successivamente i pattern analitici.
3. [verbi_sintetici_freqs.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici_freqs.csv): contiene la frequenza in Paisà dei verbi raccolti in [verbi_sintetici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici.csv).
4. [verbi_analitici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_analitici.csv): contiene la lista dei pattern annotati come verbi analitici, estratta a partire da Paisà.
5. [merge_datasets.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/merge_datasets.py): unisce i due dataset [verbi_analitici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_analitici.csv) e [verbi_sintetici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici.csv). Di quest'ultimo seleziona solo i verbi attestati in Paisà (cf.[verbi_sintetici_freqs.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici_freqs.csv)).
6. [predicati_denominali.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/predicati_denominali.csv): dataset, creato tramite [merge_datasets.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/merge_datasets.py), che contiene tutti i predicati (sintetici e analitici).


## Entropia

7. [entropy.R](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/entropy.R): calcolo dell'entropia condizionata.


## Selezione delle basi nominali

8. [matching_wn.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/matching_wn.py): script per l'estrazione dei synset e dei lexnames (o SemFields) da Open Multilingual WordNet per ogni nome.
9. [wordnet_semfields.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/wordnet_semfields.csv): dataset con i nomi del VdB associati ai SemFields.
10. [mca.R](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/mca.R): script che applica la Multiple Correspondence Analysis ai nomi annotati per SemField, e successivamente applica il clustering gerarchico con HCPC.
11. [clusters.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/clusters.csv): dataset dei nomio annotati per cluster di appartenenza.


## Similarità semantica e sostituibilità 

12. [mwe_uniform.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/mwe_uniform.py): script per uniformare i pattern in [verbi_analitici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_analitici.csv), unendo le varianti formali.
13. [pred_analitici_expanded.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/pred_analitici_expanded.csv): versione di [verbi_analitici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_analitici.csv), creata con [mwe_uniform.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/mwe_uniform.py), contenente il pattern uniformato accanto ad ogni entrata.
14. [sinonimia.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/sinonimia.csv): coppie di predicati coradicali (analitico - sintetico) annotati con giudizi umani di sinonimia ("y"/" ").
15. [train_w2v.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/train_w2v.py): script per allenare il modello word2vec sul corpus Paisà[^1]. 
16. [compare.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/compare.py):
17. [sinonimia_with_similarity.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/sinonimia_with_similarity.csv): coppie di coradicali, annotate per sinonimia e per similarità coseno.



[^1]: Per motivi di dimensioni, corpus e modello non sono inclusi nella repository. Il file del corpus corrisponde alla versione CoNLL scaricabile a questo [link](https://clarin.eurac.edu/repository/xmlui/handle/20.500.12124/3).
