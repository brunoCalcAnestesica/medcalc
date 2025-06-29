#!/usr/bin/env python3
"""
Script para padronizar a estrutura de todos os arquivos JSON na pasta assets/medicamentos
com a estrutura especificada pelo usuário.
"""

import os
import json
import glob

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
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
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
    
    # Encontra todos os arquivos JSON
    json_files = glob.glob(os.path.join(directory, '*.json'))
    
    print(f"Iniciando padronização de {len(json_files)} arquivos...")
    print(f"Diretório: {directory}")
    print("-" * 50)
    
    success_count = 0
    error_count = 0
    
    for file_path in json_files:
        filename = os.path.basename(file_path)
        if standardize_file(file_path):
            print(f"✓ {filename}")
            success_count += 1
        else:
            print(f"✗ {filename}")
            error_count += 1
    
    print("-" * 50)
    print(f"Arquivos processados com sucesso: {success_count}")
    print(f"Arquivos com erro: {error_count}")
    print("Padronização concluída!")

if __name__ == "__main__":
    main() 