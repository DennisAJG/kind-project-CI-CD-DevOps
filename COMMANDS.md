# Comandos Kubernetes usados no projeto

$ kubectl get pods -A -> lista todos os pods de todas as namespaces do cluster

$ kubectl get pods -owide -> lista os pods em execução com informações adicionais

$ kubectl get cm -n kube-system kube-proxy -oyaml -> faz o processo de exportação da yaml do kube-proxy

$ kubectl get cm -n kube-system -> comando usado para listar os ConfigMaps da namespace kube-system. 

$ kubectl get ns -> lista todas as namespaces do cluster

$ kubectl get services -n ingress-nginx -> lista o service do nginx que é do tipo LoadBalancer
