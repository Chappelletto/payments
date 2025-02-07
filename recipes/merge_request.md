# MergeRequest

## Создание
- Нужно запушить код из своей ветки в gitlab.
- В gitlab открываем вкладку [`Merge requests`](https://gitlab.com/Chappelletto/payments/-/merge_requests)
- Жмём большую синюю кнопку `New merge request` (вверху, справа)
- Выбираем `source branch` ту ветку, куда ты запушил
- Target branch всегда `main`
- `Compare branched and continue`
- Указываем title - `[PAYMENTS-123]: description` (123 - это номер твоей задачи, description - это краткое описание по русски)
- Assignie - указываешь себя (это формальность, но пусть будет)
- Проверь, что стоит галочка `Delete source branch when merge request is accepted.` (она должна ставиться сама)
- `Create Merge Request`

## Добавление новых коммитов
Просто пушиш в эту ветку

## Принятие MR
Ты этим не занимаешься, это делает лид

## Код и комменты
- они будут на главной странице MR-а
- или во вкладке `changes`

## Общие рекомендации
- Старайся разбивать правки на коммиты по смыслу
