#!/bin/bash

MG_NAME="az104-mg1"
USER_UPN="az104-02-aaduser1@ferents1vladeslavgmail.onmicrosoft.com"
GROUP_NAME="az104-02-group1"
RG_NAME="az104-02-rg1"

GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"


section() {
  echo -e "\n${CYAN}========== $1 ==========${RESET}\n"
}

section "Management Group Info"

az account management-group show --name "$MG_NAME" -o table

section "Subscriptions Attached to MG"
az account management-group subscription list --mg-name "$MG_NAME" -o table

section "Entra ID Users"

az ad user list -o table

section "Specific Lab User: $USER_UPN"
az ad user show --id "$USER_UPN" -o json

section "RBAC Role Assignments for User"

az role assignment list --assignee "$USER_UPN" -o table


section "Entra ID Groups"

az ad group list -o table

section "Specific Group: $GROUP_NAME"
az ad group show --group "$GROUP_NAME" -o json

section "Members of Group: $GROUP_NAME"
az ad group member list --group "$GROUP_NAME" -o table


section "Resources in Resource Group: $RG_NAME"

az resource list --resource-group "$RG_NAME" -o table

echo -e "\n${GREEN}✔ Перевірка завершена!${RESET}\n"