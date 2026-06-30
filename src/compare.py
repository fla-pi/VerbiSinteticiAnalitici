import pandas as pd
from gensim.models import Word2Vec
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
from gensim.models import FastText

from gensim.models.callbacks import CallbackAny2Vec

class EpochLogger(CallbackAny2Vec):
    def __init__(self):
        self.epoch = 0

    def on_epoch_begin(self, model):
        print(f"Epoch {self.epoch} start")

    def on_epoch_end(self, model):
        print(f"Epoch {self.epoch} end")
        self.epoch += 1

# carica modello
model = FastText.load("w2v_mwe.model")

# carica dataset
df = pd.read_csv("sinonimia_expanded.csv", sep=";")

def get_frequency(word):
    word = normalize_mwe(word)
    if word in model.wv.key_to_index:
        return model.wv.get_vecattr(word, "count")
    else:
        return 0


def normalize_mwe(s):
    return s.strip().replace(" ", "_")

def get_vector(word):
    if word in model.wv.key_to_index:
        return model.wv[word]
    else:
        return None

def compute_similarity(w1, w2):
    w1 = normalize_mwe(w1)
    w2 = normalize_mwe(w2)

    v1 = get_vector(w1)
    v2 = get_vector(w2)

    if v1 is None or v2 is None:
        return np.nan

    return float(cosine_similarity([v1], [v2])[0][0])

df["similarity_w2v"] = df.apply(
    lambda r: compute_similarity(r["Var1"], r["Var2"]),
    axis=1
)

df["freq_Var1"] = df["Var1"].apply(get_frequency)
df["freq_Var2"] = df["Var2"].apply(get_frequency)

print(df)
df.to_csv("sinonimia_with_similarity.csv", sep="\t", index=False)

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Crea variabile binaria più leggibile
df["sinonimia_bin"] = df["sinonimia"].apply(
    lambda x: "Sinonimi" if x == "y" else "Non sinonimi"
)

plt.figure(figsize=(5, 4))

sns.boxplot(
    data=df,
    x="sinonimia_bin",
    y="similarity_w2v",
    color="white",
    linewidth=1
)

sns.stripplot(
    data=df,
    x="sinonimia_bin",
    y="similarity_w2v",
    color="black",
    alpha=0.3,
    size=3,
    jitter=True
)

plt.ylabel("Cosine similarity (Word2Vec)")
plt.xlabel("")
sns.despine()
plt.tight_layout()
plt.show()

from scipy.stats import mannwhitneyu

syn = df[df["sinonimia"] == "y"]["similarity_w2v"]
nonsyn = df[df["sinonimia"] != "y"]["similarity_w2v"]

syn = syn.dropna().astype(float)
nonsyn = nonsyn.dropna().astype(float)


stat, p = mannwhitneyu(syn, nonsyn, alternative="greater")
print(f"U = {stat:.2f}, p = {p:.6f}")

import numpy as np

def cliffs_delta(x, y):
    nx = len(x)
    ny = len(y)
    greater = sum(1 for xi in x for yi in y if xi > yi)
    less = sum(1 for xi in x for yi in y if xi < yi)
    return (greater - less) / (nx * ny)

d = cliffs_delta(syn, nonsyn)
print("Cliff's delta:", d)

'''
import numpy as np

def permutation_test(x, y, n_perm=10000):
    observed = np.mean(x) - np.mean(y)
    combined = np.concatenate([x, y])
    count = 0

    for _ in range(n_perm):
        np.random.shuffle(combined)
        new_x = combined[:len(x)]
        new_y = combined[len(x):]
        if np.mean(new_x) - np.mean(new_y) >= observed:
            count += 1

    return count / n_perm

p_perm = permutation_test(syn.values, nonsyn.values)
print("Permutation p:", p_perm)

df2 = pd.read_csv("pred_analitici_expanded.csv", sep=";")  # usa "," se CSV normale
mwe_list = df2['Var1'].drop_duplicates().tolist()

def normalize_mwe(s):
    return s.strip().replace(" ", "_")

# Funzione per ottenere top N simili con similarità
def get_top_similar(word, topn=10):
    word_norm = normalize_mwe(word)
    if word_norm in model.wv:
        # restituisce lista di tuple (word, similarity)
        return model.wv.most_similar(word_norm, topn=topn)
    else:
        return []

# Creiamo una nuova colonna nel dataframe con i top 10 simili
df2['top10_similar'] = df2['Var1'].apply(get_top_similar)

# Se vuoi esploderla in colonne separate:
for i in range(10):
    df2[f'similar_{i+1}'] = df2['top10_similar'].apply(lambda x: x[i][0] if len(x) > i else None)
    df2[f'similarity_{i+1}'] = df2['top10_similar'].apply(lambda x: x[i][1] if len(x) > i else None)

# Ora df contiene per ogni mwe le 10 più simili con i valori di similarità
df2.to_csv("mwe_top10_similar.csv", sep=";", index=False)
'''

# Carica clusters
clusters = pd.read_csv("clusters.csv", sep=";")

# Merge diretto sulla colonna nome
df = df.merge(
    clusters[["nome", "cluster"]],
    on="nome",
    how="left"
)

from scipy.stats import kruskal

groups = [
    g["similarity_w2v"].dropna().astype(float).values
    for _, g in df.groupby("cluster")
]

stat, p = kruskal(*groups)
print(f"Kruskal-Wallis H={stat:.3f}, p={p:.6f}")


plt.figure(figsize=(6,4))

sns.boxplot(
    data=df,
    x="cluster",
    y="similarity_w2v",
    color="white",
    linewidth=1
)

sns.stripplot(
    data=df,
    x="cluster",
    y="similarity_w2v",
    color="black",
    alpha=0.3,
    size=3,
    jitter=True
)

plt.ylabel("Cosine similarity")
plt.xlabel("Cluster")
sns.despine()
plt.tight_layout()
plt.show()
