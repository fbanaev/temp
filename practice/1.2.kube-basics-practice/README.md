# Устанавливем приложение fileshare

## !! Все работы всё ещё проводим из админбокса по адресу sbox.slurm.io

1) Переходим в директорию с практикой.

```bash
cd ~/slurm/practice/1.2.kube-basics-practice
```

2) Исправляем файл kube/ingress.yaml

В нем находим
```yaml
    - host: s<номер своего логина>.k8s.slurm.io
```

И меняем на номер своего логина

3) Создаем все объекты в директории kube/

```bash
kubectl apply -f kube/
```

В ответ должны увидеть

```bash
configmap "fileshare" created
deployment.extensions "fileshare" created
ingress.extensions "fileshare" created
persistentvolumeclaim "fileshare" created
service "fileshare" created
```

4) Смотрим на поды

```bash
kubectl get pod
```

Видим

```bash
NAME                         READY     STATUS    RESTARTS   AGE
fileshare-84cd866ffb-k79wh   1/1       Running   0          1m
fileshare-84cd866ffb-sl5v6   1/1       Running   0          1m
```

5) Пробуем проверить, что наше приложение доступно через ингресс

```bash
curl -i s<номер своего логина>.k8s.slurm.io
```

В ответ получаем

```bash
HTTP/1.1 200 OK
Server: nginx/1.13.12
Date: Sun, 27 Jan 2019 15:09:36 GMT
Content-Type: application/octet-stream
Content-Length: 27
Connection: keep-alive

fileshare-84cd866ffb-sl5v6
```

И по пути файлшары

```bash
curl -i s<номер своего логина>.k8s.slurm.io/files/
```

Видим

```bash
HTTP/1.1 200 OK
Server: nginx/1.13.12
Date: Sun, 27 Jan 2019 15:10:26 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Vary: Accept-Encoding

<html>
<head><title>Index of /files/</title></head>
<body bgcolor="white">
<h1>Index of /files/</h1><hr><pre><a href="../">../</a>
</pre><hr></body>
</html>
```

6) Пробуем загрузить файл

```
curl -i s<номер своего логина>.k8s.slurm.io/files/ -T kube/configmap.yaml
```

Проверяем, что файл действительно загрузился и мы можем его прочитать

```bash
curl -i s<номер своего логина>.k8s.slurm.io/files/
```

В ответ

```bash
HTTP/1.1 200 OK
Server: nginx/1.13.12
Date: Sun, 27 Jan 2019 15:15:30 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Vary: Accept-Encoding

<html>
<head><title>Index of /files/</title></head>
<body bgcolor="white">
<h1>Index of /files/</h1><hr><pre><a href="../">../</a>
<a href="configmap.yaml">configmap.yaml</a>                                     27-Jan-2019 15:14                 464
</pre><hr></body>
</html>
```

И по команде

```bash
curl -i s<номер своего логина>.k8s.slurm.io/files/configmap.yaml
```

возвращается содержимое загруженного файла

7) Пробуем удалить один из подов

```bash
kubectl get pod
kubectl delete pod <имя одного из подов из предыдущей команды>
```

Проверяем что загруженный файл все еще на месте

```bash
curl -i s<номер своего логина>.k8s.slurm.io/files/
```

В ответ

```bash
HTTP/1.1 200 OK
Server: nginx/1.13.12
Date: Sun, 27 Jan 2019 15:15:30 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Vary: Accept-Encoding

<html>
<head><title>Index of /files/</title></head>
<body bgcolor="white">
<h1>Index of /files/</h1><hr><pre><a href="../">../</a>
<a href="configmap.yaml">configmap.yaml</a>                                     27-Jan-2019 15:14                 464
</pre><hr></body>
</html>
```

8) Обновляем конфигмап

```bash
kubectl edit configmap fileshare
```

В открывшемся редакторе находим строчку

```bash
      location /files {
```

и меняем ее на

```bash
      location /data {
```

Сохраняем и выходим из редактора

9) Смотрим в логи любого пода

```bash
kubectl get pod
kubectl logs -f <имя одного из подов из предыдущей команды>
```

и ждем появления сообщения

```bash
2019/02/01 11:23:47 [notice] /docker-entrypoint.sh: reloaded Nginx config
```

10) После этого проверяем, что изменения в конфиге действительно применились

```bash
curl -i s<номер своего логина>.k8s.slurm.io/files/
```

Отвечает теперь hostname

```bash
HTTP/1.1 200 OK
Server: nginx/1.13.12
Date: Sun, 27 Jan 2019 15:25:55 GMT
Content-Type: application/octet-stream
Content-Length: 27
Connection: keep-alive

fileshare-84cd866ffb-k79wh
```

А по пути /data/

```bash
curl -i s<номер своего логина>.k8s.slurm.io/data/
```

Мы видим загруженный файл

```bash
HTTP/1.1 200 OK
Server: nginx/1.13.12
Date: Sun, 27 Jan 2019 15:27:09 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Vary: Accept-Encoding

<html>
<head><title>Index of /data/</title></head>
<body bgcolor="white">
<h1>Index of /data/</h1><hr><pre><a href="../">../</a>
<a href="configmap.yaml">configmap.yaml</a>                                     27-Jan-2019 15:14                 464
</pre><hr></body>
</html>
```

11) Чистим за собой кластер

```bash
kubectl delete -f kube/
```
