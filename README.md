# VerbiSinteticiAnalitici
Dati e codici utilizzati nell'articolo _Strategie di verbalizzazione a confronto: un’analisi corpus-based sulla sostituibilità tra verbi sintetici e analitici nell’italiano contemporaneo_

Di seguito è illustrato il contenuto dei file e dei codici.

## Dataset

1. [verbi_sintetici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici.csv): contiene la lista di verbi sintetici raccolta in Iacobini & De Rosa (2024).
2. [verbi_sintetici_freqs.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici_freqs.csv): contiene la frequenza in Paisà dei verbi raccolti in [verbi_sintetici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici.csv).
3. [verbi_analitici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_analitici.csv): contiene la lista dei pattern annotati come verbi analitici, estratta a partire da Paisà.
4. [merge_datasets.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/merge_datasets.py): unisce i due dataset [verbi_analitici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_analitici.csv) e [verbi_sintetici.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici.csv). Di quest'ultimo seleziona solo i verbi attestati in Paisà (cf.[verbi_sintetici_freqs.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/verbi_sintetici_freqs.csv)).
5. [predicati_denominali.csv](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/data/predicati_denominali.csv): dataset, creato tramite [merge_datasets.py](https://github.com/fla-pi/VerbiSinteticiAnalitici/blob/main/src/merge_datasets.py), che contiene tutti i predicati (sintetici e analitici).

## Entropia


## Selezione delle basi nominali



## Similarità semantica e sostituibilità 

https://fla-pi.shinyapps.io/verbi-analitici-e-sintetici/
