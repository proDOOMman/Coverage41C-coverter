Перем Результат Экспорт;


Процедура ПриСозданииОбъекта() Экспорт

	Результат = Новый Соответствие();

КонецПроцедуры	


Процедура РазобратьЛог(Лог, ДанныеКонфигурации, ДанныеОбработок, ИмяРасширения) Экспорт

	Сообщить("Количество записей в логе: " + Лог.Количество());

	Для каждого Ключ Из Лог Цикл
	
		Если ЗначениеЗаполнено(ИмяРасширения) И Ключ.ExtentionName <> ИмяРасширения Тогда
			Продолжить;
		КонецЕсли;

		ЭтоНовый = Ложь;
		Если НЕ ПустаяСтрока(Ключ.URL) Тогда
			URL = СтрЗаменить(Ключ.URL, "sfile://", "");
			URL = СтрЗаменить(URL, "file://", "");
			Модуль = ДанныеОбработок.ОпределитьМодульПоId(URL, Ключ.objectID);
		Иначе	
			Модуль = ДанныеКонфигурации.ОпределитьМодульПоId(Ключ.objectID, Ключ.propertyID);
		КонецЕсли;

		ДаннныеМодуля = Результат.Получить(Модуль);
		Если ДаннныеМодуля = Неопределено Тогда
			ЭтоНовый = Истина;
			ДаннныеМодуля = Новый Структура("Путь, Строки", "", Новый Массив);
			Если НЕ ПустаяСтрока(Ключ.URL) Тогда
				ПутьКФайлуОбработки = СтрЗаменить(Ключ.URL, "sfile://", "");
				ПутьКФайлуОбработки = СтрЗаменить(ПутьКФайлуОбработки, "file://", "");

				ДаннныеМодуля.Путь = ДанныеОбработок.ПутьКФайлу(
					ПутьКФайлуОбработки, 
					Ключ.objectID, 
					Ключ.propertyID
				);
			Иначе	
				ДаннныеМодуля.Путь = ПутиФайловКонфигурации.ПутьМодуля(Модуль, ДанныеКонфигурации.ЭтоПроектEDT);
			КонецЕсли;
		КонецЕсли;	
	
		Если ДаннныеМодуля.Строки.Найти(Ключ.lineNo) = Неопределено Тогда
			ДаннныеМодуля.Строки.Добавить(Ключ.lineNo);
		КонецЕсли;
		
		Если ЭтоНовый Тогда
			Результат.Вставить(Модуль, ДаннныеМодуля);
		КонецЕсли;	

	КонецЦикла;

//	Для каждого КлючИЗначение из Результат Цикл
//		Сообщить(КлючИЗначение.Значение.Путь + " - " + КлючИЗначение.Значение.Строки.Количество())
//	КонецЦикла;

КонецПроцедуры	

Функция ЕстьСвойство(Структура, ИмяСвойства)

	ЕстьСвойство = Ложь;

	Если ТипЗнч(Структура) = Тип("Структура") 
		И Структура.Свойство(ИмяСвойства) Тогда

		ЕстьСвойство = Истина;
	КонецЕсли;	

	Возврат ЕстьСвойство;

КонецФункции	