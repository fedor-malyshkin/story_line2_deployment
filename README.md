# Код развёртывания/конфигурирования проекта

При определении того, как образом будет организовано развёртывание проекта необходимо было решить следующие вопросы:

1. Как реализовать организовано развёртывание проекта таким образом, что бы максимально повторно использовать средства те же самые скрипты/средства автоматизации/скрипты для разврётывания всех видов стендов? Т.е. обеспечить их схожесть.
1. Как обеспечить развёртывание стендов в максимально короткие сроки (избегая повторного создания двоичных артефактов на машинах для их развёртывания)
1. Как организовать развёртывание «development» / «test» стэндов с текущими артефактами (возможно SNAPSHOT), а на «production» - стэнде с указанными версиями?

В итоге были сформулированы следующие требования:

1. повторное использование скриптов (с минимальными отклонениями для видов стенда)
1. «production» – версии артефактов из конфига
1. «development» / «test» - версии артефактов из ветки
1. отсутствие исходных кодов на «production»-стэнде, только готовые артефакты

### Основные средства автоматизации
- [gradle](http://gradle.org/) для оркестрации
- [docker-compose](https://docs.docker.com/compose/) для управления группой контейнеров
- [docker](https://docs.docker.com/) (один контейнер на сервис) для стендов test/development
- [puppet](https://puppet.com/) (для управления конфигурациями и структурой ОС внутри контейнера)

## О структуре проекта
- "docker_template" - шаблоны с файлами конфигурации для Docker'a
- "puppet_config" - конфигурационные файлы puppet, замена которых происходит на сервере
- "modules" - puppet-модули для подготовки сервера, развртывания инфраструктуры и компонентов проекта
- "production" - production-специфичные скрипты, БД Hiera и `sites.pp`
- "test" - test-специфичные скрипты, БД Hiera и `sites.pp`
- "development" - development-специфичные скрипты, БД Hiera и `sites.pp`
- "teststand" - специфичные скрипты для тестового стенда, БД Hiera и `sites.pp`
- provision_development.sh - provision-код для production-сегмента (должен запускаться на периодичной основе на сервере)
- provision_production.sh - provision-код для production-сегмента (должен запускаться на периодичной основе на сервере)
- provision_test.sh - provision-код для  тестового сегмента (должен запускаться на периодичной основе на сервере)
- provision_teststand.sh - provision-код для  тестового стенда (должен запускаться на периодичной основе на сервере)

## О версионности
Касательно версий, используемых при сборке стендов необходимо отметить, что для минимизации количества конфигурационных файлов все параметры, касающиеся версий собраны в файлах yaml `%{environment}/hieradata/version.yaml`

## О стендах
### О всех видах стендов
- существует несколько видов стэнда:
	* development - стенд для разработки в котором всё ПО запускается вручную, кроме
	инфраструктурных компонентов
	* test - стенд для тестирования в котром все компоненты запускаются в полном
	объеме, но стенд "заточен" под задачи тестирования
	* production - полностью продуктивный стэнд (задачи gradle не используются)
- инициализация сборки стенда осуществляется с помощью задач gradle-скрипта
("build_scripts/build-tasks.gradle")
- имена контейнеров полностью совпадают с именами проектов!
- все приложения запускаются в виде служб, управляемых демоном-супервайзером "monit"
- предварительно (всё в будущей рабочей директории):
	2. `apt-get update && apt-get -y install git`
	2. генерируем ключ (лучше побольше) `ssh-keygen -t rsa -b 4096 -C "your_github_email_account@example.com"`
	2. Внедряем публичную часть созданного ключа в GITHUB (собственно копируем и вставляем в REPO Repository->Settings->Deploy Keys, дав ключу вменяемое название, - к примеру имя CI системы и хоста на котором она работает)
	2. внести соответствующие правки в /home/deploy-user-name/.ssh/config:
	```
	Host REPO_NAME.github.com
	    Hostname github.com
	    user git
		IdentitiesOnly yes
	    IdentityFile ~/.ssh/id_rsa.<reponame>
	```
	2. `chmod 600 ~/.ssh/config` !!!
	2. `git clone REPO_NAME.github.com:fedor-malyshkin/story_line2_deployment.git .`
	2. Добавляем host key (и проверяем работоспособность) под учткой пользователя: `ssh -T REPO_NAME.github.com`
	(в случае работы через удалённую консоль -- делаем аводобавление `ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts`)
	2. читаем [ссылку 1](https://help.github.com/articles/connecting-to-github-with-ssh/)
	2. читаем [ссылку 2](https://developer.github.com/guides/managing-deploy-keys/#managing-deploy-keys)

### О "test"/"development"
- подготовка стенда осуществляется с помощью `gradle prepareStand`
- стенд представляет собой коллекцию docker-контейнеров
- все параметры скриптов считываются из нескольких конфигурационных файлов,
используемых в зависимости от типа стенда (development/test)
- важное замечание: запуск самих контейнеров осуществляется с помощью docker - как следствие должны осуществляться с надлежащими полномочиями.

Последовательность шагов:
1. Определяется тип стенда (тип стенда по-умолчанию (development) может быть переопределён параметром к скрипту `gradle -Pproject.ext.stand_type=test`)
1. Читается конфигурационный файл `%{environment}/docker.properties`
1. Создается каталог для стенда и данных
1. Копируется содержимое каталога "docker_templates" с подстановкой значений из `docker.properties``
1. формируются Dockerfile для контейнера (с учетом параметров)
1. при указании версии компонента в виде "presented" собранный артифакт
копируется в папку '{docker_cont}/artifacts'
1. запускается docker-compose (данные в `docker-compose.yml`), осуществляется запуск контейнера (docker 'ENTRYPOINT')
1. Осуществляется запуск тестов (для test-стэнда)

### О "production"
__TODO__: *вопрос публикации Android-приложения не освещён*

- Самый сложный (и важный) вид развртывания - т.к. фактически происходит обновление серверной части приложения в которой должны обновляеться и корректно запускаться:
 - исполняемые модули
 - конфигурационные файлы
 - инфраструктырные компоненты
- стенд представляет собой фактический сервер на котором работает продуктивная система
- ключевым файлом процесса является файл с данными о версиях компонентов (`%{environment}/hieradata/version.yaml`) - именно он определяет какие артефакты будут скачиваться при конфигурировании средствами puppet

#### О "production". Настройка среды разработки
Особых требований по развёртыванию нет, однако надо очень аккуратно осуществлять commit'ы - т.к. каждый commit фактически запускает все виды тестов на сервер CI с последующей сменой метки `latest`, что вызовет обновление каталогов на продуктивном сервере с возможным запуском обновления конфигурации.

#### О "production". Настройка сервера CI
При commit в данную в данный проект (а так же может периодически) запускаются все виды тестов с последующей сменой метки `latest` (при их успешном прохождении)

#### О "production". Настройка серверной части
На продуктивном сервере настроено:
- на периодической основе:
 2. выполняется проверка SHA1 удалённой ветки репозитария 'story_line2_deployment' с меткой 'latest' с текущей версией - при различии выполняется `git pull` (при котрой получаеются puppet-скрипты, шаблоны конфигурационных файлов, БД Hiera с данными и главное файл с данными о версиях)
 2. выполняется `puppet apply` (через соотвествующий командный файл "provision_production.sh") (в рамках котрого при необходимости обновляются конфигурационные файлы, обновляются исполняемые модули (скачиваются из репозитария), перезапускаются службы, выполняются прочие изменения)
