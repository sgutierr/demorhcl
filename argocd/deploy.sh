#!/bin/bash

# Script para desplegar la demo de Connectivity Link usando ArgoCD

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Desplegando Connectivity Link Demo con ArgoCD ===${NC}\n"

# Verificar que estamos conectados al cluster
if ! oc whoami &> /dev/null; then
    echo -e "${RED}Error: No estás conectado a un cluster OpenShift${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Conectado al cluster: $(oc whoami --show-server)${NC}"

# Verificar que ArgoCD está instalado
if ! oc get namespace argocd &> /dev/null; then
    echo -e "${RED}Error: El namespace 'argocd' no existe. Por favor instala ArgoCD primero.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Namespace argocd existe${NC}"

# Pedir confirmación para actualizar el repositorio
echo -e "\n${YELLOW}IMPORTANTE: Asegúrate de haber actualizado la URL del repositorio en todos los archivos .yaml${NC}"
echo -e "${YELLOW}Archivos a revisar:${NC}"
echo "  - argocd/argocd-app.yaml"
echo "  - argocd/apps/*.yaml"
read -p "¿Has actualizado las URLs del repositorio? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Por favor actualiza las URLs del repositorio y vuelve a ejecutar este script${NC}"
    exit 1
fi

# Crear namespace de operadores si no existe
echo -e "\n${GREEN}Creando namespaces necesarios...${NC}"
oc create namespace operators --dry-run=client -o yaml | oc apply -f -
oc create namespace kuadrant-system --dry-run=client -o yaml | oc apply -f -

# Desplegar aplicaciones ArgoCD
echo -e "\n${GREEN}Desplegando aplicaciones ArgoCD...${NC}"
oc apply -k argocd/

echo -e "\n${GREEN}✓ Aplicaciones ArgoCD desplegadas${NC}"

echo -e "\n${YELLOW}Esperando a que las aplicaciones se sincronicen...${NC}"
echo -e "${YELLOW}Puedes monitorear el progreso en la UI de ArgoCD o con:${NC}"
echo "  oc get applications -n argocd"

echo -e "\n${GREEN}=== Despliegue iniciado ===${NC}"
echo -e "${GREEN}El proceso puede tardar varios minutos mientras se instalan los operadores${NC}"

