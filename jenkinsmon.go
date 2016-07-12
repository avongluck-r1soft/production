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

func isRootFull(THRESHHOLD float64) bool {
	total, free, _ := getDiskSpace("/")
	pctUsed := float64(100.00) - ( float64(free) / float64(total) * 100.0 )
	if pctUsed >= THRESHHOLD {
		fmt.Printf("percent used for root filesystem, /, on sbjenkins: %.2f\n", pctUsed)
		return true
	} else {
		return false
	}
}

func isJenkinsDown() bool {
	cmd := "ps -ef|grep [j]enkinsci >/dev/null 2>&1; echo $?"
	status, err := exec.Command("bash","-c",cmd).Output()
	if err != nil {
		fmt.Sprintf("Failed to execute command: %s", cmd)
	}

	i, _ := strconv.Atoi(strings.Trim(string(status), "\n"))

	if i == 0 {
		return false
	}
	return true
}


type email struct {
	From 			string
	NoReplyAcct 		string
	To 			string
	ToAcct1			string
	ToAcct2			string
	ToAcct3			string
	RootFullSubj		string
	RootFullMsg		string
	RootFullBody1		string
	RootFullBody2		string
	JenkinsDownSubj		string
	JenkinsDownMsg		string
	JenkinsDownBody1	string
	JenkinsDownBody2	string
	SMTPServer		string
	SMTPPort		int
}

func main() {

	m := gomail.NewMessage()

	e := email{}

	e.From		= "From"
	e.NoReplyAcct   = "noreply@r1soft.com"
	e.To		= "To"
	e.ToAcct1	= "scott.gillespie@r1soft.com"
	e.ToAcct2	= "alex.vongluck@r1soft.com"
	e.ToAcct3	= "stan.love@r1soft.com"
	e.RootFullBody1	= "text/html"
	e.SMTPServer	= "smtp.office365.com"
	e.SMTPPort	= 587

	m.SetHeader(e.From, e.NoReplyAcct)
	//m.SetHeader(e.To, e.ToAcct1)
	m.SetHeader(e.To, e.ToAcct1, e.ToAcct2, e.ToAcct3)

	pw := strings.Trim(getNoreplyPassword(), "\n")

	THRESHHOLD := float64(85.0)

	if (isRootFull(THRESHHOLD)) {

		fmt.Printf("Jenkins root directory is FULL.\n")
		fmt.Printf("sending email...\n")

		e.RootFullSubj		= "Subject"
		e.RootFullMsg		= "SBJENKINS root filesystem full."
		e.RootFullBody1		= "text/html"
		e.RootFullBody2		= "jenkins-root filesystem is full. Clean old build areas."

		m.SetHeader(e.RootFullSubj, e.RootFullMsg)
		m.SetBody(e.RootFullBody1, e.RootFullBody2)

		d := gomail.NewDialer(e.SMTPServer, e.SMTPPort, e.NoReplyAcct, pw)

		err := d.DialAndSend(m)

		if err != nil {
			log.Fatal(err)
		}
	}

	if (isJenkinsDown()) {
		fmt.Printf("Jenkins is DOWN.\n")
		fmt.Printf("sending email...\n")

		e.JenkinsDownSubj	= "Subject"
		e.JenkinsDownMsg	= "SBJENKINS JENKINS is DOWN."
		e.JenkinsDownBody1	= "text/html"
		e.JenkinsDownBody2 	= "Jenkins is DOWN. Please restart & investigate."

		m.SetHeader(e.JenkinsDownSubj, e.JenkinsDownMsg)
		m.SetBody(e.JenkinsDownBody1, e.JenkinsDownBody2)

		d := gomail.NewDialer(e.SMTPServer, e.SMTPPort, e.NoReplyAcct, pw)

		err := d.DialAndSend(m)

		if err != nil {
			log.Fatal(err)
		}
	}
}
