import csv
import nltk
#nltk.download('wordnet')
#nltk.download('omw-1.4')
from nltk.corpus import wordnet as wn
import pandas as pd

#set the relevant OMW topic (the tag in SEMFEAT's OntoClass) and the pos
wn_pos = wn.NOUN


df= pd.read_csv('C:/Users/fpisc/Downloads/VerbiSupporto/VSupp frequencies/analisi_dati/predicati_denominali_confreq.csv', sep=';',  encoding ="utf-8")


lemmalist = df['nome'].tolist()

        

#create a dictionary where keys are verbs, and values are lists of possible senses (synsets) of the pivot lemma
id_to_syn = dict()

for i in range(len(lemmalist)):
    if len(list(wn.synsets(str(lemmalist[i]), lang="ita", pos=wn_pos))) > 0:
        synsets = list(wn.synsets(str(lemmalist[i]), lang="ita", pos=wn_pos))
        id_to_syn[lemmalist[i]] = synsets
        
    else:
        id_to_syn[lemmalist[i]] = list()

#create a dictionary where keys are verbs, and values are lists of OMW topics for each possible sense of the pivot lemma
id_to_lex = dict()

for j in id_to_syn.keys():
    syns = id_to_syn[j]
    lex = []
    if len(syns)> 0:
        for synset in syns:
            lexname = synset.lexname()
            lex.append(lexname)
    else:
        lex.append('')
    id_to_lex[j] = lex

for k in id_to_lex.keys():
    id_to_lex[k] = set(id_to_lex[k])

df2 = pd.DataFrame.from_dict(id_to_lex, orient='index')    




df2.to_csv('wordnet_semfields.csv', sep = ";", encoding = "utf-8")
    

