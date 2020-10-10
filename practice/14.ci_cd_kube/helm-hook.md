# Helm hooks

Познакомимся с _Helm hooks._

### Task II

Для того, чтобы Helm в случае неудачного деплоя показывал некоторую диагностическую информацию, применим специальный Job:

+ скопировать нужный helm template в каталог с шаблонами
```sh
cp -v .sump/hooklog.yaml .helm/templates/
```
+ добавить в **.gitlab-ci.yml** необходимые для работы job'а команды и параметры
```diff
deploy:app:
+  after_script:
+    - test -f ".helm/templates/hooklog.yaml" || exit 2
+    - kubectl -n $CI_ENVIRONMENT_SLUG logs -lcomponent=atomiclog --tail=-1
+    - kubectl -n $CI_ENVIRONMENT_SLUG delete job -lcomponent=atomiclog
  extends: .env
...
        --set env.DB_PASSWORD="$PG_DB_PASSWORD"
+        --set atomicSAName=atomiclog
        --atomic
        --timeout 40s
```
+ задеплоить;
+ внести правки согласно полученной информации; <!-- Уменьшить реквесты и лимиты в .helm/values.yml -->
+ задеплоить;
+ :loop: повторять до получения положительного результата. <!-- Заменить /deleteme на / в .helm/templates/deployment.yaml -->

