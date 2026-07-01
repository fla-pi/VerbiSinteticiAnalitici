import pandas as pd


verbi_sintetici_df = pd.read_csv('verbi_sintetici.csv', sep=';', encoding='utf-8')
verbi_analitici_df = pd.read_csv('verbi_analitici.csv', sep=';', encoding='utf-8')
nomi_df = pd.read_csv('nomi.csv', sep=';', encoding='utf-8')




verbi_sintetici_tuples = [
    (row['nome'], row['verbo'])
    for _, row in verbi_sintetici_df.iterrows()
]


verbi_analitici_tuples = [
    (row['nome'], row['verbo'])
    for _, row in verbi_analitici_df.iterrows()
]


dati_finali = {}

for _, row in nomi_df.iterrows():
    nome = row['nome']
    concretezza = row['concretezza']
    animatezza = row['animatezza']
    
    verbi_sint = [v for n, v in verbi_sintetici_tuples if n == nome]
    verbi_an = [v for n, v in verbi_analitici_tuples if n == nome]
    
    dati_finali[nome] = {
        'concretezza': concretezza,
        'animatezza': animatezza,
        'verbi_sintetici': verbi_sint,
        'verbi_analitici': verbi_an,
        'vsin_num': len(verbi_sint),
        'vsupp_num': len(verbi_an),
        'vsin_bin': 'yes' if len(verbi_sint) > 0 else 'no',
        'vsupp_bin': 'yes' if len(verbi_an) > 0 else 'no'
    }


dati_csv = pd.DataFrame.from_dict(dati_finali, orient='index').reset_index()
dati_csv = dati_csv.rename(columns={'index': 'nome'})


dati_csv['verbi_sintetici'] = dati_csv['verbi_sintetici'].apply(lambda x: ', '.join(x))
dati_csv['verbi_analitici'] = dati_csv['verbi_analitici'].apply(lambda x: ', '.join(x))


dati_csv.to_csv('predicati_denominali.csv', index=False, sep=';', encoding='utf-8')

