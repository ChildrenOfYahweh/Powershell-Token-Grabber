import ctypes


class Windows:
    """Windows class to send notifications."""

    def __init__(self) -> None:
        """Initializes the Windows class."""
        pass

    def send_message(self, title, message) -> None:
        """Sends a message to the user."""
        # make a windows toast using ctypes
        pass


if __name__ == "__main__":
    windows = Windows()
    windows.send_message("Title", "Message")
