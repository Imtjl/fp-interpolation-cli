<p align="center">
  <a href="https://github.com/Imtjl/fp-interpolation-cli">
    <picture>
      <img src="resources/logo.png" height="200">
    </picture>
<h1 align="center">
  Лабораторная работа №3<br>
  (CLI-утилита для интерполяции)
</h1>

  </a>
</p>

<p align="center">  
 <a aria-label="Elixir Version" href="https://elixir-lang.org/">
  <img alt="Elixir Version" src="https://img.shields.io/badge/Elixir-1.15.7-purple?style=for-the-badge&labelColor=000000&logo=elixir&logoColor=white">
</a>
<a aria-label="Erlang/OTP Version" href="https://www.erlang.org/">
  <img alt="Erlang/OTP Version" src="https://img.shields.io/badge/Erlang%2FOTP-26.0-red?style=for-the-badge&labelColor=000000&logo=rocket&logoColor=white">
</a>
<a aria-label="Elixir CI" href="https://github.com/Imtjl/fp-interpolation-cli/actions">
  <img alt="Elixir CI" src="https://img.shields.io/github/actions/workflow/status/Imtjl/fp-interpolation-cli/ci.yml?branch=main&style=for-the-badge&logo=github-actions&labelColor=000000&color=teal">
</a>
  <a aria-label="Coverage Status" href="https://coveralls.io/github/Imtjl/fp-interpolation-cli?branch=main">
    <img alt="Coverage Status" src="https://img.shields.io/coveralls/github/Imtjl/fp-interpolation-cli/main?style=for-the-badge&labelColor=000000&logo=coveralls&color=green">
  </a>
</p>
  
<details open>
   <summary><b>Table of Contents</b></summary>

- [Title](#title)
- [Architecture](#arch)
- [Conclusion](#end)

</details>

---

<a id="title"></a>

- Студент: `Дворкин Борис Александрович`
- Группа: `P3331`
- ИСУ: `368090`
- Функциональный язык программирования: `Elixir`

---

<a id="arch"></a>

## Архитектура

Модель акторов используется в модулях `Application`, `InputHandler`,
`LinearInterpolator`, `LagrangeInterpolator` и `OutputHandler`.

- **Supervisor** - это процесс, управляющий другими процессами, называемымми
  `дочерними`, определающий стратегию их перезапуска при сбоях. Например, модуль
  `Application` создаёт и запускает `Supervisor` для ген серверов
  **InputHandler**, **LinearInterpolator**, **LagrangeInterpolator** и
  **OutputHandler** и определяет стратегию `one_for_one` - то есть, если
  дочерний процесс упадёт, то он сразу же будет перезапущен, и только он.

- **GenServer** - это абстракция Elixir для реализации акторов. Это процесс,
  хранящий состояние и обрабатывающий запросы. По принципу своей работы это
  похоже на брокеров сообщений, по типу RabbitMQ или Kafka - по сути, просто луп
  эрланговского процесса, который ждёт сообщение, исполняет релевантный ему код,
  обновляет состояние если нужно и обратно возвращается в ожиданию сообщения.

Таким образом, для CLI она не нужна, т.к. это точка входа, не имеющая состояния,
которое можно было сохранить между вызовами, и оно не требует какого-то
параллельного взаимодействия.

В то время как остальные модули работают в изолированных процессах GenServer и
общаются между собой через асинхронные сообщения `cast` и `call`, что позволяет
избежать блокировки и синхронизации, а также компоненты могут обрабатывать
данные параллельно, независимо друг от друга. Например, OutputHandler может
вводить данные в то время, как InputHandler уже обрабатывает новую порцию
данных. Для другого алгоритма интерполяции можно просто добавить ещё один ген
сервер.

```
+--------------------------------------+
|                CLI                   |
|--------------------------------------|
| Чтение и парсинг ввода               |
| Запуск и настройка компонентов       |
| Передача точек в InputHandler        |
+--------------------------------------+
                    |
                    v
+--------------------------------------+
|           InputHandler               |
|--------------------------------------|
| (GenServer)                          |
| Приём данных и сортировка            |
| Хранение входных точек               |
| Передача точек в LinearInterpolator  |
+--------------------------------------+
                    |
                    v
+--------------------------------------+
|        LinearInterpolator            |
|--------------------------------------|
| (GenServer)                          |
| Линейная интерполяция                |
| Получение точек от InputHandler      |
| Генерация промежуточных точек        |
| Передача результатов в OutputHandler |
+--------------------------------------+
                    |
                    v
+--------------------------------------+
|           OutputHandler              |
|--------------------------------------|
| (GenServer)                          |
| Приём интерполированных данных       |
| Форматирование и вывод результатов   |
+--------------------------------------+
```

<a id="end"></a>

## Вывод

Познакомился с математической моделью акторов, с её реализацией в Elixir,
порадовался как тут всё прикольно, нет проблем с бесконечными блокировками и
синхронизациями, ведь общение между Эрланговскими процессами происходит простыми
сообщениями, как в брокерах сообщений с которыми довелось работать, по типу
RabbitMQ и Kafka. Также интересна работа Супервизора - легко создать и наполнить
ген серверами, и в случае возникновения любого эксепшена не падает всё
приложение, а продолжает работу в штатном режиме. Стратегий супервизора не так
много и легко изучаются, язык прямо сделан для создания хорошей нагруженной
системы. В то же время, модули для работы с потоками I/O предоставляют
достаточно интуитивный и простой интерфейс для работы.
