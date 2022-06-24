# Include в GitLab CI/CD

[[_TOC_]]

В GitLab есть возможность подключать yml как локально,
так и из удаленных репозиториев. Для этого используется объект `include`.

## Пример

Для примера подключим в **.gitlab-ci.yml** задания для проверки синтаксиса YAML и ansible.

+ После объекта `workflow` вставить
```yaml
include:
  - project: tinkoff/ci-templates
    ref: master
    file: /ansible_lint.tmpl.yml
```
+ commit, push;
+ исправить ошибки синтаксиса;
+ commit, push.

