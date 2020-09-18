# Устанавливаем HashiCorp Vault с помощью оператора от BanzaiCloud

### Переходим в каталог с практикой

```
cd slurm/practice/8.secret/
```

### Устанавливаем оператор

1) Проверяем наличие свободных pv

```
kubectl get pv
```

2) Настроим правила RBAC
```
kubectl apply -f operator/deploy/operator-rbac.yaml
kubectl apply -f operator/deploy/rbac.yaml
```

3) Установим оператор
```
kubectl apply -f operator/deploy/operator.yaml
```

### Устанавливаем Vault

4) Создадим ресурс, который скажет оператору создать нам vault

Сначала поменяем в файле operator/deploy/cr.yaml название хоста s000000 на s<номер_студента>:

```
  ingress:
    spec:
      rules:
        - host: vault.s<номер_студента>.edu.slurm.io
```

Так же убеждаемся что в PVC описан сторадж нейм local-storage

```
kind: PersistentVolumeClaim
metadata:
  name: vault-file
  spec:
    storageClassName: "local-storage"
```
 
```
kubectl apply -f operator/deploy/cr.yaml
```

5) Посмотрели на vault

```
kubectl get pod
```


### Теперь устанавливаем mutating webhook with Helm

6) Добавляем репозиторий и устанавливаем чарт

```
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
helm upgrade --namespace vault-infra --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook --wait --create-namespace
```

### Получаем root токен администратора vault

> Токен админа root оператор записал нам в секрет куба
> Обычный вариант входа в vault - задаем переменные окружения и входим ( для примера! не выполнять )
> export VAULT_TOKEN=$(kubectl get secrets vault-unseal-keys -o jsonpath={.data.vault-root} | base64 -d)
> export VAULT_SKIP_VERIFY=true
> export VAULT_ADDR=https://127.0.0.1:8200
> vault

7) Выполняем команду

```
kubectl get secrets vault-unseal-keys -o jsonpath={.data.vault-root} | base64 -d
```

### Заходим в web UI

> при создании vault мы попросили оператора создать на ingress и включить UI, 

8) Заходим браузером по адресу  http://vault.s<номер_студента>.edu.slurm.io

> Для авторизации введем root token, получить его можно командой
> Смотрим, видим ключик с данными, он там появился, потому что в operator/deploy/cr.yaml мы попросили его создать

### войдем в vault консолью

9) создаем под, в котором настроен vault

```
kubectl apply -f console.yaml
```

10) Смотрим его имя
```
kubectl get pod
```

11) Запускаем внутри пода шелл 
```
kubectl exec -it vault-console-6f8cd6476d-6tzrm sh
```

12) выполняем внутри пода команды:

> статус vault

```
vault status
```

> добавление ключа

```
vault kv put secret/accounts/aws AWS_SECRET_ACCESS_KEY=myGreatKey
```

> выходим из пода
```
exit
```

### Проверяем в web UI изменение ключа

13) идем в браузер http://vault.s<номер_студента>.edu.slurm.io посмотреть что ключ изменился

> кстати kv версии 2 поддерживает версионирование, так что можно посмотреть предыдущие значения секретов.

### Создадим тестовое приложение, которое должно получить секреты из vault

14) Запускаем из манифеста

```
kubectl apply -f test-deployment.yaml
```

15) Посмотрели имя пода

```
kubectl get pod | grep hello-secret
```

16) Посмотрели в логи основного контейнера

```
kubectl logs hello-secrets-6d46fb96db-tvsvb
```

17) Посмотрели в логи init-контейнера

```
kubectl logs hello-secrets-6d46fb96db-tvsvb -c init-ubuntu
```

> видим что нам показывает секрет

### Проверяем манифесты

18) смотрим в описание деплоймент, видим что в env: написана ссылка на vault, и что команда выводит значение переменной окружения

```
cat test-deployment.yaml
```

19) смотрим в describe пода - видим что там так же ссылка на vault, а не секретное значение

```
kubectl describe pod hello-secrets-6d46fb96db-tvsvb

  Environment:
    AWS_SECRET_ACCESS_KEY:  vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY
```

20) Заходим в Pod и смотрим переменные окружения 

```
kubectl exec -it hello-secrets-6d46fb96db-tvsvb env | grep AWS
```

> видим также ссылку на vault: AWS_SECRET_ACCESS_KEY=vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY

21) Удаляем все

```
kubectl delete deployment vault-console
kubectl delete deployment hello-secrets

# удаляем vault, с помощью удаления CRD
kubectl delete vault vault
# смотрим
kubectl get pod

# добиваем оператора
kubectl delete deployment vault-operator
helm delete -n vault-infra vault-secrets-webhook

kubectl delete ns vault-infra

# удаляем диск с данными vault
kubectl delete pvc vault-file
```
