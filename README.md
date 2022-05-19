

## Описание, согласно критериям
1. Наличие ТЗ: 
2. ТЗ, оформленное в XML, корректное относительно DTD:
3. ER диаграмма модели предметной области: 
4. Тестовые данные: 
5. Инструкция по использованию находится в ТЗ. Полное описание можно прочитать ниже.


# Энскгортранс

Вы делаете базу данных для оператора общественного транспорта в небольшом, но весьма продвинутом в транспортном отношении городе.

### Транспортные средства
В Энскгортрансе (сокращённо ЭГТ) используются разнообразные транспортные средства: автобусы, троллейбусы и трамваи. У каждого транспортного средства (ТС) есть бортовой номер-идентификатор, год его выпуска, актуальное состояние -- значение из конечного множества <<исправен>>, <<некритические неисправности>>, <<требует ремонта>> -- и модель ТС. 

Модель транспортного средства включает, прежде всего, название типа ТС (автобус, троллейбус, трамвай, ТУАХ, электробус), название модели, определяемое производителем (<<ПКТС-6281 «Адмирал»>>), вместимость в количестве пассажиров.


### Остановки и маршруты

В вашем городе есть некоторое множество остановок ОТ. У каждой остановки есть персональный номер и адрес, записываемый в довольно произвольном виде (например, <<перекрёсток улиц Ленина и Николая Второго>>) и количество платформ -- мест для размещения одного ТС. Платформы одной остановки пронумерованы начиная с 1.

Вы определяете маршруты ТС. У маршрута есть уникальный номер, известный пассажирам, тип ТС, который его обслуживает, остановка, условно называемая начальной и условная конечная остановка. В реальности ТС ходят по маршруту туда-сюда и вполне могут двигаться в обратном направлении, от <<конечной>> остановки к <<начальной>>.

Ваш транспорт ходит по расписанию, которое тоже хранится в базе и показывается пассажирам на вашем сайте. В расписании написано с точностью до минуты, в какой момент времени ТС какого маршрута должен прибыть на ту или иную остановку и к какой платформе должен подъехать. ТС стоит у платформы одну минуту, и разумеется никакое другое ТС в это время у этой платформы стоять не может. 

**UPD 2021-10-18**

Для рабочих и выходных дней расписания одного маршрута могут быть разные, но больше дни никак не различаются.

### Выпуск ТС на маршруты

В каждый конкретный день вы составляете так называемые наряды на работу. Это задание какому-то конкретному ТС следовать в этот день по заданному маршруту, начиная с заданной остановки в указанное время. Выполнять наряд назначается водитель, от которого нам интересно ФИО и номер его служебного удостоверения. 

Диспетчерская следит за выполнением наряда при помощи GPS и записывает, в какое время исполнитель того или иного наряда действительно прибыл на ту или иную остановку.

**UPD 2021-10-25**

### Билеты и статистика перевозок
У вас есть некоторый ассортимент вариантов оплаты поездок -- билетное меню. В каждом пункте меню записано его название (<<пересадочный билет на 90 минут>>, <<беспересадочный билет на 15 минут>>, etc.) и стоимость. Пассажиры, заходя в салон ТС валидируют свои билеты. Информация о валидациях обрабатывается в онлайн-режиме некой сторонней системой, а вы же в конце работы каждого наряда записываете, сколько валидаций каждого типа билетов было сделано за время работы. Потом эта статистика используется для анализа пассажиропотоков и доходов. 

**Дополнение №3 от 2021-11-01**
### Сбор фидбека о маршрутах и остановках

Для анализа того, как используются ваша маршрутная сеть и остановки, вы запускаете очень крутую систему сбора фидбека от ваших пользователей, называемую далее Аннушка. Пассажиры могут, используя мобильное приложение Аннушки со встроенным голосовым помощником, оставлять голосовые комментарии о том, как они взаимодействуют с транспортом, почему они садятся на той или иной остановке, какая цель перемещения, долго ли им добираться до точки назначения от той остановки, где они выходят, и так далее. Могут фотографировать остановки и транспорт. 

Аннушка всё это собирает, анализирует с помощью ML бекендов и ассоциирует с пользователем и остановкой или маршрутом, которыми он воспользовался, вектор признаков (feature vector), состоящий из пар ключ-значение. Текстовые ключи -- это названия свойств, выявленных в сообщениях пользователя, например "время до остановки", "удобная платформа", "быстрая пересадка", "USB разъёмы работают". Множество ключей не предопределено, и ML бекенды могут со временем выявлять новые свойства в пользовательском фидбеке.  Значения свойств бывают текстовые, численные, булевские и URL-адреса. Кроме этого, записывается и момент времени, когда пользователь передал сообщение, из которого был извлечён вектор признаков.
 
С каждым вектором признаков ассоцируются также бекенды, куда его нужно направить для дальнейшей обработки. Эти бекенды выдают рекомендации по улучшению сервиса. От бекендов нас интересует только их название и краткое описание.

Аутентификация пользователей происходит на стороннем сервисе, от которого вы получаете только анонимизированный 8-байтовый уникальный номер пользователя, дату его регистрации в Аннушке и номер версии мобильного приложения.

**Дополнение №4 от 2021-11-01**
### Как пройти в библиотеку

Вы хотите сделать удобный сервис, показывающий, как пройти к достопримечательностям или общественным местам (назовём их POI --Point Of Interest) от остановок общественного транспорта.

У вас есть каталог POI, где записан адрес точки, её тип (это собор, бассейн, библиотека  или что-то ещё), название и URL фотографии. Для каждой точки имеется список ближайших остановок ОТ, с указанием, сколько минут идти пешком от остановки до POI, есть ли на пути преграды, создающие помехи маломобильным пассажирам, и сколько раз на пути нужно перейти через автомобильную дорогу. 


Для каждой такой пары из POI и остановки вы записываетеежедневную статистику, собираемую сторонними сервисами, о том, сколько человек воспользовалось остановкой, чтоб добраться до точки.

## App

**Дополнение №5 от 2021-11-15**
### Основные свойства маршрута

Необходимо реализовать API метод, возвращающий JSON с основными свойствами маршрутов.

**Путь**:  `/route/info` 
**Аргументы** `route: number` -- номер маршрута, опциональный 
**Пример запроса** `/route/info?route=31`
**Структура ответа**
Если в запросе указан аргумент `route`, то в ответе должна быть информация только об указанном маршруте
```
[
{
  "route": 31, // номер маршрута
  "rolling_stock_type": "троллейбус", // тип транспортных средств на маршруте
  // Условная начальная остановка маршрута
  "start": {
    "address": "Северная площадь",
    "stop_num": 4321
  },
  // Условная конечная остановка маршрута
  "finish": {
    "address": "пр. Добролюбова",
    "stop_num": 4334
  }
},
{
  "route": 6,
  "rolling_stock_type": "трамвай",
  "start": {
    "address": "ул. Кораблестроителей",
    "stop_num": 5267
  },
  "finish": {
    "address": "пл. Ленина",
    "stop_num": 7612
  }
},
]
```

**Дополнение №6 от 2021-11-17**
### Отображение расписания движения

API метод, возвращающий JSON с информацией о расписании движения ТС по данному маршруту

**Путь**:  `/schedule/info` 
**Аргументы** `route: number` -- номер маршрута, обязательный. `weekend: boolean` -- флаг, указывающий на то, требуем ли мы расписание выходного дня или буднего.
**Пример запроса** `/schedule/info?route=31&weekend=true`
**Структура ответа**
В ответе должно быть время начала первого и последнего рейсов, и последовательность остановок на маршруте, соответствующая первому рейсу, в порядке от начальной до конечной остановки.
```
{
  "route": 31, // номер маршрута
  "first_trip_start": "06:00",
  "last_trip_start": "23:10",
  "stops": [
    {
      "address": "Северная площадь",
      "stop_num": 4321      
    },
    {
      "address":  "Гражданский проспект, 90",
      "stop_num": 4322
    }
  ]
}
```

**Дополнение №7 от 2021-11-22**
### Суммарное количество валидаций

API метод, возвращающий JSON с информацией о суммарном количестве валидаций билетов каждого типа из билетного меню и суммарной их стоимости. 

**Путь**:  `/fares/stats` 
**Структура ответа**
```
[
{
  "tite": "Беспересадочный билет на 15 минут", // название билета из меню
  "total_validations": 0, // суммарное количество валидаций
  "total_price_sum": 0 // суммарная стоимость валидированных билетов
},
{
  "tite": "Пересадочный билет на 90 минут",
  "total_validations": 100500,
  "total_price_sum": 5025000
}
// и так далее
]
```

Код должен брать информацию из представления, не производя никаких действий, кроме перекладывания данных из одной структуры в другие.

Далее, необходимо изменить схему БД так, чтобы записывать каждую конкретную валидацию (ранее это учитывалось в отдельной системе, но теперь будет учитываться у нас). При каждой валидации нужно записывать её время, тип билета и ссылку на наряд во время работы которого произошла валидация. Представление нужно изменить так, чтобы код приложения был работоспособен без изменений.

Код представления, изменения схемы БД и изменённого представления нужно записать в файл `src/main/sql/task7.sql`


**Дополнение №8 от 2021-11-23**
### Количество смен, отработанных водителем

API метод, возвращающий JSON с информацией о суммарном количестве смен, отработанных каждым водителем

**Путь**:  `/staff/workload` 
**Аргументы**
`id: text|number`: -- номер служебного удостоверения водителя, опциональный

**Структура ответа**
Если номер удостоверения указан, выводится информация только об указанном водителе. Иначе выводится информация обо всех водителях.

```
[
{
  "name": "Константинопольский Константин Вениаминович", // ФИО водителя
  "id": "12345688", // номер удостоверения
  "shift_count": 42 // суммарное количество отработанных смен
},
{
  "name": "Ким Ким Кимович", 
  "id": "87654321", 
  "shift_count": 39 
},
// и так далее
]
```

Код должен брать информацию из представления, не производя никаких действий, кроме перекладывания данных из одной структуры в другие.

Далее, необходимо изменить схему БД. Мы подразумевали, что смены работы ТС и водителя одинаковые, но теперь решили что это не так. Пусть одной смене работы ТС может соответствовать  несколько смен водителей (они будут днём меня ь друг друга где-то на конечной остановке). Нужно внести изменения в схему БД и изменить представление так, чтобы код приложения был работоспособен без изменений.

Код представления, изменения схемы БД и изменённого представления нужно записать в файл `src/main/sql/task8.sql`
