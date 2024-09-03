package app

import (
	"fmt"
	"gopoolmanager/config"
	"gopoolmanager/log"
	"net/http"
	"os/exec"
	"time"
)

func CreateSandbox(name string) error {
	timeoutStr := fmt.Sprintf("%d", int((config.Config.SandboxDuration + (time.Second*30)).Seconds()))
	cmd := exec.Command(config.Config.CreateSandboxSh, name, timeoutStr)
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Log.WithField("out", string(out)).WithError(err).Warning("err CreateSandbox")
		return err
	}
	return nil
}

func DestroySandbox(name string) error {
	cmd := exec.Command(config.Config.DestroySandboxSh, name)
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Log.WithField("out", string(out)).WithError(err).Warning("err DestroySandbox")
		return err
	}
	return nil
}

func CleanAllSandbox() error {
	cmd := exec.Command(config.Config.CleanAllSandboxSh)
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Log.WithField("out", string(out)).WithError(err).Warning("err CleanAllSandbox")
		return err
	}
	return nil
}

const StampNotValid = `
Provided stamp was not valid!<br>
Try again: <a href="/">link</a>
`
const InternalError = `
There was internal_error ask admin what happen!<br>
Try again: <a href="/">link</a>
`
const NoFreeCpuError = `
There was internal_error ask admin what happen!<br>
Try again: <a href="/">link</a>
`
const FormGet1 = `
Access to this challenge is rate limited via hashcash.<br>
<br>
Please use the following command to solve the Proof of Work: <br>
%s<br>
<br>
<form method="post" action="/">
<label>PoW:</label>
<input name="stamp" type="text" value="" style="width: 200px;" placeholder="eg. 1:25:191204:yehspcop::hiATMGBMcicFX6Pt:000000000kwmP">
<button type="submit">Send PoW</button>
</form>
<br>
<span>* only hashcash v1 supported</span>
`
const FormGet2 = `
You have already sandbox.<br>
You need wait %d seconds to be able create new sandbox.
`
const FormCreated = `
We created separate sandbox instance for you.<br>
<br>
Here is you url: <a href="%s">%s</a><br>
Sandbox will be available to you until: %s<br>
`

func SandboxHandler(d *db) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if !(r.URL.Path == "" || r.URL.Path == "/") {
			w.WriteHeader(404)
			return
		}
		if !(r.Method == "GET" || r.Method == "POST") {
			w.WriteHeader(405)
			return
		}

		userIP := r.Header.Get("X-Real-IP")
		logger := log.Log.WithField("user_ip", userIP)
		w.Header().Set("Content-Type", "text/html")

		if r.Method == "GET" {
			userData, err := d.GetUser(userIP)
			if err == ErrUserNotExists {
				resource, err := GenerateRandomLowercaseAscii(8)
				if err != nil {
					logger.WithError(err).Error("get GenerateRandomLowercaseAscii(8)")
					w.WriteHeader(500)
					fmt.Fprintf(w, InternalError)
					return
				}

				userData = UserData{
					UserIP:      userIP,
					OneTimeHash: resource,
					Token:       "",
					ExpireAt:    time.Now().Add(config.Config.OneTimeHashDuration),
				}
				if err := d.AddUser(userData); err != nil {
					logger.WithError(err).Error("get AddUser")
					w.WriteHeader(500)
					fmt.Fprintf(w, InternalError)
					return
				}
			} else if err != nil {
				logger.WithError(err).Error("get GetUser")
				w.WriteHeader(500)
				fmt.Fprintf(w, InternalError)
				return
			}

			if userData.NeedRefreshOneTimeHash() {
				resource, err := GenerateRandomLowercaseAscii(8)
				if err != nil {
					logger.WithError(err).Error("get GenerateRandomLowercaseAscii(8)")
					w.WriteHeader(500)
					fmt.Fprintf(w, InternalError)
					return
				}

				userData.Token = ""
				userData.OneTimeHash = resource
				userData.ExpireAt = time.Now().Add(config.Config.OneTimeHashDuration)
				if err := d.UpdateUser(userData); err != nil {
					logger.WithError(err).Error("get UpdateUser")
					w.WriteHeader(500)
					fmt.Fprintf(w, InternalError)
					return
				}
			}

			if userData.Token == "" {
				fmt.Fprintf(w, FormGet1, GetCommandProfOfWork(userData.OneTimeHash))
			} else {
				fmt.Fprintf(w, FormGet2, int(userData.ExpireAt.Sub(time.Now()).Seconds()))
			}

			return
		}

		err := r.ParseForm()
		if err != nil {
			logger.WithError(err).Error("post ParseForm")
			w.WriteHeader(500)
			fmt.Fprintf(w, InternalError)
			return
		}

		stamp := r.PostForm.Get("stamp")
		if len(stamp) == 0 {
			logger.WithError(err).Warning("empty stamp")
			w.WriteHeader(400)
			fmt.Fprintf(w, StampNotValid)
			return
		}

		userData, err := d.GetUser(userIP)
		if err == ErrUserNotExists {
			logger.WithError(err).Warning("post GetUser not exists")
			w.WriteHeader(400)
			fmt.Fprintf(w, StampNotValid)
			return
		} else if err != nil {
			logger.WithError(err).Error("post GetUser err")
			w.WriteHeader(500)
			fmt.Fprintf(w, InternalError)
			return
		}

		token, err := GenerateRandomString(30)
		if err != nil {
			logger.WithError(err).Error("post GenerateRandomString(30)")
			w.WriteHeader(500)
			fmt.Fprintf(w, InternalError)
			return
		}

		valid, err := CheckProofOfWork(stamp, userData.OneTimeHash)
		if err != nil {
			logger.WithError(err).Error("err CheckProofOfWork")
			w.WriteHeader(400)
			fmt.Fprintf(w, StampNotValid)
			return
		}
		if !valid {
			logger.WithError(err).Warning("not valid CheckProofOfWork")
			w.WriteHeader(400)
			fmt.Fprintf(w, StampNotValid)
			return
		}

		userData.Token = token
		userData.OneTimeHash = ""
		userData.ExpireAt = time.Now().Add(config.Config.SandboxNewCreation)
		if err := d.UpdateUser(userData); err != nil {
			logger.WithError(err).Error("post UpdateUser")
			w.WriteHeader(500)
			fmt.Fprintf(w, InternalError)
			return
		}

		fmt.Fprintf(w, FormCreated,
			fmt.Sprintf("http://%s.%s", userData.Token, r.Host),
			fmt.Sprintf("%s.%s", userData.Token, r.Host),
			time.Now().Add(config.Config.SandboxDuration).Format("2006-01-02 15:04:05 -0700 MST"))

		CreateSandbox(userData.Token)
		go func(userData UserData) {
			time.Sleep(config.Config.SandboxDuration)
			DestroySandbox(userData.Token)
		}(userData)
	}
}
