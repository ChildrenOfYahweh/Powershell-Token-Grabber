import os
import sys
import time
import json
import logging


class Settings:
    def __init__(self) -> None:
        """Settings class to handle the settings of the application."""
        self.settings_file = os.path.join(
            os.getenv("APPDATA"), "Kematian-Stealer", "config.json"
        )

        self.settings_bones = {
            "port": "8080",
            "notifications": True,
            "discord": {
                "enabled": False,
                "webhook": "NONE",
            },
            "windows": {
                "enabled": True,
            },
        }

    def change_setting(self, setting: str, value: str) -> None:
        """Change the value of a setting in the settings file.

        Args:
            setting (str): Setting to change
            value (str): Value to change the setting to
        """
        with open(self.settings_file, "r") as file:
            data = json.load(file)
            data[setting] = value
        with open(self.settings_file, "w") as file:
            json.dump(data, file)

    def get_setting(self, setting: str) -> str:
        """Get the value of a setting from the settings file.

        Args:
            setting (str): Setting to get the value of

        Returns:
            str: Setting value
        """
        try:
            with open(self.settings_file, "r") as file:
                data = json.load(file)
                return data[setting]
        except KeyError:
            self.set_to_defaults()
            logging.critical(f"Setting {setting} not found, setting to default value.")
            time.sleep(3)
            sys.exit(0)

    def get_all_settings(self) -> dict:
        """Get all settings from the settings file.

        Returns:
            dict: All settings
        """
        with open(self.settings_file, "r") as file:
            return json.load(file)

    def set_to_defaults(self) -> None:
        """Set the settings file to the default settings."""
        with open(self.settings_file, "w") as file:
            json.dump(self.settings_bones, file)

    def check_settings(self) -> None:
        """Check if the settings file exists and if not, set it to the default settings."""
        if not os.path.exists(self.settings_file):
            self.set_to_defaults()
        else:
            with open(self.settings_file, "r") as file:
                data = json.load(file)
                for setting in self.settings_bones:
                    if setting not in data:
                        self.change_setting(setting, self.settings_bones[setting])
