package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os/exec"
	"strconv"
	"strings"
	"syscall"

	"gopkg.in/gomail.v2"
)

type email struct {
	From              string
	NoReplyAcct       string
	To                string
	ToAcct            string
	Subject           string
	TxtHTMLBody       string
	RootFullMsg       string
	RootFullBody      string
	JenkinsDownMsg    string
	JenkinsDownBody   string
	SMTPServer        string
	SMTPPort          int
}


func getDiskSpace(path string) (total, free int, err error) {
	s := syscall.Statfs_t{}
	err = syscall.Statfs(path, &s)
	if err != nil {
		fmt.Printf("%s\n", err.Error())
	}
	total = int(s.Bsize) * int(s.Blocks)
	free  = int(s.Bsize) * int(s.Bfree)
	return
}


func getNoreplyPassword() string {
	file, err := ioutil.ReadFile("/home/zadmin/bin/.noreplypw")
	if err != nil {
		fmt.Println(err.Error())
	}
	pw := string(file)
	return pw
}


func rootIsFull(THRESHHOLD float64) bool {
	total, free, _ := getDiskSpace("/")
	pctUsed := float64(100.00) - ( float64(free) / float64(total) * 100.0 )
	if pctUsed >= THRESHHOLD {
		fmt.Printf("percent used for root filesystem, /, on sbjenkins: %.2f\n", pctUsed)
		return true
	} 
	return false
}


func jenkinsIsDown() bool {
	cmd := "ps -ef|grep [j]enkinsci >/dev/null 2>&1; echo $?"
	status, err := exec.Command("bash","-c",cmd).Output()
	if err != nil {
		fmt.Sprintf("Failed to execute command: %s", cmd)
	}

	i, _ := strconv.Atoi(strings.Trim(string(status), "\n"))
	if i != 0 { 
		fmt.Printf("jenkinsci process DOWN on sbjenkins! Restart and investigate.\n")
		return true
	} 
	return false
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

	THRESHHOLD := float64(90.0)

	if (rootIsFull(THRESHHOLD)) {
		fmt.Printf("Jenkins - sbjenkins root directory is FULL.\n")
		fmt.Printf("sending email...\n")

		e.RootFullMsg    = "SBJENKINS root filesystem full."
		e.RootFullBody   = "jenkins-root filesystem is full. Clean old build areas."

		m.SetHeader(e.Subject, e.RootFullMsg)
		m.SetBody(e.TxtHTMLBody, e.RootFullBody)

		d := gomail.NewDialer(e.SMTPServer, e.SMTPPort, e.NoReplyAcct, pw)

		err := d.DialAndSend(m)
		if err != nil {
			log.Fatal(err)
		}
	}

	if (jenkinsIsDown()) {
		fmt.Printf("Jenkins - jenkinsci process is DOWN.\n")
		fmt.Printf("sending email...\n")

		e.JenkinsDownMsg    = "SBJENKINS jenkinsci process is DOWN."
		e.JenkinsDownBody   = "Jenkins - jenkinsci process is DOWN. Please restart & investigate."

		m.SetHeader(e.Subject, e.JenkinsDownMsg)
		m.SetBody(e.TxtHTMLBody, e.JenkinsDownBody)

		d := gomail.NewDialer(e.SMTPServer, e.SMTPPort, e.NoReplyAcct, pw)

		err := d.DialAndSend(m)
		if err != nil {
			log.Fatal(err)
		}
	}
}
