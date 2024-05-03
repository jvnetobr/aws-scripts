#!/bin/bash

# Nome do perfil AWS
read -p "Digite o nome do perfil AWS: " aws_profile

# lista de usuários IAM
users=$(aws iam list-users --query "Users[].UserName" --output text --profile $aws_profile)

# Loop sobre cada usuário
for user in $users; do
    echo "Usuário: $user"

    # Lista de grupos do usuário
    groups=$(aws iam list-groups-for-user --user-name $user --query "Groups[].GroupName" --output text --profile $aws_profile)

    # Loop sobre cada grupo
    for group in $groups; do
        echo "Grupo: $group"

        # Lista as políticas anexadas ao grupo
        policies=$(aws iam list-attached-group-policies --group-name $group --query "AttachedPolicies[].PolicyName" --output text --profile $aws_profile)

        # Verifica se existem políticas anexadas
        if [ -n "$policies" ]; then
            echo "Políticas anexadas: $policies"
        else
            echo "Não há políticas anexadas ao grupo."
        fi

        echo
    done

    echo
done
