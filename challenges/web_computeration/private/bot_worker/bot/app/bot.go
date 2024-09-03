package app

import (
	"errors"
	"fmt"
	"github.com/sirupsen/logrus"
	"github.com/tebeka/selenium"
	"github.com/tebeka/selenium/chrome"
	"gopoolbot/config"
	"gopoolbot/log"
	"net"
	"net/http"
	"strconv"
	"sync/atomic"
	"time"
)

func GetFreePort() (int, error) {
	addr, err := net.ResolveTCPAddr("tcp", "localhost:0")
	if err != nil {
		return 0, err
	}

	l, err := net.ListenTCP("tcp", addr)
	if err != nil {
		return 0, err
	}
	defer l.Close()
	return l.Addr().(*net.TCPAddr).Port, nil
}

type browser struct {
	port    int
	service *selenium.Service
}

func NewBrowser() (*browser, error) {
	freePort, err := GetFreePort()
	if err != nil {
		return nil, err
	}
	opts := []selenium.ServiceOption{
		//selenium.Output(os.Stderr),
	}
	service, err := selenium.NewChromeDriverService(config.Config.ChromeDriverPath, freePort, opts...)
	if err != nil {
		return nil, err
	}

	s := &browser{
		service: service,
		port:    freePort,
	}
	return s, nil
}

func (b *browser) Get(url string, timeout time.Duration, sleep time.Duration) error {
	caps := selenium.Capabilities{
		"browserName": "chrome",
	}
	caps.AddChrome(chrome.Capabilities{
		Args: []string{
			"--no-sandbox",
			"--headless",
			"--window-size=1420,1080",
			"--disable-gpu",
		},
	})
	browser, err := selenium.NewRemote(caps, fmt.Sprintf("http://localhost:%d/wd/hub", b.port))
	if err != nil {
		return err
	}
	defer browser.Quit()

	err = browser.SetPageLoadTimeout(timeout)
	if err != nil {
		return err
	}

	err = browser.Get(url)
	if err != nil {
		return err
	}

	if sleep > 0 {
		time.Sleep(sleep)
	}

	//output, _ := browser.PageSource()
	//log.Log.Infof("output: %v", output)
	return nil
}

func (b *browser) Close() error {
	return b.service.Stop()
}

///
type jobData struct {
	Url      string
	UserIP   string
	Timeout  time.Duration
	Sleep    time.Duration
	Region   string
	TaskName string
}

type jobResult struct {
	ID   int
	Data jobData
}

func worker(workerID int, jobs <-chan jobResult, workCounter *int64) {
	for job := range jobs {
		atomic.AddInt64(workCounter, -1)

		logger := log.Log.WithFields(logrus.Fields{
			"id":        job.ID,
			"worker":    workerID,
			"url":       job.Data.Url,
			"user_id":   job.Data.UserIP,
			"task_name": job.Data.TaskName,
			"region":    job.Data.Region,
			"timeout":   job.Data.Timeout,
			"sleep":     job.Data.Sleep,
		})
		logger.Info("started job")

		now := time.Now()
		err := (func(job jobData) error {
			b, err := NewBrowser()
			if err != nil {
				return err
			}
			defer b.Close()

			err = b.Get(job.Url, job.Timeout, job.Sleep)
			if err != nil {
				return err
			}

			return nil
		})(job.Data)

		logger.WithField("err", err).WithField("duration", time.Since(now)).Info("finished job")
	}
}

type browserPool struct {
	jobs        chan jobResult
	workCounter int64
}

func NewBrowserPool() *browserPool {
	s := &browserPool{
		jobs: make(chan jobResult, config.Config.BotWorkers*config.Config.BotPoolPerWorker),
	}
	for w := 1; w <= config.Config.BotWorkers; w++ {
		go worker(w, s.jobs, &s.workCounter)
	}
	return s
}

var ErrPoolIsFull = errors.New("pool is full")

func (p *browserPool) AddJob(jobD jobData) (int64, error) {
	job := jobResult{
		ID:   int(time.Now().UnixNano()),
		Data: jobD,
	}
	var pos int64 = -1
	select {
	case p.jobs <- job:
		pos = atomic.AddInt64(&p.workCounter, 1)
	default:
		return pos, ErrPoolIsFull
	}

	return pos, nil
}

func BotHandler(p *browserPool) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			w.Header().Set("Content-Type", "text/html")
			fmt.Fprintf(w, `
<form method="POST">
    <label>URL:</label>
    <input type="text" value="https://twitter.com/patryk4815" name="url"/>
	<button>send url</button>
</form>
`)
			return
		}
		if err := r.ParseForm(); err != nil {
			fmt.Fprintf(w, "ParseForm() err: %v", err)
			return
		}

		timeoutRaw := r.FormValue("timeout")
		timeoutI, err := strconv.Atoi(timeoutRaw)
		if err != nil {
			timeoutI = 0
		}

		sleepRaw := r.FormValue("sleep")
		sleepI, err := strconv.Atoi(sleepRaw)
		if err != nil {
			sleepI = 0
		}

		job := jobData{
			Url:      r.FormValue("url"),
			UserIP:   r.FormValue("user_ip"),                // string
			Timeout:  time.Duration(timeoutI) * time.Second, // time.Duration
			Sleep:    time.Duration(sleepI) * time.Second,   // time.Duration
			Region:   r.FormValue("region"),
			TaskName: r.FormValue("task_name"), // string
		}

		if pos, err := p.AddJob(job); err != nil {
			if err == ErrPoolIsFull {
				w.WriteHeader(http.StatusTooManyRequests)
			} else {
				w.WriteHeader(http.StatusGone)
			}
			fmt.Fprintf(w, "AddJobWait() err: %v", err)
		} else {
			fmt.Fprintf(w, "AddJobWait() success, position=%d", pos)
		}
	}
}
