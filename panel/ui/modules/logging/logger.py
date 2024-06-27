import logging
from rich.logging import RichHandler

FORMAT = "%(message)s"
logging.basicConfig(
    level="NOTSET",
    format="%(message)s",
    datefmt="[%X]",
    handlers=[RichHandler(rich_tracebacks=True)],
)


class Logger:
    """Logger class to log messages to the console."""

    @staticmethod
    def log(message: str) -> None:
        """Log a message.

        Args:
            message (str): Message to log
        """
        logger = logging.getLogger(__name__)
        logger.info(message)


if __name__ == "__main__":
    Logger.log("Test message")
