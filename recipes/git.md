# Git

## Новая ветка
1. переключаемся в main - `git checkout main`
2. обновляем локальную версию ветки `main` - `git pull origin main`
3. создаём новую ветку - `git checkout -b branch_name`

#### Название ветки (branch_name)
`feature/PAYMENTS-123_description`

- `feature` - это у нас будет константа. Может быть `fix`/`hotfix`/e.t.c
- `PAYMENTS` - это пространство имён задачи (название доски в tracker-е), у нас будет всегда константа.
- `123` - это номер задачи из tracker-а
- `description` - краткое описание о чём задача
