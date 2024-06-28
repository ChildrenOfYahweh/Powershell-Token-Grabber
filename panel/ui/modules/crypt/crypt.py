class Crypt:
    def __init__(self) -> None:
        pass

    def encrypt(self, text: str) -> str:
        return text[::-1]

    def decrypt(self, text: str) -> str:
        return text[::-1]
