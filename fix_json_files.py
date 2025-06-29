#!/usr/bin/env python3
"""
Script para corrigir arquivos JSON com problemas de sintaxe na pasta assets/medicamentos
"""

import os
import json
import glob
import re

def fix_json_file(file_path):
    """Corrige problemas comuns em arquivos JSON"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Remove caracteres extras no final do arquivo
        content = content.strip()
        
        # Remove vírgulas extras antes de fechar chaves/colchetes
        content = re.sub(r',(\s*[}\]])', r'\1', content)
        
        # Remove vírgulas extras no final de objetos
        content = re.sub(r',(\s*})', r'\1', content)
        
        # Corrige aspas não fechadas
        content = re.sub(r'([^\\])"([^"]*?)$', r'\1"\2"', content, flags=re.MULTILINE)
        
        # Tenta fazer o parse do JSON
        try:
            data = json.loads(content)
            return data
        except json.JSONDecodeError as e:
            print(f"Erro JSON em {os.path.basename(file_path)}: {e}")
            return None
            
    except Exception as e:
        print(f"Erro ao ler {file_path}: {e}")
        return None

def create_standard_structure():
    """Cria a estrutura padrão vazia"""
    return {
        "PT": {
            "bulario": {
                "nomePrincipioAtivo": "",
                "nomeComercial": "",
                "classificacao": "",
                "mecanismoAcao": "",
                "farmacocinetica": "",
                "farmacodinamica": "",
                "indicacoes": "",
                "posologia": "",
                "administracao": "",
                "doseMaxima": "",
                "doseMinima": "",
                "reacoesAdversas": "",
                "riscoGravidez": "",
                "riscoLactacao": "",
                "ajusteRenal": "",
                "ajusteHepatico": "",
                "contraindicacoes": "",
                "interacaoMedicamento": "",
                "apresentacao": "",
                "preparo": "",
                "solucoesCompatíveis": "",
                "armazenamento": "",
                "cuidadosMedicos": "",
                "cuidadosFarmaceuticos": "",
                "cuidadosEnfermagem": "",
                "fontesBibliograficas": ""
            }
        },
        "US": {
            "bulario": {
                "nomePrincipioAtivo": "",
                "nomeComercial": "",
                "classificacao": "",
                "mecanismoAcao": "",
                "farmacocinetica": "",
                "farmacodinamica": "",
                "indicacoes": "",
                "posologia": "",
                "administracao": "",
                "doseMaxima": "",
                "doseMinima": "",
                "reacoesAdversas": "",
                "riscoGravidez": "",
                "riscoLactacao": "",
                "ajusteRenal": "",
                "ajusteHepatico": "",
                "contraindicacoes": "",
                "interacaoMedicamento": "",
                "apresentacao": "",
                "preparo": "",
                "solucoesCompatíveis": "",
                "armazenamento": "",
                "cuidadosMedicos": "",
                "cuidadosFarmaceuticos": "",
                "cuidadosEnfermagem": "",
                "fontesBibliograficas": ""
            }
        },
        "ES": {
            "bulario": {
                "nomePrincipioAtivo": "",
                "nomeComercial": "",
                "classificacao": "",
                "mecanismoAcao": "",
                "farmacocinetica": "",
                "farmacodinamica": "",
                "indicacoes": "",
                "posologia": "",
                "administracao": "",
                "doseMaxima": "",
                "doseMinima": "",
                "reacoesAdversas": "",
                "riscoGravidez": "",
                "riscoLactacao": "",
                "ajusteRenal": "",
                "ajusteHepatico": "",
                "contraindicacoes": "",
                "interacaoMedicamento": "",
                "apresentacao": "",
                "preparo": "",
                "solucoesCompatíveis": "",
                "armazenamento": "",
                "cuidadosMedicos": "",
                "cuidadosFarmaceuticos": "",
                "cuidadosEnfermagem": "",
                "fontesBibliograficas": ""
            }
        }
    }

def map_field_names():
    """Mapeia os nomes de campos antigos para os novos"""
    return {
        # Mapeamento para PT
        "nomePrincipioAtivo": "nomePrincipioAtivo",
        "nomeComercial": "nomeComercial", 
        "classificacao": "classificacao",
        "mecanismoAcao": "mecanismoAcao",
        "farmacocinetica": "farmacocinetica",
        "farmacodinamica": "farmacodinamica",
        "indicacoes": "indicacoes",
        "posologia": "posologia",
        "administracao": "administracao",
        "doseMaxima": "doseMaxima",
        "doseMinima": "doseMinima",
        "reacoesAdversas": "reacoesAdversas",
        "riscoGravidez": "riscoGravidez",
        "riscoLactacao": "riscoLactacao",
        "ajusteRenal": "ajusteRenal",
        "ajusteHepatico": "ajusteHepatico",
        "contraindicacoes": "contraindicacoes",
        "interacaoMedicamento": "interacaoMedicamento",
        "apresentacao": "apresentacao",
        "preparo": "preparo",
        "solucoesCompatíveis": "solucoesCompatíveis",
        "armazenamento": "armazenamento",
        "cuidadosMedicos": "cuidadosMedicos",
        "cuidadosFarmaceuticos": "cuidadosFarmaceuticos",
        "cuidadosEnfermagem": "cuidadosEnfermagem",
        "fontesBibliograficas": "fontesBibliograficas",
        
        # Mapeamento para US (campos em inglês)
        "activeIngredientName": "nomePrincipioAtivo",
        "tradeName": "nomeComercial",
        "classification": "classificacao",
        "mechanismOfAction": "mecanismoAcao",
        "pharmacokinetics": "farmacocinetica",
        "pharmacodynamics": "farmacodinamica",
        "indications": "indicacoes",
        "dosage": "posologia",
        "administration": "administracao",
        "maximumDose": "doseMaxima",
        "minimumDose": "doseMinima",
        "adverseReactions": "reacoesAdversas",
        "pregnancyRisk": "riscoGravidez",
        "lactationRisk": "riscoLactacao",
        "renalAdjustment": "ajusteRenal",
        "hepaticAdjustment": "ajusteHepatico",
        "contraindications": "contraindicacoes",
        "drugInteractions": "interacaoMedicamento",
        "presentation": "apresentacao",
        "preparation": "preparo",
        "compatibleSolutions": "solucoesCompatíveis",
        "storage": "armazenamento",
        "medicalCare": "cuidadosMedicos",
        "pharmaceuticalCare": "cuidadosFarmaceuticos",
        "nursingCare": "cuidadosEnfermagem",
        "references": "fontesBibliograficas",
        
        # Mapeamento para ES (campos em espanhol)
        "nombrePrincipioActivo": "nomePrincipioAtivo",
        "nombreComercial": "nomeComercial",
        "clasificacion": "classificacao",
        "mecanismoAccion": "mecanismoAcao",
        "farmacocinetica": "farmacocinetica",
        "farmacodinamica": "farmacodinamica",
        "indicaciones": "indicacoes",
        "posologia": "posologia",
        "administracion": "administracao",
        "dosisMaxima": "doseMaxima",
        "dosisMinima": "doseMinima",
        "reaccionesAdversas": "reacoesAdversas",
        "riesgoEmbarazo": "riscoGravidez",
        "riesgoLactancia": "riscoLactacao",
        "ajusteRenal": "ajusteRenal",
        "ajusteHepatico": "ajusteHepatico",
        "contraindicaciones": "contraindicacoes",
        "interaccionMedicamento": "interacaoMedicamento",
        "presentacion": "apresentacao",
        "preparacion": "preparo",
        "solucionesCompatibles": "solucoesCompatíveis",
        "almacenamiento": "armazenamento",
        "cuidadosMedicos": "cuidadosMedicos",
        "cuidadosFarmaceuticos": "cuidadosFarmaceuticos",
        "cuidadosEnfermeria": "cuidadosEnfermagem",
        "fuentesBibliograficas": "fontesBibliograficas"
    }

def standardize_file(file_path):
    """Padroniza um arquivo individual"""
    try:
        # Tenta corrigir o JSON primeiro
        data = fix_json_file(file_path)
        if data is None:
            return False
        
        # Cria a estrutura padrão
        new_data = create_standard_structure()
        field_mapping = map_field_names()
        
        # Copia os dados existentes para a nova estrutura
        for lang in ['PT', 'US', 'ES']:
            if lang in data and 'bulario' in data[lang]:
                old_bulario = data[lang]['bulario']
                new_bulario = new_data[lang]['bulario']
                
                # Mapeia os campos antigos para os novos
                for old_field, value in old_bulario.items():
                    if old_field in field_mapping:
                        new_field = field_mapping[old_field]
                        new_bulario[new_field] = value
        
        # Salva o arquivo padronizado
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(new_data, f, ensure_ascii=False, indent=2)
        
        return True
    except Exception as e:
        print(f"Erro ao processar {file_path}: {e}")
        return False

def main():
    directory = 'assets/medicamentos'
    
    # Lista de arquivos que tiveram erro no processamento anterior
    problematic_files = [
        'sevoflurano.json', 'metadona.json', 'hidroxicobalamina.json', 
        'gluconato_calcio.json', 'nitroglicerina.json', 'dantroleno.json',
        'ocitocina.json', 'dobutamina.json', 'vasopressina.json',
        'dextrocetamina.json', 'lidocaina_infiltracao.json', 'fentanil.json',
        'metoclopramida.json', 'etomidato.json', 'dexmedetomidina.json',
        'neostigmina.json', 'milrinona.json', 'bulario_metaraminol.json',
        'plasmalyte.json', 'lorazepam.json', 'dexametasona.json',
        'sulfato_magnesio.json', 'torasemida.json', 'manitol.json',
        'propofol.json', 'remifentanil.json', 'dimenidrinato.json',
        'lidocaina_ev.json', 'ceftriaxona.json', 'metilprednisolona.json',
        'cloreto_potassio.json', 'azul_de_metileno.json', 'emulsao_lipidica.json',
        'tiossulfato_sodio.json', 'rocuronio.json', 'pentazocina.json',
        'dipirona.json', 'salina_hipertonica_20.json', 'insulina_regular.json',
        'tramadol.json', 'sugamadex.json'
    ]
    
    print(f"Corrigindo {len(problematic_files)} arquivos problemáticos...")
    print(f"Diretório: {directory}")
    print("-" * 50)
    
    success_count = 0
    error_count = 0
    
    for filename in problematic_files:
        file_path = os.path.join(directory, filename)
        if os.path.exists(file_path):
            if standardize_file(file_path):
                print(f"✓ {filename}")
                success_count += 1
            else:
                print(f"✗ {filename}")
                error_count += 1
        else:
            print(f"⚠ Arquivo não encontrado: {filename}")
    
    print("-" * 50)
    print(f"Arquivos corrigidos com sucesso: {success_count}")
    print(f"Arquivos com erro: {error_count}")
    print("Correção concluída!")

if __name__ == "__main__":
    main() 