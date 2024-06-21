from nicegui import ui

from ui.modules.settings.settings import Settings


def settings_stuff() -> None:
    """Settings page for the stealer. Will change the look a lot in the future but for now it's fine."""
    currentSettings = Settings()

    settings_json = currentSettings.get_all_settings()

    with ui.card().classes(
        "w-full h-full justify-center items-center no-shadow border-[1px] border-gray-200 rounded-lg"
    ):
        ui.json_editor(
            {"content": {"json": settings_json}}, on_change=change_local_settings
        ).classes("w-full h-full")


def change_local_settings(settings: dict) -> None:
    """Change the local settings of the application."""
    currentSettings = Settings()
    for setting, value in settings.items():
        currentSettings.change_setting(setting, value)
