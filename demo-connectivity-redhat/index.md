curl -k -w "%{http_code}" https://echo.travels.sandbox2183.opentlc.com && echo

prod-web-deny-all.yaml
ratelimitpolicy.yaml

for i in {1..10}; do echo "($i)"; curl -k -w "%{http_code}" https://echo.travels.sandbox2183.opentlc.com; echo; done

travel-agency-httproute.yaml


Para probar curl:

oc run test-curl --image=curlimages/curl:latest --rm -it --restart=Never -n kuadrant-system -- curl -v http://echo-api:8080/


external-istio.kuadrant-system.svc.cluster.local

Acceso HAProxy
podman exec -it a3996d3263d7 /bin/bash
podman cp haproxy2.cfg a3996d3263d7:/haproxy.cfg
podman cp a3996d3263d7:/haproxy.cfg haproxy2.cfg



Configuración del HAPROXY para la demo:

Existen dos maneras:
1-No tocar la configuración del HAPROXY e usar un port-forward
    oc port-forward svc/external-istio -n kuadrant-system
    curl -v -H "Host: kuadrant.apps.ocp4.quitala.eu" http://localhost:9000

2-El HAPROXY viene de este proyecto https://github.com/RedHat-EMEA-SSA-Team/openshift-4-loadbalancer/
  La configuración sólo se puede cambiar a través de una variable de entorno que ejecuta el host en el corre el container.
  Para cambiar la variable de entorno hay que editar el fichero y poner dentro la variable de entorno con la lógica de que si entra por kuadrant.api.ocp4.quitala.eu se redirija al node port: /etc/sysconfig/openshift-4-loadbalancer-ocp4.env

