from nicegui import ui


def fr_page() -> None:
    """Main page for the stealer. Very simple."""
    # video = ui.video("https://www.sped.lol/api/NoMercy").classes("w-full h-full")
    # video.on("ended", lambda: ui.notify("Your real asf"))
    with ui.card().classes(
        "w-full h-full justify-center items-center no-shadow border-[1px] border-gray-200 rounded-lg"
    ):
        ui.label("fixing the panel...").classes("text-2xl font-bold")
