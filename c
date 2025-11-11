Actualización Automática del Endpoint de API
Debido a que AWS API Gateway genera un nuevo endpoint cada vez que se ejecuta terraform destroy y terraform apply, se implementó un script bash (frontend_config.sh) que actualiza automáticamente el archivo config.json en el repositorio del frontend mediante la API de GitHub. Esto elimina la necesidad de modificar manualmente el endpoint antes de cada despliegue y evita tener que clonar el repositorio localmente. El script lee el endpoint generado por Terraform, compara si cambió respecto al valor actual, y solo hace un commit en GitHub si detecta modificaciones. Para su funcionamiento requiere un token de acceso personal de GitHub con permisos de repo y las credenciales configuradas en un archivo .env que incluye el token y la URL del repositorio. Se ejecuta con ./frontend_config.sh después de cada terraform apply

## Crear Usuario IAM para AWS Cli (Con mínimos privilegios)

Para crear un usuario con acceso CLI y asignar las políticas:
```bash
# Crear usuario y access keys
aws iam create-user --user-name nombre-usuario
aws iam create-access-key --user-name nombre-usuario

# Crear y adjuntar políticas desde archivos
for policy_file in ./policies/*.json; do
    policy_name=$(basename "$policy_file" .json)
    policy_arn=$(aws iam create-policy \
        --policy-name "$policy_name" \
        --policy-document "file://$policy_file" \
        --query 'Policy.Arn' \
        --output text)
    aws iam attach-user-policy --user-name nombre-usuario --policy-arn "$policy_arn"
done
```

**Nota:** Guarda las Access Keys devueltas por `create-access-key` para configurar el CLI con `aws configure`.


chmod +x user-cli.sh

aes configure --profile

aws configure --profile nombre-del-perfil

aws sts get-caller-identity --profile terraform-cli


echo "export AWS_PROFILE=$PROFILE_NAME"
