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

Principais configurações no values do ingress-nginx:
1 - tcp: 22: "gitea/gitea-ssh:22" 
----------------------------------------------------------------

## Uso do Jenkins via helm

Caminho do values.yaml:
helm-project/values/jenkins/values.yaml

Principais configurações no values do jenkins:
1 - ingress: enabled: true
2 - ingressClassName: nginx
3 - hostName: jenkins.localhost.com
4 - additionalPlugins: - pipeline-stage-view - multibranch-scan-webhook-trigger - basic-branch-build-strategies - discord-notifier
5 - hostAliases: - ip: 172.20.0.50 hostnames: - gitea.localhost.com

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

## Configuração do gitea:

Criado uma organization chamada project-devsecops
foi criado um user de serviço chamado jenkins que foi associado ao grupo devops. 
foi vinculado uma chave ssh tanto pro user admin quanto pro user jenkins 


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

Principais configurações no values do sonarqube:
1 - ingress: enabled: false
2 - hosts: - name: sonarqube.localhost.com
3 - ingressClassName: nginx


----------------------------------------------------------------

## Uso do ArgoCD via helm

caminho do values.yaml:
helm-project/values/argocd/values.yaml

Principais configurações no values do argoCD:
1 - ingress: enabled: true
2 - ingressClassName: "nginx"
3 - tls: false
4 - server.insecure: true -> vai rodar sem tls
5 - hostname: "argocd.localhost.com"

Comando para coletar a senha do admin:
$ kubectl get secret -n argocd argocd-initial-admin-secret -ojson | jq -r '.data.password' | base64 -d


----------------------------------------------------------------

## Uso do Imagepullsecret-patcher via helm
É usado para:
Para um pod conseguir utilizar uma imagem de um registry privado, ele precisa de um secret. Só que o secret ele é por namespace, então oque o imagepullsecret faz:
ele pega um secret central, e replica para toda as namespaces.

Caminho do values.yaml:
helm-project/values/imagepullsecret-patcher/values.yaml

Principais configurações no values do argoCD:
1 - secretName: "harbor-credentials"


--------------------------------------------------------------------------------------------------------------------------------------------------------

## Trabalhando com Gitflow 

dentro do jenkins, utilizei o conceito de when delimitando apenas que rode as pipelines com determinadas branchs. 

Link de referência:
https://www.jenkins.io/doc/book/pipeline/syntax/#when

Regras:
No Jenkinsfile eu usei a clausula when, onde delimito pelas tais branchs:
"feature-*"
"develop"
"hotfix-*"
"release-*"
"v*"

No Jenkins eu habilito nas configurações os parametros:
1 - Behaviours -> Filter by name (with regular expression) as expressões:
^(feature|develop|hotfix|release|v).*



---------------------------------------------------------------------------------------------------------------------------------------------------------
## Trabalhando com Jenkins-shared-libraries:

link de referência:
https://www.jenkins.io/doc/book/pipeline/shared-libraries/

---------------------------------------------------------------------------------------------------------------------------------------------------------
## Trabalhando com o Sonarqube

utilizei o sonar-scanner-ci via docker:

$ docker run \
--env SONAR_HOST_URL=http://sonarqube.localhost.com \
--env SONAR_LOGIN="sqa_73db29f64a89fc2635ba53f1ce2742f1348012d7" \
--env SONAR_SCANNER_OPTS="-Dsonar.projectKey=test" \
--network kind \
--volume $(pwd):/usr/src \
--add-host sonarqube.localhost.com:172.20.0.50 \
sonarsource/sonar-scanner-cli:5.0.1

Foi usado também o qualitygate para realizar testes do codi smell 

---------------------------------------------------------------------------------------------------------------------------------------------------

## Uso do Kaniko para build 
