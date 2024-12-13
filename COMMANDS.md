# Comandos Kubernetes usados no projeto

$ kubectl get pods -A -> lista todos os pods de todas as namespaces do cluster

$ kubectl get pods -owide -> lista os pods em execução com informações adicionais

$ kubectl get cm -n kube-system kube-proxy -oyaml -> faz o processo de exportação da yaml do kube-proxy

$ kubectl get cm -n kube-system -> comando usado para listar os ConfigMaps da namespace kube-system. 

$ kubectl get ns -> lista todas as namespaces do cluster

$ kubectl get services -n ingress-nginx -> lista o service do nginx que é do tipo LoadBalancer

$ kubectl get ingress -n jenkins -> verifica o ingress do jenkins

$ kubectl get ingressClass -> lista as classes do ingress dentro do cluster

$ kubectl logs name_pod -n namespace -> valida os logs de um determinado pods de uma namespace

$ kubectl logs name_pod -n namespace -c parametrer -> a opção -c é usado para executar parametros passados pelo log 

$ kubectl get ingress -A -> lista todos os ingress de todas as namespaces

$ kubectl describe pod -n namespace  pod_name -> mostra mais detalhes de um pod especifico.

$ kubectl get endpoints -n app -> lista os endpoints mostrando o ip do pod e a porta que está associada