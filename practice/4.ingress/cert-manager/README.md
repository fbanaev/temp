## Работа с cert-manager

1) Устанавливаем cert-manager, выпускаем тестовый сертификат

```bash
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager.crds.yaml

kubectl create namespace cert-manager

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.15.1
```

2) Проверяем работу, выпустив самоподписанный сертификат
```bash
kubectl apply -f test-resources.yaml
```

> Если возникает ошибка `Error from server (InternalError)`, то применяем манифест еще раз.

3) Убеждаемся, что сертификат создан

```bash
kubectl -n cert-manager-test describe certificate selfsigned-cert
kubectl -n cert-manager-test get certificate selfsigned-cert -o yaml
```

```bash
kubectl -n cert-manager-test describe secret selfsigned-cert-tls
kubectl -n cert-manager-test get secret selfsigned-cert-tls -o yaml
```

4) Смотрим, каким образом сертификат был выпущен - issuer
```bash
kubectl -n cert-manager-test get issuer
```

5) Удаляем тестовый ns
```bash
kubectl delete ns cert-manager-test
```

6) Создаем secret для авторизации в LE
```bash
kubectl create secret generic stage-issuer-account-key --from-file=./tls.key --namespace=cert-manager
```

7) Проверяем, что secret создался
```bash
kubectl describe secrets -n cert-manager stage-issuer-account-key
```

8) Создаем выпускальщик сертификатов. 

> **Применяем обязательно stage манифест - `clusterissuer-stage.yaml`**

```bash
kubectl apply -f clusterissuer-stage.yaml
```

9) Проверяем, что наш clusterissuer создался:
```bash
kubectl get clusterissuers letsencrypt -o yaml
```

10) Добавляем в ingress информацию о TLS. Правим в файле tls-ingress.yaml 's<свой номер логина>' на свой номер студента
```bash
kubectl apply -f tls-ingress.yaml -n default
```

11) Посмотрели на сертификат
```bash
kubectl get certificate my-tls -o yaml
```

12) Посмотрели на секрет
```bash
kubectl get secret my-tls -o yaml
```

13) Зайдем в браузер по адресу `https://my.s<свой номер логина>.edu.slurm.io` и убедимся, что сертификат от issuer: CN=Fake LE Intermediate X1. Не забываем править `s<свой номер логина>` на свой номер студента

**ДОМАШНЯЯ РАБОТА:**
- Создать новый Ingress с именем хоста `site.s<свой номер логина>.edu.slurm.io`
- Ingress должен обращаться в то же основное приложение, которое мы запустили ранее
- Выпустить для этого Ingress `Fake LE` сертификат с помощью уже созданного ранее `stage-issuer'а`
- Закрыть свой сайт `site.s<свой номер логина>.edu.slurm.io` basic-авторизацией
- Для решения ДЗ используйте документацию https://kubernetes.github.io/ingress-nginx , а также https://kubernetes.github.io/ingress-nginx/examples/auth/basic/

Правильный ответ лежит в `right_answers/homework`
