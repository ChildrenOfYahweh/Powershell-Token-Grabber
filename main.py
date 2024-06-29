import webbrowser
import uvicorn

import logging
from rich.logging import RichHandler

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

from panel.server import *

if __name__ == "__main__":
    chosen_port = current_settings.get_setting("port")
    webbrowser.open(f"https://127.0.0.1:{chosen_port}")
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=int(chosen_port),
        ssl_keyfile=os.path.join(good_dir, "Kematian-Stealer", "keyfile.pem"),
        ssl_certfile=os.path.join(good_dir, "Kematian-Stealer", "certfile.pem"),
        reload=False,
        log_config=None,  # we need this to disable the default uvicorn logger
    )
