## Решение домашней работы

1) За основу под свой Ingress можно взять файл `site-ingress.yaml`. Правим в нем плейсхолдеры и применяем.

2) Проверяем, что `Fake LE` сертификат выписался

```bash
curl https://site.s<ваш номер логина>.edu.slurm.io -vvvvv
```

3) Создаем токен для Basic-авторизации. Ставим необходимый пакет. ВАЖНО! Файл должен иметь имя `auth`. При создании указываем пароль, который потом будем использовать для захода на сайт

```bash
yum install httpd-tools -y

htpasswd -c auth foo
```

4) Создаем Secret из файла с паролем:

```bash
kubectl create secret generic basic-auth --from-file=auth
```

5) Добавляем в файл вашего Ingress следующие аннотации:

```bash
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - foo'

```

6) Применяем изменения:

```bash
kubectl apply -f site-ingress.yaml
``` 

7) Видим, что теперь нам по запросу отдается 401:

```bash
curl https://site.s<ваш номер логина>.edu.slurm.io -k
```

8) Заходим через Инкогнито браузером на `https://site.s<ваш номер логина>.edu.slurm.io`, соглашаемся с рисками о кривом сертификате. Вводим логин: `foo`, пароль: `тот, что вы задали ранее`.
