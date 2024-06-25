import ctypes


class Errors:
    """error handling module."""

    def make_error(message: str) -> None:
        """Make an error message.

        Args:
            message (str): The error message.
        """
        ctypes.windll.user32.MessageBoxW(0, message, "Error", 0x10)


if __name__ == "__main__":
    Errors.make_error("Error message")
