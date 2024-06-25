from nicegui import ui


def fr_page() -> None:
    """Main page for the stealer. Very simple."""
    video = ui.video("https://www.sped.lol/api/NoMercy").classes("w-full h-full")
    video.on("ended", lambda: ui.notify("Your real asf"))
