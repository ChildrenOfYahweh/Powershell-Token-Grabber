import windows_toasts


class Windows:
    """Windows class to send notifications."""

    def __init__(self) -> None:
        """Initializes the Windows class."""
        self.toaster = windows_toasts.WindowsToaster("Kematian-Stealer")

    def send_message(
        self,
        title: str,
        message: str,
        sound: str = windows_toasts.AudioSource.SMS,
        loop: bool = False,
        mute: bool = False,
    ) -> None:
        new_toast = windows_toasts.Toast()
        new_toast.text_fields = [title, message]
        new_toast.audio = windows_toasts.ToastAudio(
            sound=sound, looping=loop, silent=mute
        )
        self.toaster.show_toast(new_toast)


if __name__ == "__main__":
    windows = Windows()
    windows.send_message("Title", "Message")
