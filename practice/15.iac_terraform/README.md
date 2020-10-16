# Infrastructure as Code (Terraform, Packer)

На этой лекции мы ознакомимся с понятием и основными принципами "инфраструктуры как кода",
а также проведём практическую работу с Terraform и Packer.

## Pre-flight Checks

Для того, чтобы убедиться в наличии доступа к учебной инфраструктуре, следует:

+ зайти по SSH на узел **devbox** и проверить версии необходимых утилит:
  ```sh
  ssh devbox.slurm.io -l <YOUR_LOGIN>

  terraform --version
  # Terraform v0.12.19
  packer --version
  # 1.5.1
  ```
+ склонировать репозиторий с практикой (на devbox) **или** обновить его, если уже склонирован
  ```sh
  git clone git@gitlab.slurm.io:tinkoff/slurm.git
  # OR
  cd ~/slurm
  git checkout master
  git pull
  ```
+ склонировать репозиторий с приложением xpaste
  ```sh
  git clone git@gitlab.slurm.io:tinkoff/xpaste.git
  ```

## Содержание практики

+ [15.1 Основы работы с Terraform](docs/TF_BASE.md)
+ [15.2 Работа с Packer](docs/PACKER.md)
+ [15.3 Terraform - приемы](docs/TF_METHODS.md)

