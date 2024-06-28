from datetime import datetime

import aiosqlite

from panel.ui.modules.first_time.first_time import MakeFiles


class StatisticsHandler:
    """Class to handle all the statistics related stuff."""

    def __init__(self) -> None:
        """Simply sets the current day and the maker object."""
        self.current_day = datetime.now().strftime("%Y-%m-%d")
        self.maker = MakeFiles()
        self.db_path = self.maker.get_SQLiteDBGraphs_path()

    async def get_people(self) -> list:
        """Method to get the people who have visited the site.

        Returns:
            dict: Returns a dictionary with the date as the key and the number of people as the value.
        """
        people_dict = {}

        async with aiosqlite.connect(self.db_path) as db:
            async with db.execute("SELECT * FROM graphs") as cursor:
                rows = await cursor.fetchall()
                for row in rows:
                    people_dict[row[1]] = people_dict.get(row[1], 0) + 1

        sorted_dates = self.sort_date_array(people_dict)
        return sorted_dates

    def sort_date_array(self, date_array: dict) -> list:
        # sort the date array in ascending order
        sorted_items = sorted(
            date_array.items(), key=lambda x: datetime.strptime(x[0], "%Y-%m-%d")
        )
        return sorted_items
