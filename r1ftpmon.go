package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"gopkg.in/gomail.v2"
)

func getNoreplyPassword() string {
	file, err := ioutil.ReadFile("/home/continuum/bin/.noreplypw")
	if err != nil {
		fmt.Println(err.Error())
	}
	pw := string(file)
	return pw
}

func proftpdIsDown() bool {
	cmd := "ps -ef|grep [p]roftpd >/dev/null 2>&1; echo $?"
	status, err := exec.Command("bash","-c",cmd).Output()
	if err != nil {
		fmt.Sprintf("Failed to execute command: %s\n", cmd)
	}

	i, _ := strconv.Atoi(strings.Trim(string(status), "\n"))
	if i != 0 { 
		return true
	} 
	return false
}

func restartProftpd() bool {
	cmd := "service proftpd restart"
	status, err := exec.Command("bash","-c",cmd).Output()
	if err != nil {
		fmt.Sprintf("Failed to execute command: %s\n", cmd)
	}

	i, _ := strconv.Atoi(strings.Trim(string(status), "\n"))
	if i != 0 {
		return true
	}
	return false
}

type email struct {
	From                string
	NoReplyAcct         string
	To                  string
	ToAcct              string
	Subject             string
	TxtHTMLBody         string
	ProftpdIsDownMsg    string
	ProftpdIsDownBody   string
	ProftpdRestartedMsg string
	SMTPServer          string
	SMTPPort            int
}

func main() {

	e := email{}

	e.From		= "From"
	e.NoReplyAcct   = "noreply@r1soft.com"
	e.To		= "To"
	e.ToAcct        = "c247devops@r1soft.com"
	e.TxtHTMLBody   = "text/html"
	e.Subject       = "Subject"
	e.SMTPServer    = "smtp.office365.com"
	e.SMTPPort      = 587

	m := gomail.NewMessage()

	m.SetHeader(e.From, e.NoReplyAcct)
	m.SetHeader(e.To, e.ToAcct)

	pw := strings.Trim(getNoreplyPassword(), "\n")

	if (proftpdIsDown()) {

		hostname, _ := os.Hostname()

		e.ProftpdIsDownMsg    = "PROFTPD DOWN ON " + hostname
		e.ProftpdIsDownBody   = "proftpd server is down on host: " + hostname

		m.SetHeader(e.Subject, e.ProftpdIsDownMsg)
		m.SetBody(e.TxtHTMLBody, e.ProftpdIsDownBody)

		d := gomail.NewDialer(e.SMTPServer, e.SMTPPort, e.NoReplyAcct, pw)

		err := d.DialAndSend(m)
		if err != nil {
			log.Fatal(err)
		}

		// restart proftpd
		fmt.Printf("restarting proftpd on %s.\n", hostname)
		ret := restartProftpd()
		if ret {

			e.ProftpdRestartedMsg  = "proftpd restarted on host: " + hostname
			m.SetBody(e.TxtHTMLBody, e.ProftpdRestartedMsg)
			d := gomail.NewDialer(e.SMTPServer, e.SMTPPort, e.NoReplyAcct, pw)

			err := d.DialAndSend(m)
			if err != nil {
				log.Fatal(err)
			}
			fmt.Printf("proftpd restarted on %s.\n", hostname)

		} else {

			e.ProftpdRestartedMsg  = "proftpd did not restart on host: " + hostname
			m.SetBody(e.TxtHTMLBody, e.ProftpdRestartedMsg)
			d := gomail.NewDialer(e.SMTPServer, e.SMTPPort, e.NoReplyAcct, pw)

			err := d.DialAndSend(m)
			if err != nil {
				log.Fatal(err)
			}
			fmt.Printf("unable to restart proftpd on %s. Please investigate.\n", hostname)
		}
	}
}
