package app

import (
	"errors"
	"sync"
	"time"
)

type db struct {
	mu sync.Mutex
	dbUser map[string]UserData
	dbPorts map[int]bool
}

func NewDB() (*db, error) {
	return &db{
		dbUser: make(map[string]UserData),
		dbPorts: make(map[int]bool),
	}, nil
}

func (d *db) Init() error {
	return nil
}

type UserData struct {
	UserIP      string
	ExpireAt    time.Time
	Token       string
	OneTimeHash string
	PasswordTF2 string
	PortTF2 int
	PortHTTP int
}

func (u UserData) NeedRefreshOneTimeHash() bool {
	return time.Now().After(u.ExpireAt)
}

var ErrUserNotExists = errors.New("user not exists")

func (d *db) AddUser(user UserData) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.dbUser[user.UserIP] = user
	return nil
}

func (d *db) UpdateUser(user UserData) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.dbUser[user.UserIP] = user
	return nil
}

func (d *db) GetUser(userIP string) (UserData, error) {
	d.mu.Lock()
	defer d.mu.Unlock()
	if out, exists := d.dbUser[userIP]; exists {
		return out, nil
	}
	return UserData{}, ErrUserNotExists
}

func (d *db) GetFreePort() (int, int, int, error) {
	d.mu.Lock()
	defer d.mu.Unlock()

	portIndex := 1
	for {
		if _, exists := d.dbPorts[portIndex]; exists {
		    portIndex++
			continue
		}
		break
	}
	d.dbPorts[portIndex] = true
	return portIndex, 80 + portIndex, 27015 + portIndex, nil
}

func (d *db) FreePort(portUid int) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	delete(d.dbPorts, portUid)
	return nil
}