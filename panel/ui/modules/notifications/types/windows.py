from notifypy import Notify


class Windows:
    """Windows class to send notifications."""

    def __init__(self) -> None:
        """Initializes the Windows class."""
        self.notification = Notify(
            default_notification_application_name="Kematian-Stealer",
        )

    def send_message(self, title, message) -> None:
        """Sends a message to the user."""

        self.notification.title = title
        self.notification.message = message
        self.notification.send()


if __name__ == "__main__":
    windows = Windows()
    windows.send_message("Title", "Message")
