#!/bin/bash

# Nome do perfil AWS
read -p "Digite o nome do perfil AWS: " aws_profile

# Nome do arquivo de saída
output_file="aws_users.txt"

# Limpa o arquivo
echo "" > "$output_file"

# Lista de usuários IAM
users=$(aws iam list-users --query "Users[].UserName" --output text --profile $aws_profile)

# Repete sobre cada usuário
for user in $users; do
    echo >> "$output_file"
    echo "--------------------------------------------------------------------------" >> "$output_file"
    echo "Usuário: $user" >> "$output_file"

    # Lista de grupos do usuário
    groups=$(aws iam list-groups-for-user --user-name $user --query "Groups[].GroupName" --output text --profile $aws_profile)
    # Verifica se existem grupos associados
    if [ -n "$groups" ]; then
        echo "Grupos: $groups" >> "$output_file"
        # Repete sobre cada grupo
        for group in $groups; do
            echo "Grupo: $group" >> "$output_file"

            # Lista de políticas anexadas ao grupo
            name_policies=$(aws iam list-attached-group-policies --group-name $group --query "AttachedPolicies[].PolicyName" --output text --profile $aws_profile)
            policies=$(aws iam list-attached-group-policies --group-name $group --query "AttachedPolicies[].PolicyArn" --output text --profile $aws_profile)

            # Verifica se existem políticas anexadas
            if [ -n "$policies" ]; then
                # Repete sobre cada política
                echo "Políticas anexadas: $name_policies" >> "$output_file"
                for policy in $policies; do
                    echo "Política: $policy" >> "$output_file"
                    echo "Ações (Actions) da Política:" >> "$output_file"
            
                    # Versão mais recente da política
                    version=$(aws iam get-policy --policy-arn $policy --query "Policy.DefaultVersionId" --output text --profile $aws_profile)
                    # Ações (actions) da política
                    actions=$(aws iam get-policy-version --policy-arn $policy --version-id $version --query "PolicyVersion.Document.Statement[].Action" --output text --profile $aws_profile)
            
                    # Verifica se existem ações
                    if [ -n "$actions" ]; then
                        echo "$actions" >> "$output_file"
                    else
                        echo "Não existem ações (actions) associadas à política." >> "$output_file"
                    fi
                    echo >> "$output_file"

                done
            else
                echo "Não existem políticas anexadas ao grupo." >> "$output_file"
                echo >> "$output_file"
            fi
        done
    else
        echo "Não existem grupos associados ao usuário." >> "$output_file"
    fi
done

echo "A lista de usuários IAM foi salva no arquivo: $output_file"