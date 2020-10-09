# Развертывание оператора

+ Создать учётную запись (serviceaccount) для деплоя служебных объектов в кластер:
  ```sh
  kubectl create ns users
  kubectl -n users create serviceaccount deploy-admin
  kubectl create clusterrolebinding ci:cluster-admin --clusterrole=cluster-admin --serviceaccount=users:deploy-admin
  ```
+ Получить токен этой учётной записи:
  ```sh
  kubectl -n users get -o jsonpath='{ .data.token }' secret deploy-admin-token-<TAB> | base64 -d; echo
  ```
+ Сделать форк проекта https://gitlab.slurm.io/tinkoff/dynns-operator в свою группу;
+ добавить **CI variable** с именем `K8S_CI_TOKEN`, поместив в значение переменной
ранее полученный токен;
+ добавить **CI variable** с именем `K8S_API_URL`, поместив в значение переменной
Kubernetes master URL, взятый из вывода команды `kubectl cluster-info`;
+ добавить GitLab Deploy Token: 
  + **Settings -> Repository -> Deploy Tokens**
  + Name: `gitlab-deploy-token`
  + Scopes: read_registry
  + [Create deploy token]
+ _выполнить специфичные для данного оператора действия:_
  + генерацию случайного пароля
    ```sh
    dd status=none if=/dev/urandom count=$(shuf -i 16-32 -n 1) bs=1|base64 -w0 > .vault_pass
    ```
  + создание пространства имён и секрета
    ```sh
    kubectl create ns op-dynns
    kubectl -n op-dynns create secret generic ansible-vault --from-file=.vault_pass
    ```
+ запустить пайплайн (**CI/CD -> Pipelines -> Run pipeline**);
+ убедиться, что оператор задеплоился и работает:
  ```sh
  kubectl -n op-dynns get po -o wide
  kubectl -n op-dynns get metadynns
  kubectl -n op-dynns describe metadynns xpaste
  ```

----

**Далее:** [14.2 CD посредством Helm](helm-deploy.md)

