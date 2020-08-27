### Resources and Probes

Создаем deployment с ресурсами и пробами
```bash
kubectl apply -f ~/slurm/practice/1.kube-basics-lecture/4.resources-and-probes/
```
Смотрим что получилось
```bash
kubectl get pod
```
Должны увидеть что-то типа такого
```bash
NAME                             READY     STATUS              RESTARTS   AGE
my-deployment-57fff9c845-2qv5l   0/1       ContainerCreating   0          1s
my-deployment-57fff9c845-h8bbw   0/1       ContainerCreating   0          1s
```
Увеличиваем количество ресурсов для нашего деплоймента
```bash
kubectl patch deployment my-deployment --patch '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"requests":{"cpu":"10"},"limits":{"cpu":"10"}}}]}}}}'
```
Смотрим что получилось
```bash
kubectl get pod
```
Должны увидеть что-то типа такого
```bash
NAME                             READY     STATUS    RESTARTS   AGE
my-deployment-57fff9c845-h8bbw   1/1       Running   0          8m
my-deployment-845d88fdcf-9bd29   0/1       Pending   0          2s
my-deployment-845d88fdcf-mprfk   0/1       Pending   0          2s
```
Смотрим, почему поды не могут создаться
```bash
kubectl describe po my-deployment-845d88fdcf-9bd29
```
Видим в эвентах что-то типа
```bash
Events:
  Type     Reason            Age               From               Message
  ----     ------            ----              ----               -------
  Warning  FailedScheduling  41s (x8 over 1m)  default-scheduler  0/1 nodes are available: 1 Insufficient cpu.
```
Чистим за собой кластер
```bash
kubectl delete deployment --all
```


