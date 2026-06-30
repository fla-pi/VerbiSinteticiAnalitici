import pandas as pd
import re
import itertools

# --- Funzione che hai già ---
def expand_mwe(mwe):
    """
    Espande MWE con:
    - un/il
    - (un/il)
    - un(/il)
    """
    tokens = mwe.split()
    expanded_tokens = []

    for tok in tokens:
        # Caso 1: un(/il)
        m = re.match(r"^(.+)\(/\s*([^/]+)\)$", tok)
        if m:
            base = m.group(1)
            alt = m.group(2)
            expanded_tokens.append([base, alt])
            continue

        # Caso 2: (un/il)
        m = re.match(r"^\(([^)]+)\)$", tok)
        if m:
            alts = m.group(1).split("/")
            expanded_tokens.append([""] + alts)
            continue

        # Caso 3: un/il
        if "/" in tok:
            expanded_tokens.append(tok.split("/"))
            continue

        # Caso normale
        expanded_tokens.append([tok])

    # combina tutto
    results = []
    for combo in itertools.product(*expanded_tokens):
        sent = " ".join(w for w in combo if w)
        sent = re.sub(r"\s+", " ", sent).strip()
        results.append(sent)

    return sorted(set(results))

# --- Leggi il CSV ---
df = pd.read_csv("verbi_analitici.csv", sep=";")  # usa sep="\t" se è tab-delimited

# --- Espandi solo la colonna Var1 ---
expanded_rows = []

for idx, row in df.iterrows():
    var1 = str(row['verbo'])
    expanded = expand_mwe(var1)
    for e in expanded:
        new_row = row.copy()
        new_row['Var1'] = e  # sostituisci Var1 con la versione espansa
        expanded_rows.append(new_row)

# --- Crea nuovo DataFrame e salva ---
df_expanded = pd.DataFrame(expanded_rows)
df_expanded.to_csv("pred_analitici_expanded.csv", sep=";", index=False)
