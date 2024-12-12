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

### A forma que eu usei é usando o DaemonSet

--------------------------------------------------------------
