#!/usr/bin/env python3
"""
Script para renomear arquivos de medicamentos seguindo boas práticas de nomenclatura de bancos de dados.
Regras:
- Nomes em minúsculas (snake_case)
- Sem acentos nos nomes dos arquivos
- Nomes descritivos e consistentes
- Separadores com underscore
"""

import os
import unicodedata
import re

def remove_accents(text):
    """Remove acentos de uma string"""
    return ''.join(c for c in unicodedata.normalize('NFD', text)
                  if unicodedata.category(c) != 'Mn')

def normalize_filename(filename):
    """Normaliza o nome do arquivo seguindo as boas práticas"""
    # Remove a extensão .json
    name = filename.replace('.json', '')
    
    # Remove acentos
    name = remove_accents(name)
    
    # Converte para minúsculas
    name = name.lower()
    
    # Substitui espaços e hífens por underscore
    name = re.sub(r'[\s\-]+', '_', name)
    
    # Remove caracteres especiais, mantendo apenas letras, números e underscore
    name = re.sub(r'[^a-z0-9_]', '', name)
    
    # Remove underscores múltiplos
    name = re.sub(r'_+', '_', name)
    
    # Remove underscores no início e fim
    name = name.strip('_')
    
    return name + '.json'

def main():
    directory = 'assets/bulas/medicamentos'
    
    # Mapeamento de nomes específicos que precisam de tratamento especial
    special_mappings = {
        'Acido_Borico.json': 'acido_borico.json',
        'Acido_Kojico.json': 'acido_kojico.json',
        'Acido_Salicilico.json': 'acido_salicilico.json',
        'Adapaleno.json': 'adapaleno.json',
        'Alcaftadina.json': 'alcaftadina.json',
        'Alclometasona.json': 'alclometasona.json',
        'Amorolfina.json': 'amorolfina.json',
        'Atropina_Oftalmica.json': 'atropina_oftalmica.json',
        'Belimumabe.json': 'belimumabe.json',
        'Benzoato_de_Benzila.json': 'benzoato_de_benzila.json',
        'Betaina_HCl.json': 'betaina_hcl.json',
        'Betametasona_Topico.json': 'betametasona_topico.json',
        'Bimatoprosta.json': 'bimatoprosta.json',
        'Bismuto_Coloidal.json': 'bismuto_coloidal.json',
        'Brentuximabe_Vedotina.json': 'brentuximabe_vedotina.json',
        'Brometo_Tiotropio.json': 'brometo_tiotropio.json',
        'Bromfenaco.json': 'bromfenaco.json',
        'Cabotegravir.json': 'cabotegravir.json',
        'Calamina.json': 'calamina.json',
        'Calcio_Citrato.json': 'calcio_citrato.json',
        'Casirivimabe.json': 'casirivimabe.json',
        'Cetoconazol_Topico.json': 'cetoconazol_topico.json',
        'Ciclosporina_Oftalmica.json': 'ciclosporina_oftalmica.json',
        'Clioquinol.json': 'clioquinol.json',
        'Clotrimazol.json': 'clotrimazol.json',
        'Dexametasona_Oftalmica.json': 'dexametasona_oftalmica.json',
        'Dupilumabe.json': 'dupilumabe.json',
        'Econazol.json': 'econazol.json',
        'Emedastina.json': 'emedastina.json',
        'Eritromicina_Topica.json': 'eritromicina_topica.json',
        'Etesevimabe.json': 'etesevimabe.json',
        'Fluocinolona.json': 'fluocinolona.json',
        'Fluoresceina.json': 'fluoresceina.json',
        'Fluorometolona.json': 'fluorometolona.json',
        'Fluticasona_Topico.json': 'fluticasona_topico.json',
        'Fluvoxamina.json': 'fluvoxamina.json',
        'Gentamicina_Topica.json': 'gentamicina_topica.json',
        'Guselkumabe.json': 'guselkumabe.json',
        'Homatropina.json': 'homatropina.json',
        'Insulina_Acao_Prolongada.json': 'insulina_acao_prolongada.json',
        'Insulina_Acao_Rapida.json': 'insulina_acao_rapida.json',
        'Insulina.json': 'insulina.json',
        'Interferon_Alfa2b_Oftalmico.json': 'interferon_alfa2b_oftalmico.json',
        'Interferon_Beta.json': 'interferon_beta.json',
        'Interferon_Gamma.json': 'interferon_gamma.json',
        'Isoconazol.json': 'isoconazol.json',
        'Isotretinoina.json': 'isotretinoina.json',
        'Ixekizumabe.json': 'ixekizumabe.json',
        'Lidocaina_Topica.json': 'lidocaina_topica.json',
        'Metilprednisolona.json': 'metilprednisolona.json',
        'Metronidazol_Topico.json': 'metronidazol_topico.json',
        'Mupirocina.json': 'mupirocina.json',
        'Nedocromil.json': 'nedocromil.json',
        'Neomicina.json': 'neomicina.json',
        'Nitrato_de_Prata.json': 'nitrato_de_prata.json',
        'Olopatadina_Oftalmica.json': 'olopatadina_oftalmica.json',
        'Permetrina.json': 'permetrina.json',
        'Pilocarpina.json': 'pilocarpina.json',
        'Remdesivir.json': 'remdesivir.json',
        'Ribavirina.json': 'ribavirina.json',
        'Ritonavir.json': 'ritonavir.json',
        'Sotrovimabe.json': 'sotrovimabe.json',
        'Tacalcitol.json': 'tacalcitol.json',
        'Tacrolimo_Topico.json': 'tacrolimo_topico.json',
        'Terbinafina_Topica.json': 'terbinafina_topica.json',
        'Tetracaina.json': 'tetracaina.json',
        'Tildrakizumabe.json': 'tildrakizumabe.json',
        'Triancinolona.json': 'triancinolona.json',
        'Triantereno.json': 'triantereno.json',
        'Trimetazidina.json': 'trimetazidina.json',
        'Tropicamida.json': 'tropicamida.json',
        'Undecilato_de_Zinco.json': 'undecilato_de_zinco.json',
        'Ureia.json': 'ureia.json',
        'Uroquinase.json': 'uroquinase.json',
        'Ustekinumabe.json': 'ustekinumabe.json',
        'Valganciclovir.json': 'valganciclovir.json',
        'Vasopressina.json': 'vasopressina.json',
        'Venetoclax.json': 'venetoclax.json',
        'Vildagliptina.json': 'vildagliptina.json'
    }
    
    print("Iniciando renomeação de arquivos...")
    print(f"Diretório: {directory}")
    print("-" * 50)
    
    renamed_count = 0
    
    for old_name, new_name in special_mappings.items():
        old_path = os.path.join(directory, old_name)
        new_path = os.path.join(directory, new_name)
        
        if os.path.exists(old_path):
            try:
                os.rename(old_path, new_path)
                print(f"✓ {old_name} → {new_name}")
                renamed_count += 1
            except Exception as e:
                print(f"✗ Erro ao renomear {old_name}: {e}")
        else:
            print(f"⚠ Arquivo não encontrado: {old_name}")
    
    print("-" * 50)
    print(f"Total de arquivos renomeados: {renamed_count}")
    print("Renomeação concluída!")

if __name__ == "__main__":
    main() 