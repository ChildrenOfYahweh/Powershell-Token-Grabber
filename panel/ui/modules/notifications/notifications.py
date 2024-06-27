from panel.ui.modules.notifications.types.windows import Windows
from panel.ui.modules.notifications.types.discord import Discord

from panel.ui.modules.settings.settings import Settings

from panel.ui.modules.errors.errors import Errors


class Notifications:
    """Notifications class to send notifications to Discord and Windows."""

    def __init__(self) -> None:
        """Initializes the Notifications class.

        Args:
            discord (bool, optional): Switch for Discord Webhook Notifications. Defaults to False.
            windows (bool, optional): Switch for Windows Notifications. Defaults to True.
        """
        self.settings = Settings()
        self.discord = self.settings.get_setting("discord")["enabled"]
        self.windows = self.settings.get_setting("windows")["enabled"]

    def send_notification(self, message: str) -> None:
        """Send a notification.

        Args:
            message (str): Message to send
        """
        if self.discord:
            try:
                webhook = self.settings.get_setting("discord")["webhook"]
                if webhook:
                    discord = Discord(webhook=webhook)
                    message_response = discord.send_message("Notification", message)
                    if message_response != 200:
                        Errors.make_error(
                            f"Error sending Discord notification: {message_response}"
                        )
            except Exception as e:
                Errors.make_error(f"Error sending Discord notification: {e}")
        if self.windows:
            Windows().send_message(title="NEW LOG", message=message)
