from nicegui import ui


def fr_page() -> None:
    """Main page for the stealer. Very simple."""
    ui.echart(
        {
            "xAxis": {"type": "category"},
            "yAxis": {"type": "value"},
            "series": [{"type": "line", "data": [20, 10, 30, 50, 40, 30]}],
        },
        on_point_click=ui.notify,
    ).classes("m-4 w-full h-full")
