# RBAC

1) Создаем объекты

```bash
cd ~/slurm/practice/3.advanced-abstractions/5.rbac
kubectl apply -f .

```

Видим:

```bash
rolebinding.rbac.authorization.k8s.io/user created
serviceaccount/user created
```

2) Пробуем получить список сервисов под юзером

```bash
kubectl get service --as=system:serviceaccount:default:user
```

Список сервисов возвращается:
```bash
NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                 AGE
kubernetes          ClusterIP   10.107.0.1      <none>        443/TCP                                 25h
```

3) Пробуем получить список сервисов под юзером в неймспейсе kube-system

```bash
kubectl get service --as=system:serviceaccount:default:user -n kube-system
```

Возвращается ошибка:
```bash
Error from server (Forbidden): services is forbidden: User "system:serviceaccount:default:user" cannot list resource "services" in API group "" in the namespace "kube-system"
```

4) Теперь пробуем удалить сервис kubernetes под юзером

```bash
kubectl delete service --as=system:serviceaccount:default:user kubernetes
```

Видим что RBAC работает:

```bash
Error from server (Forbidden): services "kubernetes" is forbidden: User "system:serviceaccount:default:user" cannot delete resource "services" in API group "" in the namespace "default"
```

5) Чистим за собой кластер

```bash
kubectl delete -f .
```
