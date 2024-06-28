from datetime import datetime

import aiosqlite

from panel.ui.modules.first_time.first_time import MakeFiles


class StatisticsHandler:
    def __init__(self) -> None:
        self.current_day = datetime.now().strftime("%Y-%m-%d")
        self.maker = MakeFiles()
        self.db_path = self.maker.get_SQLiteDB_path()

    async def get_people(self) -> dict:
        people_dict = {}

        async with aiosqlite.connect(self.db_path) as db:
            async with db.execute("SELECT * FROM entries") as cursor:
                rows = await cursor.fetchall()
                for row in rows:
                    people_dict[row[4]] = people_dict.get(row[4], 0) + 1

        sorted_dates = self.sort_date_array(people_dict)
        return sorted_dates

    def sort_date_array(self, date_array: dict) -> list:
        # sort the date array in ascending order
        sorted_items = sorted(
            date_array.items(), key=lambda x: datetime.strptime(x[0], "%Y-%m-%d")
        )
        return sorted_items
