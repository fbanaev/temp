### Оглавление

* [1. pod](1.pod/README.md)
* [2. replicaset](2.replicaset/README.md)
* [3. deployment](3.deployment/README.md)
* [4. resource and probes](4.resources-and-probes/README.md)
* [5. configmap](5.configmap/README.md)
* [6. secret](6.secret/README.md)
* [7. service](7.service/README.md)
* [8. ingress](8.ingress/README.md)
* [9. pvc](9.pvc/README.md)


## Все работы проводим из админбокса по адресу sbox.slurm.io

Публичный ключ с админбокса (sbox.slurm.io) уже добавлен в Gitlab.

Если необходимо, то можете добавить свой публичный SSH ключ в Gitlab.
Для этого заходим в [Gitlab](https://gitlab.slurm.io).
В правом верхнем углу нажимаем на значок своей учетной записи.
В выпадающем меню нажимаем Settings.
Дальше в левом меню выбираем раздел SSH Keys и в поле ```Key``` вставляем свой ПУБЛИЧНЫЙ SSH ключ.

Клонируем репозиторий Slurm в свой админбокс
```bash
git clone git@gitlab.slurm.io:tinkoff/slurm.git
```





