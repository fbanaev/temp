# Основы GitLab CI/CD

[[_TOC_]]

## Содержание

+ [12.1. Настройка gitlab-runner](gitlab-runner.md)
+ [2. Настройка GitLab CI/CD](gitlab-ci.md)
+ [3. Шаблоны GitLab CI/CD](gitlab-ci-include.md)

## SSH login

Для выполнения практики нам понадобится SSH доступ на узлы **sandbox** и **xpaste**:
```sh
ssh sandbox
```
и, в другой консоли
```sh
ssh xpaste
```

## Форк проекта xpaste (если ещё не сделан)

+ Зайти в проект https://gitlab.slurm.io/tinkoff/xpaste ;
  + справа вверху нажать кнопочку 'Fork';
  + на следующей странице выбрать свою группу (`g******`).
+ Склонировать **свой форк** проекта xpaste на devbox или локалхост --
по желанию, как вам удобнее работать (используя схему **ssh://**)

