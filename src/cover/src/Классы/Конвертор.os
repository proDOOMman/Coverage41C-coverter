#Использовать v8metadata-reader

Перем _ПолучениеПоддержки;
Перем _УровеньПоддержки;
Перем _ГенераторПутей;

Перем Лог;
Перем ДанныеКонфигурации;
Перем ДанныеОбработок;
Перем ПолеДанныеПокрытия;
Перем ПутьКФайлуКонфигурации;

Процедура ПриСозданииОбъекта()

	ПолеДанныеПокрытия = Новый ДанныеПокрытия();
	_УровеньПоддержки = 1;

КонецПроцедуры	

Процедура ПодготовитьЛог(ЛогДляРазбора, ИмяРасширения) Экспорт

	json = Новый ЧтениеJSON();
	json.ОткрытьФайл(ЛогДляРазбора);
	Лог = ПрочитатьJson(json);
	json.Закрыть();
	
	ПолеДанныеПокрытия.РазобратьЛог(Лог, ДанныеКонфигурации, ДанныеОбработок, ИмяРасширения);

КонецПроцедуры	

Процедура УстановитьФайлКонфигурации(ВхПутьКФайлуКонфигурации) Экспорт

	ПутьКФайлуКонфигурации = ВхПутьКФайлуКонфигурации;
	ДанныеКонфигурации = Новый ДанныеКофигурации(ПутьКФайлуКонфигурации);
	ДанныеОбработок = Новый ДанныеОбработок(ПутьКФайлуКонфигурации);

КонецПроцедуры	

Процедура СохранитьРезультат(КаталогРезультатов) Экспорт

	СохранитьВGenericCoverage(КаталогРезультатов);

КонецПроцедуры	

Процедура СохранитьВGenericCoverage(КаталогРезультатов)

	ФайлРезультата = "/genericCoverage.xml";
	КоличествоСтрок = 0;
	КоличествоСтрокПокрыто = 0;
	ПутиКИсходникам = ПутьКФайлуКонфигурации;
	Если СтрНачинаетсяС(ПутьКФайлуКонфигурации, "./") Тогда
		ПутиКИсходникам = ТекущийКаталог() + Сред(ПутьКФайлуКонфигурации, 2);
	КонецЕсли;	

	_ГенераторПутей = Новый Путь1СПоМетаданным(ПутиКИсходникам);


	Если ДанныеКонфигурации.ЭтоПроектEDT Тогда
		путьКФайлуПоддержки = ОбъединитьПути( ПутиКИсходникам, "Configuration", "ParentConfigurations.bin" );
	Иначе
		путьКФайлуПоддержки = ОбъединитьПути( ПутиКИсходникам, "Ext", "ParentConfigurations.bin" );
	КонецЕсли;
	
	Если ВыгрузкаКонфигурации.ФайлСуществует(путьКФайлуПоддержки ) Тогда
		_ПолучениеПоддержки = Новый Поддержка(ПутиКИсходникам);
		всеФайлыКПокрытию = _ПолучениеПоддержки.ВсеФайлы(_УровеньПоддержки + 1, "+");
	Иначе
		всеФайлыКПокрытию = Новый Массив;
		МассивИсходников = НайтиФайлы(ПутиКИсходникам, "*.bsl", Истина );
		Для каждого ФайлИсходногоКода из МассивИсходников Цикл
			всеФайлыКПокрытию.Добавить(ФайлИсходногоКода.ПолноеИмя);
		КонецЦикла;
	КонецЕсли;

	ЗаписьXML = Новый ЗаписьXML();
	ЗаписьXML.ОткрытьФайл(КаталогРезультатов + ФайлРезультата);
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	ЗаписьXML.ЗаписатьНачалоЭлемента("coverage");
	ЗаписьXML.ЗаписатьАтрибут("version", "1");

	_ТаблицаПокрытыхСтрок = Новый ТаблицаЗначений;
	_ТаблицаПокрытыхСтрок.Колонки.Добавить("Путь");
	_ТаблицаПокрытыхСтрок.Колонки.Добавить("ПокрытыеСтроки");

	Для Каждого Модуль Из ПолеДанныеПокрытия.Результат Цикл
	
		Если ПустаяСтрока(Модуль.Значение.Путь) Тогда
			Продолжить;
		КонецЕсли;

		Если ЗначениеЗаполнено(всеФайлыКПокрытию) 
			И всеФайлыКПокрытию.Количество() > 0 
			И всеФайлыКПокрытию.Найти(ПутиКИсходникам + Модуль.Значение.Путь) = Неопределено Тогда
				Продолжить;
		КонецЕсли;

		новСтрока = _ТаблицаПокрытыхСтрок.Добавить();
		новСтрока.Путь = ПутиКИсходникам + Модуль.Значение.Путь;
		ПокрытыеСтроки = Новый Соответствие;
		Для Каждого СтрокаМодуля Из Модуль.Значение.Строки Цикл
			ПокрытыеСтроки.Вставить(Число(СтрокаМодуля), Истина);
		КонецЦикла;
		новСтрока.ПокрытыеСтроки = ПокрытыеСтроки;

	КонецЦикла;

	Для каждого ФайлКПокрытию из всеФайлыКПокрытию Цикл

		ЗаписьXML.ЗаписатьНачалоЭлемента("file");

		ЗаписьXML.ЗаписатьАтрибут("path", ФайлКПокрытию);
	
		_ТаблицаПокрытия = Новый ТаблицаЗначений;

		_ТаблицаПокрытия.Колонки.Добавить("Номер");
		_ТаблицаПокрытия.Колонки.Добавить("Покрыто");

		НайденнаяСтрокаПокрытыхСтрок = _ТаблицаПокрытыхСтрок.Найти(ФайлКПокрытию, "Путь");
		Если НЕ ЗначениеЗаполнено(НайденнаяСтрокаПокрытыхСтрок) Тогда
			покрытыеСтроки = Новый Соответствие;
		Иначе
			покрытыеСтроки = НайденнаяСтрокаПокрытыхСтрок.ПокрытыеСтроки;
		КонецЕсли;

		Для Каждого цСтрока Из ФайлыСИсходнымКодом.ПолучитьСтрокиМодуля(ФайлКПокрытию) Цикл

			новСтрока = _ТаблицаПокрытия.Добавить();
			новСтрока.Номер = цСтрока.Номер;
			новСтрока.Покрыто = Не покрытыеСтроки[цСтрока.Номер] = Неопределено;
	
			покрытыеСтроки.Удалить(цСтрока.Номер);
			
		КонецЦикла;

		// Все строки, что есть в покрытии автоматически считаем кодом
		Для каждого цКлючИЗначение Из покрытыеСтроки Цикл

			новСтрока = _ТаблицаПокрытия.Добавить();
			новСтрока.Номер = цКлючИЗначение.Ключ;
			новСтрока.Покрыто = Истина;

			Сообщить( "Некорректно рассчитана строка для покрытия. Файл " + Модуль.Значение.Путь + ", строка " + новСтрока.Номер );

		КонецЦикла;

		_ТаблицаПокрытия.Сортировать("Номер");

		Для Каждого СтрокаПокрытия Из _ТаблицаПокрытия Цикл

			ЗаписьXML.ЗаписатьНачалоЭлемента("lineToCover");
			ЗаписьXML.ЗаписатьАтрибут("lineNumber", Формат(СтрокаПокрытия.Номер, "ЧГ=" ));
			ЗаписьXML.ЗаписатьАтрибут("covered", ?(СтрокаПокрытия.Покрыто,"true","false"));
			ЗаписьXML.ЗаписатьКонецЭлемента();

			КоличествоСтрок = КоличествоСтрок + 1;
			Если СтрокаПокрытия.Покрыто Тогда
				КоличествоСтрокПокрыто = КоличествоСтрокПокрыто + 1;
			КонецЕсли;
		КонецЦикла;

		ЗаписьXML.ЗаписатьКонецЭлемента();

	КонецЦикла;	

	ЗаписьXML.ЗаписатьКонецЭлемента();
	ЗаписьXML.Закрыть();

	Сообщить("Всего строк: " + КоличествоСтрок);
	Сообщить("Покрыто: " + КоличествоСтрокПокрыто);
	Сообщить("Процент покрытия: " + Окр((КоличествоСтрокПокрыто / КоличествоСтрок) * 100, 2));

КонецПроцедуры	
