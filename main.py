import uvicorn

import logging
from rich.logging import RichHandler

from panel.server import *

FORMAT = "%(message)s"
logging.basicConfig(
    level="INFO",
    format=FORMAT,
    handlers=[RichHandler(rich_tracebacks=True, markup=True, show_time=False)],
)
logger = logging.getLogger("uvicorn")
logger.handlers = []
logger.propagate = False
logger.setLevel(logging.INFO)
handler = RichHandler(rich_tracebacks=True, markup=True, show_time=False)
handler.setFormatter(logging.Formatter(FORMAT))
logger.addHandler(handler)

if __name__ == "__main__":
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=int(
            current_settings.get_setting("port"),
        ),
        ssl_keyfile=os.path.join(good_dir, "Kematian-Stealer", "keyfile.pem"),
        ssl_certfile=os.path.join(good_dir, "Kematian-Stealer", "certfile.pem"),
        reload=False,
        log_config=None,  # we need this to disable the default uvicorn logger
    )
