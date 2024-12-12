# kind-project-CI-CD-DevOps
Projeto de desenvolvimento de um cluster Kubernetes com toda a estrutura e ferramentas para o CI/CD


## Procedimentos para subir o cluster kind 
Comando kind para subir o cluster -> $ kind create cluster --config /clusters-kind/config.yaml


## Historico de atividades no projeto. 
Comando no linux que faz com que remova o limite de criação de arquivos pois o cluster kind simula como se fosse 3 máquinas virtuais.
$ echo fs.inotify.max_user_watches=655360 | sudo tee -a /etc/sysctl.conf
$ echo fs.inotify.max_user_instances=1280 | sudo tee -a /etc/sysctl.conf
$ sudo sysctl -p -> aplica em memoria

--------------------------------------------------------------

Dentro do config.yaml para subir o cluster kind, já deixei configurado o container registry do harbor privado.


--------------------------------------------------------------
Incluir hostnames no /etc/hosts para resolução de nomes local 
dentro do /etc/hosts:

DNS Kubernets


172.20.0.50     argocd.localhost.com jenkins.localhost.com gitea.localhost.com sonarqube.localhost.com harbor.localhost.com api.localhost.com appliferay.localhost.com

Foi incluido em todos os nodes do cluster kind 

Comando bash usado para incluir em todos os nodes do cluster:
$ for container in $(docker ps --filter "label=io.x-k8s.kind.role=worker" -q); do docker exec $container bash -c "echo '172.20.0.50     argocd.localhost.com jenkins.localhost.com gitea.localhost.com sonarqube.localhost.com harbor.localhost.com api.localhost.com appliferay.localhost.com' >> /etc/hosts"; done


A forma que eu usei é usando o DaemonSet
Caminho do daemonset para o setup-hosts
/manifests/setup-hosts.yaml

## Configuração e uso do Metallb:
Usei o modo L2 leader 

Instalação via manifesto:
$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml

Foi atomatizado no makefile 

O arquivo de configuração está em /manifests/metallb-pool.yaml

----------------------------------------------------------------
## Uso do Ingress-Nginx-Controller

Usando helm:
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

$ helm upgrade --install --namespace ingress-nginx --create-namespace -f /helm-project/values/ingress-nginx/values.yaml ingress-nginx ingress-nginx/ingress-nginx

----------------------------------------------------------------

## Uso do Jenkins via helm

Caminho do values.yaml:
helm-project/values/jenkins/values.yaml

Principais configurações no values do jenkins:
1 - ingress: enabled: true
2 - ingressClassName: nginx
3 - hostName: jenkins.localhost.com

Comando para coletar a senha do admin:
$ kubectl get secret -n jenkins jenkins -ojson | jq -r '.data."jenkins-admin-password"' | base64 -d

---------------------------------------------------------------

## Uso do Gitea via helm

Caminho do values.yaml:
helm-project/values/gitea/values.yaml
helm-project/values/gitea/secret-gitea.yaml

Principais configurações no values do gitea:
1 - ingress: enabled: true
2 - ClassName: nginx
3 - hosts: - host: gitea.localhost.com


----------------------------------------------------------------

## Uso do Harbor via helm

caminho do values.yaml:
helm-project/values/harbor/values.yaml

Principais configurações no values do harbor:
1 - expose: type: ingress
2 - tls: enabled: false
3 - ingress: hosts: core: harbor.localhost.com
4 - externalURL: http://harbor.localhost.com
5 - className: "nginx"

----------------------------------------------------------------

## Uso do SonarQube via helm

caminho do values.yaml:
helm-project/values/sonarqube/values.yaml