package app

import (
	"errors"
	"gopoolmanager/config"
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
	Cpu *int
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

func (d *db) SetUserCpu(user UserData, cpu int) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	user.Cpu = &cpu
	d.dbUser[user.UserIP] = user
	return nil
}

var ErrNoFreeCpu = errors.New("no free cpu")
func (d *db) GetFreeCpu() (int, error) {
	d.mu.Lock()
	defer d.mu.Unlock()

	var freeCpu int
	for i := 1; i < config.Config.MaxCores; i++ {
		if _, exists := d.dbPorts[i]; exists {
			continue
		}
		freeCpu = i
		break
	}
	if freeCpu == 0 {
		return 0, ErrNoFreeCpu
	}
	d.dbPorts[freeCpu] = true
	return freeCpu, nil
}

func (d *db) FreeCpu(cpuUid int) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	delete(d.dbPorts, cpuUid)
	return nil
}
