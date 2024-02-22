import requests
import csv

# Функция для получения данных о станциях
def get_station_data(apikey):
    url = "https://api.rasp.yandex.net/v3.0/stations_list/"
    params = {"apikey": apikey, "format": "json", "lang": "ru_RU"}
    
    response = requests.get(url, params=params)
    
    if response.status_code == 200:
        return response.json().get("countries", [])
    else:
        print(f"Ошибка при выполнении запроса: {response.status_code}")
        return []

# Функция для сохранения данных в CSV-файл
def save_to_csv(data, filename):
    with open(filename, mode="w", newline="", encoding="utf-8") as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow(["country_nm", "settlement_nm", "station_nm", "direction", "yandex_cd", "station_type", "transport_type", "long", "lat"])

        for country in data:
            for region in country.get("regions", []):
                for settlement in region.get("settlements", []):
                    for station in settlement.get("stations", []):
                        csv_writer.writerow([
                            country.get("title", ""),
                            region.get("title", ""),
                            settlement.get("title", ""),
                            station.get("direction", ""),
                            station.get("codes", {}).get("yandex_code", ""),
                            station.get("station_type", ""),
                            station.get("transport_type", ""),
                            station.get("longitude", ""),
                            station.get("latitude", "")
                        ])

# Функция для чтения API-ключа из файла
def get_api_key(filename="api_key.txt"):
    try:
        with open(filename, "r") as file:
            api_key = file.read().strip()
            return api_key
    except FileNotFoundError:
        print(f"Файл {filename} не найден.")
        return None

# Пример использования
apikey = get_api_key()
# Получение данных о станциях
station_data = get_station_data(apikey)

# Сохранение данных в CSV-файл
if station_data:
    save_to_csv(station_data, "stations_data.csv")
    print("Данные успешно записаны в файл stations_data.csv.")
else:
    print("Не удалось получить данные о станциях.")
