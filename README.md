# AsIsBackuper

Конфигурируемый скрипт резервного копирования

Архивирует конфигурации указанных компонентов с сохранением структуры директорий, прав

Может выполнять необходимые команды при подготовке бекапов

Создавать выгрузки баз данных, очищать логи.

Опционально выполняет дневной, недельный, месячный срез с сохранением указанного числа копий каждого среза


Весь процесс описывается в конфигурационном файле.

## Вызов:

`./path/to/backup.sh` a|m|w|d

- a - automatic, first day of period as described below
- m - month
- w - week
- d - day

##Формат файла:

/path 	- add to backup
-/path	- remove from backup after coping
D/path	- create an empty directory into backup
!command	- execute a command
*ANY		- execute any string when that char called as second parameter
>/path/|ignore|ignore... - copy path ignoring folders
@archive=/folder/|ignore|ignore|+unignore_inside_ignore