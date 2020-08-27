# Ingress

1) Меняем имя хоста в ingress.yaml

Открываем файл

```bash
vim ~/slurm/practice/1.kube-basics-lecture/8.ingress/ingress.yaml
```

Там меняем строчку

```yaml
    - host: s<номер своего логина>.k8s.slurm.io
```

на свой номер логина

> !! Если вы вошли в vim и не знаете что делать, то нажимайте :wq<Enter>

2) Создаем ingress

```bash
kubectl apply -f ~/slurm/practice/1.kube-basics-lecture/8.ingress/ingress.yaml
```

3) Проверяем, что ингресс создался

```bash
kubectl get ingress

```

Видим что-то типа

```bash
NAME         HOSTS                     ADDRESS   PORTS     AGE
my-ingress   s000001.k8s.slurm.io             80        1s
```

4) Проверяем, что наши поды теперь доступны снаружи по имени хоста в ингрессе

```bash
curl -i s<номер своего логина>.k8s.slurm.io
```

В ответ видим выданный нам nginx'ом hostname пода

```bash
HTTP/1.1 200 OK
Server: nginx/1.12.2
Date: Sun, 27 Jan 2019 13:36:20 GMT
Content-Type: application/octet-stream
Content-Length: 31
Connection: keep-alive

my-deployment-5b47d48b58-r95lt
```

5) Чистим за собой кластер

```bash
kubectl delete all --all
kubectl delete configmap --all
kubectl delete ingress --all
```
