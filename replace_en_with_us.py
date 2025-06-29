#!/usr/bin/env python3
"""
Script para substituir "EN" por "US" nos arquivos JSON da pasta assets/medicamentos
sem alterar o conteúdo dos documentos.
"""

import os
import json
import glob

def replace_en_with_us(file_path):
    """Substitui "EN" por "US" no arquivo JSON"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Substitui "EN" por "US" apenas nas chaves do JSON
        # Usa regex para garantir que só substitui "EN" que é uma chave de objeto
        import re
        content = re.sub(r'"EN":', '"US":', content)
        
        # Salva o arquivo modificado
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return True
    except Exception as e:
        print(f"Erro ao processar {file_path}: {e}")
        return False

def main():
    directory = 'assets/medicamentos'
    
    # Encontra todos os arquivos JSON
    json_files = glob.glob(os.path.join(directory, '*.json'))
    
    print(f"Substituindo 'EN' por 'US' em {len(json_files)} arquivos...")
    print(f"Diretório: {directory}")
    print("-" * 50)
    
    success_count = 0
    error_count = 0
    
    for file_path in json_files:
        filename = os.path.basename(file_path)
        if replace_en_with_us(file_path):
            print(f"✓ {filename}")
            success_count += 1
        else:
            print(f"✗ {filename}")
            error_count += 1
    
    print("-" * 50)
    print(f"Arquivos processados com sucesso: {success_count}")
    print(f"Arquivos com erro: {error_count}")
    print("Substituição concluída!")

if __name__ == "__main__":
    main() 