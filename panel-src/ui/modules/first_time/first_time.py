import os

from ui.modules.settings.settings import Settings


class MakeFiles:
    """Sets up the necessary files and directories for the application to run properly."""

    def __init__(self) -> None:
        """Simply sets the appdir variable to the APPDATA environment variable."""
        self.appdir = os.getenv("APPDATA")

    def make_appdir_directory(self) -> None:
        """Makes the directory where all the files and directories will be stored."""
        self.directoryName = "Kematian-Stealer"
        os.mkdir(os.path.join(self.appdir, self.directoryName))

    def get_appdir_directory(self) -> str:
        """Gets the directory where all the files and directories are stored.

        Returns:
            str: Returns the directory where all the files and directories are stored.
        """
        return os.path.join(self.appdir, self.directoryName)

    def makeSQLiteDB(self) -> None:
        """Makes the SQLite database file where all the data will be stored."""
        self.dbName = "kdot.db"
        self.dbPath = os.path.join(self.appdir, self.directoryName, self.dbName)
        with open(self.dbPath, "w") as f:
            f.write("")

    def get_SQLiteDB_path(self) -> str:
        """Method to get the path of the SQLite database file.

        Returns:
            str: Returns the path of the SQLite database file."""
        return os.path.join(self.appdir, self.directoryName, self.dbName)

    def make_config(self) -> None:
        """Makes the config file where all the settings will be stored."""
        settings = Settings()
        self.configName = "config.json"
        self.configPath = os.path.join(self.appdir, self.directoryName, self.configName)
        with open(self.configPath, "w") as f:
            f.write("{}")
        settings.set_to_defaults()

    def get_config_file_path(self) -> str:
        """Gets the path of the config file.

        Returns:
            str: Returns the path of the config file.
        """
        return os.path.join(self.appdir, self.directoryName, self.configName)

    def make_logs_directory(self) -> None:
        """Makes the logs directory where all the logs will be stored."""
        self.logs_directory = "logs"
        os.mkdir(os.path.join(self.appdir, self.directoryName, self.logs_directory))

    def make_build_ids_file(self) -> None:
        """Makes the build_ids file where all the build ids will be stored."""
        self.build_ids_file = "build_ids.json"
        with open(
            os.path.join(self.appdir, self.directoryName, self.build_ids_file), "w"
        ) as f:
            f.write("{}")

    def get_logs_directory(self) -> str:
        """Gets the logs directory where all the logs are stored.

        Returns:
            str: Returns the logs directory where all the logs are stored.
        """
        return os.path.join(self.appdir, self.directoryName, self.logs_directory)

    def make_all(self) -> None:
        """Makes all the files and directories needed for the application to run properly."""
        self.make_appdir_directory()
        self.makeSQLiteDB()
        self.make_config()
        self.make_logs_directory()
        self.make_build_ids_file()
