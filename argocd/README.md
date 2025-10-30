# ArgoCD - Connectivity Link Demo

Este directorio contiene la configuración de ArgoCD para automatizar el despliegue completo de la demo de Connectivity Link.

## Estructura

```
argocd/
├── argocd-app.yaml              # Aplicación raíz que gestiona todas las demás
├── apps/
│   ├── operators-namespace.yaml  # Namespace para operadores
│   ├── operators.yaml            # Operadores (Istio Service Mesh, Kuadrant)
│   ├── tls-secret-app.yaml       # Secret de TLS para el Gateway
│   ├── kuadrant-config.yaml     # Configuración del Gateway de Kuadrant
│   └── echo-api-app.yaml         # Aplicación echo-api y HTTPRoute
└── manifests/
    ├── echo-api/
    │   ├── deployment.yaml       # Deployment de echo-api
    │   ├── service.yaml          # Service de echo-api
    │   └── httproute.yaml        # HTTPRoute que conecta con el Gateway
    └── tls-secret.yaml            # Secret de TLS (debe ser actualizado)
```

## Orden de despliegue

Las aplicaciones se despliegan en el siguiente orden debido a las dependencias:

1. **operators-system**: Crea el namespace para operadores
2. **connectivity-link-operators**: Despliega los operadores de Istio y Kuadrant
3. **tls-secret**: Crea el secret de TLS necesario para el Gateway
4. **kuadrant-config**: Configura el Gateway de Istio
5. **echo-api-demo**: Despliega la aplicación echo-api y su HTTPRoute

## Requisitos previos

1. **ArgoCD instalado** en el cluster OpenShift
2. **Repositorio Git** con acceso desde ArgoCD
3. **Permisos necesarios** para crear recursos en los namespaces:
   - `openshift-operators`
   - `kuadrant-system`

## Configuración

### 1. Actualizar URLs del repositorio

Edita todos los archivos `.yaml` en `argocd/apps/` y `argocd/argocd-app.yaml` y actualiza:

```yaml
source:
  repoURL: https://github.com/tu-usuario/demorhcl.git  # Cambiar por tu repositorio
```

### 2. Generar el secret de TLS

El archivo `argocd/manifests/tls-secret.yaml` contiene valores de ejemplo que deben ser reemplazados.

Para generar un certificado válido:

```bash
# Generar certificado y clave
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes \
  -subj "/CN=kuadrant.apps.ocp4.quitala.eu"

# Codificar en base64
TLS_CRT=$(cat cert.pem | base64 -w 0)
TLS_KEY=$(cat key.pem | base64 -w 0)

# Actualizar el archivo tls-secret.yaml con estos valores
```

O puedes usar OpenShift para generar el certificado:

```bash
# Crear el secret directamente en el cluster
oc create secret tls api-external \
  --cert=/path/to/cert.pem \
  --key=/path/to/key.pem \
  -n kuadrant-system
```

### 3. Desplegar las aplicaciones ArgoCD

#### Opción A: Desde el CLI

```bash
# Desplegar todas las aplicaciones
oc apply -f argocd/apps/

# O desplegar la aplicación raíz que gestiona todo
oc apply -f argocd/argocd-app.yaml
```

#### Opción B: Desde la UI de ArgoCD

1. Accede a la UI de ArgoCD
2. Haz clic en "New App"
3. Importa cada aplicación desde `argocd/apps/`

## Verificación

Después del despliegue, verifica que todo está funcionando:

```bash
# Verificar operadores
oc get subscriptions -n openshift-operators

# Verificar Kuadrant
oc get kuadrant -n kuadrant-system

# Verificar Gateway
oc get gateway -n kuadrant-system

# Verificar la aplicación
oc get pods -n kuadrant-system | grep echo-api

# Verificar HTTPRoute
oc get httproute -n kuadrant-system
```

## Sincronización automática

Todas las aplicaciones están configuradas con `syncPolicy.automated` que:
- **Auto-sync**: Sincroniza automáticamente cuando se detectan cambios en el repositorio
- **Self-heal**: Restaura la configuración si se modifican manualmente los recursos
- **Prune**: Elimina recursos que ya no están en el repositorio

## Troubleshooting

### Las aplicaciones no se sincronizan

1. Verifica que ArgoCD tiene acceso al repositorio
2. Verifica que la rama `targetRevision` existe
3. Verifica los logs de ArgoCD: `oc logs -n argocd deployment/argocd-repo-server`

### Los operadores no se instalan

1. Verifica que tienes permisos en `openshift-operators`
2. Verifica que los CatalogSources están disponibles: `oc get catalogsource -n openshift-marketplace`

### El Gateway no tiene IP externa

Esto es normal cuando se usa un load balancer externo. El estado "pending" no afecta la funcionalidad si el load balancer está configurado correctamente.

## Personalización

Para personalizar el despliegue:

- **Hostname**: Edita `gateway-quitala.yaml` y `echo-api/httproute.yaml`
- **Imagen de la aplicación**: Edita `echo-api/deployment.yaml`
- **Recursos**: Edita los limits y requests en `echo-api/deployment.yaml`

