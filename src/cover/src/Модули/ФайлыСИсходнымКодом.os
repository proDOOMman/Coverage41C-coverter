
Перем кэшРазделителиСлов;
Перем ключевыеСловаПереноса;
Перем ключевыеСловаНеКода;


#Область ПрограммныйИнтерфейс

Функция ПолучитьСтрокиМодуля( Знач Путь ) Экспорт
	
	тзСтрокиМодуля = Новый ТаблицаЗначений();
	тзСтрокиМодуля.Колонки.Добавить("Номер");
	тзСтрокиМодуля.Колонки.Добавить("Содержимое");
	
	ключевыеСловаНеКода = КлючевыеСловаНачалаНеКода();
	ключевыеСловаПереноса = КлючевыеСловаПереноса();
	кэшРазделителиСлов = Новый Соответствие();

	Чтение = Новый ЧтениеТекста();
	Чтение.Открыть(Путь, КодировкаТекста.UTF8);
	
	ТекстСтроки = Чтение.ПрочитатьСтроку();
	
	НомерСтроки = 1;
	вариантПереноса = 0; // 0 - нет переноса, 1 - составное выражение, 2 - перенос параметров в объявлении
	
	Пока НЕ ТекстСтроки = Неопределено Цикл
		
		Если ЕстьКодВСтроке(ТекстСтроки, вариантПереноса) Тогда
			
			новСтрока = тзСтрокиМодуля.Добавить();
			
			новСтрока.Номер = НомерСтроки;
			новСтрока.Содержимое = ТекстСтроки;
			
		КонецЕсли;
		
		предСтрока = ТекстСтроки;
		
		ТекстСтроки = Чтение.ПрочитатьСтроку();
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;
	
	Чтение.Закрыть();
	
	Возврат тзСтрокиМодуля;

	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЕстьКодВСтроке(Знач пСтрокаКода, вариантПереноса)
	
	строкаКода = ВРег( СокрЛП( пСтрокаКода ) );
	
	Если НЕ ЗначениеЗаполнено(строкаКода) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если СтрНачинаетсяС( строкаКода, "//" ) Тогда
		Возврат Ложь;
	КонецЕсли;

	Если СтрНачинаетсяС( строкаКода, "ПЕРЕМ " ) Тогда // Удивительно, но объявления переменных за код не считается в замерах
		Возврат Ложь;
	КонецЕсли;

	строкаКода = КодБезКомментариев( строкаКода );
	
	Если СтрНачинаетсяС( строкаКода, "|" ) Тогда
		вариантПереноса = СтрокаЗаканчиваетсяПереносом( строкаКода, вариантПереноса );
		
		массивСтрокКода = СтрРазделить( строкаКода, """", Ложь );
		
		Для ц = 0 По массивСтрокКода.ВГраница() Цикл
			
			// В четных текст запроса, в нечетных код
			
			Если ц%2 = 0 Тогда
				Продолжить;
			КонецЕсли;
			
			естьВызов = СтрНайти( массивСтрокКода[ц], "(" ) > 0;
			
			Если естьВызов Тогда
				Возврат Истина;
			КонецЕсли;
			
		КонецЦикла;
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Если СтрНачинаетсяС( строкаКода, "#" )
		ИЛИ СтрНачинаетсяС( строкаКода, "&" ) Тогда
		вариантПереноса = 0;
		Возврат Ложь;
	КонецЕсли;
	
	Для каждого цИсключение Из ключевыеСловаНеКода Цикл
		
		Если СтрНачинаетсяС( строкаКода, ВРег( цИсключение ) )
			И ЭтоОтдельноеСлово( ВРег( цИсключение ), строкаКода, 1 ) Тогда
			вариантПереноса = СтрокаЗаканчиваетсяПереносом( строкаКода, вариантПереноса );
			Возврат Ложь;
		КонецЕсли;
		
	КонецЦикла;
	
	естьКодВСтроке = Истина;
	
	Если Не вариантПереноса = 0 Тогда
		
		естьКодВСтроке = СтрНайти( строкаКода, "(" ) > 0;
		
	КонецЕсли;
	
	вариантПереноса = СтрокаЗаканчиваетсяПереносом( строкаКода, вариантПереноса );
	
	Возврат естьКодВСтроке;
	
КонецФункции

Функция СтрокаЗаканчиваетсяПереносом( Знач пСтрока, Знач пТекущийВариантПереноса )
	
	// Вариант объявления
	
	Если ( СтрНачинаетсяС( пСтрока, "ПРОЦЕДУРА" )
		ИЛИ СтрНачинаетсяС( пСтрока, "ФУНКЦИЯ" ) ) Тогда
		
		Если СтрЗаканчиваетсяНа( пСтрока, ")" )
			ИЛИ СтрЗаканчиваетсяНа( пСтрока, "ЭКСПОРТ" ) Тогда
			
			Возврат 0;
			
		Иначе
			
			Возврат 2;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Вариант переноса параметров в объявлении
	
	Если пТекущийВариантПереноса = 2 Тогда
		
		Если СтрНайти( пСтрока, ")" ) > 0
			ИЛИ ПозицияФрагмента( пСтрока, "ЭКСПОРТ", Истина) > 0 Тогда
			
			Возврат 0;
			
		Иначе
			
			Возврат 2;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если СтрЗаканчиваетсяНа( пСтрока, ";" ) Тогда
		
		Возврат 0;
		
	КонецЕсли;
	
	Для каждого цСлово Из ключевыеСловаПереноса Цикл
		
		Если ПозицияФрагмента( пСтрока, цСлово, Истина) > 0 Тогда
			
			Возврат 0;
		
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат 1;
	
КонецФункции

Функция КодБезКомментариев( Знач пСтрока )
	
	ПозицияКомментария = ПозицияФрагмента( пСтрока, "//" );
	
	Если ПозицияКомментария = 0 Тогда
		
		Возврат СокрЛП( пСтрока );
		
	Иначе
		
		Возврат СокрЛП( Лев( пСтрока, ПозицияКомментария - 1 ) );
		
	КонецЕсли;
	
КонецФункции

Функция КлючевыеСловаПереноса()
	
	словаПереноса = Новый Массив;
	
	словаПереноса.Добавить( "ТОГДА" );
	словаПереноса.Добавить( "ИНАЧЕ" );
	словаПереноса.Добавить( "ЦИКЛ" );
	словаПереноса.Добавить( "КОНЕЦПРОЦЕДУРЫ" );
	словаПереноса.Добавить( "КОНЕЦФУНКЦИИ" );
	словаПереноса.Добавить( "ЭКСПОРТ" );
	словаПереноса.Добавить( "ПОПЫТКА" );
	словаПереноса.Добавить( "ИСКЛЮЧЕНИЕ" );
	
	Возврат словаПереноса;
	
КонецФункции

Функция КлючевыеСловаНачалаНеКода()

	ключевыеСлова = Новый Массив;
	ключевыеСлова.Добавить( "Процедура" );
	ключевыеСлова.Добавить( "Функция" );
	ключевыеСлова.Добавить( "Иначе" );
	ключевыеСлова.Добавить( "Попытка" );
	ключевыеСлова.Добавить( "Исключение" );
	
	Возврат ключевыеСлова;

КонецФункции

Функция ПозицияФрагмента( Знач пСтрока, Знач пФрагмент, Знач ИскатьОтдельноеСлово = Ложь )
	
	позицияФрагмента = СтрНайти( пСтрока, пФрагмент );
	
	Если ИскатьОтдельноеСлово Тогда
		
		Пока Не позицияФрагмента = 0 Цикл
			
			Если ЭтоОтдельноеСлово( пФрагмент, пСтрока, позицияФрагмента ) Тогда
				
				Прервать;
				
			КонецЕсли;
			
			Если позицияФрагмента = СтрДлина( пСтрока ) Тогда
				
				позицияФрагмента = 0;
				Прервать;
				
			КонецЕсли;
			
			позицияФрагмента = СтрНайти( пСтрока, пФрагмент, , позицияФрагмента + 1 );
			
		КонецЦикла;
		
	КонецЕсли;
	
	Если позицияФрагмента = 0 Тогда
		
		Возврат 0;
		
	КонецЕсли;
	
	Если Не пФрагмент = "//" Тогда
		
		ПозицияКомментария = ПозицияФрагмента( пСтрока, "//" );
		
		Если ПозицияКомментария > 0
			И ПозицияКомментария < позицияФрагмента Тогда
			
			Возврат 0;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ПозицияКавычек = СтрНайти( пСтрока, """" );
	
	// Проверяем есть ли вначале строки символ "|".
	ПервыйСимвол = Сред( СокрЛП( пСтрока ), 1, 1 );
	
	Если пФрагмент = "|"
		И ПервыйСимвол = "|" Тогда
		
		Возврат позицияФрагмента;
		
	КонецЕсли;
	
	// Нет кавычек, оставляем весь комментарий.
	// Кавычки после комментария, оставляем весь комментарий.
	
	Если ( ПозицияКавычек = 0 ИЛИ ПозицияКавычек > позицияФрагмента )
		И ПервыйСимвол <> "|" Тогда
		
		Возврат позицияФрагмента;
		
	ИначеЕсли ПервыйСимвол = "|"
		И ПозицияКавычек = 0 Тогда
		
		// Все в строке
		
		Возврат 0;
		
	ИначеЕсли ПервыйСимвол = "|"
		И ПозицияКавычек > 0 Тогда
		
		строкаПослеКавычек = Сред( пСтрока, ПозицияКавычек + 1 );
		
		позицияФрагмента = ПозицияФрагмента( строкаПослеКавычек, пФрагмент );
		
		Если позицияФрагмента = 0 Тогда
			
			Возврат 0;
			
		Иначе
			
			Возврат ПозицияКавычек + позицияФрагмента;
			
		КонецЕсли;
		
	Иначе
		
		строкаПослеКавычек = "|" + Сред( пСтрока, ПозицияКавычек + 1 );
		
		позицияФрагмента = ПозицияФрагмента( строкаПослеКавычек, пФрагмент );
		
		Если позицияФрагмента = 0 Тогда
			
			Возврат 0;
			
		Иначе
			
			Возврат ПозицияКавычек + позицияФрагмента - 1;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецФункции

Функция ЭтоОтдельноеСлово( Знач пСлово, Знач пСтрока, Знач пПозиция )
	
	слеваРазделитель  = Ложь;
	справаРазделитель = Ложь;
	
	Если пПозиция = 1 Тогда
		
		слеваРазделитель = Истина;
		
	Иначе
		
		слеваРазделитель = ЭтоРазделительСлов( КодСимвола( пСтрока, пПозиция - 1 ) );
		
	КонецЕсли;
	
	позицияПравогоРазделителя = пПозиция + СтрДлина( пСлово );
	
	Если позицияПравогоРазделителя > СтрДлина( пСтрока ) Тогда
		
		справаРазделитель = Истина;
		
	Иначе
		
		справаРазделитель = ЭтоРазделительСлов( КодСимвола( пСтрока, позицияПравогоРазделителя ) );
		
	КонецЕсли;
	
	Возврат слеваРазделитель И справаРазделитель;
	
КонецФункции

Функция ЭтоРазделительСлов( Знач КодСимвола )
	
	значениеКеша = кэшРазделителиСлов[ КодСимвола ];
	
	Если Не значениеКеша = Неопределено Тогда
		
		Возврат значениеКеша;
		
	КонецЕсли;
	
	Диапазоны = Новый Массив;
	Диапазоны.Добавить( Новый Структура( "Мин,Макс", 48, 57 ) );     // цифры
	Диапазоны.Добавить( Новый Структура( "Мин,Макс", 65, 90 ) );     // латиница большие
	Диапазоны.Добавить( Новый Структура( "Мин,Макс", 97, 122 ) );    // латиница маленькие
	Диапазоны.Добавить( Новый Структура( "Мин,Макс", 1040, 1103 ) ); // кириллица
	Диапазоны.Добавить( Новый Структура( "Мин,Макс", 1025, 1025 ) ); // символ "Ё"
	Диапазоны.Добавить( Новый Структура( "Мин,Макс", 1105, 1105 ) ); // символ "ё"
	Диапазоны.Добавить( Новый Структура( "Мин,Макс", 95, 95 ) );     // символ "_"
	
	Для Каждого Диапазон Из Диапазоны Цикл
		
		Если КодСимвола >= Диапазон.Мин И КодСимвола <= Диапазон.Макс Тогда
			
			кэшРазделителиСлов.Вставить( КодСимвола, Ложь );
			
			Возврат Ложь;
			
		КонецЕсли;
		
	КонецЦикла;
	
	кэшРазделителиСлов.Вставить( КодСимвола, Истина );
	
	Возврат Истина;
	
КонецФункции

#КонецОбласти



