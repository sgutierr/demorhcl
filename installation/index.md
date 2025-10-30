
Orden de instalación

# Creación de namespaces
istio-namespace.yaml

# Instalación de Service Mesh3
servicemesh3-operator.yaml
istio-cni.yaml
istio.yaml

# En versiones 4.18 o < tenemos que habilitar el GatewayAPI en la instalación de Service Mesh 3.0
oc get crd gateways.gateway.networking.k8s.io &> /dev/null ||  { oc kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.0.0" | oc apply -f -; }

# Instalación de Kuadrant
kuadrant.yaml