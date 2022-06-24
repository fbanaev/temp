# Ansible: IaC
## Форк и клонирование 2-х репозиториев
### Fork
+ Зайти в проект https://gitlab.slurm.io/tinkoff/ansible-inventory ;
  + справа вверху нажать кнопочку 'Fork';
  + на следующей странице выбрать свою группу (`g******`).
+ повторить то же самое для https://gitlab.slurm.io/tinkoff/terraform-inventory
+ удалить старый форк **xpaste**, затем форкните и его
### git clone
Склонировать на devbox репозитории (**Clone with SSH**!)
+ свой форк **ansible-inventory**
+ свой форк **terraform-inventory**
+ свой форк **xpaste** (если ещё не сделано)

**[devbox.slurm.io]**
```sh
cd ~
git clone <ansible-inventory>
git clone <terraform-inventory>
git clone <xpaste>
```
## Развёртывание тестовой площадки через terraform
```sh
cd ~/terraform-inventory/slurm
vim secret.tfvars # Указать данные своего аккаунта Selectel
terraform init
terraform apply -var-file="secret.tfvars"
terraform output -state=terraform.tfstate ansible_inventory > ~/ansible-inventory/slurm/hosts/main
```
### Получение доступа к тестовой площадке по ssh
```sh
eval `ssh-agent`
ssh-add
ssh-add -l
ssh-keyscan -t rsa <bastion_host_floatingip_address> >> ~/.ssh/known_hosts
ssh -lroot -A <bastion_host_floatingip_address>
```
**После перелогина на сервер (devbox.slurm.io) по ssh нужно снова запускать** ``eval `ssh-agent` && ssh-add``
## Настройка Ansible
Создать virtualenv и установить ansible _(длительная операция)_

**[devbox.slurm.io]**
```sh
cd ~/ansible-inventory
virtualenv-3.6 ~/venv-ansible
source ~/venv-ansible/bin/activate
pip3 install -r requirements.txt
```

**Ξ**

Настроить шифрование sensitive data
```sh
pwgen 20 1 > ~/.vpasswd
cat ~/.vpasswd
cd ~/ansible-inventory
ssh-keygen -t ed25519 -N '' -f files/deploy_key/id_ed25519
ansible-vault encrypt files/deploy_key/id_ed25519
ansible-vault view files/deploy_key/id_ed25519
```
### GitLab user key
Добавить содержимое `files/deploy_key/id_ed25519.pub` своему пользователю
- **<Верхний правый угол> -> Settings -> SSH keys**
### GitLab runner token
- `<MY_GITLAB_GROUP_TOKEN>` брать в GitLab'е (Groups -> <g*****> -> Settings -> CI/CD -> Runners -> Set up a group Runner manually)
```sh
ansible-vault encrypt_string <MY_GITLAB_GROUP_TOKEN>
vim slurm/hosts/group_vars/runners.yml # Отредактировать переменную runner_reg_token
```
- При вставке зашифрованного токена 
  - перевести **vim** в режим вставки и включить визуальное отображение концов строк:
```
:se listchars=trail:+,eol:$
:se list
:se paste
```
  - убедиться, что в конце строк не вставились **лишние пробелы**.
## Run site.yml
Подтянуть необходимые роли и запустить плейбук
```sh
ansible-galaxy install -r requirements.yml --force
ansible-playbook --diff site.yml -i slurm/hosts
```

**Ξ**

После прохода плейбука пойти в **<Группа> -> Settings -> CI/CD -> Runners** и проверить регистрацию раннеров
## Bootstrap
### SSH
**[bastion]**
```sh
sudo -iu gitlab-runner
echo "<YOUR_VAULT_KEY>" > ~/.vpasswd # Брать его в выводе `cat ~/.vpasswd` (предыдущий блок)
```
**[devbox.slurm.io]**
```sh
ansible-playbook --diff bootstrap.yml -i slurm/hosts
git add slurm/hosts/main slurm/hosts/group_vars/runners.yml files/deploy_key
git commit -m 'Try ro run pipeline'
git push
```
Пойти в "Pipelines" проекта **ansible-inventory** и посмотреть на результат.

**Ξ**

## Periodic run
+ **ansible-inventory -> CI/CD -> Schedules**
+ [New schedule]
+ Description: `ansible-persist`
+ Custom: `0 * * * *`
# Ansible: deploy
## GitLab Variables
Поместить в GitLab CI/CD Variables проекта **xpaste** следующие значения:
+ `SECRET_KEY_BASE` -- нагенерить произвольную строку;
+ взять значения из **ansible-inventory/slurm/hosts/group_vars/db.yml**
  + `TEST_DB`
  + `TEST_DB_PASSWORD`
  + `PROD_DB`
  + `PROD_DB_PASSWORD`
## CI file
```
cd ~/xpaste
cp -iv .gitlab-ci.yml.ansible.bak .gitlab-ci.yml
git add .gitlab-ci.yml
git commit -m 'CI file added'
git push
```
Пойти в "Pipelines" проекта **xpaste** и посмотреть на выполнение.

После завершения пайплайна зайти на IP балансера и посмотреть на работу приложения
## Broken deploy
```sh
cd ~/xpaste
vim ansible_rolling.yml ; Закомментировать строку 'RAILS_ENV: production'
git add ansible_rolling.yml
git commit -m 'Break a puma'
git push
```
После падения шага rolling update (т.е. неудачи обновления) убедиться, что приложение продолжает работать на **puma-2**
# Ansible: Pacemaker + PostgreSQL cluster
```sh
cd ~/terraform-inventory/slurm
vim secret.tfvars # db_count = "3"
terraform apply -var-file="secret.tfvars"
terraform output -state=terraform.tfstate ansible_inventory > ~/ansible-inventory/slurm/hosts/main
```
```sh
cd ~/ansible-inventory
ansible-playbook --diff bootstrap.yml -i slurm/hosts
```
```sh
vim slurm/hosts/pgcluster # Раскомментировать всё
git add slurm/hosts/main slurm/hosts/pgcluster
git commit -m 'pg 3 nodes'
git push
```
Дождаться завершения пайплайна. Зайти на pg-1 и посмотреть на пустой кластер:
```sh
pcs cluster status
pcs status
```
Затем выполнить:
```sh
ansible-playbook --diff pg_cluster.yml -i slurm/hosts
```
```sh
ssh pg-1
crm_mon -Afr
```
Дождаться, пока слейвы покажут `STREAMING|ASYNC`

**[devbox.slurm.io]**
Перенастроить pgbouncer'ы на виртуальный IP кластера
```sh
cd ~/ansible-inventory
vim slurm/hosts/group_vars/runners.yml # Поменять deploy_db_host на 172.16.100.100
git add slurm/hosts/group_vars/runners.yml
git commit -m 'Set deploy_db_host to cluster virtual IP'
git push
```
Починить и передеплоить приложение
```sh
cd ~/xpaste
vim ansible_rolling.yml # Раскомментировать строку 'RAILS_ENV: production'
git add ansible_rolling.yml
git commit -m 'Repair puma env'
git push
```
## Pacemaker + PostgreSQL failover
```sh
ssh pg-1
poweroff
ssh pg-2
crm_mon -Afr
```
Подождать промоута несколько секунд и убедиться (в браузере), что приложение работает (например, сохранить пасту).
## Ввод в кластер зафейленого мастера (вручную)
**[devbox.slurm.io]**

Включить ВМ обратно (через terraform)
```sh
cd ~/terraform-inventory/slurm
terraform apply -var-file="secret.tfvars"
```
```sh
ssh pg-1
rm /var/lib/pgsql/11/tmp/PGSQL.lock
/srv/southbridge/bin/pgsql-pcmk-slave-copy.sh
pcs resource cleanup PGSQL
crm_mon -Afr # Убедиться, что нода вернулась как слейв
```
<!--
## Terraform remote backend
**[devbox.slurm.io]**

Раскомментировать описание pg backend и заменить строку `<bastion_host_floatingip_address>` на свой bastion_host_floatingip_address;
затем выполнить перенос стейта в удалённый бэкенд:
```sh
cd ~/terraform-inventory/slurm
vim main.tf
terraform init
```
Запушить изменённый **main.tf** в репозиторий
```sh
git add main.tf
git commit -m 'Enable pg backend'
git push
```-->

----
<!--
## Technical notes
+ Install following packages on devbox: `python3-pip python36-virtualenv libselinux-python3`
+ Don't install **ansible** and **mitogen** packages on devbox
+ Don't create **~/.ansible.cfg**
-->
