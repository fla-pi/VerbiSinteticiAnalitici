import pandas as pd
from gensim.models import Word2Vec
from gensim.models.callbacks import CallbackAny2Vec

# =========================
# CONFIGURAZIONE
# =========================

CSV_MWE_PATH = r"..\data\pred_analitici_expanded.csv"
CONLL_PATH = r"paisa.annotated.CoNLL.utf8.txt"
MODEL_OUT = "w2v_mwe.model"

CSV_SEPARATOR = ";"
LEMMA_COL = 2   
POS_COL = 3     
POS_TO_SKIP = {"F"}  

VECTOR_SIZE = 200
WINDOW = 5
MIN_COUNT = 20
EPOCHS = 5
WORKERS = 8



class EpochLogger(CallbackAny2Vec):
    def __init__(self):
        self.epoch = 0

    def on_epoch_begin(self, model):
        print(f"\n===== Epoch {self.epoch + 1} / {EPOCHS} =====")

    def on_epoch_end(self, model):
        print(f"===== End Epoch {self.epoch + 1} =====\n")
        self.epoch += 1


# =========================
# CARICA MWE
# =========================

df = pd.read_csv(CSV_MWE_PATH, sep=CSV_SEPARATOR)
mwe_list = df['Var1'].drop_duplicates().str.lower().tolist()
print(f"Totale MWE caricate: {len(mwe_list)}")


# Iterate on conll

class ConllCorpusIterator:
    def __init__(self, conll_path, mwe_list):
        self.conll_path = conll_path

        self.mwe_by_len = {}
        for mwe in mwe_list:
            toks = tuple(mwe.split())
            L = len(toks)
            self.mwe_by_len.setdefault(L, set()).add(toks)

        self.lengths = sorted(self.mwe_by_len.keys(), reverse=True)

    def __iter__(self):
        sentence = []
        sent_count = 0

        with open(self.conll_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()

                if not line:
                    if sentence:
                        sent_count += 1
                        if sent_count % 100000 == 0:
                            print(f"Processed {sent_count:,} sentences")
                        yield self.merge_mwe(sentence)
                        sentence = []
                    continue

                if line.startswith("#"):
                    continue

                cols = line.split("\t")

                if len(cols) > max(LEMMA_COL, POS_COL):
                    lemma = cols[LEMMA_COL].lower()
                    pos = cols[POS_COL]

                    if pos in POS_TO_SKIP:
                        continue

                    sentence.append(lemma)

            if sentence:
                sent_count += 1
                print(f"Processed {sent_count:,} sentences")
                yield self.merge_mwe(sentence)

    def merge_mwe(self, lemmas):
        out = []
        i = 0
        n = len(lemmas)

        while i < n:
            matched = False
            for L in self.lengths:
                if i + L <= n:
                    seq = tuple(lemmas[i:i+L])
                    if seq in self.mwe_by_len[L]:
                        out.append("_".join(seq))
                        i += L
                        matched = True
                        break
            if not matched:
                out.append(lemmas[i])
                i += 1

        return out


# Train W2v

corpus = ConllCorpusIterator(CONLL_PATH, mwe_list)

model = Word2Vec(
    sentences=corpus,
    vector_size=200,
    window=5,
    min_count=20,
    sg=1,
    workers=8,
    epochs=5
)

model.save(MODEL_OUT)

print(f"\nModello salvato in: {MODEL_OUT}")


