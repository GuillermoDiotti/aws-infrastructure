#!/bin/bash

USUARIO="terraform-cli"

# 1. Crear el usuario
aws iam create-user --user-name $USUARIO

# 2. Crear access keys para CLI
aws iam create-access-key --user-name $USUARIO

# 3. Crear y adjuntar todas las políticas de la carpeta
for policy_file in ./user-policies/*.json; do
    policy_name=$(basename "$policy_file" .json)

    # Crear la política
    policy_arn=$(aws iam create-policy \
        --policy-name "$policy_name" \
        --policy-document "file://$policy_file" \
        --query 'Policy.Arn' \
        --output text)

    # Adjuntarla al usuario
    aws iam attach-user-policy \
        --user-name $USUARIO \
        --policy-arn "$policy_arn"

    echo "✓ Política $policy_name adjuntada"
done

echo "Usuario $USUARIO creado exitosamente"